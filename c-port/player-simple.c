// TODO: VGM logging
#ifdef _WIN32
#include <windows.h>
#include <conio.h>
#ifdef _DEBUG
#include <crtdbg.h>
#endif
#endif

#ifdef _MSC_VER
#define strdup	_strdup
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include <common_def.h>
#include <audio/AudioStream.h>
#include <audio/AudioStream_SpcDrvFuns.h>
#include <emu/Resampler.h>
#include <utils/OSMutex.h>

#include <emu/EmuStructs.h>
#include <emu/SoundEmu.h>
#include <emu/Resampler.h>
#include <emu/SoundDevs.h>
#include <emu/EmuCores.h>


// from SBFMDRV.c
void fnResetPlayer(void);
INT16 fnStartPlaying(const UINT8* songPtr);
INT16 fnPausePlaying(void);
INT16 fnContinuePlaying(void);
void isr08(void);
UINT16 fnGetVersion(void);
UINT8* fnSetMarkerPtr(UINT8* newPtr);
const UINT8* fnSetTimbrePtr(const UINT8* timbrePtr, UINT8 timbreCount);
INT16 fnStopPlaying(void);
UINT16 fnSetChainedPeriod(UINT16 period);
UINT16 fnSetPlayerPeriod(UINT16 period);
INT16 fnSetTranspose(INT16 transp);
UINT16 fnSetSysexHandler(void* ptr);
UINT8* fnGetChMaskPtr(void);
const UINT8* fnGetSongPosition(void);
UINT16 fnSetFade(UINT16 mainVol, UINT16 fadeVol, UINT16 volInc, UINT16 stepTicks);
UINT8 initPlayer(void);
static void WriteVgmHeader(void);
static void FinishVgm(void);
static void FlushVgmDelay(void);
static void WriteVgmOPLCommand(UINT8 reg, UINT8 data);


#define PLAYSTATE_PLAY	0x01	// is playing
#define PLAYSTATE_PAUSE	0x02	// is paused (render wave, but don't advance in the song)
#define PLAYSTATE_END	0x04	// has reached the end of the file


int main(int argc, char* argv[]);
static UINT32 CalcCurrentVolume(UINT32 playbackSmpl);
static UINT32 FillBuffer(void* drvStruct, void* userParam, UINT32 bufSize, void* Data);
static UINT32 GetNthAudioDriver(UINT8 adrvType, INT32 drvNumber);
static UINT8 InitAudioSystem(void);
static UINT8 DeinitAudioSystem(void);
static UINT8 StartAudioDevice(void);
static UINT8 StopAudioDevice(void);
static UINT8 StartEmulation(void);
static UINT8 StopEmulation(void);


static UINT32 smplSize;
static void* audDrv;
static UINT32 smplAlloc;
static WAVE_32BS* smplData;
static UINT32 localAudBufSize;
static void* localAudBuffer;
static OS_MUTEX* renderMtx;	// render thread mutex

static UINT32 sampleRate = 44100;
static UINT32 maxLoops = 2;
static bool manualRenderLoop = false;
static volatile UINT8 playState;

static UINT32 idWavOut;
static UINT32 idWavOutDev;

static INT32 AudioOutDrv = 1;

static UINT32 pbSmplPos;
static UINT32 masterVol = 0x10000;	// fixed point 16.16
static UINT8* cmfMarkerPtr = NULL;

static DEV_INFO opl2DefInf;
static RESMPL_STATE opl2Resmpl;
static DEVFUNC_WRITE_A8D8 opl2Write;

static UINT32 fileLen;
static UINT8* fileData;

static UINT32 timerBase = 1193182;	// 13125000 / 11
static UINT32 timerDivider = 1;
static UINT32 timerCntr = 1;
static UINT8 timerState = 0x00;

static UINT32 vgmSmplCnt = 0;
static UINT32 vgmLastSmpl = 0;
static UINT32 vgmPitRest = 0;
static UINT8 vgmOPLReg = 0x00;
static FILE* hFileVGM = NULL;

