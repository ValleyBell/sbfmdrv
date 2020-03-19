#include <stddef.h>
#include <string.h>
#include <stdio.h>	// for puts()
#include <stdtype.h>

// port functions from main.c
UINT8 in(UINT16 port);
void out(UINT16 port, UINT8 data);


#define DOS_TERMINATE		0x4C
#define DOS_STAY_RESIDENT	0x31

#define DSP_DISABLE_SPEAKER		0xD3
#define DSP_INVERT_BYTE			0xE0
#define DSP_WRITE_TEST_REGISTER	0xE4
#define DSP_READ_TEST_REGISTER	0xE8

#define CMD_NONE		0
#define CMD_INSTALL		1
#define CMD_UNINSTALL	2


#define MAX_FN			14
#define MAX_FN_INTERNAL	2

#define MAKE_VERSION(major, minor)	(((major) << 8) | ((minor) << 0))

#define BYTE_LOW(x)	((x >> 0) & 0xFF)
#define BYTE_HIGH(x)	((x >> 8) & 0xFF)

typedef void (*MIDI_CMD_FUNC)(void);
typedef void (*MIDI_CTRL_FUNC)(UINT8 val);
typedef UINT16 (*FN_PTR)(void);
typedef void (*CALLBACK_FUNC)(void);

static void setVector(int vector, void* ptr);
static void* getVector(int vector);
static void setPITPeriod(UINT16 period);
static void writeOPL(UINT8 reg, UINT8 val);
static void silence(void);
static void resetOperators(void);
static void setMarker(UINT8 value);
static void setVoiceTimbre(UINT8 insID, UINT8 voiceID);
static UINT32 getVarLen(void);
static void incrSongPosition(UINT32 offset);
static UINT8 allocateVoice(UINT8 midiCh);
static void resetChannels(void);
void fnResetPlayer(void);
INT16 fnStartPlaying(const UINT8* songPtr);
INT16 fnPausePlaying(void);
INT16 fnContinuePlaying(void);
static void doSongData(void);
static void midiNoteOff(void);
static void doNoteOff(void);
static void isNoteOff(void);
static void midiNoteOn(void);
static void startPercNote(UINT8 channel);
static UINT16 startMelodicNote(UINT8 voice);
static UINT16 setVoiceFNum(UINT8 note, UINT8 voice);
static void midiControl(void);
static void ctrlMarker(UINT8 val);
static void ctrlSetRhythmMode(UINT8 val);
static void ctrlBendDown(UINT8 val);
static void ctrlBendUp(UINT8 val);
static void midiIgnore2(void);
static void midiIgnore1(void);
static void midiIgnore0(void);
static void midiProgCh(void);
static void midiSpecial(void);
static void midiSysex(void);
static void midiSysexContd(void);
static void midiSpecialStop(void);
static void midiMeta(void);
void isr08(void);
void isr09(void);
void isrDriver(UINT16* result, INT16 intFunc);
UINT16 fnGetVersion(void);
UINT8* fnSetMarkerPtr(UINT8* newPtr);
const UINT8* fnSetTimbrePtr(const UINT8* timbrePtr, UINT8 timbreCount);
static void stopPlaying(void);
INT16 fnStopPlaying(void);
UINT16 fnSetChainedPeriod(UINT16 period);
UINT16 fnSetPlayerPeriod(UINT16 period);
INT16 fnSetTranspose(INT16 transp);
UINT16 fnSetSysexHandler(void* ptr);
UINT8* fnGetChMaskPtr(void);
const UINT8* fnGetSongPosition(void);
void* fnGetChainedVector(UINT16 vector);
UINT32 fnGetChainedCount(void);
static UINT8 waitOPLTimer(UINT8 mask);
static UINT8 detectOPL(void);
UINT16 isr08Measure(UINT16 param);
static void measureTiming(void);
static UINT8 readDSPbyte(UINT8* result);
static UINT8 writeDSPcommand(UINT8 cmd);
static UINT8 resetDSP(void);
static UINT16 parseCommandLine(const char* cmdLine);
int DOS_main(const char* command_line);
UINT8 initPlayer(void);
static void* findUsedVector(void);
static UINT8 testCard(void);
static UINT8 initCard(void);
static UINT8 walkMCB(void);
static UINT8 makeResident(void);
static void setVectors8and9(void);
void cmdInstall(void);
void cmdUninstall(void);


static void** INT_VECTORS = NULL;
static UINT8 exitServiceCode = DOS_TERMINATE;

static const char signature[6] = "FMDRV";
static UINT16 ioBase = 0x220;
static UINT8 vectorNum = 0x80;
static const UINT16 internalVersion = MAKE_VERSION(1, 10);

static void* chainedVector08;	// previous timer interrupt vector
static void* prevVector09;
static const UINT8* ptrTimbres;	// instrument lib. pointer
static const UINT8* songPosition;
static const UINT8* songData;
static UINT32 waitInterval;
static UINT8* ptrMarker;
static CALLBACK_FUNC ptrSysexHandler;
static UINT16 indexDelay;
static UINT16 dataDelay;
static UINT16 chainedPeriod;
static UINT16 playerPeriod;
static UINT16 pitPeriod;
static UINT16 chainedCount;
static UINT16 chainedCumulative;
static UINT16 maxVoice;
static UINT16 midiCh;
static UINT16 midiCmd;
static UINT16 eventCounter;
static INT16 transpose;
static UINT32 callerStack;

