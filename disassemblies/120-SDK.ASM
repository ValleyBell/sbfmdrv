.model tiny
.code
                        include DEFINES.INC

MAX_FN                  EQU     15
MAX_FN_INTERNAL         EQU     3
                        .startup
scratch:                jmp     near ptr isrDriver
signature               byte    'FMDRV',0
ioBase                  word    220h
vectorNum               byte    0
internalVersion         word    114h
chainedVector08         dword   0
prevVector09            dword   0
ptrTimbres              dword   0
songPosition            dword   0
songData                dword   0
waitInterval            dword   0
ptrMarker               dword   0
ptrSysexHandler         dword   0
indexDelay              word    0
dataDelay               word    0
chainedPeriod           word    0
playerPeriod            word    0
pitPeriod               word    0
chainedCount            word    0
maxVoice                word    0
midiCh                  word    0
midiCmd                 word    0
eventCounter            word    0
transpose               word    0
callerStack             dword   0
defaultTimbres          byte    021h, 021h, 0D1h, 007h, 0A3h, 0A4h, 046h, 025h, 0, 0, 0Ah, 0, 0, 0, 0, 0
                        byte    022h, 022h, 00Fh, 00Fh, 0F6h, 0F6h, 095h, 036h, 0, 0, 0Ah, 0, 0, 0, 0, 0
                        byte    0E1h, 0E1h, 000h, 000h, 044h, 054h, 024h, 034h, 2, 2, 07h, 0, 0, 0, 0, 0
                        byte    0A5h, 0B1h, 0D2h, 080h, 081h, 0F1h, 003h, 005h, 0, 0, 02h, 0, 0, 0, 0, 4
                        byte    071h, 022h, 0C5h, 005h, 06Eh, 08Bh, 017h, 00Eh, 0, 0, 02h, 0, 0, 0, 0, 4
                        byte    032h, 021h, 016h, 080h, 073h, 075h, 024h, 057h, 0, 0, 0Eh, 0, 0, 0, 0, 4
                        byte    001h, 011h, 04Fh, 000h, 0F1h, 0D2h, 053h, 074h, 0, 0, 06h, 0, 0, 0, 0, 4
                        byte    007h, 012h, 04Fh, 000h, 0F2h, 0F2h, 060h, 072h, 0, 0, 08h, 0, 0, 0, 0, 4
                        byte    031h, 0A1h, 01Ch, 080h, 051h, 054h, 003h, 067h, 0, 0, 0Eh, 0, 0, 0, 0, 4
                        byte    031h, 0A1h, 01Ch, 080h, 041h, 092h, 00Bh, 03Bh, 0, 0, 0Eh, 0, 0, 0, 0, 4
                        byte    031h, 016h, 087h, 080h, 0A1h, 07Dh, 011h, 043h, 0, 0, 08h, 0, 0, 0, 0, 4
                        byte    030h, 0B1h, 0C8h, 080h, 0D5h, 061h, 019h, 01Bh, 0, 0, 0Ch, 0, 0, 0, 0, 4
                        byte    0F1h, 021h, 001h, 00Dh, 097h, 0F1h, 017h, 018h, 0, 0, 08h, 0, 0, 0, 0, 4
                        byte    032h, 016h, 087h, 080h, 0A1h, 07Dh, 010h, 033h, 0, 0, 08h, 0, 0, 0, 0, 4
                        byte    001h, 012h, 04Fh, 000h, 071h, 052h, 053h, 07Ch, 0, 0, 0Ah, 0, 0, 0, 0, 4
                        byte    002h, 003h, 08Dh, 003h, 0D7h, 0F5h, 037h, 018h, 0, 0, 04h, 0, 0, 0, 0, 0
voiceMIDICh             byte    11 dup(0)
voiceFIndex             byte    11 dup(0)
voiceKey                byte    11 dup(0)
voiceTimbreKSL          byte    11 dup(0)
voiceTimbreScaledVol    byte    11 dup(0)
voiceTimbreVol          byte    11 dup(0)
voiceFNum               word    11 dup(0)
voiceEventCount         word    11 dup(0)
mainVolume              byte    99
targetVolume            byte    99
fadeCount               word    0
fadePeriod              word    0
fadeDelta               byte    0
voice2Op                byte    00h, 01h, 02h, 08h, 09h, 0Ah, 10h, 11h, 12h
silentTimbre            byte    001h, 011h, 04Fh, 000h, 0F1h, 0F2h, 053h, 074h, 0, 0, 08h
voice2OpPerc            byte    10h, 14h, 12h, 15h, 11h
midiCh2BDBit            byte    10h, 08h, 04h, 02h, 01h
voice2FMChPerc          byte    6, 7, 8, 8, 7
numTimbres              byte    0
playStatus              byte    0
midiKey                 byte    0
midiVelocity            byte    0
driverActive            byte    0
defaultMarker           byte    0
valueBD                 byte    0
rhythmMode              byte    0
                        byte    0
midiChProgram           byte    16 dup(0)
midiChBend              word    16 dup(0)
midiChMask              byte    16 dup(1)
midiCmdTable            word    offset midiNoteOff
                        word    offset midiNoteOn
                        word    offset midiIgnore2
                        word    offset midiControl
                        word    offset midiProgCh
                        word    offset midiIgnore1
                        word    offset midiIgnore2
                        word    offset midiSpecial
midiControlTable        word    offset ctrlMarker
                        word    offset ctrlSetRhythmMode
                        word    offset ctrlBendUp
                        word    offset ctrlBendDown
midiSpecialTable        word    offset midiSysex
                        word    offset midiIgnore0
                        word    offset midiIgnore2
                        word    offset midiIgnore1
                        word    offset midiIgnore0
                        word    offset midiIgnore0
                        word    offset midiIgnore0
                        word    offset midiSysexContd
                        word    offset midiIgnore0
                        word    offset midiIgnore0
                        word    offset midiIgnore0
                        word    offset midiIgnore0
                        word    offset midiSpecialStop
                        word    offset midiIgnore0
                        word    offset midiIgnore0
                        word    offset midiMeta
fnTable                 word    offset fnGetVersion
                        word    offset fnSetMarkerPtr
                        word    offset fnSetTimbrePtr
                        word    offset fnSetChainedPeriod
                        word    offset fnSetPlayerPeriod
                        word    offset fnSetTranspose
                        word    offset fnStartPlaying
                        word    offset fnStopPlaying
                        word    offset fnResetPlayer
                        word    offset fnPausePlaying
                        word    offset fnContinuePlaying
                        word    offset fnSetSysexHandler
                        word    offset fnGetChMaskPtr
                        word    offset fnGetSongPosition
                        word    offset fnSetFade
fnTableLoad             word    offset fnLoadDriver
                        word    offset fnUnloadDriver
                        word    offset fnSetIoBase
key2FIndex              byte    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
                        byte    11, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 32, 33, 34, 35, 36
                        byte    37, 38, 39, 40, 41, 42, 43, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58
                        byte    59, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 80, 81, 82, 83, 84
                        byte    85, 86, 87, 88, 89, 90, 91, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105
                        byte    106, 107, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123
                        byte    112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 123, 123
                        byte    123, 123, 123, 123, 123, 123
