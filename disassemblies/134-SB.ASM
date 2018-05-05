.model tiny
.code
                        include DEFINES.INC

MAX_FN                  EQU     16
MAX_FN_INTERNAL         EQU     5
STACK_SIZE              EQU     100
                        .startup
scratch:                jmp     main
signature               byte    "FMDRV",0
                        byte    7 dup (0)
internalVersion         word    134h
ptrProductName          word    offset  mProductName
ioBase                  word    220h
vectorNum               byte    80h
loopCount               word    0
chainedVector08         dword   0
prevVector09            dword   0
ptrTimbres              dword   0
songPosition            dword   0
songSeekablePosition    dword   0
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
chainedCumulative       word    0
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
voiceMIDICh             byte    11 dup(0) ; Bit 7: 1=available
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
voice2OpPerc            byte    10h, 14h, 12h, 15h, 11h ; Translates voice# to operator register in percussion mode
midiCh2BDBit            byte    10h, 08h, 04h, 02h, 01h ; Translates MIDI channel to BD register bit in percussion mode
voice2FMChPerc          byte    6, 7, 8, 8, 7           ; Translates voice# FM channel in percussion mode
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
midiCmdTable            word    offset  midiNoteOff
                        word    offset  midiNoteOn
                        word    offset  midiIgnore2
                        word    offset  midiControl
                        word    offset  midiProgCh
                        word    offset  midiIgnore1
                        word    offset  midiIgnore2
                        word    offset  midiSpecial
midiControlTable        word    offset  ctrlMarker
                        word    offset  ctrlSetRhythmMode
                        word    offset  ctrlBendUp
                        word    offset  ctrlBendDown
midiSpecialTable        word    offset  midiSysex
                        word    offset  midiIgnore0
                        word    offset  midiIgnore2
                        word    offset  midiIgnore1
                        word    offset  midiIgnore0
                        word    offset  midiIgnore0
                        word    offset  midiIgnore0
                        word    offset  midiSysexContd
                        word    offset  midiIgnore0
                        word    offset  midiIgnore0
                        word    offset  midiIgnore0
                        word    offset  midiIgnore0
                        word    offset  midiSpecialStop
                        word    offset  midiIgnore0
                        word    offset  midiIgnore0
                        word    offset  midiMeta
fnTable                 word    offset  fnGetVersion
                        word    offset  fnSetMarkerPtr
                        word    offset  fnSetTimbrePtr
                        word    offset  fnSetChainedPeriod
                        word    offset  fnSetPlayerPeriod
                        word    offset  fnSetTranspose
                        word    offset  fnStartPlaying
                        word    offset  fnStopPlaying
                        word    offset  fnResetPlayer
                        word    offset  fnPausePlaying
                        word    offset  fnContinuePlaying
                        word    offset  fnSetSysexHandler
                        word    offset  fnGetChMaskPtr
                        word    offset  fnGetSongPosition
                        word    offset  fnSetFade
                        word    offset  fnSetLoopCount
fnTableInternal         word    offset  fnGetChainedVector
                        word    offset  fnGetChainedCount
                        word    offset  fnGetActivePtr
                        word    offset  fnSetChainedVector
                        word    offset  fnGetStatusPtr
key2FIndex              byte    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25
                        byte    26, 27, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 64, 65, 66
                        byte    67, 68, 69, 70, 71, 72, 73, 74, 75, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 96, 97, 98, 99, 100, 101, 102
                        byte    103, 104, 105, 106, 107, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 112, 113, 114, 115, 116, 117
                        byte    118, 119, 120, 121, 122, 123, 123, 123, 123, 123, 123, 123, 123, 123