static const UINT8 defaultTimbres[0x10 * 0x10] =
{
	0x21, 0x21, 0xD1, 0x07, 0xA3, 0xA4, 0x46, 0x25, 0x00, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x22, 0x22, 0x0F, 0x0F, 0xF6, 0xF6, 0x95, 0x36, 0x00, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00,
	0xE1, 0xE1, 0x00, 0x00, 0x44, 0x54, 0x24, 0x34, 0x02, 0x02, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00,
	0xA5, 0xB1, 0xD2, 0x80, 0x81, 0xF1, 0x03, 0x05, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x04,
	0x71, 0x22, 0xC5, 0x05, 0x6E, 0x8B, 0x17, 0x0E, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x04,
	0x32, 0x21, 0x16, 0x80, 0x73, 0x75, 0x24, 0x57, 0x00, 0x00, 0x0E, 0x00, 0x00, 0x00, 0x00, 0x04,
	0x01, 0x11, 0x4F, 0x00, 0xF1, 0xD2, 0x53, 0x74, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x00, 0x04,
	0x07, 0x12, 0x4F, 0x00, 0xF2, 0xF2, 0x60, 0x72, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x04,
	0x31, 0xA1, 0x1C, 0x80, 0x51, 0x54, 0x03, 0x67, 0x00, 0x00, 0x0E, 0x00, 0x00, 0x00, 0x00, 0x04,
	0x31, 0xA1, 0x1C, 0x80, 0x41, 0x92, 0x0B, 0x3B, 0x00, 0x00, 0x0E, 0x00, 0x00, 0x00, 0x00, 0x04,
	0x31, 0x16, 0x87, 0x80, 0xA1, 0x7D, 0x11, 0x43, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x04,
	0x30, 0xB1, 0xC8, 0x80, 0xD5, 0x61, 0x19, 0x1B, 0x00, 0x00, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x04,
	0xF1, 0x21, 0x01, 0x0D, 0x97, 0xF1, 0x17, 0x18, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x04,
	0x32, 0x16, 0x87, 0x80, 0xA1, 0x7D, 0x10, 0x33, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x04,
	0x01, 0x12, 0x4F, 0x00, 0x71, 0x52, 0x53, 0x7C, 0x00, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x04,
	0x02, 0x03, 0x8D, 0x03, 0xD7, 0xF5, 0x37, 0x18, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00,
};
static UINT8 voiceMIDICh[11];	// Bit 7: 1=available
static UINT8 voiceFIndex[11];
static UINT8 voiceKey[11];
static UINT8 voiceTimbreKSL[11];
static UINT8 voiceTimbreVol[11];
static UINT16 voiceFNum[11];
static UINT16 voiceEventCount[11];
static const UINT8 voice2Op[9] = {0x00, 0x01, 0x02, 0x08, 0x09, 0x0A, 0x10, 0x11, 0x12};
static const UINT8 silentTimbre[0x0B] = {0x01, 0x11, 0x4F, 0x00, 0xF1, 0xF2, 0x53, 0x74, 0x00, 0x00, 0x08};
static const UINT8 voice2OpPerc[5] = {0x10, 0x14, 0x12, 0x15, 0x11};	// Translates voice# to operator register in percussion mode
static const UINT8 midiCh2BDBit[5] = {0x10, 0x08, 0x04, 0x02, 0x01};	// Translates MIDI channel to BD register bit in percussion mode
static const UINT8 voice2FMChPerc[5] = {6, 7, 8, 8, 7};	// Translates voice# FM channel in percussion mode
static UINT8 numTimbres;
static UINT8 playStatus;
static UINT8 midiKey;
static UINT8 midiVelocity;
static UINT8 driverActive;
static UINT8 defaultMarker;
static UINT8 valueBD;
static UINT8 rhythmMode;
static UINT8 midiChProgram[0x10];
static INT16 midiChBend[0x10];
static UINT8 midiChMask[0x10] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};

static const MIDI_CMD_FUNC midiCmdTable[8] =
{
	midiNoteOff,
	midiNoteOn,
	midiIgnore2,
	midiControl,
	midiProgCh,
	midiIgnore1,
	midiIgnore2,
	midiSpecial,
};
static const MIDI_CTRL_FUNC midiControlTable[4] =
{
	ctrlMarker,
	ctrlSetRhythmMode,
	ctrlBendUp,
	ctrlBendDown,
};
static const MIDI_CMD_FUNC midiSpecialTable[0x10] =
{
	midiSysex, midiIgnore0, midiIgnore2, midiIgnore1,	// F0..F3
	midiIgnore0, midiIgnore0, midiIgnore0, midiSysexContd,	// F4..F7
	midiIgnore0, midiIgnore0, midiIgnore0, midiIgnore0,	// F8..FB
	midiSpecialStop, midiIgnore0, midiIgnore0, midiMeta,	// FC..FF
};

#if 0
static const FN_PTR fnTable[MAX_FN] =
{
	fnGetVersion,
	fnSetMarkerPtr,
	fnSetTimbrePtr,
	fnSetChainedPeriod,
	fnSetPlayerPeriod,
	fnSetTranspose,
	fnStartPlaying,
	fnStopPlaying,
	fnResetPlayer,
	fnPausePlaying,
	fnContinuePlaying,
	fnSetSysexHandler,
	fnGetChMaskPtr,
	fnGetSongPosition,
};
static const FN_PTR fnTableInternal[MAX_FN_INTERNAL] =
{
	fnGetChainedVector,
	fnGetChainedCount,
};
#endif