FIndex2FNum             word    157h, 157h, 158h, 158h, 158h, 158h, 159h, 159h, 159h, 15Ah, 15Ah, 15Ah, 15Bh, 15Bh, 15Bh, 15Ch
                        word    15Ch, 15Ch, 15Dh, 15Dh, 15Dh, 15Dh, 15Eh, 15Eh, 15Eh, 15Fh, 15Fh, 15Fh, 160h, 160h, 160h, 161h
                        word    161h, 161h, 162h, 162h, 162h, 163h, 163h, 163h, 164h, 164h, 164h, 164h, 165h, 165h, 165h, 166h
                        word    166h, 166h, 167h, 167h, 167h, 168h, 168h, 168h, 169h, 169h, 169h, 16Ah, 16Ah, 16Ah, 16Bh, 16Bh
                        word    16Bh, 16Ch, 16Ch, 16Ch, 16Dh, 16Dh, 16Dh, 16Eh, 16Eh, 16Eh, 16Fh, 16Fh, 16Fh, 170h, 170h, 170h
                        word    171h, 171h, 171h, 172h, 172h, 172h, 173h, 173h, 173h, 174h, 174h, 174h, 175h, 175h, 175h, 176h
                        word    176h, 176h, 177h, 177h, 177h, 178h, 178h, 178h, 179h, 179h, 179h, 17Ah, 17Ah, 17Ah, 17Bh, 17Bh
                        word    17Bh, 17Ch, 17Ch, 17Ch, 17Dh, 17Dh, 17Dh, 17Eh, 17Eh, 17Eh, 17Fh, 17Fh, 180h, 180h, 180h, 181h
                        word    181h, 181h, 182h, 182h, 182h, 183h, 183h, 183h, 184h, 184h, 184h, 185h, 185h, 185h, 186h, 186h
                        word    187h, 187h, 187h, 188h, 188h, 188h, 189h, 189h, 189h, 18Ah, 18Ah, 18Ah, 18Bh, 18Bh, 18Bh, 18Ch
                        word    18Ch, 18Dh, 18Dh, 18Dh, 18Eh, 18Eh, 18Eh, 18Fh, 18Fh, 18Fh, 190h, 190h, 191h, 191h, 191h, 192h
                        word    192h, 192h, 193h, 193h, 193h, 194h, 194h, 195h, 195h, 195h, 196h, 196h, 196h, 197h, 197h, 197h
                        word    198h, 198h, 199h, 199h, 199h, 19Ah, 19Ah, 19Ah, 19Bh, 19Bh, 19Ch, 19Ch, 19Ch, 19Dh, 19Dh, 19Dh
                        word    19Eh, 19Eh, 19Eh, 19Fh, 19Fh, 1A0h, 1A0h, 1A0h, 1A1h, 1A1h, 1A1h, 1A2h, 1A2h, 1A3h, 1A3h, 1A3h
                        word    1A4h, 1A4h, 1A5h, 1A5h, 1A5h, 1A6h, 1A6h, 1A6h, 1A7h, 1A7h, 1A8h, 1A8h, 1A8h, 1A9h, 1A9h, 1A9h
                        word    1AAh, 1AAh, 1ABh, 1ABh, 1ABh, 1ACh, 1ACh, 1ADh, 1ADh, 1ADh, 1AEh, 1AEh, 1AEh, 1AFh, 1AFh, 1B0h
                        word    1B0h, 1B0h, 1B1h, 1B1h, 1B2h, 1B2h, 1B2h, 1B3h, 1B3h, 1B4h, 1B4h, 1B4h, 1B5h, 1B5h, 1B6h, 1B6h
                        word    1B6h, 1B7h, 1B7h, 1B8h, 1B8h, 1B8h, 1B9h, 1B9h, 1BAh, 1BAh, 1BAh, 1BBh, 1BBh, 1BCh, 1BCh, 1BCh
                        word    1BDh, 1BDh, 1BEh, 1BEh, 1BEh, 1BFh, 1BFh, 1C0h, 1C0h, 1C0h, 1C1h, 1C1h, 1C2h, 1C2h, 1C2h, 1C3h
                        word    1C3h, 1C4h, 1C4h, 1C4h, 1C5h, 1C5h, 1C6h, 1C6h, 1C6h, 1C7h, 1C7h, 1C8h, 1C8h, 1C9h, 1C9h, 1C9h
                        word    1CAh, 1CAh, 1CBh, 1CBh, 1CBh, 1CCh, 1CCh, 1CDh, 1CDh, 1CDh, 1CEh, 1CEh, 1CFh, 1CFh, 1D0h, 1D0h
                        word    1D0h, 1D1h, 1D1h, 1D2h, 1D2h, 1D3h, 1D3h, 1D3h, 1D4h, 1D4h, 1D5h, 1D5h, 1D5h, 1D6h, 1D6h, 1D7h
                        word    1D7h, 1D8h, 1D8h, 1D8h, 1D9h, 1D9h, 1DAh, 1DAh, 1DBh, 1DBh, 1DBh, 1DCh, 1DCh, 1DDh, 1DDh, 1DEh
                        word    1DEh, 1DEh, 1DFh, 1DFh, 1E0h, 1E0h, 1E1h, 1E1h, 1E1h, 1E2h, 1E2h, 1E3h, 1E3h, 1E4h, 1E4h, 1E5h
                        word    1E5h, 1E5h, 1E6h, 1E6h, 1E7h, 1E7h, 1E8h, 1E8h, 1E8h, 1E9h, 1E9h, 1EAh, 1EAh, 1EBh, 1EBh, 1ECh
                        word    1ECh, 1ECh, 1EDh, 1EDh, 1EEh, 1EEh, 1EFh, 1EFh, 1F0h, 1F0h, 1F0h, 1F1h, 1F1h, 1F2h, 1F2h, 1F3h
                        word    1F3h, 1F4h, 1F4h, 1F5h, 1F5h, 1F5h, 1F6h, 1F6h, 1F7h, 1F7h, 1F8h, 1F8h, 1F9h, 1F9h, 1FAh, 1FAh
                        word    1FAh, 1FBh, 1FBh, 1FCh, 1FCh, 1FDh, 1FDh, 1FEh, 1FEh, 1FFh, 1FFh, 1FFh, 200h, 200h, 201h, 201h
                        word    202h, 202h, 203h, 203h, 204h, 204h, 205h, 205h, 206h, 206h, 206h, 207h, 207h, 208h, 208h, 209h
                        word    209h, 20Ah, 20Ah, 20Bh, 20Bh, 20Ch, 20Ch, 20Dh, 20Dh, 20Eh, 20Eh, 20Eh, 20Fh, 20Fh, 210h, 210h
                        word    211h, 211h, 212h, 212h, 213h, 213h, 214h, 214h, 215h, 215h, 216h, 216h, 217h, 217h, 218h, 218h
                        word    219h, 219h, 21Ah, 21Ah, 21Ah, 21Bh, 21Bh, 21Ch, 21Ch, 21Dh, 21Dh, 21Eh, 21Eh, 21Fh, 21Fh, 220h
                        word    220h, 221h, 221h, 222h, 222h, 223h, 223h, 224h, 224h, 225h, 225h, 226h, 226h, 227h, 227h, 228h
                        word    228h, 229h, 229h, 22Ah, 22Ah, 22Bh, 22Bh, 22Ch, 22Ch, 22Dh, 22Dh, 22Eh, 22Eh, 22Fh, 22Fh, 230h
                        word    230h, 231h, 231h, 232h, 232h, 233h, 233h, 234h, 234h, 235h, 235h, 236h, 236h, 237h, 237h, 238h
                        word    238h, 239h, 239h, 23Ah, 23Bh, 23Bh, 23Ch, 23Ch, 23Dh, 23Dh, 23Eh, 23Eh, 23Fh, 23Fh, 240h, 240h
                        word    241h, 241h, 242h, 242h, 243h, 243h, 244h, 244h, 245h, 245h, 246h, 246h, 247h, 248h, 248h, 249h
                        word    249h, 24Ah, 24Ah, 24Bh, 24Bh, 24Ch, 24Ch, 24Dh, 24Dh, 24Eh, 24Eh, 24Fh, 24Fh, 250h, 251h, 251h
                        word    252h, 252h, 253h, 253h, 254h, 254h, 255h, 255h, 256h, 256h, 257h, 258h, 258h, 259h, 259h, 25Ah
                        word    25Ah, 25Bh, 25Bh, 25Ch, 25Ch, 25Dh, 25Eh, 25Eh, 25Fh, 25Fh, 260h, 260h, 261h, 261h, 262h, 262h
                        word    263h, 264h, 264h, 265h, 265h, 266h, 266h, 267h, 267h, 268h, 269h, 269h, 26Ah, 26Ah, 26Bh, 26Bh
                        word    26Ch, 26Ch, 26Dh, 26Eh, 26Eh, 26Fh, 26Fh, 270h, 270h, 271h, 272h, 272h, 273h, 273h, 274h, 274h
                        word    275h, 275h, 276h, 277h, 277h, 278h, 278h, 279h, 279h, 27Ah, 27Bh, 27Bh, 27Ch, 27Ch, 27Dh, 27Dh
                        word    27Eh, 27Fh, 27Fh, 280h, 280h, 281h, 282h, 282h, 283h, 283h, 284h, 284h, 285h, 286h, 286h, 287h
                        word    287h, 288h, 289h, 289h, 28Ah, 28Ah, 28Bh, 28Bh, 28Ch, 28Dh, 28Dh, 28Eh, 28Eh, 28Fh, 290h, 290h
                        word    291h, 291h, 292h, 293h, 293h, 294h, 294h, 295h, 296h, 296h, 297h, 297h, 298h, 299h, 299h, 29Ah
                        word    29Ah, 29Bh, 29Ch, 29Ch, 29Dh, 29Dh, 29Eh, 29Fh, 29Fh, 2A0h, 2A0h, 2A1h, 2A2h, 2A2h, 2A3h, 2A3h
                        word    2A4h, 2A5h, 2A5h, 2A6h, 2A6h, 2A7h, 2A8h, 2A8h, 2A9h, 2AAh, 2AAh, 2ABh, 2ABh, 2ACh, 2ADh, 2ADh