int main(int argc, char* argv[])
{
	int argbase;
	UINT8 retVal;
	int curSong;
	
	printf("DOS MIDI Player\n---------------\n");
	if (argc < 2)
	{
		printf("Usage: %s inputfile\n", argv[0]);
		return 0;
	}
	argbase = 1;
#ifdef _WIN32
	SetConsoleOutputCP(65001);	// set UTF-8 codepage
#endif
	
	retVal = InitAudioSystem();
	if (retVal)
		return 1;
	retVal = StartAudioDevice();
	if (retVal)
	{
		DeinitAudioSystem();
		return 1;
	}
	playState = 0x00;
	
	for (curSong = 1; curSong < argc; curSong ++)
	{
	FILE* hFile = fopen(argv[curSong], "rb");
	if (hFile == NULL)
	{
		printf("Error opening %s\n", argv[curSong]);
		continue;
	}
	fseek(hFile, 0, SEEK_END);
	fileLen = ftell(hFile);
	fseek(hFile, 0, SEEK_SET);
	fileData = (UINT8*)malloc(fileLen);
	fread(fileData, 0x01, fileLen, hFile);
	fclose(hFile);
	
	{
		char* vgmName = strdup(argv[curSong]);
		char* extPtr = strrchr(vgmName, '.');
		strcpy(extPtr, ".vgm");
		hFileVGM = fopen(vgmName, "wb");
		free(vgmName);
		WriteVgmHeader();
	}
	
	StartEmulation();
	timerCntr = 0;
	pbSmplPos = 0;
	initPlayer();
	fnResetPlayer();
	cmfMarkerPtr = fnSetMarkerPtr(&retVal);
	fnSetMarkerPtr(cmfMarkerPtr);
	
	//player->SetSampleRate(sampleRate);
	//player->Start();
	{
		UINT16 insTblOfs;
		UINT16 seqDataOfs;
		UINT16 tpQ;	// ticks per quarter
		UINT16 tpS;	// ticks per second
		UINT16 numIns;
		
		memcpy(&insTblOfs, &fileData[0x06], 0x02);
		memcpy(&seqDataOfs, &fileData[0x08], 0x02);
		memcpy(&tpQ, &fileData[0x0A], 0x02);
		memcpy(&tpS, &fileData[0x0C], 0x02);
		memcpy(&numIns, &fileData[0x24], 0x02);
		
		fnSetTimbrePtr(&fileData[insTblOfs], (UINT8)numIns);
		fnSetPlayerPeriod(timerBase / tpS);
		fnStartPlaying(&fileData[seqDataOfs]);
	}
	
	if (audDrv != NULL)
		retVal = AudioDrv_SetCallback(audDrv, FillBuffer, NULL);
	else
		retVal = 0xFF;
	manualRenderLoop = (retVal != 0x00);
	playState &= ~PLAYSTATE_END;
	while(! (playState & PLAYSTATE_END))
	{
		if (! (playState & PLAYSTATE_PAUSE))
		{
			double secs = pbSmplPos / (double)sampleRate;
			printf("Playing %.2f ...   \r", secs);
			fflush(stdout);
		}
		
		if (! manualRenderLoop || (playState & PLAYSTATE_PAUSE))
			Sleep(50);
		else
		{
			UINT32 wrtBytes = FillBuffer(audDrv, NULL, localAudBufSize, localAudBuffer);
			AudioDrv_WriteData(audDrv, wrtBytes, localAudBuffer);
		}
		
		if (_kbhit())
		{
			int inkey = _getch();
			int letter = toupper(inkey);
			
			if (letter == ' ' || letter == 'P')
			{
				playState ^= PLAYSTATE_PAUSE;
				if (audDrv != NULL)
				{
					if (playState & PLAYSTATE_PAUSE)
						AudioDrv_Pause(audDrv);
					else
						AudioDrv_Resume(audDrv);
				}
			}
			else if (letter == 'R')	// restart
			{
				OSMutex_Lock(renderMtx);
				//player->Reset();
				OSMutex_Unlock(renderMtx);
			}
			else if (inkey == 0x1B || letter == 'Q')	// quit
			{
				playState |= PLAYSTATE_END;
				curSong = argc - 1;
			}
			else if (letter == 'F')
			{
				fnSetFade(0, 100, 1, 4);
			}
		}
		if (*cmfMarkerPtr == 0)
			playState |= PLAYSTATE_END;
	}
	// remove callback to prevent further rendering
	// also waits for render thread to finish its work
	if (audDrv != NULL)
		AudioDrv_SetCallback(audDrv, NULL, NULL);
	
	fnStopPlaying();
	
	StopEmulation();
	free(fileData);
	//player->Stop();
	//player->UnloadFile();
	//delete player;	player = NULL;
	
	if (hFileVGM != NULL)
	{
		FinishVgm();
		fclose(hFileVGM);	hFileVGM = NULL;
	}
	
	}	// end for(curSong)
	
	StopAudioDevice();
	DeinitAudioSystem();
	printf("Done.\n");
	
#if defined(_DEBUG) && (_MSC_VER >= 1400)
	// doesn't work well with C++ containers
	//if (_CrtDumpMemoryLeaks())
	//	_getch();
#endif
	
	return 0;
}