FIndex2FNum             word    157h, 157h, 158h, 158h, 158h, 158h, 159h, 159h, 159h, 15Ah, 15Ah, 15Ah, 15Bh, 15Bh, 15Bh, 15Ch, 15Ch, 15Ch, 15Dh
                        word    15Dh, 15Dh, 15Dh, 15Eh, 15Eh, 15Eh, 15Fh, 15Fh, 15Fh, 160h, 160h, 160h, 161h, 161h, 161h, 162h, 162h, 162h, 163h
                        word    163h, 163h, 164h, 164h, 164h, 164h, 165h, 165h, 165h, 166h, 166h, 166h, 167h, 167h, 167h, 168h, 168h, 168h, 169h
                        word    169h, 169h, 16Ah, 16Ah, 16Ah, 16Bh, 16Bh, 16Bh, 16Ch, 16Ch, 16Ch, 16Dh, 16Dh, 16Dh, 16Eh, 16Eh, 16Eh, 16Fh, 16Fh
                        word    16Fh, 170h, 170h, 170h, 171h, 171h, 171h, 172h, 172h, 172h, 173h, 173h, 173h, 174h, 174h, 174h, 175h, 175h, 175h
                        word    176h, 176h, 176h, 177h, 177h, 177h, 178h, 178h, 178h, 179h, 179h, 179h, 17Ah, 17Ah, 17Ah, 17Bh, 17Bh, 17Bh, 17Ch
                        word    17Ch, 17Ch, 17Dh, 17Dh, 17Dh, 17Eh, 17Eh, 17Eh, 17Fh, 17Fh, 180h, 180h, 180h, 181h, 181h, 181h, 182h, 182h, 182h
                        word    183h, 183h, 183h, 184h, 184h, 184h, 185h, 185h, 185h, 186h, 186h, 187h, 187h, 187h, 188h, 188h, 188h, 189h, 189h
                        word    189h, 18Ah, 18Ah, 18Ah, 18Bh, 18Bh, 18Bh, 18Ch, 18Ch, 18Dh, 18Dh, 18Dh, 18Eh, 18Eh, 18Eh, 18Fh, 18Fh, 18Fh, 190h
                        word    190h, 191h, 191h, 191h, 192h, 192h, 192h, 193h, 193h, 193h, 194h, 194h, 195h, 195h, 195h, 196h, 196h, 196h, 197h
                        word    197h, 197h, 198h, 198h, 199h, 199h, 199h, 19Ah, 19Ah, 19Ah, 19Bh, 19Bh, 19Ch, 19Ch, 19Ch, 19Dh, 19Dh, 19Dh, 19Eh
                        word    19Eh, 19Eh, 19Fh, 19Fh, 1A0h, 1A0h, 1A0h, 1A1h, 1A1h, 1A1h, 1A2h, 1A2h, 1A3h, 1A3h, 1A3h, 1A4h, 1A4h, 1A5h, 1A5h
                        word    1A5h, 1A6h, 1A6h, 1A6h, 1A7h, 1A7h, 1A8h, 1A8h, 1A8h, 1A9h, 1A9h, 1A9h, 1AAh, 1AAh, 1ABh, 1ABh, 1ABh, 1ACh, 1ACh
                        word    1ADh, 1ADh, 1ADh, 1AEh, 1AEh, 1AEh, 1AFh, 1AFh, 1B0h, 1B0h, 1B0h, 1B1h, 1B1h, 1B2h, 1B2h, 1B2h, 1B3h, 1B3h, 1B4h
                        word    1B4h, 1B4h, 1B5h, 1B5h, 1B6h, 1B6h, 1B6h, 1B7h, 1B7h, 1B8h, 1B8h, 1B8h, 1B9h, 1B9h, 1BAh, 1BAh, 1BAh, 1BBh, 1BBh
                        word    1BCh, 1BCh, 1BCh, 1BDh, 1BDh, 1BEh, 1BEh, 1BEh, 1BFh, 1BFh, 1C0h, 1C0h, 1C0h, 1C1h, 1C1h, 1C2h, 1C2h, 1C2h, 1C3h
                        word    1C3h, 1C4h, 1C4h, 1C4h, 1C5h, 1C5h, 1C6h, 1C6h, 1C6h, 1C7h, 1C7h, 1C8h, 1C8h, 1C9h, 1C9h, 1C9h, 1CAh, 1CAh, 1CBh
                        word    1CBh, 1CBh, 1CCh, 1CCh, 1CDh, 1CDh, 1CDh, 1CEh, 1CEh, 1CFh, 1CFh, 1D0h, 1D0h, 1D0h, 1D1h, 1D1h, 1D2h, 1D2h, 1D3h
                        word    1D3h, 1D3h, 1D4h, 1D4h, 1D5h, 1D5h, 1D5h, 1D6h, 1D6h, 1D7h, 1D7h, 1D8h, 1D8h, 1D8h, 1D9h, 1D9h, 1DAh, 1DAh, 1DBh
                        word    1DBh, 1DBh, 1DCh, 1DCh, 1DDh, 1DDh, 1DEh, 1DEh, 1DEh, 1DFh, 1DFh, 1E0h, 1E0h, 1E1h, 1E1h, 1E1h, 1E2h, 1E2h, 1E3h
                        word    1E3h, 1E4h, 1E4h, 1E5h, 1E5h, 1E5h, 1E6h, 1E6h, 1E7h, 1E7h, 1E8h, 1E8h, 1E8h, 1E9h, 1E9h, 1EAh, 1EAh, 1EBh, 1EBh
                        word    1ECh, 1ECh, 1ECh, 1EDh, 1EDh, 1EEh, 1EEh, 1EFh, 1EFh, 1F0h, 1F0h, 1F0h, 1F1h, 1F1h, 1F2h, 1F2h, 1F3h, 1F3h, 1F4h
                        word    1F4h, 1F5h, 1F5h, 1F5h, 1F6h, 1F6h, 1F7h, 1F7h, 1F8h, 1F8h, 1F9h, 1F9h, 1FAh, 1FAh, 1FAh, 1FBh, 1FBh, 1FCh, 1FCh
                        word    1FDh, 1FDh, 1FEh, 1FEh, 1FFh, 1FFh, 1FFh, 200h, 200h, 201h, 201h, 202h, 202h, 203h, 203h, 204h, 204h, 205h, 205h
                        word    206h, 206h, 206h, 207h, 207h, 208h, 208h, 209h, 209h, 20Ah, 20Ah, 20Bh, 20Bh, 20Ch, 20Ch, 20Dh, 20Dh, 20Eh, 20Eh
                        word    20Eh, 20Fh, 20Fh, 210h, 210h, 211h, 211h, 212h, 212h, 213h, 213h, 214h, 214h, 215h, 215h, 216h, 216h, 217h, 217h
                        word    218h, 218h, 219h, 219h, 21Ah, 21Ah, 21Ah, 21Bh, 21Bh, 21Ch, 21Ch, 21Dh, 21Dh, 21Eh, 21Eh, 21Fh, 21Fh, 220h, 220h
                        word    221h, 221h, 222h, 222h, 223h, 223h, 224h, 224h, 225h, 225h, 226h, 226h, 227h, 227h, 228h, 228h, 229h, 229h, 22Ah
                        word    22Ah, 22Bh, 22Bh, 22Ch, 22Ch, 22Dh, 22Dh, 22Eh, 22Eh, 22Fh, 22Fh, 230h, 230h, 231h, 231h, 232h, 232h, 233h, 233h
                        word    234h, 234h, 235h, 235h, 236h, 236h, 237h, 237h, 238h, 238h, 239h, 239h, 23Ah, 23Bh, 23Bh, 23Ch, 23Ch, 23Dh, 23Dh
                        word    23Eh, 23Eh, 23Fh, 23Fh, 240h, 240h, 241h, 241h, 242h, 242h, 243h, 243h, 244h, 244h, 245h, 245h, 246h, 246h, 247h
                        word    248h, 248h, 249h, 249h, 24Ah, 24Ah, 24Bh, 24Bh, 24Ch, 24Ch, 24Dh, 24Dh, 24Eh, 24Eh, 24Fh, 24Fh, 250h, 251h, 251h
                        word    252h, 252h, 253h, 253h, 254h, 254h, 255h, 255h, 256h, 256h, 257h, 258h, 258h, 259h, 259h, 25Ah, 25Ah, 25Bh, 25Bh
                        word    25Ch, 25Ch, 25Dh, 25Eh, 25Eh, 25Fh, 25Fh, 260h, 260h, 261h, 261h, 262h, 262h, 263h, 264h, 264h, 265h, 265h, 266h
                        word    266h, 267h, 267h, 268h, 269h, 269h, 26Ah, 26Ah, 26Bh, 26Bh, 26Ch, 26Ch, 26Dh, 26Eh, 26Eh, 26Fh, 26Fh, 270h, 270h
                        word    271h, 272h, 272h, 273h, 273h, 274h, 274h, 275h, 275h, 276h, 277h, 277h, 278h, 278h, 279h, 279h, 27Ah, 27Bh, 27Bh
                        word    27Ch, 27Ch, 27Dh, 27Dh, 27Eh, 27Fh, 27Fh, 280h, 280h, 281h, 282h, 282h, 283h, 283h, 284h, 284h, 285h, 286h, 286h
                        word    287h, 287h, 288h, 289h, 289h, 28Ah, 28Ah, 28Bh, 28Bh, 28Ch, 28Dh, 28Dh, 28Eh, 28Eh, 28Fh, 290h, 290h, 291h, 291h
                        word    292h, 293h, 293h, 294h, 294h, 295h, 296h, 296h, 297h, 297h, 298h, 299h, 299h, 29Ah, 29Ah, 29Bh, 29Ch, 29Ch, 29Dh
                        word    29Dh, 29Eh, 29Fh, 29Fh, 2A0h, 2A0h, 2A1h, 2A2h, 2A2h, 2A3h, 2A3h, 2A4h, 2A5h, 2A5h, 2A6h, 2A6h, 2A7h, 2A8h, 2A8h
                        word    2A9h, 2AAh, 2AAh, 2ABh, 2ABh, 2ACh, 2ADh, 2ADh
velocityTable           word    -16, -14, -12, -10, -8, -4, -2, 0, 1, 2, 3, 4, 5, 6, 7, 8

unknown                 proc
                        push    ax
                        pop     ax
                        ret
unknown                 endp

setVector               proc
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
                        ret
setVector               endp

getVector               proc
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
                        ret
getVector               endp

setPITPeriod            proc
                        mov     pitPeriod, ax
                        mov     al, 36h
                        out     43h, al
                        mov     al, byte ptr pitPeriod
                        out     40h, al
                        mov     al, ah
                        out     40h, al
                        ret
setPITPeriod            endp

writeOPL                proc
                        pushf
                        cli
                        push    ax
                        push    dx
                        push    cx
                        mov     dx, ioBase
                        xchg    ah, al
                        out     dx, al
                        mov     cx, indexDelay
@@:                     nop
                        dec     cx
                        or      cx, cx
                        jnz     @b
                        inc     dx
                        mov     al, ah
                        out     dx, al
                        mov     cx, dataDelay
@@:                     nop
                        dec     cx
                        or      cx, cx
                        jnz     @b
                        pop     cx
                        pop     dx
                        pop     ax
                        popf
                        ret
writeOPL                endp

silence                 proc
                        pushf
                        cli
                        mov     bx, maxVoice
                        dec     bx
voiceLoop:              mov     ah, 80h
                        add     ah, bl
                        mov     al, 13h
                        call    writeOPL
                        cmp     voiceMIDICh[bx], 7Fh
                        ja      @f
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
@@:                     dec     bl
                        jns     voiceLoop
                        and     valueBD, 0E0h
                        mov     al, valueBD
                        mov     ah, 0BDh
                        call    writeOPL
                        mov     ax, 90FFh
@@:                     call    writeOPL
                        inc     ah
                        cmp     ah, 95h
                        jbe     @b
                        popf
                        ret
silence                 endp

resetOperators          proc
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
voiceLoop:              mov     ax, 0BDC0h
                        call    writeOPL
                        mov     ax, 800h
                        call    writeOPL
                        mov     ah, [di]
                        mov     cx, 4
                        mov     si, offset silentTimbre