setVector               proc near
                        pushf
                        push    ds
                        push    ax
                        sub     ax, ax
                        mov     ds, ax
                        pop     ax
                        shl     bx, 1
                        shl     bx, 1
                        cli
                        mov     [bx], ax
                        mov     [bx+2], dx
                        pop     ds
                        popf
                        retn
setVector               endp

getVector               proc near
                        pushf
                        push    ds
                        sub     ax, ax
                        mov     ds, ax
                        shl     bx, 1
                        shl     bx, 1
                        cli
                        mov     ax, [bx]
                        mov     dx, [bx+2]
                        pop     ds
                        popf
                        retn
getVector               endp

setPITPeriod            proc near
                        mov     pitPeriod, ax
                        mov     al, 36h
                        out     43h, al         ; Timer 8253-5 (AT: 8254.2).
                        mov     al, byte ptr pitPeriod
                        out     40h, al         ; Timer 8253-5 (AT: 8254.2).
                        mov     al, ah
                        out     40h, al         ; Timer 8253-5 (AT: 8254.2).
                        retn
setPITPeriod            endp

writeOPL                proc near
                        push    ax
                        push    cx
                        push    dx
                        mov     dx, ioBase
                        xchg    ah, al
                        out     dx, al
                        mov     cx, indexDelay
loc_94C:
                        nop
                        dec     cx
                        or      cx, cx
                        jnz     short loc_94C
                        inc     dx
                        mov     al, ah
                        out     dx, al
                        mov     cx, dataDelay
loc_95A:
                        nop
                        dec     cx
                        or      cx, cx
                        jnz     short loc_95A
                        pop     dx
                        pop     cx
                        pop     ax
                        retn
writeOPL                endp

silence                 proc near
                        pushf
                        cli
                        mov     bx, 8
voiceLoop:
                        mov     ah, 83h
                        add     al, bl
                        mov     al, 13h
                        call    writeOPL
                        cmp     voiceMIDICh[bx], 7Fh
                        ja      short loc_993
                        shl     bx, 1
                        mov     dx, voiceFNum[bx]
                        shr     bx, 1
                        mov     ah, 0A0h
                        add     ah, bl
                        mov     al, dl
                        call    writeOPL
                        mov     ah, 0B0h
                        add     ah, bl
                        mov     al, dh
                        call    writeOPL
loc_993:
                        dec     bl
                        jns     short voiceLoop
                        cmp     rhythmMode, 0
                        jz      short loc_9AB
                        and     valueBD, 0E0h
                        mov     al, valueBD
                        mov     ah, 0BDh
                        call    writeOPL
loc_9AB:
                        popf
                        retn
silence                 endp

resetOperators          proc near
                        push    es
                        push    di
                        push    si
                        mov     cx, cs
                        mov     es, cx
                        mov     cx, 16
                        mov     di, offset midiChProgram
                        sub     al, al
                        rep stosb
                        mov     cx, 11
                        mov     al, 0FFh
                        mov     di, offset voiceMIDICh
                        rep stosb
                        mov     di, offset voice2Op
                        mov     bl, 0
voiceLoop:
                        call    resetChannels
                        mov     ax, 800h
                        call    writeOPL
                        mov     ah, [di]
                        mov     cx, 4
                        mov     si, offset silentTimbre
loc_9DE:
                        add     ah, 20h
                        lodsb
                        call    writeOPL
                        add     ah, 3
                        lodsb
                        call    writeOPL
                        sub     ah, 3
                        loop    loc_9DE
                        add     ah, 60h
                        lodsb
                        call    writeOPL
                        add     ah, 3
                        lodsb
                        call    writeOPL
                        mov     ah, [di]
                        add     ah, bl
                        lodsb
                        call    writeOPL
                        inc     di
                        inc     bl
                        cmp     bl, 9
                        jb      short voiceLoop
                        pop     si
                        pop     di
                        pop     es
                        retn