static const UINT8 key2FIndex[0x80] =	// mostly a "modulo 12" table
{
	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B,
	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B,
	0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B,
	0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B,
	0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B,
	0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x4B,
	0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x5B,
	0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6B,
	0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0x7B,
	0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0x7B,
	0x7B, 0x7B, 0x7B, 0x7B, 0x7B, 0x7B, 0x7B, 0x7B
};
static const UINT16 FIndex2FNum[12 * 0x40] =	// 12 semitones per octave, 64 fraction steps per semitone
{
	0x157, 0x157, 0x158, 0x158, 0x158, 0x158, 0x159, 0x159, 0x159, 0x15A, 0x15A, 0x15A, 0x15B, 0x15B, 0x15B, 0x15C,
	0x15C, 0x15C, 0x15D, 0x15D, 0x15D, 0x15D, 0x15E, 0x15E, 0x15E, 0x15F, 0x15F, 0x15F, 0x160, 0x160, 0x160, 0x161,
	0x161, 0x161, 0x162, 0x162, 0x162, 0x163, 0x163, 0x163, 0x164, 0x164, 0x164, 0x164, 0x165, 0x165, 0x165, 0x166,
	0x166, 0x166, 0x167, 0x167, 0x167, 0x168, 0x168, 0x168, 0x169, 0x169, 0x169, 0x16A, 0x16A, 0x16A, 0x16B, 0x16B,
	
	0x16B, 0x16C, 0x16C, 0x16C, 0x16D, 0x16D, 0x16D, 0x16E, 0x16E, 0x16E, 0x16F, 0x16F, 0x16F, 0x170, 0x170, 0x170,
	0x171, 0x171, 0x171, 0x172, 0x172, 0x172, 0x173, 0x173, 0x173, 0x174, 0x174, 0x174, 0x175, 0x175, 0x175, 0x176,
	0x176, 0x176, 0x177, 0x177, 0x177, 0x178, 0x178, 0x178, 0x179, 0x179, 0x179, 0x17A, 0x17A, 0x17A, 0x17B, 0x17B,
	0x17B, 0x17C, 0x17C, 0x17C, 0x17D, 0x17D, 0x17D, 0x17E, 0x17E, 0x17E, 0x17F, 0x17F, 0x180, 0x180, 0x180, 0x181,
	
	0x181, 0x181, 0x182, 0x182, 0x182, 0x183, 0x183, 0x183, 0x184, 0x184, 0x184, 0x185, 0x185, 0x185, 0x186, 0x186,
	0x187, 0x187, 0x187, 0x188, 0x188, 0x188, 0x189, 0x189, 0x189, 0x18A, 0x18A, 0x18A, 0x18B, 0x18B, 0x18B, 0x18C,
	0x18C, 0x18D, 0x18D, 0x18D, 0x18E, 0x18E, 0x18E, 0x18F, 0x18F, 0x18F, 0x190, 0x190, 0x191, 0x191, 0x191, 0x192,
	0x192, 0x192, 0x193, 0x193, 0x193, 0x194, 0x194, 0x195, 0x195, 0x195, 0x196, 0x196, 0x196, 0x197, 0x197, 0x197,
	
	0x198, 0x198, 0x199, 0x199, 0x199, 0x19A, 0x19A, 0x19A, 0x19B, 0x19B, 0x19C, 0x19C, 0x19C, 0x19D, 0x19D, 0x19D,
	0x19E, 0x19E, 0x19E, 0x19F, 0x19F, 0x1A0, 0x1A0, 0x1A0, 0x1A1, 0x1A1, 0x1A1, 0x1A2, 0x1A2, 0x1A3, 0x1A3, 0x1A3,
	0x1A4, 0x1A4, 0x1A5, 0x1A5, 0x1A5, 0x1A6, 0x1A6, 0x1A6, 0x1A7, 0x1A7, 0x1A8, 0x1A8, 0x1A8, 0x1A9, 0x1A9, 0x1A9,
	0x1AA, 0x1AA, 0x1AB, 0x1AB, 0x1AB, 0x1AC, 0x1AC, 0x1AD, 0x1AD, 0x1AD, 0x1AE, 0x1AE, 0x1AE, 0x1AF, 0x1AF, 0x1B0,
	
	0x1B0, 0x1B0, 0x1B1, 0x1B1, 0x1B2, 0x1B2, 0x1B2, 0x1B3, 0x1B3, 0x1B4, 0x1B4, 0x1B4, 0x1B5, 0x1B5, 0x1B6, 0x1B6,
	0x1B6, 0x1B7, 0x1B7, 0x1B8, 0x1B8, 0x1B8, 0x1B9, 0x1B9, 0x1BA, 0x1BA, 0x1BA, 0x1BB, 0x1BB, 0x1BC, 0x1BC, 0x1BC,
	0x1BD, 0x1BD, 0x1BE, 0x1BE, 0x1BE, 0x1BF, 0x1BF, 0x1C0, 0x1C0, 0x1C0, 0x1C1, 0x1C1, 0x1C2, 0x1C2, 0x1C2, 0x1C3,
	0x1C3, 0x1C4, 0x1C4, 0x1C4, 0x1C5, 0x1C5, 0x1C6, 0x1C6, 0x1C6, 0x1C7, 0x1C7, 0x1C8, 0x1C8, 0x1C9, 0x1C9, 0x1C9,
	
	0x1CA, 0x1CA, 0x1CB, 0x1CB, 0x1CB, 0x1CC, 0x1CC, 0x1CD, 0x1CD, 0x1CD, 0x1CE, 0x1CE, 0x1CF, 0x1CF, 0x1D0, 0x1D0,
	0x1D0, 0x1D1, 0x1D1, 0x1D2, 0x1D2, 0x1D3, 0x1D3, 0x1D3, 0x1D4, 0x1D4, 0x1D5, 0x1D5, 0x1D5, 0x1D6, 0x1D6, 0x1D7,
	0x1D7, 0x1D8, 0x1D8, 0x1D8, 0x1D9, 0x1D9, 0x1DA, 0x1DA, 0x1DB, 0x1DB, 0x1DB, 0x1DC, 0x1DC, 0x1DD, 0x1DD, 0x1DE,
	0x1DE, 0x1DE, 0x1DF, 0x1DF, 0x1E0, 0x1E0, 0x1E1, 0x1E1, 0x1E1, 0x1E2, 0x1E2, 0x1E3, 0x1E3, 0x1E4, 0x1E4, 0x1E5,
	
	0x1E5, 0x1E5, 0x1E6, 0x1E6, 0x1E7, 0x1E7, 0x1E8, 0x1E8, 0x1E8, 0x1E9, 0x1E9, 0x1EA, 0x1EA, 0x1EB, 0x1EB, 0x1EC,
	0x1EC, 0x1EC, 0x1ED, 0x1ED, 0x1EE, 0x1EE, 0x1EF, 0x1EF, 0x1F0, 0x1F0, 0x1F0, 0x1F1, 0x1F1, 0x1F2, 0x1F2, 0x1F3,
	0x1F3, 0x1F4, 0x1F4, 0x1F5, 0x1F5, 0x1F5, 0x1F6, 0x1F6, 0x1F7, 0x1F7, 0x1F8, 0x1F8, 0x1F9, 0x1F9, 0x1FA, 0x1FA,
	0x1FA, 0x1FB, 0x1FB, 0x1FC, 0x1FC, 0x1FD, 0x1FD, 0x1FE, 0x1FE, 0x1FF, 0x1FF, 0x1FF, 0x200, 0x200, 0x201, 0x201,
	
	0x202, 0x202, 0x203, 0x203, 0x204, 0x204, 0x205, 0x205, 0x206, 0x206, 0x206, 0x207, 0x207, 0x208, 0x208, 0x209,
	0x209, 0x20A, 0x20A, 0x20B, 0x20B, 0x20C, 0x20C, 0x20D, 0x20D, 0x20E, 0x20E, 0x20E, 0x20F, 0x20F, 0x210, 0x210,
	0x211, 0x211, 0x212, 0x212, 0x213, 0x213, 0x214, 0x214, 0x215, 0x215, 0x216, 0x216, 0x217, 0x217, 0x218, 0x218,
	0x219, 0x219, 0x21A, 0x21A, 0x21A, 0x21B, 0x21B, 0x21C, 0x21C, 0x21D, 0x21D, 0x21E, 0x21E, 0x21F, 0x21F, 0x220,
	
	0x220, 0x221, 0x221, 0x222, 0x222, 0x223, 0x223, 0x224, 0x224, 0x225, 0x225, 0x226, 0x226, 0x227, 0x227, 0x228,
	0x228, 0x229, 0x229, 0x22A, 0x22A, 0x22B, 0x22B, 0x22C, 0x22C, 0x22D, 0x22D, 0x22E, 0x22E, 0x22F, 0x22F, 0x230,
	0x230, 0x231, 0x231, 0x232, 0x232, 0x233, 0x233, 0x234, 0x234, 0x235, 0x235, 0x236, 0x236, 0x237, 0x237, 0x238,
	0x238, 0x239, 0x239, 0x23A, 0x23B, 0x23B, 0x23C, 0x23C, 0x23D, 0x23D, 0x23E, 0x23E, 0x23F, 0x23F, 0x240, 0x240,
	
	0x241, 0x241, 0x242, 0x242, 0x243, 0x243, 0x244, 0x244, 0x245, 0x245, 0x246, 0x246, 0x247, 0x248, 0x248, 0x249,
	0x249, 0x24A, 0x24A, 0x24B, 0x24B, 0x24C, 0x24C, 0x24D, 0x24D, 0x24E, 0x24E, 0x24F, 0x24F, 0x250, 0x251, 0x251,
	0x252, 0x252, 0x253, 0x253, 0x254, 0x254, 0x255, 0x255, 0x256, 0x256, 0x257, 0x258, 0x258, 0x259, 0x259, 0x25A,
	0x25A, 0x25B, 0x25B, 0x25C, 0x25C, 0x25D, 0x25E, 0x25E, 0x25F, 0x25F, 0x260, 0x260, 0x261, 0x261, 0x262, 0x262,
	
	0x263, 0x264, 0x264, 0x265, 0x265, 0x266, 0x266, 0x267, 0x267, 0x268, 0x269, 0x269, 0x26A, 0x26A, 0x26B, 0x26B,
	0x26C, 0x26C, 0x26D, 0x26E, 0x26E, 0x26F, 0x26F, 0x270, 0x270, 0x271, 0x272, 0x272, 0x273, 0x273, 0x274, 0x274,
	0x275, 0x275, 0x276, 0x277, 0x277, 0x278, 0x278, 0x279, 0x279, 0x27A, 0x27B, 0x27B, 0x27C, 0x27C, 0x27D, 0x27D,
	0x27E, 0x27F, 0x27F, 0x280, 0x280, 0x281, 0x282, 0x282, 0x283, 0x283, 0x284, 0x284, 0x285, 0x286, 0x286, 0x287,
	
	0x287, 0x288, 0x289, 0x289, 0x28A, 0x28A, 0x28B, 0x28B, 0x28C, 0x28D, 0x28D, 0x28E, 0x28E, 0x28F, 0x290, 0x290,
	0x291, 0x291, 0x292, 0x293, 0x293, 0x294, 0x294, 0x295, 0x296, 0x296, 0x297, 0x297, 0x298, 0x299, 0x299, 0x29A,
	0x29A, 0x29B, 0x29C, 0x29C, 0x29D, 0x29D, 0x29E, 0x29F, 0x29F, 0x2A0, 0x2A0, 0x2A1, 0x2A2, 0x2A2, 0x2A3, 0x2A3,
	0x2A4, 0x2A5, 0x2A5, 0x2A6, 0x2A6, 0x2A7, 0x2A8, 0x2A8, 0x2A9, 0x2AA, 0x2AA, 0x2AB, 0x2AB, 0x2AC, 0x2AD, 0x2AD,
};