@@:                     add     ah, 20h
                        lodsb
                        call    writeOPL
                        add     ah, 3
                        lodsb
                        call    writeOPL
                        sub     ah, 3
                        loop    @b
                        add     ah, 60h
                        lodsb
                        call    writeOPL
                        add     ah, 3
                        lodsb
                        call    writeOPL
                        mov     ah, [di]        ; Nonsense! Should be 0C0h +bl
                        add     ah, bl
                        lodsb
                        call    writeOPL
                        inc     di
                        inc     bl
                        cmp     bl, 9
                        jb      voiceLoop
                        pop     si
                        pop     di
                        pop     es
                        ret
resetOperators          endp

setMarker               proc
                        push    ds
                        push    bx
                        lds     bx, ptrMarker
                        mov     [bx], al
                        pop     bx
                        pop     ds
                        ret
setMarker               endp

setVoiceTimbre          proc
                        push    es
                        push    cx
                        push    di
                        cmp     al, numTimbres
                        jb      @f
                        jmp     exit
@@:                     cbw
                        shl     ax, 1
                        shl     ax, 1
                        shl     ax, 1
                        shl     ax, 1
                        les     di, ptrTimbres
                        add     di, ax
                        mov     al, es:[di+3]
                        cmp     rhythmMode, 0
                        jz      @f
                        cmp     bl, 7
                        jb      @f
                        mov     al, es:[di+2]
@@:                     mov     ah, al
                        and     ax, 0C03Fh
                        mov     voiceTimbreKSL[bx], ah
                        sub     al, 3Fh
                        neg     al
                        mov     voiceTimbreVol[bx], al
                        mov     voiceTimbreScaledVol[bx], al
                        cmp     rhythmMode, 0
                        jz      @f
                        cmp     bx, 6
                        ja      percTimbre
@@:                     mov     ah, voice2Op[bx]
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
@@:                     add     ah, 20h
                        mov     al, es:[di]
                        inc     di
                        call    writeOPL
                        add     ah, 3
                        mov     al, es:[di]
                        inc     di
                        call    writeOPL
                        sub     ah, 3
                        loop    @b

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
                        jmp     exit
percTimbre:             mov     ah, (voice2OpPerc-6)[bx]
@@:                     add     ah, 20h
                        mov     al, es:[di]
                        inc     di
                        inc     di
                        call    writeOPL
                        add     ah, 20h
                        inc     di
                        inc     di
                        mov     cx, 2
@@:                     add     ah, 20h
                        mov     al, es:[di]
                        inc     di
                        inc     di
                        call    writeOPL
                        loop    @b
                        add     ah, 60h
                        mov     al, es:[di]
                        inc     di
                        inc     di
                        call    writeOPL
                        mov     ah, (voice2FMChPerc-6)[bx]
                        add     ah, 0C0h
                        mov     al, es:[di]
                        call    writeOPL
                        jmp     exit
exit:                   pop     di
                        pop     cx
                        pop     es
                        ret
setVoiceTimbre          endp

getVarLen               proc
                        push    si
                        push    bx
                        push    ds
                        sub     bx, bx
                        sub     dx, dx
                        lds     si, songPosition
nextByte:               lodsb
                        push    ax
                        and     al, 7Fh
                        cbw
                        add     bx, ax
                        adc     dx, 0
                        pop     ax
                        or      al, al
                        jns     done
                        mov     al, 7
@@:                     shl     bx, 1
                        rcl     dx, 1
                        dec     al
                        jnz     @b
                        jmp     nextByte
done:                   pop     ds
                        mov     ax, bx
                        mov     word ptr songPosition, si
                        pop     bx
                        pop     si
modify:                 cmp     byte ptr scratch+1, 0
                        jnz     exit
                        mov     byte ptr setPlayStatus+4, 1
exit:                   mov     byte ptr modify, 0C3h ; RET instruction. Removes the anti-tampering check from future invocations of getVarLen.
                        ret
getVarLen               endp

incrSongPosition        proc
                        push    cx
                        add     word ptr songPosition, ax
                        jnb     @f
                        add     word ptr songPosition+2, 1000h
@@:                     mov     cl, 4
                        mov     dh, dl
                        sub     dl, dl
                        shl     dx, cl
                        add     word ptr songPosition+2, dx
                        mov     si, word ptr songPosition
                        pop     cx
                        ret
incrSongPosition        endp

allocateVoice           proc
                        push    es
                        mov     cx, ds
                        mov     es, cx
                        mov     cx, maxVoice
                        mov     ah, al
                        or      al, 80h         ; find a free voice that previously played on the sane MIDI channel
                        mov     di, offset voiceMIDICh
                        repne   scasb
                        jz      done
                        mov     cx, maxVoice
                        mov     al, 0FFh        ; find a free voice that was not used at all, or has just had its timbre changed
                        mov     di, offset voiceMIDICh
                        repne   scasb
                        jz      done
                        mov     cx, maxVoice
                        mov     al, 7Fh         ; find any free voice
                        mov     di, offset voiceMIDICh
@@:                     cmp     al, [di]
                        jb      found
                        inc     di
                        loop    @b
                        jmp     noFreeVoice
found:                  inc     di
                        jmp     done
noFreeVoice:            push    si
                        sub     si, si          ; Steal the voice that has been playing the longest
                        mov     cx, maxVoice
                        mov     di, offset voiceEventCount
                        mov     ax, di
voiceLoop:              mov     dx, [di]
                        sub     dx, eventCounter
                        neg     dx
                        cmp     dx, si
                        jbe     @f
                        mov     si, dx
                        mov     ax, di
@@:                     inc     di
                        inc     di
                        dec     cx
                        jnz     voiceLoop
                        sub     ax, offset voiceEventCount
                        mov     bx, ax          ; Turn off the playing voice before reusing it for the new note
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
                        jmp     exit
done:                   sub     di, (offset voiceMIDICh+1)
                        mov     ax, di
exit:                   pop     es
                        ret
allocateVoice           endp

resetChannels           proc
                        mov     maxVoice, 9
                        mov     ax, 0C0h
                        mov     word ptr valueBD, ax
                        mov     ax, 0BDC0h
                        call    writeOPL
                        ret
resetChannels           endp

fnResetPlayer           proc
                        mov     loopCount, 0
                        mov     mainVolume, 0FFh
                        mov     targetVolume, 0FFh
                        call    stopPlaying
                        call    resetChannels
                        mov     cx, 16/2
                        mov     di, offset midiChMask
                        mov     ax, 101h
                        rep     stosw
                        mov     numTimbres, 16
                        mov     word ptr ptrTimbres, offset defaultTimbres
                        mov     word ptr ptrTimbres+2, ds
                        call    resetOperators
                        mov     playerPeriod, 1193182 /64
                        sub     ax, ax
                        mov     transpose, ax
                        ret
fnResetPlayer           endp

fnStartPlaying          proc
                        mov     cx, ax
                        mov     ax, -2
                        cmp     playStatus, 0
                        jnz     exit
                        mov     word ptr songData, cx
                        mov     word ptr songData+2, dx
                        mov     word ptr songPosition, cx
                        mov     word ptr songPosition+2, dx
                        mov     cx, 16
                        sub     ax, ax
                        mov     di, offset midiChBend
                        rep     stosw
                        mov     cx, 9
                        mov     al, 0FFh
                        mov     di, offset voiceMIDICh
                        rep     stosb
                        call    getVarLen
                        mov     word ptr waitInterval, ax
                        mov     word ptr waitInterval+2, dx
                        mov     dx, word ptr songPosition+2
                        mov     word ptr songSeekablePosition+2, dx
                        mov     ax, word ptr songPosition
                        mov     word ptr songSeekablePosition, ax
                        mov     eventCounter, 0
                        mov     ax, playerPeriod
                        call    setPITPeriod
                        mov     chainedCount, 0
                        call    resetChannels
                        pushf
                        cli
setPlayStatus::         mov     playStatus, 0   ; Actually 1; will be changed to that by some ridiculous anti-tampering code in getVarLen
                        mov     al, -1
                        call    setMarker
                        popf
                        sub     ax, ax
exit:                   ret
fnStartPlaying          endp