resetOperators          endp

setMarker               proc near
                        push    ds
                        push    bx
                        lds     bx, ptrMarker
                        mov     [bx], al
                        pop     bx
                        pop     ds
                        retn
setMarker               endp

setVoiceTimbre          proc near
                        push    es
                        push    cx
                        push    di
                        cmp     al, numTimbres
                        jb      short loc_A2A
                        jmp     exit
loc_A2A:
                        cbw
                        shl     ax, 1
                        shl     ax, 1
                        shl     ax, 1
                        shl     ax, 1
                        les     di, ptrTimbres
                        add     di, ax
                        mov     al, es:[di+3]
                        cmp     rhythmMode, 0
                        jz      short loc_A4D
                        cmp     bl, 7
                        jb      short loc_A4D
                        mov     al, es:[di+2]
loc_A4D:
                        mov     ah, al
                        and     ax, 0C03Fh
                        mov     voiceTimbreKSL[bx], ah
                        sub     al, 3Fh
                        neg     al
                        mov     voiceTimbreVol[bx], al
                        mul     mainVolume
                        add     al, al
                        adc     ah, 0
                        mov     voiceTimbreScaledVol[bx], ah
                        cmp     rhythmMode, 0
                        jz      short loc_A77
                        cmp     bx, 6
                        ja      short percTimbre
loc_A77:
                        mov     ah, voice2Op[bx]
                        add     ah, 20h
                        mov     al, es:[di]
                        inc     di
                        call    writeOPL
                        add     ah, 3
                        mov     al, es:[di]
                        inc     di
                        call    writeOPL
                        sub     ah, 3
                        add     ah, 20h
                        mov     al, es:[di]
                        inc     di
                        call    writeOPL
                        inc     di
                        mov     cx, 2
loc_AA0:
                        add     ah, 20h
                        mov     al, es:[di]
                        inc     di
                        call    writeOPL
                        add     ah, 3
                        mov     al, es:[di]
                        inc     di
                        call    writeOPL
                        sub     ah, 3
                        loop    loc_AA0
                        add     ah, 60h
                        mov     al, es:[di]
                        inc     di
                        call    writeOPL
                        add     ah, 3
                        mov     al, es:[di]
                        inc     di
                        call    writeOPL
                        sub     ah, 3
                        mov     ah, bl
                        add     ah, 0C0h
                        mov     al, es:[di]
                        call    writeOPL
                        jmp     short exit
percTimbre:
                        mov     ah, (voice2OpPerc-6)[bx]
                        add     ah, 20h
                        mov     al, es:[di]
                        inc     di
                        inc     di
                        call    writeOPL
                        add     ah, 20h
                        inc     di
                        inc     di
                        mov     cx, 2
loc_AF4:
                        add     ah, 20h
                        mov     al, es:[di]
                        inc     di
                        inc     di
                        call    writeOPL
                        loop    loc_AF4
                        add     ah, 60h
                        mov     al, es:[di]
                        inc     di
                        inc     di
                        call    writeOPL
                        mov     ah, (voice2FMChPerc-6)[bx]
                        add     ah, 0C0h
                        mov     al, es:[di]
                        call    writeOPL
                        jmp     short $+2
exit:                   pop     di
                        pop     cx
                        pop     es
                        retn
setVoiceTimbre          endp

getVarLen               proc near
                        push    si
                        push    bx
                        push    ds
                        sub     bx, bx
                        sub     dx, dx
                        lds     si, songPosition
nextByte:
                        lodsb
                        push    ax
                        and     al, 7Fh
                        cbw
                        add     bx, ax
                        adc     dx, 0
                        pop     ax
                        or      al, al
                        jns     short done
                        mov     al, 7
loc_B3B:
                        shl     bx, 1
                        rcl     dx, 1
                        dec     al
                        jnz     short loc_B3B
                        jmp     short nextByte
done:                   pop     ds
                        mov     ax, bx
                        mov     word ptr songPosition, si
                        pop     bx
                        pop     si
                        retn
getVarLen               endp

incrSongPosition        proc near
                        push    cx
                        add     word ptr songPosition, ax
                        jnb     short loc_B5C
                        add     word ptr songPosition+2, 1000h
loc_B5C:
                        mov     cl, 4
                        mov     dh, dl
                        sub     dl, dl
                        shl     dx, cl
                        add     word ptr songPosition+2, dx
                        mov     si, word ptr songPosition
                        pop     cx
                        retn
incrSongPosition        endp

allocateVoice           proc near
                        push    es
                        mov     cx, ds
                        mov     es, cx
                        mov     cx, maxVoice
                        mov     ah, al
                        or      al, 80h
                        mov     di, offset voiceMIDICh
                        repne scasb
                        jz      short done
                        mov     cx, maxVoice
                        mov     al, 0FFh
                        mov     di, offset voiceMIDICh
                        repne scasb
                        jz      short done
                        mov     cx, maxVoice
                        mov     al, 7Fh
                        mov     di, offset voiceMIDICh
loc_B98:
                        cmp     al, [di]
                        jb      short found
                        inc     di
                        loop    loc_B98
                        jmp     short noFreeVoice
found:
                        inc     di
                        jmp     short done
noFreeVoice:
                        push    si
                        sub     si, si
                        mov     cx, maxVoice
                        mov     di, offset voiceEventCount
                        mov     ax, di
loc_BB0:
                        mov     dx, [di]
                        sub     dx, eventCounter
                        neg     dx
                        cmp     dx, si
                        jbe     short loc_BC0
                        mov     si, dx
                        mov     ax, di
loc_BC0:
                        inc     di
                        inc     di
                        dec     cx
                        jnz     short loc_BB0
                        sub     ax, offset voiceEventCount
                        mov     bx, ax
                        mov     ax, voiceFNum[bx]
                        shr     bx, 1
                        mov     dh, 0A0h
                        xchg    dh, ah
                        add     ah, bl
                        call    writeOPL
                        add     ah, 10h
                        mov     al, dh
                        call    writeOPL
                        mov     ax, bx
                        pop     si
                        jmp     short exit
done:                   sub     di, (offset voiceMIDICh+1)
                        mov     ax, di
exit:                   pop     es
                        retn
allocateVoice           endp

resetChannels           proc near
                        mov     maxVoice, 9
                        mov     ax, 0C0h
                        mov     word ptr valueBD, ax
                        mov     ah, 0BDh
                        call    writeOPL
                        retn
resetChannels           endp

fnResetPlayer           proc near
                        mov     mainVolume, 0FFh
                        mov     targetVolume, 0FFh
                        call    stopPlaying
                        call    resetChannels
                        mov     cx, 16/2
                        mov     di, offset midiChMask
                        mov     ax, 101h
                        rep stosw
                        mov     numTimbres, 16
                        mov     word ptr ptrTimbres, offset defaultTimbres
                        mov     word ptr ptrTimbres+2, ds
                        call    resetOperators
                        mov     playerPeriod, 1193182 /64
                        sub     ax, ax
                        mov     transpose, ax
                        retn
fnResetPlayer           endp