static const char mTitle[] =
	"Creative Sound Blaster FM-Driver  Version 1.11\r\n"
	"Copyright (c) Creative Labs, Inc., 1990.  All rights reserved.\r\n"
	"Copyright (c) Creative Technology Pte Ltd, 1990.  All rights reserved.\r\n"
	"\n"
	"\tSound Blaster Card Version\n"
	"\r\n";
static const char mCRLF[] = "\r\n";
static const char mAlready[] = "Driver already installed.";
static       char mIOAddress[] = "Driver's I/O address set at 220 Hex\r\n";
static       char mInstalled[] = "Driver installed at INT 00H.";
static const char mRemoved[] = "Driver removed.";
static const char mSBFMDRV[] = "SBFMDRV: ";
static const char mError0[] = "Error 0000: Unknown command switch.";
static const char mError1[] = "Error 0001: Sound Blaster Card does not exist at the I/O address specified.";
static const char mError2[] = "Error 0002: FM feature not available on the card.";
static const char mError3[] = "Error 0003: No interrupt vector available.";
static const char mError4[] = "Error 0004: Driver does not install previously.";
static const char mError5[] = "Error 0005: Other program exist after SBFMDRV.";

// dx/ax - ptr
// bx - vector
static void setVector(int vector, void* ptr)
{
	INT_VECTORS[vector] = ptr;
	return;
}

// bx - vector
// returns in dx/ax
static void* getVector(int vector)
{
	return INT_VECTORS[vector];
}

static void setPITPeriod(UINT16 period)
{
	pitPeriod = period;
	out(0x43, 0x36);
	out(0x40, BYTE_LOW(pitPeriod));
	out(0x40, BYTE_HIGH(pitPeriod));
	return;
}

static void writeOPL(UINT8 reg, UINT8 val)
{
	int i;
	out(ioBase + 0, reg);
	for (i = 0; i  < indexDelay; i++)
		;
	out(ioBase + 1, val);
	for (i = 0; i  < dataDelay; i++)
		;
	return;
}

static void silence(void)
{
	int voice;
	
	for (voice = maxVoice - 1; voice >= 0; voice --)
	{
		writeOPL(0x83, 0x13);	// [bug] supposed to set RL=3 to all channels
		if (voiceMIDICh[voice] <= 0x7F)
		{
			UINT16 fnum = voiceFNum[voice];
			writeOPL(0xA0 + voice, BYTE_LOW(fnum));
			writeOPL(0xB0 + voice, BYTE_HIGH(fnum));
		}
	}
	valueBD &= 0xE0;
	writeOPL(0xBD, valueBD);
	
	return;
}

static void resetOperators(void)
{
	UINT8 voice;	// bl
	
	memset(midiChProgram, 0x00, 0x10);
	memset(voiceMIDICh, 0xFF, 11);
	for (voice = 0; voice < 9; voice ++)
	{
		const UINT8* insPtr;	// si
		UINT8 reg;	// ah
		UINT8 regSlot;	// cx
		
		writeOPL(0xBD, 0x00);
		writeOPL(0x08, 0x00);
		insPtr = silentTimbre;
		
		reg = voice2Op[voice];
		for (regSlot = 0; regSlot < 4; regSlot ++)
		{
			reg += 0x20;	// register 20/40/60/80
			writeOPL(reg + 0x00, *(insPtr++));
			writeOPL(reg + 0x03, *(insPtr++));
		}
		reg += 0x60;	// register E0
		writeOPL(reg + 0x00, *(insPtr++));
		writeOPL(reg + 0x03, *(insPtr++));
		reg = voice2Op[voice] + voice;	// [bug] should be: 0xC0 + voice;
		writeOPL(reg, *(insPtr++));
	}
	
	return;
}

// al = value
static void setMarker(UINT8 value)
{
	*ptrMarker = value;
	return;
}