#if 1
#define VOLCALC64
#define VOL_BITS	16	// use .X fixed point for working volume
#else
#define VOL_BITS	8	// use .X fixed point for working volume
#endif
#define VOL_SHIFT	(16 - VOL_BITS)	// shift for master volume -> working volume

// Pre- and post-shifts are used to make the calculations as accurate as possible
// without causing the sample data (likely 24 bits) to overflow while applying the volume gain.
// Smaller values for VOL_PRESH are more accurate, but have a higher risk of overflows during calculations.
// (24 + VOL_POSTSH) must NOT be larger than 31
#define VOL_PRESH	4	// sample data pre-shift
#define VOL_POSTSH	(VOL_BITS - VOL_PRESH)	// post-shift after volume multiplication

static UINT32 CalcCurrentVolume(UINT32 playbackSmpl)
{
	return masterVol;
}

static UINT32 FillBuffer(void* drvStruct, void* userParam, UINT32 bufSize, void* data)
{
	UINT32 basePbSmpl;
	UINT32 smplCount;
	INT16* SmplPtr16;
	UINT32 curSmpl;
	WAVE_32BS fnlSmpl;	// final sample value
	INT32 curVolume;
	
	smplCount = bufSize / smplSize;
	if (! smplCount)
		return 0;
	
	OSMutex_Lock(renderMtx);
	if (smplCount > smplAlloc)
		smplCount = smplAlloc;
	memset(smplData, 0, smplCount * sizeof(WAVE_32BS));
	basePbSmpl = pbSmplPos;
	
	{
		double timerIncD;
		UINT32 timerInc;
		UINT32 timerOverflow;
		UINT64 tempVal;
		
		timerIncD = timerBase / (double)sampleRate;
		timerIncD *= smplCount;
		
		timerInc = (UINT32)((UINT64)timerBase * smplCount / sampleRate);
		timerOverflow = timerDivider;
		timerCntr += timerInc;
		while(timerCntr >= timerOverflow)
		{
			timerCntr -= timerOverflow;
			isr08();
			
			// Increment VGM sample counter using the formula from NewRisingRun's CMF2VGM.
			// (allows for byte-by-byte comparisons)
			// VGM samples = PITperiod * 11 / 13125000 * 44100 = PITperiod * 231 / 6250
			tempVal = 231 * (UINT64)timerDivider + vgmPitRest;
			vgmPitRest = (UINT32)(tempVal % 6250);
			vgmSmplCnt += (UINT32)(tempVal / 6250);
		}
	}
	
	Resmpl_Execute(&opl2Resmpl, smplCount, smplData);
	
	curVolume = (INT32)CalcCurrentVolume(basePbSmpl) >> VOL_SHIFT;
	SmplPtr16 = (INT16*)data;
	for (curSmpl = 0; curSmpl < smplCount; curSmpl ++, basePbSmpl ++, SmplPtr16 += 2)
	{
		// Input is about 24 bits (some cores might output a bit more)
		fnlSmpl = smplData[curSmpl];
		
#ifdef VOLCALC64
		fnlSmpl.L = (INT32)( ((INT64)fnlSmpl.L * curVolume) >> VOL_BITS );
		fnlSmpl.R = (INT32)( ((INT64)fnlSmpl.R * curVolume) >> VOL_BITS );
#else
		fnlSmpl.L = ((fnlSmpl.L >> VOL_PRESH) * curVolume) >> VOL_POSTSH;
		fnlSmpl.R = ((fnlSmpl.R >> VOL_PRESH) * curVolume) >> VOL_POSTSH;
#endif
		
		fnlSmpl.L >>= 8;	// 24 bit -> 16 bit
		fnlSmpl.R >>= 8;
		if (fnlSmpl.L < -0x8000)
			fnlSmpl.L = -0x8000;
		else if (fnlSmpl.L > +0x7FFF)
			fnlSmpl.L = +0x7FFF;
		if (fnlSmpl.R < -0x8000)
			fnlSmpl.R = -0x8000;
		else if (fnlSmpl.R > +0x7FFF)
			fnlSmpl.R = +0x7FFF;
		SmplPtr16[0] = (INT16)fnlSmpl.L;
		SmplPtr16[1] = (INT16)fnlSmpl.R;
	}
	pbSmplPos = basePbSmpl;
	OSMutex_Unlock(renderMtx);
	
	return curSmpl * smplSize;
}