fnPausePlaying          proc
                        mov     ax, -3
                        cmp     playStatus, 1
                        jnz     exit
                        mov     playStatus, 2
                        call    silence
                        sub     ax, ax
exit:                   ret
fnPausePlaying          endp

fnContinuePlaying       proc
                        mov     ax, -4
                        cmp     playStatus, 2
                        jnz     exit
                        mov     playStatus, 1
                        sub     ax, ax
exit:                   ret
fnContinuePlaying       endp

doSongData              proc
                        push    es
                        inc     eventCounter
                        mov     ax, word ptr songPosition
                        shr     ax, 1
                        shr     ax, 1
                        shr     ax, 1
                        shr     ax, 1
                        add     word ptr songPosition+2, ax
                        and     word ptr songPosition, 0Fh
doEvent:                les     si, songPosition
                        mov     word ptr songSeekablePosition+2, es
                        mov     word ptr songSeekablePosition, si
                        mov     al, es:[si]
                        or      al, al
                        jns     @f
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
@@:                     mov     bx, midiCmd
                        shl     bx, 1
                        call    midiCmdTable[bx]
                        mov     word ptr songPosition, si
                        cmp     playStatus, 0
                        jz      checkLoop
                        call    getVarLen
                        mov     word ptr waitInterval, ax
                        mov     word ptr waitInterval+2, dx
                        or      ax, dx
                        jz      doEvent
                        sub     word ptr waitInterval, 1
                        sbb     word ptr waitInterval+2, 0
                        jmp     exit
checkLoop:              cmp     loopCount, 0
                        jz      exit
                        mov     ax, cs
                        mov     es, ax
                        mov     ax, word ptr songData
                        mov     dx, word ptr songData+2
                        call    fnStartPlaying
                        cmp     loopCount, -1
                        jz      exit
                        dec     loopCount
exit:                   pop     es
                        ret
doSongData              endp

midiNoteOff             proc
                        mov     ax, es:[si]
                        inc     si
                        inc     si
                        mov     midiKey, al
                        mov     midiVelocity, ah
doNoteOff::             push    es
                        mov     ax, ds
                        mov     es, ax
                        mov     cx, maxVoice
                        mov     ah, byte ptr midiCh
                        cmp     cl, 6
                        ja      melodicNote
                        cmp     ah, 11
                        jb      melodicNote
                        sub     bh, bh
                        mov     bl, ah
                        mov     al, midiCh2BDBit[bx-11]
                        not     al
                        and     al, valueBD
                        mov     valueBD, al
                        mov     ah, 0BDh
                        call    writeOPL
                        jmp     exit
melodicNote:            mov     al, midiKey
                        mov     di, offset voiceKey
keepSearching:          repne   scasb
                        jnz     exit
                        mov     bx, di
                        sub     bx, (offset voiceKey+1)
                        cmp     ah, voiceMIDICh[bx]
                        jz      found
                        jcxz    exit
                        jmp     keepSearching
found:                  or      voiceMIDICh[bx], 80h
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
                        ret
midiNoteOff             endp

isNoteOff               proc
                        jmp     doNoteOff
isNoteOff               endp

midiNoteOn              proc
                        mov     ax, es:[si]
                        inc     si
                        inc     si
                        mov     midiKey, al
                        mov     midiVelocity, ah
                        or      ah, ah
                        jz      isNoteOff
                        mov     al, byte ptr midiCh
                        mov     bl, al
                        sub     bh, bh
                        cmp     bh, midiChMask[bx]
                        jz      exit
                        cmp     rhythmMode, 0
                        jz      @f
                        cmp     al, 11
                        jb      @f
                        call    startPercNote
                        jmp     exit
@@:                     call    allocateVoice
                        mov     bx, ax
                        mov     al, byte ptr midiCh
                        xchg    al, voiceMIDICh[bx]
                        and     al, 7Fh
                        cmp     al, byte ptr midiCh
                        jz      @f
                        mov     di, midiCh
                        mov     al, midiChProgram[di]
                        call    setVoiceTimbre
@@:                     ; Convert the MIDI velocity value from linear to log (very roughly)
                        push    di
                        mov     cl, midiVelocity
                        sub     ch, ch
                        mov     di, cx
                        shr     di, 1 ; 0-127 -> 0-15
                        shr     di, 1
                        shr     di, 1
                        adc     di, 0
                        shl     di, 1 ; WORD elements
                        mov     cx, velocityTable[di]
                        pop     di
                        mov     al, voiceTimbreScaledVol[bx]
                        cbw     ; Add velocity to timbre's volume value. This is correct since we are dealing with logarithmic volume values.
                        add     ax, cx
                        jns     @f
                        sub     ax, ax
                        jmp     gotVolume
@@:                     cmp     ax, 63
                        jbe     gotVolume
                        mov     ax, 63
gotVolume:              sub     al, 63
                        neg     al
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
exit:                   ret
midiNoteOn              endp

startPercNote           proc
                        sub     al, 5
                        cbw
                        mov     bx, ax
                        mov     al, (MIDICH2BDBit-6)[bx]
                        or      valueBD, al
                        push    di
                        mov     cl, midiVelocity
                        sub     ch, ch
                        mov     di, cx
                        shr     di, 1
                        shr     di, 1
                        shr     di, 1
                        adc     di, 0
                        shl     di, 1
                        mov     cx, velocityTable[di]
                        pop     di
                        mov     al, voiceTimbreScaledVol[bx]
                        sub     ah, ah
                        add     ax, cx
                        jns     @f
                        sub     ax, ax
                        jmp     gotVolume
@@:                     cmp     ax, 63
                        jbe     gotVolume
                        mov     al, 63
gotVolume:              sub     al, 3Fh
                        neg     al
                        or      al, voiceTimbreKSL[bx]
                        mov     ah, (voice2OpPerc-6)[bx]
                        cmp     bl, 6
                        jnz     @f
                        add     ah, 3
@@:                     add     ah, 40h
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
                        ret
startPercNote           endp

startMelodicNote        proc
                        mov     al, midiKey
                        mov     voiceKey[bx], al
                        cbw
                        mov     di, transpose
                        add     di, ax
                        jns     @f
                        sub     di, di
                        jmp     keyOk
@@:                     cmp     di, 128
                        jb      keyOk
                        mov     di, 127
keyOk:                  mov     al, key2FIndex[di]
                        mov     voiceFIndex[bx], al
                        call    setVoiceFNum
                        ret
startMelodicNote        endp

setVoiceFNum            proc
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
                        jns     @f
                        add     ax, 768
                        sub     dl, 4
                        jns     indexOk
                        sub     dl, dl
                        sub     ax, ax
                        jmp     indexOk
@@:                     cmp     ax, 768
                        jb      indexOk
                        sub     ax, 768
                        add     dl, 4
                        cmp     dl, 28
                        jbe     indexOk
                        mov     ax, 767
                        mov     dl, 28
indexOk:                shl     ax, 1
                        mov     di, ax
                        mov     ax, FIndex2FNum[di]
                        or      ah, dl
                        shl     bx, 1
                        mov     voiceFNum[bx], ax
                        mov     cx, eventCounter
                        mov     voiceEventCount[bx], cx
                        shr     bx, 1
                        ret
setVoiceFNum            endp

midiControl             proc
                        mov     ax, es:[si]
                        inc     si
                        inc     si
                        sub     al, 102
                        cmp     al, 4
                        jnb     exit
                        mov     bl, al
                        sub     bh, bh
                        shl     bx, 1
                        call    midiControlTable[bx]
exit:                   ret
midiControl             endp

ctrlMarker              proc
                        mov     al, ah
                        call    setMarker
                        ret
ctrlMarker              endp

ctrlSetRhythmMode       proc
                        push    ax
                        call    resetOperators
                        pop     ax
                        mov     cx, 9C0h
                        mov     rhythmMode, ah
                        or      ah, ah
                        jz      @f
                        mov     cx, 6E0h
@@:                     mov     valueBD, cl
                        mov     byte ptr maxVoice, ch
                        mov     al, valueBD
                        mov     ah, 0BDh
                        call    writeOPL
                        ret
