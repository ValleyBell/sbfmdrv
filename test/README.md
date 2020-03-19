# CMF Test Cases

This folder contains test cases that were used to test the output of the SBFMDRV C port against the original driver.


## CMF songs

- 01.CMF - Dyna Blaster: Battle Music
	- features some overlapping notes (-> channel allocation test)
- 08.CMF - Dyna Blaster: Title Screen
	- uses add drum channels (except for channel 14, the Tom-Tom)
- 15.CMF - Dyna Blaster: Intro Cutscene
	- uses note velocities to fade out
- FUNKY.CMF - Jill of the Jungle: Funky
	- a well-known song that uses velocities a lot
- HELLOMY.CMF
	- uses chords on channels (-> good test for channel allocation)
- VOLTEST.CMF - velocity/volume test
	- plays each note velocity once
- VOLTEST2.CMF - velocity/volume test
	- plays each note velocity once (different instrument TL level than VOLTEST.CMF)
- ZAP_RAP.CMF - Drum Blaster: Zap Rap

TODO:
- CMF with 9 melody channels (rhythm mode off)
- CMF that uses the drum channel 14 (Tom-Tom)


## VGM logs

Naming scheme:

- ss_dd_A.VGM - song ss, driver dd, ASM version
	- log done with NewRisingSun's CMF2VGM tool using original SBFMDRV driver
- ss_dd_C.VGM - song ss, driver dd, C version
	- log made with SBFMDRV code ported to C

VGM logs are considered matching when all OPL 2/3 register writes and all delays match, except for the very last delay (61 xx xx) in the file.