static UINT32 GetNthAudioDriver(UINT8 adrvType, INT32 drvNumber)
{
	UINT32 drvCount;
	UINT32 curDrv;
	INT32 typedDrv;
	AUDDRV_INFO* drvInfo;
	
	if (drvNumber == -1)
		return (UINT32)-1;
	
	// go through all audio drivers get the ID of the requested Output/Disk Writer driver
	drvCount = Audio_GetDriverCount();
	for (typedDrv = 0, curDrv = 0; curDrv < drvCount; curDrv ++)
	{
		Audio_GetDriverInfo(curDrv, &drvInfo);
		if (drvInfo->drvType == adrvType)
		{
			if (typedDrv == drvNumber)
				return curDrv;
			typedDrv ++;
		}
	}
	
	return (UINT32)-1;
}

// initialize audio system and search for requested audio drivers
static UINT8 InitAudioSystem(void)
{
	AUDDRV_INFO* drvInfo;
	UINT8 retVal;
	
	retVal = OSMutex_Init(&renderMtx, 0);
	
	printf("Opening Audio Device ...\n");
	retVal = Audio_Init();
	if (retVal == AERR_NODRVS)
		return retVal;
	
	idWavOut = GetNthAudioDriver(ADRVTYPE_OUT, AudioOutDrv);
	idWavOutDev = 0;	// default device
	if (AudioOutDrv != -1 && idWavOut == (UINT32)-1)
	{
		fprintf(stderr, "Requested Audio Output driver not found!\n");
		Audio_Deinit();
		return AERR_NODRVS;
	}
	
	audDrv = NULL;
	if (idWavOut != (UINT32)-1)
	{
		Audio_GetDriverInfo(idWavOut, &drvInfo);
		printf("Using driver %s.\n", drvInfo->drvName);
		retVal = AudioDrv_Init(idWavOut, &audDrv);
		if (retVal)
		{
			fprintf(stderr, "WaveOut: Driver Init Error: %02X\n", retVal);
			Audio_Deinit();
			return retVal;
		}
#ifdef AUDDRV_DSOUND
		if (drvInfo->drvSig == ADRVSIG_DSOUND)
			DSound_SetHWnd(AudioDrv_GetDrvData(audDrv), GetDesktopWindow());
#endif
	}
	
	return 0x00;
}

static UINT8 DeinitAudioSystem(void)
{
	UINT8 retVal;
	
	retVal = 0x00;
	if (audDrv != NULL)
	{
		retVal = AudioDrv_Deinit(&audDrv);	audDrv = NULL;
	}
	Audio_Deinit();
	
	OSMutex_Deinit(renderMtx);	renderMtx = NULL;
	
	return retVal;
}