ctrlSetRhythmMode       endp

ctrlBendDown            proc
                        neg     ah
ctrlBendDown            endp

ctrlBendUp              proc
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
@@:                     repne   scasb
                        jnz     exit
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
                        jnz     @b
exit:                   pop     es
                        ret
ctrlBendUp              endp

midiIgnore2             proc
                        inc     si
midiIgnore2             endp

midiIgnore1             proc
                        inc     si
midiIgnore1             endp

midiIgnore0             proc
                        ret
midiIgnore0             endp

midiProgCh              proc
                        mov     al, es:[si]
                        inc     si
@@:                     cmp     al, numTimbres
                        jb      @f
                        sub     al, numTimbres
                        jmp     @b

@@:                     mov     bx, midiCh
                        add     bx, offset midiChProgram
                        mov     [bx], al
                        push    es
                        mov     ax, ds
                        mov     es, ax
                        cmp     rhythmMode, 0
                        jz      melodic
                        cmp     midiCh, 11
                        jb      melodic
                        mov     bx, midiCh
                        mov     al, midiChProgram[bx]
                        sub     bl, 5
                        call    setVoiceTimbre
                        jmp     exit
melodic:
                        ; Set the MIDI Channel of all free voices on this channel to FF so they no longer get preferential treatment when allocating a voice on this MIDI channel.
                        mov     cx, maxVoice
                        mov     al, byte ptr midiCh
                        or      al, 80h
                        mov     di, offset voiceMIDICh
@@:                     repne   scasb
                        jnz     @f
                        mov     byte ptr [di-1], 0FFh
                        or      cx, cx
                        jnz     @b
@@:                     ; Update the timbre of all voices playing on that MIDI channel.
                        mov     cx, maxVoice
                        mov     di, offset voiceMIDICh
@@:                     mov     al, byte ptr midiCh
                        repne scasb
                        jnz     exit
                        mov     bx, midiCh
                        mov     al, midiChProgram[bx]
                        mov     bx, di
                        sub     bx, (offset voiceMIDICh+1)
                        call    setVoiceTimbre
                        or      cx, cx
                        jnz     @b
exit:                   pop     es
                        ret
midiProgCh              endp

midiSpecial             proc
                        mov     bl, byte ptr midiCh
                        sub     bh, bh
                        shl     bx, 1
                        call    midiSpecialTable[bx]
                        ret
midiSpecial             endp

midiSysex               proc
                        mov     word ptr songPosition, si
                        cmp     word ptr ptrSysexHandler+2, 0
                        jz      @f
                        call    ptrSysexHandler
@@:                     call    getVarLen
                        call    incrSongPosition
                        ret
midiSysex               endp

midiSysexContd          proc
                        mov     word ptr songPosition, si
                        call    getVarLen
                        call    incrSongPosition
                        ret
midiSysexContd          endp

midiSpecialStop         proc
                        call    stopPlaying
                        ret
midiSpecialStop         endp

midiMeta                proc
                        mov     al, es:[si]
                        inc     si
                        cmp     al, 2Fh
                        jnz     @f
                        call    stopPlaying
@@:                     mov     word ptr songPosition, si
                        call    getVarLen
                        call    incrSongPosition
                        ret
midiMeta                endp

isr08                   proc far
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
                        jnz     keepWaiting
                        mov     ax, word ptr mainVolume
                        cmp     al, ah  ; Note: MASM 6.0 uses a different opcode encoding than original
                        jz      @f
                        dec     fadeCount
                        jnz     @f
                        mov     cx, fadePeriod
                        mov     fadeCount, cx
                        call    doFade
@@:                     sub     word ptr waitInterval, 1
                        sbb     word ptr waitInterval+2, 0
                        jnb     keepWaiting
                        mov     word ptr callerStack+2, ss
                        mov     word ptr callerStack, sp
                        cli
                        mov     ax, cs
                        mov     ss, ax
                        mov     sp, (offset endResidentCode +STACK_SIZE)
                        cld
                        call    doSongData
                        mov     ss, word ptr callerStack+2
                        mov     sp, word ptr callerStack
keepWaiting:            mov     cx, chainedPeriod
                        mov     ax, pitPeriod
                        add     chainedCumulative, ax
                        add     chainedCount, ax
                        jb      @f
                        cmp     chainedCount, cx
                        jb      done
@@:                     sub     chainedCount, cx
                        pushf
                        call    chainedVector08
                        cmp     chainedCount, cx
                        ja      @b
                        jmp     exit
done:                   mov     al, 20h
                        out     20h, al
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

isr09                   proc
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
                        in      al, 60h
                        or      al, al
                        js      @f
                        cmp     al, 53h
                        jnz     @f
                        mov     ah, 2
                        int     16h
                        and     al, 0Ch
                        cmp     al, 0Ch
                        jnz     @f
                        call    silence
@@:                     pop     bp
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
                        push    cx              ; envp
                        push    dx
                        push    di              ; argv
                        push    si
                        push    bp              ; argc
                        mov     bp, sp
                        mov     ax, cs
                        mov     ds, ax
                        mov     es, ax
                        mov     ax, [bp+callerAX]
                        cmp     driverActive, 0
                        jnz     alreadyActive
                        mov     driverActive, 1
                        sti
                        cld
                        mov     word ptr [bp+callerAX], -1
                        or      bx, bx
                        js      internalFN
                        cmp     bx, word ptr MAX_FN
                        jnb     done
                        shl     bx, 1
                        call    fnTable[bx]
                        mov     [bp+callerAX], ax
                        jmp     done
internalFN:             not     bx
                        cmp     bx, word ptr MAX_FN_INTERNAL
                        jnb     done
                        shl     bx, 1
                        call    fnTableInternal[bx]
                        mov     [bp+callerAX], ax
                        jmp     done
done:                   mov     driverActive, 0
                        jmp     exit
alreadyActive:          mov     word ptr [bp+callerAX], -8
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
isrDriver               endp

fnGetVersion            proc
                        mov     ax, internalVersion
                        ret
fnGetVersion            endp

fnSetMarkerPtr          proc
                        xchg    dx, word ptr ptrMarker+2
                        xchg    ax, word ptr ptrMarker
                        mov     [bp+6], dx
                        push    ax
                        sub     ax, ax
                        call    setMarker
                        pop     ax
                        ret
fnSetMarkerPtr          endp

fnSetTimbrePtr          proc
                        mov     numTimbres, cl
                        mov     word ptr ptrTimbres+2, dx
                        mov     word ptr ptrTimbres, ax
                        call    resetChannels
                        call    resetOperators
                        sub     ax, ax
                        ret
fnSetTimbrePtr          endp

stopPlaying             proc
                        cmp     playStatus, 0
                        jz      exit
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
exit:                   ret
stopPlaying             endp

fnStopPlaying           proc
                        mov     ax, -3
                        cmp     playStatus, 0
                        jz      exit
                        call    stopPlaying
                        sub     ax, ax
exit:                   ret
fnStopPlaying           endp

fnSetChainedPeriod      proc
                        mov     chainedPeriod, ax
                        ret
fnSetChainedPeriod      endp

fnSetPlayerPeriod       proc
                        mov     playerPeriod, ax
                        call    setPITPeriod
                        sub     ax, ax
                        ret
fnSetPlayerPeriod       endp

fnSetTranspose          proc
                        mov     transpose, ax
                        sub     ax, ax
                        ret
fnSetTranspose          endp

fnSetSysexHandler       proc
                        pushf
                        cli
                        mov     word ptr ptrSysexHandler+2, dx
                        mov     word ptr ptrSysexHandler, ax
                        sub     ax, ax
                        popf
                        ret
fnSetSysexHandler       endp

fnGetChMaskPtr          proc
                        mov     word ptr [bp+6], cs
                        mov     ax, offset midiChMask
                        ret
fnGetChMaskPtr          endp

fnGetSongPosition       proc
                        pushf
                        cli
                        mov     dx, word ptr songSeekablePosition+2
                        mov     ax, word ptr songSeekablePosition
                        mov     [bp+6], dx
                        popf
                        ret