fnStartPlaying          proc near
                        mov     cx, ax
                        mov     ax, -2
                        cmp     playStatus, 0
                        jnz     short exit
                        mov     word ptr songData, cx
                        mov     word ptr songData+2, dx
                        mov     word ptr songPosition, cx
                        mov     word ptr songPosition+2, dx
                        mov     cx, 16
                        sub     ax, ax
                        mov     di, offset midiChBend
                        rep stosw
                        mov     cx, 9
                        mov     al, 0FFh
                        mov     di, offset voiceMIDICh
                        rep stosb
                        call    getVarLen
                        mov     word ptr waitInterval, ax
                        mov     word ptr waitInterval+2, dx
                        mov     eventCounter, 0
                        mov     ax, playerPeriod
                        call    setPITPeriod
                        mov     chainedCount, 0
                        call    resetChannels
                        pushf
                        cli
                        mov     playStatus, 1
                        mov     al, -1
                        call    setMarker
                        popf
                        sub     ax, ax
exit:                   retn
fnStartPlaying          endp

fnPausePlaying          proc near
                        mov     ax, -3
                        cmp     playStatus, 1
                        jnz     short exit
                        mov     playStatus, 2
                        call    silence
                        sub     ax, ax
exit:                   retn
fnPausePlaying          endp

fnContinuePlaying       proc near
                        mov     ax, -4
                        cmp     playStatus, 2
                        jnz     short exit
                        mov     playStatus, 1
                        sub     ax, ax
exit:                   retn
fnContinuePlaying       endp

doSongData              proc near
                        push    es
                        inc     eventCounter
                        mov     ax, word ptr songPosition
                        shr     ax, 1
                        shr     ax, 1
                        shr     ax, 1
                        shr     ax, 1
                        add     word ptr songPosition+2, ax
                        and     word ptr songPosition, 0Fh
doEvent:
                        les     si, songPosition
                        mov     al, es:[si]
                        or      al, al
                        jns     short loc_CFA
                        inc     si
                        mov     ah, al
                        and     al, 0Fh
                        mov     byte ptr midiCh, al
                        shr     ah, 1
                        shr     ah, 1
                        shr     ah, 1
                        shr     ah, 1
                        sub     ah, 8
                        mov     byte ptr midiCmd, ah
loc_CFA:
                        mov     bx, midiCmd
                        shl     bx, 1
                        call    midiCmdTable[bx]
                        mov     word ptr songPosition, si
                        cmp     playStatus, 0
                        jz      short exit
                        call    getVarLen
                        mov     word ptr waitInterval, ax
                        mov     word ptr waitInterval+2, dx
                        or      ax, dx
                        jz      short doEvent
                        sub     word ptr waitInterval, 1
                        sbb     word ptr waitInterval+2, 0
exit:                   pop     es
                        retn
doSongData              endp

midiNoteOff             proc near
                        mov     ax, es:[si]
                        inc     si
                        inc     si
                        mov     midiKey, al
                        mov     midiVelocity, ah
doNoteOff:
                        push    es
                        mov     ax, ds
                        mov     es, ax
                        mov     cx, maxVoice
                        mov     ah, byte ptr midiCh
                        cmp     cl, 6
                        ja      short melodicNote
                        cmp     ah, 11
                        jb      short melodicNote
                        sub     bh, bh
                        mov     bl, ah
                        mov     al, midiCh2BDBit[bx-11]
                        not     al
                        and     al, valueBD
                        mov     valueBD, al
                        mov     ah, 0BDh
                        call    writeOPL
                        jmp     short exit
melodicNote:
                        mov     al, midiKey
                        mov     di, offset voiceKey
keepSearching:
                        repne scasb
                        jnz     short exit
                        mov     bx, di
                        sub     bx, (offset voiceKey+1)
                        cmp     ah, voiceMIDICh[bx]
                        jz      short found
                        jcxz    short exit
                        jmp     short keepSearching
found:
                        or      voiceMIDICh[bx], 80h
                        shl     bx, 1
                        mov     ax, voiceFNum[bx]
                        shr     bx, 1
                        mov     dl, ah
                        mov     ah, 0A0h
                        add     ah, bl
                        call    writeOPL
                        mov     al, dl
                        add     ah, 10h
                        call    writeOPL
exit:                   pop     es
                        retn
midiNoteOff             endp

loc_D9E:
                        jmp     short doNoteOff
midiNoteOn              proc near
                        mov     ax, es:[si]
                        inc     si
                        inc     si
                        mov     midiKey, al
                        mov     midiVelocity, ah
                        or      ah, ah
                        jz      short loc_D9E
                        mov     al, byte ptr midiCh
                        mov     bl, al
                        sub     bh, bh
                        cmp     bh, midiChMask[bx]
                        jz      short exit
                        cmp     rhythmMode, 0
                        jz      short loc_DCD
                        cmp     al, 11
                        jb      short loc_DCD
                        call    startPercNote
                        jmp     short exit
loc_DCD:
                        call    allocateVoice
                        mov     bx, ax
                        mov     al, byte ptr midiCh
                        xchg    al, voiceMIDICh[bx]
                        and     al, 7Fh
                        cmp     al, byte ptr midiCh
                        jz      short loc_DEC
                        mov     di, midiCh
                        mov     al, midiChProgram[di]
                        call    setVoiceTimbre
loc_DEC:
                        mov     cl, midiVelocity
                        or      cl, 80h
                        mov     al, voiceTimbreScaledVol[bx]
                        mul     cl
                        mov     al, 3Fh
                        sub     al, ah
                        or      al, voiceTimbreKSL[bx]
                        mov     ah, voice2Op[bx]
                        add     ah, 43h
                        call    writeOPL
                        call    startMelodicNote
                        mov     dl, ah
                        mov     ah, 0A0h
                        add     ah, bl
                        call    writeOPL
                        mov     al, dl
                        or      al, 20h
                        add     ah, 10h
                        call    writeOPL
exit:                   retn
midiNoteOn              endp

startPercNote           proc near
                        sub     al, 5
                        cbw
                        mov     bx, ax
                        mov     al, (midiCh2BDBit-6)[bx]
                        or      valueBD, al
                        mov     cl, midiVelocity
                        or      cl, 80h
                        mov     al, voiceTimbreScaledVol[bx]
                        mul     cl
                        mov     al, 3Fh
                        sub     al, ah
                        or      al, voiceTimbreKSL[bx]
                        mov     ah, (voice2OpPerc-6)[bx]
                        cmp     bl, 6
                        jnz     short loc_E50
                        add     ah, 3
loc_E50:
                        add     ah, 40h
                        call    writeOPL
                        call    startMelodicNote
                        mov     dl, ah
                        mov     ah, 0A0h
                        add     ah, (voice2FMChPerc-6)[bx]
                        call    writeOPL
                        mov     al, dl
                        add     ah, 10h
                        call    writeOPL
                        mov     al, valueBD
                        mov     ah, 0BDh
                        call    writeOPL
                        retn
startPercNote           endp

