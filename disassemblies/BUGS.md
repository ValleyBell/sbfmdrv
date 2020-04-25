# Known SBFMDRV Bugs

- *[1.11]* When calling `resetOperators`, the vibrato/tremolo depth bits (register 0BDh) are cleared.
  This happens when resetting the sound driver or when changing between "melody" and "rhythm" modes. (MIDI CC #103)
  However the internally saved register state has those bits set and playing any rhythm sound will set the bits on the OPL chip as well.  
  *Fixed in 1.20:* The vibrato/tremolo bits are always set.
- *[all versions]* In `resetOperators` it writes writes a timbre to all channels in order to silence them.
  However when writing to register 0C0h, the driver screws up and writes the value to an arbitrary register in the range 00h..1Bh.
- *[1.11]* When loading a 1-operator rhythm instrument (SD/TT/CY/HH), the "Total Level" value (reg 40h) is loaded from the "carrier TL" slot (offset 3) instead of the "modulator TL" slot (offset 2).
  All other parameters are taken from the "modulator TL" slot.  
  *Fixed in 1.20:* The TL value is taken from offset 2 ("modulator TL").
- *[1.30+]* A linear → logarithmic scale conversion is applied to note velocities.
  However the ROL files most CMFs are converted from assume that no such conversions take place,
  thus most notes play at the maximum volume now.  
  Versions <=1.22 just linearly scaled the velocities to the OPL volume range, which was the correct way based on ROL composition and ROL2CMF.
- *[all versions]* pitch bends (MIDI CC #104/#105) have only a range of a *half* semitione up and down.  
  However, when composing ROL files in AdLib Visual Composer, you have a range of a full semitone.
  ROL2CMF scales the values by multiplying them with 127.  
  So most CMFs were probably intended to have a pitch bend range of a *full* semitone.
- *[1.30-1.33]* The version number returned by `fnGetVersion` (call #0) is wrong.
  The function returns "1.21". (Yes, it returns a lower version number than 1.22.)  
  *Semi-fixed in 1.34:* The function returns "1.34", but BCD-encoded whereas earlier drivers returned the version number as plain decimal numbers.
- *[1.11]* The `fnGetSongPosition` API function (call #13) may return an offset that points into the middle of an event.  
  *Fixed in 1.20:* The returned value always points to the beginning of an event.  
  However this value still can not be used for seeking directly, as `fnStartPlaying` requires you to point to the *delay before* an event.
- *[1.11-1.20]* Interrupt #9 handler (raised by Ctrl+Alt+Del) checks for an incorrect key code (83h) before silencing the OPL chip.  
  *Fixed in 1.22:* It checks for the correct key code 53h (decimal: 83).
- *[1.22+]* Fading with steps other than 1 can results in it never reaching the target volume.
  Instead it oscillates around it.
- *[1.22+]* The driver is initialized with volume 100. (equals no change in volume)
  However when using fading, values are clamped incorrectly to 0..99, thus you can never reach the initial volume again.
- *[1.30+]* Fading (added in 1.22) is not working, because the fade volume modifier is not applied to note velocities anymore.
- *[all versions]* When stopping or pausing the music, the sound driver tries to softly stop all channels instantly, but fails to do so.
  - *[1.11-1.33]* It sets "Release Rate = 3" when processing all 9 channels - but it always sends it to FM channel 0's carrier operator.
    So this is the only channel that is guaranteed to fade out. (albeit slowly)
  - *[1.34]* "Release Rate = 3" goes to operator offsets 0..8, which covers channels 0..2 (modulator + carrier) and channel 3 modulator.
    Additionally, "Release Rate = 15" (fastest) goes to modulator+carrier of channels 6..8.
    Channels 3..5 end up left untouched.
- *[all versions]* Resuming music doesn't restore the instruments that were modified when silencing the channels.  
  *[1.11-1.33]* The bug is not very noticeable in some cases, as silencing instruments barely does anything.
- *[1.32 SBPro2]* In `disableOPL3` (called when stopping/pausing), it resets all waveforms.
  However it misses two operators: channel 7+8 carrier (regs 0F4h/0F5h)  
  It also doesn't reload the waveforms when resuming playback, causing broken instruments.