// al = insID
// bx = voiceID
static void setVoiceTimbre(UINT8 insID, UINT8 voiceID)
{
	const UINT8* insPtr;
	UINT8 tlData;	// al
	UINT8 reg;	// ah
	UINT8 regSlot;	// cx
	
	if (insID >= numTimbres)
		return;
	
	insPtr = &ptrTimbres[insID * 0x10];
	tlData = insPtr[3];	// get TL/KSR (carrier)
	// [bug] It should read insPtr[2] for rhythm SD/TT/CY/HH channels.
	voiceTimbreKSL[voiceID] = tlData & 0xC0;	// save KSR bits
	voiceTimbreVol[voiceID] = 0x3F - (tlData & 0x3F);	// get volume
	if (! rhythmMode || voiceID <= 6)
	{
		reg = voice2Op[voiceID];
		for (regSlot = 0; regSlot < 4; regSlot ++)
		{
			reg += 0x20;	// register 20/40/60/80
			writeOPL(reg + 0x00, *(insPtr++));
			writeOPL(reg + 0x03, *(insPtr++));
		}
		reg += 0x60;	// register E0
		writeOPL(reg + 0x00, *(insPtr++));
		writeOPL(reg + 0x03, *(insPtr++));
		reg = 0xC0 + voiceID;
		writeOPL(reg, *insPtr);
	}
	else
	{
		//percTimbre:
		reg = voice2OpPerc[voiceID - 6];
		for (regSlot = 0; regSlot < 4; regSlot ++)
		{
			reg += 0x20;	// register 20/40/60/80
			writeOPL(reg + 0x00, *insPtr);
			insPtr += 2;
		}
		reg += 0x60;	// register E0
		writeOPL(reg, *insPtr);
		insPtr += 2;
		reg = 0xC0 + voice2FMChPerc[voiceID - 6];
		writeOPL(reg, *insPtr | 0x01);	// Why are we enforcing additive synthesis here??
	}
	return;
}

// returns in dx/ax
static UINT32 getVarLen(void)
{
	UINT32 dx_bx;
	UINT8 al;
	
	dx_bx = 0;
	while(1)
	{
		al = *songPosition;
		songPosition ++;
		dx_bx += (al & 0x7F);
		if (! (al & 0x80))
			break;
		dx_bx <<= 7;
	}
	
	return dx_bx;
}

// dx/ax = offset
static void incrSongPosition(UINT32 offset)
{
	songPosition += offset;
	return;
}

// al - midiCh
// returns in ax (ah is always 0)
static UINT8 allocateVoice(UINT8 midiCh)
{
	UINT8 voice;	// di
	UINT8 maxEvtVoice;	// ax
	UINT16 maxEvtCount;	// si
	
	for (voice = 0; voice < maxVoice; voice ++)
	{
		if (voiceMIDICh[voice] == (0x80 | midiCh))
			return (UINT8)voice;
	}
	for (voice = 0; voice < maxVoice; voice ++)
	{
		if (voiceMIDICh[voice] == 0xFF)
			return (UINT8)voice;
	}
	
	for (voice = 0; voice < maxVoice; voice ++)
	{
		if (voiceMIDICh[voice] >= 0x80)
			return (UINT8)voice;
	}
	
	//noFreeVoice:
	maxEvtVoice = 0;
	maxEvtCount = 0;
	for (voice = 0; voice < maxVoice; voice ++)
	{
		UINT16 passedEvts = eventCounter - voiceEventCount[voice];
		if (passedEvts > maxEvtCount)
		{
			maxEvtCount = passedEvts;
			maxEvtVoice = (UINT8)voice;
		}
	}
	
	writeOPL(0xA0 + maxEvtVoice, BYTE_LOW(voiceFNum[maxEvtVoice]));
	writeOPL(0xB0 + maxEvtVoice, BYTE_HIGH(voiceFNum[maxEvtVoice]));
	return maxEvtVoice;
}

static void resetChannels(void)
{
	maxVoice = 9;
	valueBD = 0xC0;
	writeOPL(0xBD, 0xC0);
	return;
}

void fnResetPlayer(void)
{
	stopPlaying();
	resetChannels();
	memset(midiChMask, 0x01, 0x10);
	numTimbres = 0x10;
	ptrTimbres = defaultTimbres;
	resetOperators();
	playerPeriod = 1193182 / 64;
	transpose = 0;
	return;
}

// dx/ax - songPtr
// returns in ax
INT16 fnStartPlaying(const UINT8* songPtr)
{
	if (playStatus != 0)
		return -2;
	songData = songPtr;
	songPosition = songPtr;
	memset(midiChBend, 0x00, 0x10);
	memset(voiceMIDICh, 0xFF, 9);
	waitInterval = getVarLen();
	eventCounter = 0;
	setPITPeriod(playerPeriod);
	chainedCount = 0;
	resetChannels();
	
	playStatus = 1;
	setMarker((UINT8)-1);
	return 0;
}

// returns in ax
INT16 fnPausePlaying(void)
{
	if (playStatus != 1)
		return -3;
	playStatus = 2;
	silence();
	return 0;
}

// returns in ax
INT16 fnContinuePlaying(void)
{
	if (playStatus != 2)
		return -4;
	playStatus = 1;
	return 0;
}

static void doSongData(void)
{
	eventCounter ++;
	// -- songPositon using optimal segment/address pair --
	do
	{
		//doEvent:
		UINT8 al = *songPosition;
		if (al >= 0x80)
		{
			songPosition ++;
			midiCh = al & 0x0F;
			midiCmd = (al >> 4) - 0x08;
		}
		midiCmdTable[midiCmd]();
		if (playStatus == 0)
			break;
		waitInterval = getVarLen();
	} while(waitInterval == 0);
	waitInterval --;
	return;
}

static void midiNoteOff(void)
{
	midiKey = *songPosition;	songPosition ++;
	midiVelocity = *songPosition;	songPosition ++;
	doNoteOff();
	return;
}

static void doNoteOff(void)
{
	int voice;	// bx/di
	
	if (maxVoice <= 6 && midiCh >= 11)
	{
		valueBD &= ~midiCh2BDBit[midiCh - 11];
		writeOPL(0xBD, valueBD);
		return;
	}
	
	for (voice = 0; voice < maxVoice; voice ++)
	{
		if (voiceKey[voice] == midiKey && voiceMIDICh[voice] == midiCh)
			break;
	}
	if (voice >= maxVoice)
		return;
	//found:
	voiceMIDICh[voice] |= 0x80;
	writeOPL(0xA0 + voice, BYTE_LOW(voiceFNum[voice]));
	writeOPL(0xB0 + voice, BYTE_HIGH(voiceFNum[voice]));
	return;
}

static void isNoteOff(void)
{
	doNoteOff();
	return;
}