startMelodicNote        proc near
                        mov     al, midiKey
                        mov     voiceKey[bx], al
                        cbw
                        mov     di, transpose
                        add     di, ax
                        jns     short loc_E89
                        sub     di, di
                        jmp     short keyOk
loc_E89:
                        cmp     di, 128
                        jb      short keyOk
                        mov     di, 127
keyOk:
                        mov     al, key2FIndex[di]
                        mov     voiceFIndex[bx], al
                        call    setVoiceFNum
                        retn
startMelodicNote        endp

setVoiceFNum            proc near
                        mov     dl, al
                        and     dl, 70h
                        shr     dl, 1
                        shr     dl, 1
                        and     al, 0Fh
                        cbw
                        xchg    al, ah
                        shr     ax, 1
                        shr     ax, 1
                        mov     di, midiCh
                        shl     di, 1
                        add     ax, midiChBend[di]
                        jns     short loc_ECA
                        add     ax, 768
                        sub     dl, 4
                        jns     short indexOk
                        sub     dl, dl
                        sub     ax, ax
                        jmp     short indexOk
loc_ECA:
                        cmp     ax, 768
                        jb      short indexOk
                        sub     ax, 768
                        add     dl, 4
                        cmp     dl, 1Ch
                        jbe     short indexOk
                        mov     ax, 767
                        mov     dl, 28
indexOk:
                        shl     ax, 1
                        mov     di, ax
                        mov     ax, FIndex2FNum[di]
                        or      ah, dl
                        shl     bx, 1
                        mov     voiceFNum[bx], ax
                        mov     cx, eventCounter
                        mov     voiceEventCount[bx], cx
                        shr     bx, 1
                        retn
setVoiceFNum            endp

midiControl             proc near
                        mov     ax, es:[si]
                        inc     si
                        inc     si
                        sub     al, 102
                        cmp     al, 4
                        jnb     short locret_F0F
                        mov     bl, al
                        sub     bh, bh
                        shl     bx, 1
                        call    midiControlTable[bx]
locret_F0F:
                        retn
midiControl             endp

ctrlMarker              proc near
                        mov     al, ah
                        call    setMarker
                        retn
ctrlMarker              endp

ctrlSetRhythmMode       proc near
                        push    ax
                        call    resetOperators
                        pop     ax
                        mov     cx, 9C0h
                        mov     rhythmMode, ah
                        or      ah, ah
                        jz      short loc_F29
                        mov     cx, 6E0h
loc_F29:
                        mov     valueBD, cl
                        mov     byte ptr maxVoice, ch
                        mov     al, valueBD
                        mov     ah, 0BDh
                        call    writeOPL
                        retn
ctrlSetRhythmMode       endp

ctrlBendDown            proc near
                        neg     ah
ctrlBendDown            endp

ctrlBendUp              proc near
                        push    es
                        mov     bx, cs
                        mov     es, bx
                        mov     al, ah
                        cbw
                        sar     ax, 1
                        sar     ax, 1
                        mov     bx, midiCh
                        shl     bx, 1
                        mov     midiChBend[bx], ax
                        shr     bx, 1
                        mov     cx, maxVoice
                        mov     di, offset voiceMIDICh
                        mov     al, bl
loc_F5D:
                        repne scasb
                        jnz     short loc_F8B
                        push    ax
                        push    cx
                        push    di
                        sub     di, (offset voiceMIDICh+1)
                        mov     bx, di
                        mov     al, voiceFIndex[bx]
                        call    setVoiceFNum
                        mov     dl, ah
                        mov     ah, 0A0h
                        add     ah, bl
                        call    writeOPL
                        mov     al, dl
                        or      al, 20h
                        add     ah, 10h
                        call    writeOPL
                        pop     di
                        pop     cx
                        pop     ax
                        or      cx, cx
                        jnz     short loc_F5D
loc_F8B:
                        pop     es
                        retn
ctrlBendUp              endp

midiIgnore2             proc near
                        inc     si
midiIgnore2             endp

midiIgnore1             proc near
                        inc     si
midiIgnore1             endp

midiIgnore0             proc near
                        retn
midiIgnore0             endp

midiProgCh              proc near
                        mov     al, es:[si]
                        inc     si
loc_F94:
                        cmp     al, numTimbres
                        jb      short loc_FA0
                        sub     al, numTimbres
                        jmp     short loc_F94
loc_FA0:
                        mov     bx, midiCh
                        add     bx, offset midiChProgram
                        mov     [bx], al
                        push    es
                        mov     ax, ds
                        mov     es, ax
                        cmp     rhythmMode, 0
                        jz      short melodic
                        cmp     midiCh, 11
                        jb      short melodic
                        mov     bx, midiCh
                        mov     al, midiChProgram[bx]
                        sub     bl, 5
                        call    setVoiceTimbre
                        jmp     short exit
melodic:
                        mov     cx, maxVoice
                        mov     al, byte ptr midiCh
                        or      al, 80h
                        mov     di, offset voiceMIDICh
loc_FD9:
                        repne scasb
                        jnz     short loc_FE5
                        mov     byte ptr [di-1], 0FFh
                        or      cx, cx
                        jnz     short loc_FD9
loc_FE5:
                        mov     cx, maxVoice
                        mov     di, offset voiceMIDICh
loc_FEC:
                        mov     al, byte ptr midiCh
                        repne scasb
                        jnz     short exit
                        mov     bx, midiCh
                        mov     al, midiChProgram[bx]
                        mov     bx, di
                        sub     bx, (offset voiceMIDICh+1)
                        call    setVoiceTimbre
                        or      cx, cx
                        jnz     short loc_FEC
exit:                   pop     es
                        retn
midiProgCh              endp

midiSpecial             proc near
                        mov     bl, byte ptr midiCh
                        sub     bh, bh
                        shl     bx, 1
                        call    midiSpecialTable[bx]
                        retn
midiSpecial             endp

midiSysex               proc near
                        mov     word ptr songPosition, si
                        cmp     word ptr ptrSysexHandler+2, 0
                        jz      short loc_1026
                        call    ptrSysexHandler
loc_1026:
                        call    getVarLen
                        call    incrSongPosition
                        retn
midiSysex               endp

midiSysexContd          proc near
                        mov     word ptr songPosition, si
                        call    getVarLen
                        call    incrSongPosition
                        retn
midiSysexContd          endp

midiSpecialStop         proc near
                        call    stopPlaying
                        retn
midiSpecialStop         endp

midiMeta                proc near
                        mov     al, es:[si]
                        inc     si
                        cmp     al, 2Fh
                        jnz     short loc_1047
                        call    stopPlaying
loc_1047:
                        mov     word ptr songPosition, si
                        call    getVarLen
                        call    incrSongPosition
                        retn
midiMeta                endp

isr08                   proc near
                        push    ds
                        push    es
                        push    ax
                        push    bx
                        push    cx
                        push    dx
                        push    di
                        push    si
                        push    bp
                        mov     ax, cs
                        mov     ds, ax
                        mov     es, ax
                        cmp     playStatus, 1
                        jnz     short keepWaiting
                        mov     ax, word ptr mainVolume
                        cmp     al, ah
                        jz      short loc_1080
                        dec     fadeCount
                        jnz     short loc_1080
                        mov     cx, fadePeriod
                        mov     fadeCount, cx
                        call    doFade
