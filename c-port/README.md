# SBFMDRV C ports

This folder contains C ports of SBFMDRV made by Valley Bell.

All versions from the disassemblies folder were ported.


Note:
The drivers were tested by compiling each driver and the respective "player_opl#.c" file and linking libvgm-audio/libvgm-emu to it.
I included the Visual C++ 2010 test project (dosmidiplay) that I used.
But you will need to get [libvgm](https://github.com/ValleyBell/libvgm/), compile it by yourself and adjust the paths in the project.


## Players and SBFMDRV versions

- player-opl2 (OPL2): 1.11, 1.20 SDK, 1.22, 1.30B SB, 1.32 SB16, 1.33 SBP6, 13.4 SB, 1.34 SBP6
- player-opl2x2 (Dual OPL2): 1.30 SBP1
- player-opl3 (OPL3): 1.32 SBP2


## Driver accuracy check

The output of the C ports was verified to be 100% accurate to the original drivers.
The procedure was this:
- In DOSBox, load the respective SBFMDRV.COM file.
- Run NewRisingSun's CMF2VGM on all test case CMFs, resulting in VGMs rendered by the original driver.
- Play all test case CMFs back using the C port and log the output to VGM as well.
- Do a binary comparison on the VGMs.
- The VGM made with CMF2VGM + original driver has to exactly match log from the C port.
  The only exception is the very last delay before EOF and the VGM's "total sample" count. (player.c always stops a bit late.)
- You can find the test case CMFs and the resulting VGMs in the "test" folder.