static void midiNoteOn(void)
{
	UINT8 voice;	// bx
	UINT8 al;
	UINT8 ah;
	UINT8 cl;
	UINT16 freq;	// ax
	
	midiKey = *songPosition;	songPosition ++;
	midiVelocity = *songPosition;	songPosition ++;
	if (midiVelocity == 0)
	{
		isNoteOff();
		return;
	}
	
	if (midiChMask[midiCh] == 0)
		return;
	if (rhythmMode != 0 && midiCh >= 11)
	{
		startPercNote((UINT8)midiCh);
		return;
	}
	
	voice = allocateVoice((UINT8)midiCh);
	
	al = voiceMIDICh[voice] & 0x7F;
	voiceMIDICh[voice] = (UINT8)midiCh;
	if (al != midiCh)
		setVoiceTimbre(midiChProgram[midiCh], voice);
	
	cl = midiVelocity | 0x80;
	ah = (voiceTimbreVol[voice] * cl) >> 8;
	al = (0x3F - ah) | voiceTimbreKSL[voice];
	writeOPL(0x43 + voice2Op[voice], al);
	
	freq = startMelodicNote(voice);
	writeOPL(0xA0 + voice, BYTE_LOW(freq));
	writeOPL(0xB0 + voice, BYTE_HIGH(freq) | 0x20);
	
	return;
}

// al - channel
static void startPercNote(UINT8 channel)
{
	UINT8 percChn;	// bl
	UINT8 fmChn;	// ah
	UINT8 tlReg;	// ah
	UINT16 freq;	// ax
	UINT8 al;
	UINT8 ah;
	UINT8 cl;
	
	percChn = channel - 5;
	valueBD |= midiCh2BDBit[percChn - 6];
	
	cl = midiVelocity | 0x80;
	ah = (voiceTimbreVol[percChn] * cl) >> 8;
	al = (0x3F - ah) | voiceTimbreKSL[percChn];
	
	tlReg = 0x40 + voice2OpPerc[percChn - 6];
	if (percChn == 6)
		tlReg += 0x03;
	writeOPL(tlReg, al);
	
	freq = startMelodicNote(percChn);
	fmChn = voice2FMChPerc[percChn - 6];
	writeOPL(0xA0 + fmChn, BYTE_LOW(freq));
	writeOPL(0xB0 + fmChn, BYTE_HIGH(freq));
	
	writeOPL(0xBD, valueBD);
	
	return;
}

// bx - voice
static UINT16 startMelodicNote(UINT8 voice)
{
	INT16 di;
	
	voiceKey[voice] = midiKey;
	di = transpose + midiKey;
	if (di < 0x00)
		di = 0x00;
	else if (di > 0x7F)
		di = 0x7F;
	voiceFIndex[voice] = key2FIndex[di];
	return setVoiceFNum(voiceFIndex[voice], voice);
}

// al - note
// bx - voice
// returns in ax
static UINT16 setVoiceFNum(UINT8 note, UINT8 voice)
{
	INT8 octave;	// dl
	INT16 freq;	// ax - note value (4.6 fixed point, without octave)
	
	octave = note & 0x70;
	octave >>= 2;
	freq = (note & 0x0F) << 6;
	freq += midiChBend[midiCh];
	if (freq < 0)
	{
		freq += 0x300;
		octave -= 4;
		if (octave < 0)
		{
			octave = 0;
			freq = 0x000;
		}
	}
	else if (freq >= 0x300)
	{
		freq -= 0x300;
		octave += 4;
		if (octave > 28)
		{
			freq = 0x2FF;
			octave = 28;
		}
	}
	//indexOk:
	voiceFNum[voice] = (octave << 8) | FIndex2FNum[freq];
	voiceEventCount[voice] = eventCounter;
	return voiceFNum[voice];
}

static void midiControl(void)
{
	UINT8 ctrlID;
	UINT8 ctrlVal;
	
	ctrlID = *songPosition;	songPosition ++;
	ctrlVal = *songPosition;	songPosition ++;
	if (ctrlID < 102 || ctrlID >= 106)
		return;
	
	midiControlTable[ctrlID - 102](ctrlVal);
	return;
}

static void ctrlMarker(UINT8 val)
{
	setMarker(val);
}

static void ctrlSetRhythmMode(UINT8 val)
{
	rhythmMode = val;
	if (! rhythmMode)
	{
		valueBD = 0xC0;
		maxVoice = 9;
	}
	else
	{
		valueBD = 0xE0;
		maxVoice = 6;
	}
	voiceMIDICh[6] = 0xFF;
	voiceMIDICh[7] = 0xFF;
	voiceMIDICh[8] = 0xFF;
	writeOPL(0xBD, valueBD);
	resetOperators();
	return;
}

static void ctrlBendDown(UINT8 val)
{
	ctrlBendUp(-val);
	return;
}

static void ctrlBendUp(UINT8 val)
{
	INT16 pbFreq;	// ax
	UINT8 voice;	// bx
	
	pbFreq = (INT8)val >> 2;
	midiChBend[midiCh] = pbFreq;	// TODO: something here is wrong
	for (voice = 0; voice < maxVoice; voice ++)
	{
		if (voiceMIDICh[voice] == midiCh)
		{
			UINT16 freq;
			
			freq = setVoiceFNum(voiceFIndex[voice], voice);
			writeOPL(0xA0 + voice, BYTE_LOW(freq));
			writeOPL(0xB0 + voice, BYTE_HIGH(freq) | 0x20);
		}
	}
	return;
}

static void midiIgnore2(void)
{
	songPosition += 0x02;
	return;
}

static void midiIgnore1(void)
{
	songPosition += 0x01;
	return;
}

static void midiIgnore0(void)
{
	return;
}

static void midiProgCh(void)
{
	UINT8 insID;	// al
	UINT8 voice;	// di/bx
	
	insID = *songPosition;	songPosition ++;
	insID %= numTimbres;
	midiChProgram[midiCh] = insID;
	if (rhythmMode != 0 && midiCh >= 11)
	{
		setVoiceTimbre(midiChProgram[midiCh], midiCh - 5);
	}
	else
	{
		for (voice = 0; voice < maxVoice; voice ++)
		{
			if (voiceMIDICh[voice] == (0x80 | midiCh))
				voiceMIDICh[voice] = 0xFF;
		}
		for (voice = 0; voice < maxVoice; voice ++)
		{
			if (voiceMIDICh[voice] == midiCh)
				setVoiceTimbre(midiChProgram[midiCh], voice);
		}
	}
	return;
}

static void midiSpecial(void)
{
	midiSpecialTable[midiCh]();
	return;
}

static void midiSysex(void)
{
	if (ptrSysexHandler != NULL)
		ptrSysexHandler();
	incrSongPosition(getVarLen());
	return;
}

static void midiSysexContd(void)
{
	incrSongPosition(getVarLen());
	return;
}

static void midiSpecialStop(void)
{
	stopPlaying();
	return;
}

static void midiMeta(void)
{
	UINT8 metaType;
	
	metaType = *songPosition;	songPosition ++;
	if (metaType == 0x2F)
		stopPlaying();
	incrSongPosition(getVarLen());
	return;
}