loc_1080:
                        sub     word ptr waitInterval, 1
                        sbb     word ptr waitInterval+2, 0
                        jnb     short keepWaiting
                        mov     word ptr callerStack+2, ss
                        mov     word ptr callerStack, sp
                        cli
                        mov     ax, cs
                        mov     ss, ax
                        mov     sp, offset waitOPLTimer
                        cld
                        call    doSongData
                        mov     ss, word ptr callerStack+2
                        mov     sp, word ptr callerStack
keepWaiting:
                        mov     cx, chainedPeriod
                        mov     ax, pitPeriod
                        add     chainedCount, ax
                        jb      short loc_10BB
                        cmp     chainedCount, cx
                        jb      short done
loc_10BB:
                        sub     chainedCount, cx
                        pushf
                        call    chainedVector08
                        cmp     chainedCount, cx
                        ja      short loc_10BB
                        jmp     short exit
done:                   mov     al, 20h
                        out     20h, al         ; Interrupt controller, 8259A.
exit:                   pop     bp
                        pop     si
                        pop     di
                        pop     dx
                        pop     cx
                        pop     bx
                        pop     ax
                        pop     es
                        pop     ds
                        iret
isr08                   endp

isr09                   proc near
                        push    ds
                        push    es
                        push    ax
                        push    bx
                        push    cx
                        push    dx
                        push    di
                        push    si
                        push    bp
                        mov     ax, cs
                        mov     ds, ax
                        mov     es, ax
                        cld
                        in      al, 60h         ; 8042 keyboard controller data register
                        or      al, al
                        js      short loc_1101
                        cmp     al, 83h
                        jnz     short loc_1101
                        mov     ah, 2
                        int     16h             ; KEYBOARD - GET SHIFT STATUS
                                                ; AL = shift status bits
                        and     al, 0Ch
                        cmp     al, 0Ch
                        jnz     short loc_1101
                        call    silence
loc_1101:
                        pop     bp
                        pop     si
                        pop     di
                        pop     dx
                        pop     cx
                        pop     bx
                        pop     ax
                        pop     es
                        pop     ds
                        jmp     cs:prevVector09
isr09                   endp

isrDriver               proc far
callerAX                equ     0Ch
                        push    ds
                        push    es
                        push    ax
                        push    bx
                        push    cx
                        push    dx
                        push    di
                        push    si
                        push    bp
                        mov     bp, sp
                        mov     ax, cs
                        mov     ds, ax
                        mov     es, ax
                        mov     ax, [bp+callerAX]
                        cmp     driverActive, 0
                        jnz     short alreadyActive
                        mov     driverActive, 1
                        sti
                        cld
                        mov     word ptr [bp+callerAX], -1
                        or      bx, bx
                        js      short internalFN
                        cmp     bx, MAX_FN
                        jnb     short done
                        shl     bx, 1
                        call    fnTable[bx]
                        jmp     short loc_1154
internalFN:
                        not     bx
                        cmp     bx, MAX_FN_INTERNAL
                        jnb     short done
                        shl     bx, 1
                        call    fnTableLoad[bx]
loc_1154:
                        mov     [bp+callerAX], ax
done:                   mov     driverActive, 0
                        jmp     short exit
alreadyActive:
                        mov     word ptr [bp+callerAX], -8
exit:                   pop     bp
                        pop     si
                        pop     di
                        pop     dx
                        pop     cx
                        pop     bx
                        pop     ax
                        pop     es
                        pop     ds
                        retf
isrDriver               endp

fnGetVersion            proc near
                        mov     ax, internalVersion
                        retn
fnGetVersion            endp

fnSetMarkerPtr          proc near
                        xchg    dx, word ptr ptrMarker+2
                        xchg    ax, word ptr ptrMarker
                        mov     [bp+6], dx
                        push    ax
                        sub     ax, ax
                        call    setMarker
                        pop     ax
                        retn
fnSetMarkerPtr          endp

fnSetTimbrePtr          proc near
                        mov     numTimbres, cl
                        mov     word ptr ptrTimbres+2, dx
                        mov     word ptr ptrTimbres, ax
                        call    resetChannels
                        call    resetOperators
                        sub     ax, ax
                        retn
fnSetTimbrePtr          endp

stopPlaying             proc near
                        cmp     playStatus, 0
                        jz      short exit
                        pushf
                        cli
                        sub     al, al
                        mov     playStatus, al
                        mov     ax, chainedPeriod
                        call    setPITPeriod
                        call    silence
                        sub     ax, ax
                        call    setMarker
                        popf
exit:                   retn
stopPlaying             endp

fnStopPlaying           proc near
                        mov     ax, -3
                        cmp     playStatus, 0
                        jz      short exit
                        call    stopPlaying
                        sub     ax, ax
exit:                   retn
fnStopPlaying           endp

fnSetChainedPeriod      proc near
                        mov     chainedPeriod, ax
                        retn
fnSetChainedPeriod      endp

fnSetPlayerPeriod       proc near
                        mov     playerPeriod, ax
                        call    setPITPeriod
                        sub     ax, ax
                        retn
fnSetPlayerPeriod       endp

fnSetTranspose          proc near
                        mov     transpose, ax
                        sub     ax, ax
                        retn
fnSetTranspose          endp

fnSetSysexHandler       proc near
                        pushf
                        cli
                        mov     word ptr ptrSysexHandler+2, dx
                        mov     word ptr ptrSysexHandler, ax
                        sub     ax, ax
                        popf
                        retn
fnSetSysexHandler       endp

fnGetChMaskPtr          proc near
                        mov     word ptr [bp+6], cs
                        mov     ax, offset midiChMask
                        retn
fnGetChMaskPtr          endp

fnGetSongPosition       proc near
                        pushf
                        cli
                        mov     dx, word ptr songPosition+2
                        mov     ax, word ptr songPosition
                        mov     [bp+6], dx
                        popf
                        retn
fnGetSongPosition       endp

fnSetFade               proc near
                        push    dx
                        push    ax
                        mov     fadePeriod, di
                        mov     fadeCount, di
                        mov     ax, cx
                        call    trimFadeVal
                        mov     ah, 100
                        call    calcFadeParam
                        mov     fadeDelta, al
                        pop     ax
                        cli
                        cmp     ax, 65535
                        jnz     short loc_121E
                        mov     al, mainVolume
                        jmp     short gotVolumes
loc_121E:
                        call    trimFadeVal
                        mov     ah, 100
                        call    calcFadeParam
gotVolumes:
                        mov     mainVolume, al
                        mov     targetVolume, al
                        sti
                        mov     cx, 11
                        mov     di, offset voiceTimbreScaledVol
                        mov     si, offset voiceTimbreVol
                        mov     dl, al
loc_1238:
                        lodsb
                        mul     dl
                        add     al, al
                        adc     ah, 0
                        mov     al, ah
                        stosb
                        loop    loc_1238
                        pop     ax
                        call    trimFadeVal
                        mov     ah, 100
                        call    calcFadeParam
                        mov     targetVolume, al
                        retn