fnGetSongPosition       endp

fnSetFade               proc
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
                        cmp     ax, -1
                        jnz     @f
                        mov     al, mainVolume
                        jmp     gotVolumes
@@:                     call    trimFadeVal
                        mov     ah, 100
                        call    calcFadeParam
gotVolumes:             mov     mainVolume, al
                        mov     targetVolume, al
                        sti
                        mov     cx, 11
                        mov     di, offset voiceTimbreScaledVol
                        mov     si, offset voiceTimbreVol
                        mov     dl, al
@@:                     lodsb
                        mul     dl
                        add     al, al
                        adc     ah, 0
                        mov     al, ah
                        stosb
                        loop    @b
                        pop     ax
                        call    trimFadeVal
                        mov     ah, 100
                        call    calcFadeParam
                        mov     targetVolume, al
                        ret
fnSetFade               endp

fnSetLoopCount          proc
                        xchg    ax, loopCount
                        ret
fnSetLoopCount          endp


fnGetChainedVector      proc
                        cbw
                        mov     bx, ax
                        shl     bx, 1
                        shl     bx, 1
                        mov     ax, word ptr chainedVector08[bx]
                        mov     dx, word ptr (chainedVector08+2)[bx]
                        mov     [bp+6], dx
                        ret
fnGetChainedVector      endp

fnGetChainedCount       proc
                        mov     ax, offset chainedCumulative
                        mov     word ptr [bp+6], cs
                        ret
fnGetChainedCount       endp

fnGetActivePtr          proc
                        mov     word ptr [bp+6], cs
                        mov     ax, offset driverActive
                        ret
fnGetActivePtr          endp

fnSetChainedVector      proc
                        sub     ch, ch
                        mov     bx, cx
                        shl     bx, 1
                        shl     bx, 1
                        cli
                        mov     word ptr chainedVector08[bx], ax
                        mov     word ptr (chainedVector08+2)[bx], dx
                        sti
                        ret
fnSetChainedVector      endp

fnGetStatusPtr          proc
                        mov     dx, cs
                        mov     word ptr [bp+6], cs
                        mov     ax, offset playStatus
                        ret
fnGetStatusPtr          endp


trimFadeVal             proc
                        or      ax, ax
                        jns     @f
                        sub     ax, ax
                        jmp     exit
@@:                     cmp     ax, 100
                        jb      exit
                        mov     ax, 99
exit:                   ret
trimFadeVal             endp

calcFadeParam           proc
                        push    cx
                        push    dx
                        mov     dh, ah
                        sub     ah, ah
                        div     dh
                        xchg    al, ah
                        sub     dl, dl
                        mov     cx, 8
bitLoop:                shl     dl, 1
                        shl     al, 1
                        jb      @f
                        cmp     al, dh
                        jb      next
@@:                     or      dl, 1
                        sub     al, dh
next:                   loop    bitLoop
                        shl     al, 1
                        adc     dl, 0
                        mov     al, dl
                        pop     dx
                        pop     cx
                        ret
calcFadeParam           endp

doFade                  proc
                        mov     cl, fadeDelta
                        mov     ax, word ptr mainVolume
                        cmp     al, ah  ; Note: MASM 6.0 uses a different opcode encoding than original
                        jb      increase
                        sub     al, cl
                        jnb     done
                        jmp     trim
increase:               add     al, cl
                        jnb     done
trim:                   mov     al, ah
done:                   mov     mainVolume, al
                        mov     dl, al
                        mov     si, offset voiceTimbreVol
                        mov     di, offset voiceTimbreScaledVol
                        mov     cx, 11
@@:                     lodsb
                        mul     dl
                        add     al, al
                        adc     ah, 0
                        mov     al, ah
                        stosb
                        loop    @b
                        ret
doFade                  endp

                        byte    0F1h                     ; Anti-tampering --- set to get the checksum at $0101 to $00.

endResidentCode         label   byte
mTitle                  byte    'Creative Sound Blaster FM-Driver  Version 1.34',0Dh,0Ah
                        byte    'Copyright (c) Creative Labs, Inc.,  1990-1993.  All rights reserved.',0Dh,0Ah
                        byte    'Copyright (c) Creative Technology Ltd,  1990-1993.  All rights reserved.',0Dh,0Ah
                        byte    0Ah
                        byte    9,'SB 1.5 / SB 2.0 / MCV 2.0',0
mCRLF                   byte    0Dh,0Ah,'$'
mAlready                byte    'Driver already installed.$'
mIOAddress              byte    0Dh,0Ah,"Driver's I/O address set at "
mIOAddressValue         byte    '220 Hex',0Dh,0Ah,'$'
mInstalled              byte    'Driver installed at INT '
mInstalledValue         byte    '00H.',0Dh,0Ah,'$'
mRemoved                byte    0Dh,0Ah,'Driver removed.$'
mSBFMDRV                byte    0Dh,0Ah,'SBFMDRV: $'
mError0                 byte    'Error 0000: Unknown command switch.$'
mError1                 byte    'Error 0001: SB 1.5 / SB 2.0 / MCV 2.0  does not exist at the I/O address specified.$'
mError2                 byte    'Error 0002: FM feature not available on the card.$'
mError3                 byte    'Error 0003: No interrupt vector available.$'
mError4                 byte    'Error 0004: Driver does not install previously.$'
mError5                 byte    'Error 0005: Other program exist after SBFMDRV.$'
mError6                 byte    'Error 0006: BLASTER environment string does not exist.$'
mProductName            byte    "SB 1.5 / SB 2.0 / MCV 2.0",0
cmdTable                word    offset cmdInstall
                        word    offset cmdUninstall

waitOPLTimer            proc
                        push    cx
                        push    dx
                        mov     cx, 40h
                        mov     ah, al
                        and     ah, 0E0h
                        mov     dx, ioBase
@@:                     in      al, dx
                        and     al, 0E0h
                        cmp     ah, al  ; Note: MASM 6.0 uses a different opcode encoding than original
                        jz      @f
                        loop    @b
                        stc
                        jmp     exit
@@:                     clc
exit:                   pop     dx
                        pop     cx
                        ret
waitOPLTimer            endp

detectOPL               proc
                        mov     ax, 100h
                        call    writeOPL
                        mov     ax, 460h
                        call    writeOPL
                        mov     ax, 480h
                        call    writeOPL
                        mov     al, 0
                        call    waitOPLTimer
                        jb      exit
                        mov     ax, 2FFh
                        call    writeOPL
                        mov     ax, 421h
                        call    writeOPL
                        mov     al, 0C0h
                        call    waitOPLTimer
                        jb      exit
                        mov     ax, 460h
                        call    writeOPL
                        mov     ax, 480h
                        call    writeOPL
                        clc
exit:                   ret
detectOPL               endp

isr08Measure            proc far
                        not     ax
                        push    ax
                        mov     al, 20h
                        out     20h, al
                        pop     ax
                        iret
isr08Measure            endp

measureTiming           proc
                        mov     bx, 8
                        call    getVector
                        mov     word ptr chainedVector08, ax
                        mov     word ptr chainedVector08+2, dx
                        cli
                        in      al, 21h
                        mov     indexDelay, ax
                        mov     al, 0FEh
                        out     21h, al
                        mov     ax, 7000
                        call    setPITPeriod
                        mov     bx, 8
                        mov     dx, cs
                        mov     ax, offset isr08Measure
                        call    setVector
                        sub     ax, ax
                        sub     cx, cx
                        sti
@@:                     or      ax, ax
                        jz      @b
@@:                     or      ax, ax
                        jnz     @b
@@:                     nop
                        inc     cx
                        or      ax, ax
                        jz      @b
                        cli
                        mov     ax, indexDelay
                        out     21h, al
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
                        cmp     ax, 80
                        jnb     @f
                        mov     ax, 64