void isr08(void)
{
	if (playStatus == 1)
	{
		waitInterval --;
		if ((INT32)waitInterval < 0)	// check for overflow
		{
			//callerStack = reg sp/ss;
			doSongData();
			//reg sp/ss = callerStack;
		}
	}
	//keepWaiting:
	chainedCumulative += pitPeriod;
	chainedCount += pitPeriod;
	if (chainedCount >= chainedPeriod)	// Note: The ASM code also handles overflow.
	{
		CALLBACK_FUNC cbFunc = (CALLBACK_FUNC)chainedVector08;
		do
		{
			chainedCount -= chainedPeriod;
			//cbFunc();
		} while(chainedCount >= chainedPeriod);
	}
	else
	{
		out(0x20, 0x20);
	}
	return;
}

void isr09(void)
{
	UINT8 a = in(0x60);
	if (! (a & 0x80) && a != 0x83)	// [bug] should compare with 0x53
	{
		//a = interrupt(0x16, 2);	// get keyboard shift status
		if ((a & 0x0C) == 0x0C)
			silence();
	}
	return;
}

// bp+0x0C - result
// bx - intFunc
void isrDriver(UINT16* result, INT16 intFunc)
{
	if (driverActive != 0)
	{
		*result = -8;	// already active
		return;
	}
	driverActive = 1;
	*result = -1;
	if (intFunc >= 0)
	{
		//if (intFunc < MAX_FN)
		//	*result = fnTable[intFunc]();
	}
	else
	{
		intFunc = ~intFunc;
		//if (intFunc < MAX_FN_INTERNAL)
		//	*result = fnTableInternal[intFunc]();
	}
	driverActive = 0;
	return;
}

// returns in ax
UINT16 fnGetVersion(void)
{
	return internalVersion;
}

// dx/ax - ptr
// returns in ax and [bp+6]
UINT8* fnSetMarkerPtr(UINT8* newPtr)
{
	UINT8* oldPtr = ptrMarker;
	ptrMarker = newPtr;
	setMarker(0);
	return oldPtr;
}

// dx/ax - timbrePtr
// cl - timbreCount
// returns in [bp+6] / ax
const UINT8* fnSetTimbrePtr(const UINT8* timbrePtr, UINT8 timbreCount)
{
	numTimbres = timbreCount;
	ptrTimbres = timbrePtr;
	return 0;
}

static void stopPlaying(void)
{
	if (playStatus == 0)
		return;
	playStatus = 0;
	setPITPeriod(chainedPeriod);
	silence();
	setMarker(0);
	return;
}

// returns in ax
INT16 fnStopPlaying(void)
{
	if (playStatus == 0)
		return -3;
	stopPlaying();
	return 0;
}

// ax - period
// returns in ax
UINT16 fnSetChainedPeriod(UINT16 period)
{
	chainedPeriod = period;
	return chainedPeriod;
}

// ax - period
// returns in ax
UINT16 fnSetPlayerPeriod(UINT16 period)
{
	playerPeriod = period;
	setPITPeriod(playerPeriod);
	return 0;
}

// ax - transp
// returns in ax
INT16 fnSetTranspose(INT16 transp)
{
	transpose = transp;
	return 0;
}

// dx/ax - ptr
// returns in ax
UINT16 fnSetSysexHandler(CALLBACK_FUNC ptr)
{
	ptrSysexHandler = ptr;
	return 0;
}

// returns in ax / [bp+6]
UINT8* fnGetChMaskPtr(void)
{
	return midiChMask;
}

// returns in [bp+6] / ax
const UINT8* fnGetSongPosition(void)
{
	return songPosition;
}

// ax - vector
// returns in [bp+6] / ax
void* fnGetChainedVector(UINT16 vector)
{
	return (&chainedVector08)[vector];
}

// returns in [bp+6] / ax
UINT32 fnGetChainedCount(void)
{
	return chainedCumulative;
}


// al - mask
// returns in carry flag
static UINT8 waitOPLTimer(UINT8 mask)
{
	UINT16 attempt;
	UINT8 status;
	
	mask &= 0xE0;
	for (attempt = 0x00; attempt < 0x40; attempt ++)
	{
		status = in(ioBase) & 0xE0;
		if (status == mask)
			return 0;
	}
	return 1;
}

// returns in carry flag
static UINT8 detectOPL(void)
{
	writeOPL(0x01, 0x00);
	writeOPL(0x04, 0x60);
	writeOPL(0x04, 0x80);
	if (waitOPLTimer(0x00))
		return 1;
	writeOPL(0x02, 0xFF);
	writeOPL(0x04, 0x21);
	if (waitOPLTimer(0xC0))
		return 1;
	writeOPL(0x04, 0x60);
	writeOPL(0x04, 0x80);
	return 0;
}

// ax - param
UINT16 isr08Measure(UINT16 param)
{
	out(0x20, 0x20);
	return ~param;
}

static void measureTiming(void)
{
	UINT16 ax;
	UINT16 delayCntr;	// cx
	
	chainedVector08 = (CALLBACK_FUNC)getVector(8);
	indexDelay = (UINT16)in(0x21);
	// -- disable interrupts --
	out(0x21, 0xFE);
	setPITPeriod(7000);	// set to 5.867 ms
	setVector(8, isr08Measure);
	
	delayCntr = 0;
	ax = 0;
	// -- enable interrupts --
	while(! ax)
		;	// -- wait for isr08Measure to change ax to 0xFFFF --
	while(! ax)
		;	// -- wait for isr08Measure to change ax back to 0x0000 --
	while(ax == 0)
		delayCntr ++;	// -- wait for isr08Measure to change ax to 0xFFFF --
	// -- disable interrupts --
	out(0x21, (UINT8)indexDelay);
	setPITPeriod(chainedPeriod);
	// -- enable interrupts --
	setVector(8, chainedVector08);
	indexDelay = (delayCntr * 9) >> 10;	// delay for register write in CPU cycles
	dataDelay = indexDelay * 7;
	ioBase += 8;
	
	return;
}

// al - result
// returns in carry flag
static UINT8 readDSPbyte(UINT8* result)
{
	UINT16 portAddr;	// dx
	UINT16 cntr;	// cx
	UINT8 retVal;	// al
	
	portAddr = (ioBase & 0xFFF0) + 0x0E;
	for (cntr = 0; cntr < 512; cntr ++)
	{
		retVal = in(portAddr);
		if (retVal & 0x80)
		{
			*result = in(portAddr - 0x04);
			return 0;
		}
	}
	return 1;
}

// cmd - al
// returns in carry flag
static UINT8 writeDSPcommand(UINT8 cmd)
{
	UINT16 portAddr;	// dx
	UINT16 cntr;	// cx
	UINT8 retVal;	// al
	
	portAddr = (ioBase & 0xFFF0) + 0x0C;
	for (cntr = 0; cntr < 512; cntr ++)
	{
		retVal = in(portAddr);
		if (! (retVal & 0x80))
		{
			out(portAddr, cmd);
			return 0;
		}
	}
	return 1;
}