static UINT8 StartAudioDevice(void)
{
	AUDIO_OPTS* opts;
	UINT8 retVal;
	
	opts = NULL;
	smplAlloc = 0x00;
	smplData = NULL;
	
	if (audDrv != NULL)
		opts = AudioDrv_GetOptions(audDrv);
	if (opts == NULL)
		return 0xFF;
	opts->sampleRate = sampleRate;
	opts->numChannels = 2;
	opts->numBitsPerSmpl = 16;
	smplSize = opts->numChannels * opts->numBitsPerSmpl / 8;
	
	if (audDrv != NULL)
	{
		printf("Opening Device %u ...\n", idWavOutDev);
		retVal = AudioDrv_Start(audDrv, idWavOutDev);
		if (retVal)
		{
			fprintf(stderr, "Device Init Error: %02X\n", retVal);
			return retVal;
		}
		
		smplAlloc = AudioDrv_GetBufferSize(audDrv) / smplSize;
		localAudBufSize = 0;
	}
	else
	{
		smplAlloc = opts->sampleRate / 4;
		localAudBufSize = smplAlloc * smplSize;
	}
	
	smplData = (WAVE_32BS*)malloc(smplAlloc * sizeof(WAVE_32BS));
	localAudBuffer = localAudBufSize ? malloc(localAudBufSize) : NULL;
	
	return 0x00;
}

static UINT8 StopAudioDevice(void)
{
	UINT8 retVal;
	
	retVal = 0x00;
	if (audDrv != NULL)
		retVal = AudioDrv_Stop(audDrv);
	free(smplData);	smplData = NULL;
	free(localAudBuffer);	localAudBuffer = NULL;
	
	return retVal;
}

static UINT8 StartEmulation(void)
{
	DEV_GEN_CFG devCfg;
	UINT8 deviceID;
	UINT8 retVal;
	
	devCfg.emuCore = 0x00;
	devCfg.srMode = DEVRI_SRMODE_NATIVE;
	devCfg.flags = 0x00;
	devCfg.clock = 3579545;
	devCfg.smplRate = sampleRate;
	
	deviceID = DEVID_YM3812;
	if (deviceID == DEVID_YMF262)
		devCfg.clock *= 4;	// OPL3 uses a 14 MHz clock
	retVal = SndEmu_Start(deviceID, &devCfg, &opl2DefInf);
	if (retVal)
		return retVal;
	SndEmu_GetDeviceFunc(opl2DefInf.devDef, RWF_REGISTER | RWF_WRITE, DEVRW_A8D8, 0, (void**)&opl2Write);
	
	Resmpl_SetVals(&opl2Resmpl, 0xFF, 0x100, sampleRate);
	Resmpl_DevConnect(&opl2Resmpl, &opl2DefInf);
	Resmpl_Init(&opl2Resmpl);
	
	return 0x00;
}

static UINT8 StopEmulation(void)
{
	Resmpl_Deinit(&opl2Resmpl);
	SndEmu_Stop(&opl2DefInf);
	return 0x00;
}

UINT8 in(UINT16 port)
{
	return 0x00;	// dummy function
}