@@:                     mov     indexDelay, ax
                        mov     cx, ax
                        shl     ax, 1
                        add     cx, ax
                        shl     ax, 1
                        add     cx, ax
                        mov     dataDelay, cx
                        add     ioBase, 8

                        ; Checksum calculation for some silly anti-tamper protection.
                        mov     cx, offset endResidentCode -offset midiCmdTable
                        mov     si, offset midiCmdTable
                        sub     ah, ah
@@:                     lodsb
                        add     ah, al
                        loop    @b
                        sub     ah, vectorNum
                        add     ah, 80h
                        mov     word ptr scratch, ax
                        ret
measureTiming           endp

readDSPbyte             proc
                        push    cx
                        push    dx
                        mov     dx, ioBase
                        and     dl, 0F0h
                        add     dl, 0Eh
                        mov     cx, 512
@@:                     in      al, dx
                        or      al, al
                        js      @f
                        loop    @b
                        stc
                        jmp     exit
@@:                     sub     dl, 4
                        in      al, dx
                        clc
exit:
                        pop     dx
                        pop     cx
                        ret
readDSPbyte             endp

writeDSPcommand         proc
                        push    cx
                        push    dx
                        mov     dx, ioBase
                        and     dl, 0F0h
                        add     dl, 0Ch
                        mov     cx, 512
                        mov     ah, al
@@:                     in      al, dx
                        or      al, al
                        jns     @f
                        loop    @b
                        stc
                        jmp     exit
@@:                     mov     al, ah
                        out     dx, al
                        clc
exit:                   pop     dx
                        pop     cx
                        ret
writeDSPcommand         endp

resetDSP                proc
                        mov     dx, ioBase
                        add     dl, 0Ch
                        mov     al, DSP_DISABLE_SPEAKER
                        call    writeDSPcommand
                        mov     cx, 65535
@@:                     loop    @b
                        mov     dx, ioBase
                        add     dl, 6
                        mov     al, 1
                        out     dx, al
                        sub     al, al
@@:                     dec     al
                        jnz     @b
                        out     dx, al
                        mov     cx, 32
readLoop:               call    readDSPbyte
                        jb      @f
                        cmp     al, 0AAh
                        jnz     @f
                        jmp     exit
@@:                     loop    readLoop
                        stc
exit:                   ret
resetDSP                endp

parseCommandLine        proc
                        mov     si, 81h
@@:                     lodsb
                        cmp     al, ' '
                        jz      @b
                        cmp     al, 13
                        jz      done
                        cmp     al, '/'
                        jnz     unknownCommand
                        lodsb
                        cmp     al, 'a'
                        jb      @f
                        cmp     al, 'z'
                        ja      @f
                        sub     al, ' '
@@:                     cmp     al, 'U'
                        jnz     unknownCommand
                        mov     ax, CMD_UNINSTALL
                        jmp     exit
unknownCommand:         mov     dx, offset mSBFMDRV
                        mov     ah, DOS_PRINT_STRING
                        int     21h
                        mov     dx, offset mError0      ; Unknown command switch
                        mov     ah, DOS_PRINT_STRING
                        int     21h
                        sub     ax, ax
                        jmp     exit
done:                   mov     ax, CMD_INSTALL
exit:                   ret
parseCommandLine        endp

main                    proc
                        mov     dx, offset mTitle
                        mov     ah, DOS_PRINT_STRING
                        int     21h
                        call    parseEnv
                        or      ax, ax
                        jz      gotEnv
                        mov     dx, offset mError6
                        mov     ah, DOS_PRINT_STRING
                        int     21h
                        jmp     @f
gotEnv:                 call    parseCommandLine
                        or      ax, ax
                        jz      @f
                        mov     bx, ax
                        dec     bx
                        shl     bx, 1
                        call    cmdTable[bx]
@@:                     mov     dx, offset mCRLF
                        mov     ah, DOS_PRINT_STRING
                        int     21h
                        mov     dx, (offset endResidentCode +STACK_SIZE +15) ; +15 to round up when shifting right by four bits
                        mov     cl, 4
                        shr     dx, cl
exitService::           mov     ax, (DOS_TERMINATE SHL 8) +0
                        int     21h
main                    endp

initPlayer              proc
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
                        ret
initPlayer              endp

findUsedVector          proc
                        mov     bx, 80h
vectorLoop:             push    bx
                        call    getVector
                        pop     bx
                        or      dx, dx
                        jnz     vectorUsed
nextVector:             inc     bx
                        cmp     bx, 0C0h
                        jb      vectorLoop
                        sub     ax, ax
                        jmp     exit
vectorUsed:             mov     es, dx
                        mov     si, offset signature
                        mov     di, si
                        mov     cx, 6
                        repe cmpsb
                        mov     ax, ds
                        mov     es, ax
                        jnz     nextVector
                        mov     ax, dx
exit:                   ret
findUsedVector          endp

initCard                proc
                        call    resetDSP
                        jb      @f
                        mov     al, DSP_INVERT_BYTE
                        call    writeDSPcommand
                        jb      @f
                        mov     al, 55h
                        call    writeDSPcommand
                        jb      @f
                        call    readDSPbyte
                        jb      @f
                        cmp     al, 0AAh
                        jz      okay
@@:                     mov     dx, offset mSBFMDRV
                        mov     ah, DOS_PRINT_STRING
                        int     21h
                        mov     dx, offset mError1      ; Sound Blaster Card not found at I/O address
                        mov     ah, DOS_PRINT_STRING
                        int     21h
                        stc
                        jmp     exit
okay:                   mov     al, DSP_WRITE_TEST_REGISTER
                        call    writeDSPcommand

                        ; The test register will be read later, and its content will be used to change DOS function 4Ch to 31h to stay resident.
                        ; Utterly ridiculous attempt at preventing competing card manufacturers from making their products compatible with SBFMDRV.
                        mov     al, DOS_TERMINATE -DOS_STAY_RESIDENT
                        call    writeDSPcommand
                        call    measureTiming
                        call    detectOPL
                        jnb     exit
                        mov     dx, offset mSBFMDRV
                        mov     ah, DOS_PRINT_STRING
                        int     21h
                        mov     dx, offset mError2      ; Card has no FM chip
                        mov     ah, DOS_PRINT_STRING
                        int     21h
                        stc
exit:                   ret
initCard                endp

; Walk the MCB chain to see if the loaded driver can be unloaded. Why? AH=49 will signal an error by itself if the program cannot be unloaded.
walkMCB                 proc
                        mov     ax, word ptr scratch
                        dec     ax
                        mov     dx, cs
                        sub     bx, bx
mcbLoop:                mov     es, ax
                        add     ax, es:[bx+3]
                        inc     ax
                        mov     es, ax
                        cmp     es:[bx+1], dx
                        jz      @f
                        cmp     word ptr es:[bx+1], 0
                        jz      mcbLoop
                        stc
                        jmp     exit
@@:                     push    ax
                        inc     ax
                        cmp     ax, dx
                        pop     ax
                        jnz     mcbLoop
                        clc
exit:                   mov     ax, ds
                        mov     es, ax
                        ret
walkMCB                 endp

makeResident            proc
                        mov     bx, 80h         ; first possible vector number
@@:
                        push    bx
                        call    getVector
                        pop     bx
                        or      dx, ax
                        jz      @f
                        inc     bx
                        cmp     bx, 0C0h
                        jb      @b
                        mov     dx, offset mSBFMDRV
                        mov     ah, DOS_PRINT_STRING
                        int     21h
                        mov     dx, offset mError3      ; No interrupt vector available
                        mov     ah, DOS_PRINT_STRING
                        int     21h
                        stc
                        jmp     exit
@@:                     mov     vectorNum, bl
                        and     bl, 0Fh
                        add     byte ptr mInstalledValue+1, bl
                        mov     bl, vectorNum
                        mov     cl, 4
                        shr     bl, cl
                        add     byte ptr mInstalledValue, bl
                        mov     dx, offset mInstalled
                        mov     ah, DOS_PRINT_STRING
                        int     21h
                        mov     bl, vectorNum
                        sub     bh, bh
                        mov     dx, cs
                        mov     ax, offset isrDriver
                        call    setVector
                        mov     al, DSP_READ_TEST_REGISTER
                        call    writeDSPcommand
                        call    readDSPbyte
                        sub     byte ptr exitService+2, al
                        clc