// returns in carry flag
static UINT8 resetDSP(void)
{
	UINT16 portAddr;	// dx
	UINT16 cntr;	// cx
	UINT8 retVal;	// al
	
	portAddr = ioBase + 0x0C;
	writeDSPcommand(0xD3);	// DSP_DISABLE_SPEAKER
	for (cntr = 0; cntr < 0xFFFF; cntr ++)
		;	// wait a bit
	portAddr = ioBase + 0x06;
	out(ioBase + 0x06, 0x01);
	for (cntr = 0x00; cntr < 0x100; cntr ++)
		;
	out(ioBase + 0x06, 0x00);
	
	for (cntr = 0x00; cntr < 0x20; cntr ++)
	{
		if (! readDSPbyte(&retVal))
		{
			if (retVal == 0xAA)
				return 0;
		}
	}
	return 1;
}

// returns in ax
static UINT16 parseCommandLine(const char* cmdLine)
{
	char cmdChar;
	
	while(1)
	{
		while(*cmdLine == ' ')
			cmdLine ++;
		cmdChar = *cmdLine;
		cmdLine ++;
		if (cmdChar == '\r')
			return CMD_INSTALL;
		if (cmdChar != '/')
			break;
		
		cmdChar = *cmdLine;
		cmdLine ++;
		if (cmdChar >= 'a' && cmdChar <= 'z')
			cmdChar -= 0x20;	// make uppercase
		if (cmdChar == 'U')
			return CMD_UNINSTALL;
	}
	puts(mSBFMDRV);
	puts(mError0);	// unknown command switch
	return CMD_NONE;
}

int DOS_main(const char* command_line)
{
	UINT16 cmdID;
	
	puts(mTitle);
	cmdID = parseCommandLine(command_line);
	if (cmdID > 0)
	{
		if (cmdID == 1)
			cmdInstall();
		else if (cmdID == 2)
			cmdUninstall();
	}
	puts("\r\n");
	// at this point we call either DOS_TERMINATE or DOS_STAY_RESIDENT, depending on the value of exitServiceCode
	return 0;
}

UINT8 initPlayer(void)
{
	chainedPeriod = 0xFFFF;
	pitPeriod = 0xFFFF;
	playerPeriod = 1193182 / 64;
	ptrMarker = &defaultMarker;
	writeOPL(0x01, 0x20);
	writeOPL(0x08, 0x00);
	fnResetPlayer();
	return 0;
}

// returns in es/ax
static void* findUsedVector(void)
{
	UINT16 vector;
	
	for (vector = 0x80; vector < 0xC0; vector ++)
	{
		void* vPtr = getVector(vector);
		if (vPtr != NULL)
		{
			if (! memcmp(vPtr, signature, 6))
				return vPtr;
		}
	}
	
	return NULL;
}

// returns in carry flag
static UINT8 testCard(void)
{
	UINT8 dspData;
	
	if (resetDSP())
		return 1;
	if (writeDSPcommand(DSP_INVERT_BYTE))
		return 1;
	if (writeDSPcommand(0x55))
		return 1;
	if (readDSPbyte(&dspData))
		return 1;
	return (dspData != 0xAA);	// return 0 on success
}

// returns in carry flag
static UINT8 initCard(void)
{
	if (testCard())
	{
		puts(mSBFMDRV);
		puts(mError1);	// Sound Blaster Card not found at I/O address
		return 1;
	}
	
	writeDSPcommand(DSP_WRITE_TEST_REGISTER);
	
	// write DOS function ID, used for self-modifying code that tried to make
	// SBFMDRV incompatible with non-Creative cards
	//writeDSPcommand(DOS_TERMINATE - DOS_STAY_RESIDENT);
	
	measureTiming();
	if (detectOPL())
	{
		puts(mSBFMDRV);
		puts(mError2);	// card has no FM chip
		return 1;
	}
	
	return 0;
}

// returns in es/ax
// Walk the MCB chain to see if the loaded driver can be unloaded.
static UINT8 walkMCB(void)
{
	// I can't be bothered to port this as it messes around with the segment registers as lot.
	return 0;	// Let's just return "success".
}

// returns in carry flag
static UINT8 makeResident(void)
{
	UINT16 vector;
	
	for (vector = 0x80; vector < 0xC0; vector ++)
	{
		void* vPtr = getVector(vector);
		if (vPtr == NULL)
		{
			//UINT8 dspReg;
			
			vectorNum = (UINT8)vector;
			mInstalled[0x19] = '0' + (vectorNum & 0x0F);
			mInstalled[0x18] = '0' + (vectorNum >> 4);
			puts(mInstalled);
			setVector(vectorNum, isrDriver);
			
			//writeDSPcommand(DSP_READ_TEST_REGISTER);
			//readDSPbyte(&dspData);
			//exitServiceCode -= dspData;	// turn DOS_TERMINATE into DOS_STAY_RESIDENT
			exitServiceCode = DOS_STAY_RESIDENT;	// that's what it does
			return 0;
		}
	}
	puts(mSBFMDRV);
	puts(mError3);	// no interrupt vector available
	return 1;
}

static void setVectors8and9(void)
{
	chainedVector08 = (CALLBACK_FUNC)getVector(8);
	setVector(8, isr08);
	prevVector09 = (CALLBACK_FUNC)getVector(9);
	setVector(9, isr09);
	
	return;
}

void cmdInstall(void)
{
	mIOAddress[0x1D] = '0' + ((ioBase & 0xF0) >> 4);
	puts(mIOAddress);
	if (findUsedVector() != NULL)
	{
		puts(mAlready);
		return;
	}
	
	if (initCard())
		return;
	if (makeResident())
		return;
	initPlayer();
	setVectors8and9();
	
	return;
}

//static void callDriver(void)
//{
//	interrupt(vectorNum);
//	return;
//}

void cmdUninstall(void)
{
	void* vPtr;
	
	if (findUsedVector() == NULL)
	{
		puts(mSBFMDRV);
		puts(mError4);	// driver not installed -- cannot remove.
		return;
	}
	//write interrupt ID into instruction in callDriver function
	if (walkMCB())
	{
		puts(mSBFMDRV);
		puts(mError5);	// cannot unload driver; another program was loaded afterwards.
		return;
	}
	
	vPtr = fnGetChainedVector(0);	// executed via callDriver()
	setVector(8, vPtr);
	vPtr = fnGetChainedVector(1);	// executed via callDriver()
	setVector(9, vPtr);
	setVector(vectorNum, NULL);
	
	// -- free sound driver memory here --
	puts(mRemoved);
	return;
}
