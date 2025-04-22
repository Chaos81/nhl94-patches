NHL94 Fight Code Injection

Sub-Routines needed from NHL93 ported into 94:

fightinput - controller processing for fighting   (93 - 0x95C4 start, 9A size)
checkfight - look for start of fight between players a2 and a3 (93 - 0x103A0 start, 166 size)
ChkFightValue - as described (93 - 0x1056A start, B4 size)
SF - start the fight (93 - 0x10508 start, 5E size)
assfight - fighting logic (93 - 0xA58A start, 144 size)
assfwatch - player who is watching fight (93 - 0xA9B8 start, 93 size)
chkhit - part of fight to see if player is hit (93 - 0xA6CE start, 114 size)
CwdFight - increases crowd level, adjust player velocity (93 - 0xA7E2 start, 28 size)
FightFall - as described (93 - 0xA80A start, A4 size)

There's probably more. I need to fully analyze FightFall

Later add-ons:
    - routines for header
    - routines for possible player injury

Injection points:

fightinput: This is called at 0xB25E (bne.w fightinput). A JSR will be needed here.
    - So, the previous code line needs to be added to the fightinput code (0xB258 - btst #0, $63(a3) ; fighting in progress)

checkfight: This is called at 0x13B1E (bsr.w checkfight). A JSR will be needed here .
    - The previous 2 lines of code are also bsr. These 3 can be combined into a small subroutine, all turned into jsrs.

ChkFightValue: This is part of checkfight code, so no injection needed.

SF:  This is part of the checkfight code, so no injection needed.

assfight and assfwatch: Need to change the pointers on asstab list (0x18D7C). assfight pointer at 0x18DCC, assfwatch at 0x18DD0

chkhit, CwdFight, FightFall: This is part of the assfight code, so no injection needed.


Modifications to the 93 code:

- Need to update label addresses.
- ChkFightValue might need modifications for 94 attributes.
- Need to change what happens when fight is over (currently, no injury possible, so will need a small change to bypass that)
- Need to update Penalty pointers (so they are assigned the correct penalties). PenFighting - 0x13, PenFighting* - 0x14
- some pflags might need to be changed
- Temporarily, will need to change the sprite animations for fighting to a known value in 94

Modifications to the 94 code:

- modify injection points
- Add code and adjust the ROM locations where needed.
- Need to add a RAM variable for Checkdown counts, if planning to use this to determine fight. This is done in the FallDown routine in 93, so that will need to be modified

FFB10 - FFDFF - Free space in vanilla ROM (2EF free - 751 bytes)
This is probably not enough. Will need to increase the ROM space.