exit:                   ret
makeResident            endp

setVectors8and9         proc
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
                        ret
setVectors8and9         endp

cmdInstall              proc
                        pushf
                        push    si
                        push    dx
                        std
                        mov     cx, 3
                        mov     di, offset mIOAddressValue
                        add     di, 2
                        mov     ax, ioBase
digitLoop:              push    ax
                        and     ax, 0Fh
                        cmp     ax, 9
                        jg      @f
                        add     al, '0'
                        jmp     gotASC
@@:                     add     al, 38h
gotASC:                 stosb
                        pop     ax
                        shr     ax, 1
                        shr     ax, 1
                        shr     ax, 1
                        shr     ax, 1
                        loop    digitLoop
                        pop     dx
                        pop     si
                        popf
                        mov     dx, offset mIOAddress
                        mov     ah, DOS_PRINT_STRING
                        int     21h
                        call    findUsedVector
                        or      ax, ax
                        jz      @f
                        mov     dx, offset mAlready
                        mov     ah, DOS_PRINT_STRING
                        int     21h
                        jmp     exit
@@:                     call    initCard
                        jb      exit
                        call    makeResident
                        jb      exit
                        call    initPlayer
                        call    setVectors8and9
                        mov     bx, 4           ; Close STDxxx file handles
@@:                     push    bx
                        mov     ah, 3Eh
                        int     21h
                        pop     bx
                        dec     bx
                        jns     @b
                        mov     bx, 2Ch         ; Free environment variable block
                        mov     es, word ptr [bx]
                        mov     ah, DOS_FREE_MEMORY
                        int     21h
                        mov     word ptr [bx], 0
                        mov     ax, ds
                        mov     es, ax
exit:                   ret
cmdInstall              endp

callDriver              proc
                        int     80h
                        ret
callDriver              endp

cmdUninstall            proc
                        call    findUsedVector
                        or      ax, ax
                        jnz     found
                        mov     dx, offset mSBFMDRV
                        mov     ah, DOS_PRINT_STRING
                        int     21h
                        mov     dx, offset mError4      ; Driver not installed -- cannot remove.
                        mov     ah, DOS_PRINT_STRING
                        int     21h
                        jmp     exit
found:                  mov     word ptr scratch, ax
                        mov     es, ax
                        mov     al, es:vectorNum
                        mov     byte ptr callDriver+1, al
                        mov     ax, ds
                        mov     es, ax
                        call    walkMCB
                        jnb     @f
                        mov     dx, offset mSBFMDRV
                        mov     ah, DOS_PRINT_STRING
                        int     21h
                        mov     dx, offset mError5      ; Cannot unload driver; another program was loaded afterwards.
                        mov     ah, DOS_PRINT_STRING
                        int     21h
                        jmp     exit
@@:                     sub     al, al
                        mov     bx, FN_GET_CHAINED_VECTOR
                        call    callDriver
                        mov     bx, 8
                        call    setVector
                        mov     al, 1
                        mov     bx, FN_GET_CHAINED_VECTOR
                        call    callDriver
                        mov     bx, 9
                        call    setVector
                        sub     dx, dx
                        sub     ax, ax
                        mov     bl, byte ptr callDriver+1
                        sub     bh, bh
                        call    setVector
                        mov     es, word ptr scratch
                        mov     ah, DOS_FREE_MEMORY
                        int     21h
                        mov     dx, offset mRemoved
                        mov     ah, DOS_PRINT_STRING
                        int     21h
exit:                   ret
cmdUninstall            endp

parseEnv                proc
                        push    es
                        push    di
                        push    si
                        mov     dx, cs
                        mov     ax, offset sBlaster
                        call    findEnvVar
                        push    ds
                        push    dx
                        mov     ds, dx
                        mov     dx, ax
                        call    upperCase
                        pop     dx
                        pop     ds
                        mov     di, 1
                        or      dx, dx
                        jz      exit
                        mov     es, dx
                        mov     si, ax
                        mov     di, 1
                        mov     al, 'A'
                        call    checkEnvParam
                        jb      exit
                        mov     bx, ax
                        call    readHexNumber
                        jb      exit
                        cmp     ah, 2
                        jnz     exit
                        and     al, 0F0h
                        cmp     al, 80h
                        ja      exit
                        cmp     al, 20h
                        jb      exit
                        test    al, 10h
                        jnz     exit
                        mov     ioBase, ax
                        sub     di, di
exit:                   mov     ax, di
                        pop     si
                        pop     di
                        pop     es
                        ret
parseEnv                endp

sBlaster                byte    "BLASTER", 0

upperCase               proc
                        push    si
                        push    ax
                        mov     si, dx
charLoop:               lodsb
                        cmp     al, 60h
                        jb      @f
                        sub     al, 20h
                        mov     [si-1], al
@@:                     or      al, al
                        jnz     charLoop
                        pop     ax
                        pop     si
                        ret
upperCase               endp

checkEnvParam           proc
                        push    ds
                        push    si
                        push    es
                        pop     ds
                        mov     ah, al
charLoop:               lodsb
                        or      al, al
                        jz      fail
                        cmp     al, 'a'
                        jb      @f
                        cmp     al, 'z'
                        ja      @f
                        sub     al, ' '
@@:                     cmp     al, ah  ; Note: MASM 6.0 uses a different opcode encoding than original
                        jnz     charLoop
                        mov     ax, si
                        clc
                        jmp     exit
fail:                   stc
exit:                   pop     si
                        pop     ds
                        ret
checkEnvParam           endp

readHexNumber           proc
                        sub     dx, dx
                        mov     al, es:[bx]
                        inc     bx
                        cmp     al, ' '
                        jz      fail
                        cmp     al, 0
                        jz      fail
digitLoop:              mov     cl, 4
                        shl     dx, cl
                        cmp     al, '0'
                        jb      @f
                        cmp     al, '9'
                        ja      @f
                        sub     al, '0'
                        or      dl, al
                        jmp     next
@@:                     cmp     al, 'a'
                        jb      @f
                        cmp     al, 'z'
                        ja      @f
                        sub     al, 'a'
@@:                     cmp     al, 'A'
                        jb      fail
                        cmp     al, 'F'
                        ja      fail
                        sub     al, '7'
                        or      dl, al
next:                   mov     al, es:[bx]
                        inc     bx
                        cmp     al, ' '
                        jz      @f
                        or      al, al
                        jnz     digitLoop
@@:                     mov     ax, dx
                        jmp     exit
fail:                   stc
exit:                   ret
readHexNumber           endp

findEnvVar              proc
                        push    ds
                        push    es
                        push    di
                        push    si
                        mov     es, dx
                        mov     di, ax
                        mov     ah, DOS_GET_PSP
                        int     21h
                        mov     ax, bx
                        or      ax, ax
                        jz      fail
                        mov     ds, ax
                        mov     bx, 2Ch         ; Get environment block segment
                        mov     ds, word ptr [bx]
                        sub     si, si
                        mov     bx, di
nextVar:                mov     di, bx
                        mov     ah, es:[di]
@@:                     lodsb
                        cmp     ah, al  ; Note: MASM 6.0 uses a different opcode encoding than original
                        jnz     skipVar
                        inc     di
                        mov     ah, es:[di]
                        or      ah, ah
                        jnz     @b
@@:                     lodsb
                        cmp     al, ' '
                        jz      @b
                        cmp     al, '='
                        jnz     @f
                        mov     dx, ds
                        mov     ax, si
                        jmp     exit
skipVar:                or      al, al
                        jz      checkLast
@@:                     lodsb
                        or      al, al
                        jnz     @b
checkLast:              cmp     al, [si]
                        jnz     nextVar
fail:                   sub     dx, dx
                        sub     ax, ax
exit:                   pop     si
                        pop     di
                        pop     es
                        pop     ds
                        ret
findEnvVar              endp

lastByte                label   byte

                        end