fnSetFade               endp

fnGetChainedVector      proc near
                        cbw
                        mov     bx, ax
                        shl     bx, 1
                        shl     bx, 1
                        mov     ax, word ptr chainedVector08[bx]
                        mov     dx, word ptr (chainedVector08+2)[bx]
                        mov     [bp+6], dx
                        retn
fnGetChainedVector      endp

trimFadeVal             proc near
                        or      ax, ax
                        jns     short loc_126D
                        sub     ax, ax
                        jmp     short exit
loc_126D:
                        cmp     ax, 100
                        jb      short exit
                        mov     ax, 99
exit:                   retn
trimFadeVal             endp

calcFadeParam           proc near
                        push    cx
                        push    dx
                        mov     dh, ah
                        sub     ah, ah
                        div     dh
                        xchg    al, ah
                        sub     dl, dl
                        mov     cx, 8
bitLoop:
                        shl     dl, 1
                        shl     al, 1
                        jb      short loc_128F
                        cmp     al, dh
                        jb      short next
loc_128F:
                        or      dl, 1
                        sub     al, dh
next:
                        loop    bitLoop
                        shl     al, 1
                        adc     dl, 0
                        mov     al, dl
                        pop     dx
                        pop     cx
                        retn
calcFadeParam           endp

doFade                  proc near
                        mov     cl, fadeDelta
                        mov     ax, word ptr mainVolume
                        cmp     al, ah
                        jb      short increase
                        sub     al, cl
                        jnb     short done
                        jmp     short trim
increase:
                        add     al, cl
                        jnb     short done
trim:                   mov     al, ah
done:                   mov     mainVolume, al
                        mov     dl, al
                        mov     si, offset voiceTimbreVol
                        mov     di, offset voiceTimbreScaledVol
                        mov     cx, 11
loc_12C5:
                        lodsb
                        mul     dl
                        add     al, al
                        adc     ah, 0
                        mov     al, ah
                        stosb
                        loop    loc_12C5
                        retn
doFade                  endp

                        byte    64h dup(0)

waitOPLTimer            proc near
                        push    cx
                        push    dx
                        mov     cx, 40h
                        mov     ah, al
                        and     ah, 0E0h
                        mov     dx, ioBase
loc_1345:
                        in      al, dx
                        and     al, 0E0h
                        cmp     ah, al
                        jz      short loc_1351
                        loop    loc_1345
                        stc
                        jmp     short exit
loc_1351:
                        clc
exit:                   pop     dx
                        pop     cx
                        retn
waitOPLTimer            endp

detectOPL               proc near
                        mov     ax, 100h
                        call    writeOPL
                        mov     ax, 460h
                        call    writeOPL
                        mov     ax, 480h
                        call    writeOPL
                        mov     al, 0
                        call    waitOPLTimer
                        jb      short exit
                        mov     ax, 2FFh
                        call    writeOPL
                        mov     ax, 421h
                        call    writeOPL
                        mov     al, 0C0h
                        call    waitOPLTimer
                        jb      short exit
                        mov     ax, 460h
                        call    writeOPL
                        mov     ax, 480h
                        call    writeOPL
                        clc
exit:                   retn
detectOPL               endp

isr08Measure:
                        not     ax
                        push    ax
                        mov     al, 20h
                        out     20h, al         ; Interrupt controller, 8259A.
                        pop     ax
                        iret
measureTiming           proc near
                        mov     bx, 8
                        call    getVector
                        mov     word ptr chainedVector08, ax
                        mov     word ptr chainedVector08+2, dx
                        cli
                        in      al, 21h         ; Interrupt controller, 8259A.
                        mov     indexDelay, ax
                        mov     al, 0FEh
                        out     21h, al         ; Interrupt controller, 8259A.
                        mov     ax, 7000
                        call    setPITPeriod
                        mov     bx, 8
                        mov     dx, cs
                        mov     ax, offset isr08Measure
                        call    setVector
                        sub     ax, ax
                        sub     cx, cx
                        sti
loc_13C5:
                        or      ax, ax
                        jz      short loc_13C5
loc_13C9:
                        or      ax, ax
                        jnz     short loc_13C9
loc_13CD:
                        nop
                        inc     cx
                        or      ax, ax
                        jz      short loc_13CD
                        cli
                        mov     ax, indexDelay
                        out     21h, al         ; Interrupt controller, 8259A.
                        mov     ax, chainedPeriod
                        call    setPITPeriod
                        sti
                        mov     bx, 8
                        mov     dx, word ptr chainedVector08+2
                        mov     ax, word ptr chainedVector08
                        call    setVector
                        mov     ax, cx
                        shr     cx, 1
                        add     ax, cx
                        mov     cl, 10
                        shr     ax, cl
                        mov     indexDelay, ax
                        mov     cx, ax
                        shl     cx, 1
                        add     ax, cx
                        shl     cx, 1
                        add     ax, cx
                        mov     dataDelay, ax
                        add     ioBase, 8
                        retn
measureTiming           endp

initPlayer              proc near
                        mov     chainedPeriod, 0FFFFh
                        mov     pitPeriod, 0FFFFh
                        mov     playerPeriod, 1193182/64
                        mov     word ptr ptrMarker+2, cs
                        mov     word ptr ptrMarker, offset defaultMarker
                        mov     ax, 120h
                        call    writeOPL
                        mov     ax, 800h
                        call    writeOPL
                        call    fnResetPlayer
                        sub     ax, ax
                        retn
initPlayer              endp

setVectors8and9         proc near
                        mov     bx, 8
                        call    getVector
                        mov     word ptr chainedVector08+2, dx
                        mov     word ptr chainedVector08, ax
                        mov     bx, 8
                        mov     dx, cs
                        mov     ax, offset isr08
                        call    setVector
                        mov     bx, 9
                        call    getVector
                        mov     word ptr prevVector09+2, dx
                        mov     word ptr prevVector09, ax
                        mov     bx, 9
                        mov     dx, cs
                        mov     ax, offset isr09
                        call    setVector
                        retn
setVectors8and9         endp

restoreVectors8and9     proc near
                        mov     bx, 8
                        mov     dx, word ptr chainedVector08+2
                        mov     ax, word ptr chainedVector08
                        call    setVector
                        mov     bx, 9
                        mov     dx, word ptr prevVector09+2
                        mov     ax, word ptr prevVector09
                        call    setVector
                        retn
restoreVectors8and9     endp

fnLoadDriver            proc near
                        call    measureTiming
                        call    detectOPL
                        jb      short loc_149A
                        call    initPlayer
                        call    setVectors8and9
                        mov     ax, 1
                        jmp     short locret_149C
loc_149A:
                        sub     ax, ax
locret_149C:
                        retn
fnLoadDriver            endp

fnUnloadDriver          proc near
                        call    stopPlaying
                        call    restoreVectors8and9
                        sub     ax, ax
                        retn
fnUnloadDriver          endp

fnSetIoBase             proc near
                        mov     ioBase, ax
                        sub     ax, ax
                        retn
fnSetIoBase             endp

seg000                  ends
                        end