void out(UINT16 port, UINT8 data)
{
	switch(port)
	{
	case 0x40:	// PIT counter 0
		if (timerState == 0x01)
		{
			timerDivider &= ~0xFF;
			timerDivider |= (data << 0);
			timerState ++;
		}
		else if (timerState == 0x02)
		{
			timerDivider &= ~0xFF00;
			timerDivider |= (data << 8);
			timerState = 0x00;
		}
		break;
	case 0x41:	// PIT counter 1
	case 0x42:	// PIT counter 2
		break;
	case 0x43:	// PIT control
		{
			UINT8 timerID = (data & 0xC0) >> 6;
			UINT8 reloadOp = (data & 0x30) >> 4;	// 1 = low, 2 = high, 3 = low, then high
			UINT8 mode = (data & 0x0E) >> 1;	// 3 - square wave mode (SBFMDRV only this mode)
			UINT8 count = (data & 0x01) >> 0;	// 0 - count in binary, 1 - count in BCD
			if (timerID == 0 && reloadOp == 0x03 && count == 0)
				timerState = 0x01;
		}
		break;
		// FM ports
	case 0x220:
	case 0x221:
	case 0x228:
	case 0x229:
	case 0x388:
	case 0x389:
		opl2Write(opl2DefInf.dataPtr, port & 0x01, data);
		if (port & 1)
		{
			if (hFileVGM != NULL)
				WriteVgmOPLCommand(vgmOPLReg, data);
			vgmOPLReg = 0x00;
		}
		else
		{
			vgmOPLReg = data;
		}
		break;
	}
	return;
}


typedef struct _vgm_file_header VGM_HEADER;
struct _vgm_file_header
{
	UINT32 fccVGM;
	UINT32 lngEOFOffset;
	UINT32 lngVersion;
	UINT32 lngHzPSG;
	UINT32 lngHz2413;
	UINT32 lngGD3Offset;
	UINT32 lngTotalSamples;
	UINT32 lngLoopOffset;
	UINT32 lngLoopSamples;
	UINT32 lngRate;
	UINT8 psgParams[4];
	UINT32 lngHz2612;
	UINT32 lngHz2151;
	UINT32 lngDataOffset;
	UINT32 lngHzSPCM;
	UINT32 lngSPCMIntf;
	UINT32 lngHzRF5C68;
	UINT32 lngHz2203;
	UINT32 lngHz2608;
	UINT32 lngHz2610;
	UINT32 lngHz3812;
	UINT32 lngHz3526;
	UINT32 lngHz8950;
	UINT32 lngHz262;
};	// -> 0x60 Bytes

static void WriteVgmHeader(void)
{
	VGM_HEADER vgmHdr;
	
	if (hFileVGM == NULL)
		return;
	memset(&vgmHdr, 0x00, sizeof(VGM_HEADER));
	vgmHdr.fccVGM = 0x206D6756;	// 'Vgm '
	vgmHdr.lngEOFOffset = 0x00;
	vgmHdr.lngVersion = 0x0151;
	vgmHdr.lngDataOffset = sizeof(VGM_HEADER) - 0x34;
	vgmHdr.lngHz3812 = 3579545;
	vgmSmplCnt = 0;
	vgmLastSmpl = 0;
	vgmPitRest = 0;
	vgmOPLReg = 0x00;
	
	rewind(hFileVGM);
	fwrite(&vgmHdr, 1, sizeof(VGM_HEADER), hFileVGM);
	return;
}

static void FinishVgm(void)
{
	UINT32 eofOfs;
	
	FlushVgmDelay();
	fputc(0x66, hFileVGM);
	
	eofOfs = ftell(hFileVGM) - 0x04;
	fseek(hFileVGM, 0x04, SEEK_SET);
	fwrite(&eofOfs, 0x04, 1, hFileVGM);
	fseek(hFileVGM, 0x18, SEEK_SET);
	fwrite(&vgmLastSmpl, 0x04, 1, hFileVGM);
	return;
}

static void FlushVgmDelay(void)
{
	UINT32 smplDiff;
	UINT16 delaySmpls;
	
	smplDiff = vgmSmplCnt - vgmLastSmpl;
	while(smplDiff > 0)
	{
		delaySmpls = (smplDiff > 0xFFFF) ? 0xFFFF : (UINT16)smplDiff;
		fputc(0x61, hFileVGM);
		fwrite(&delaySmpls, 0x02, 1, hFileVGM);
		smplDiff -= delaySmpls;
		vgmLastSmpl += delaySmpls;
	}
	return;
}

static void WriteVgmOPLCommand(UINT8 reg, UINT8 data)
{
	FlushVgmDelay();
	fputc(0x5A, hFileVGM);
	fputc(reg, hFileVGM);
	fputc(data, hFileVGM);
	return;
}
