# nhl94-patches
 Patches for adding/changing the NHL94 ROM

 94_expand - A patch to expand any NHL94 ROM to 3MB or 4MB.

 94_fight - A patch to the original NHL94 Genesis ROM to add the fighting code from NHLPA93.

 94_custom_patch - A patch to apply the 94_expand and 94_fight patches to ANY NHL94 ROM. Can be applied to the default 94 ROM, 30 team, and 32 team ROM hacks.

 All these patches are for PC only (because they rely on a 68k Assembler that is Windows compatible).

## 94_custom_patch - Version 1.0

### How to use this patch:

A program that will apply the above patches to a any given ROM. This is the easiest patch to use for anyone making their own ROM.

The program requires Python 3.10+ to be installed on your PC.

- Make changes as needed to the scripts/fight_patchc.asm file (i.e. set the default menu option for fighting)
- Run the custom_patch.py. Follow the instructions.
- Drag and drop your custom ROM into the console screen when requested, and hit ENTER.
- The script will generate the necessary files needed.
- Run the buildfight.bat file to build the new version of your ROM. It will be in the output folder when finished. If there is no ROM, check the build.log file for errors.
- Load the ROM up and play! 

## 94_expand - Version 1.0

94_to_3MB.bat - Patch to expand to 3MB
94_to_4MB.bat - Patch to expand to 4MB

Currently, the ROM you want to patch needs to be copied to the 94_expand folder and renamed as "temp.bin" (no quotes).
I plan on making a python script to make this process easier.

Expanding is easy, as it just pads the ROM to the size with $FF bytes. The hard part is dealing with SRAM (Save RAM).

SRAM is mapped to $200000 address range in the Genesis/MegaDrive (2MB range). A hardware flag can be used to switch out SRAM for ROM data and vice-versa when needed.
The script modifies the 94 code that writes or reads to SRAM to use this flag, and moves this modified code to a new location.
The location needs to be in the lower 2MB, so free space is needed. The code currently is place at $1F9A00 (which looks like empty space in a 32-team ROM), and takes up about 400 bytes.


## 94_fight patch - Version 1.0 (currently in testing phase)

A patch that adds the NHLPA93 sprites and fight code to the NHL94 ROM.

Current version updates:
- Official release
- Included 94_expand in the fight patch. Fight patch will do it all (expand ROM to 3MB, apply fight and sprite patches)
- Change the name of the ROM and serial # in the header.
- Add a new title screen and update credits
- Add a default setting for the fight option in the Main Menu
- Fix Hot Spots for fight frames (needed to add empty frames for the player arrows before adding fight frame Hot Spots)

Previous version updates:
- Fixed reverse angle replay bug where glove/stick location wouldn't change.

- Fixed reverse angle replay bug where the fighters wouldn't flip in the X direction.

- Fixed bug causing hesitation at times when player is knocked down. This bug fix also fixes the problem where the fight winner isn't always declared after a knock down.
- Adjust Arcade Mode settings to cause less frequent fights.
- Fixed bug with injuries from fight

- Added menu option for fighting (Off, On, On - Arcade Mode) thanks to McMarkis - [NHL94 Gens Patches](https://github.com/Mhopkinsinc/NHL94-Gens-Patches/tree/main)
- Added Arcade Mode - more fights (lower # of total checks (10), lower Fgt attribute needed (6 vs. 10), less minimum checks needed, slightly higher chance of game injury

- Fixed a bug that caused a problem with momentum transfer after a check

- Adjust minimum total checks and minimum checks for based on length of period - < 2 min, 2-7 min, 7-20 min, >= 20 min
- Adjust Fight attribute display to be similar to NHLPA93 (0-100 scale, no curve applied like other 94 attributes)

- Modified patch to move code into the upper 2MB ROM range (using a 3MB or 4MB ROM for patching now). This allows compatibility with ROM hacks.
- Instead of overwriting the whole Sprite tileset, modify to only add the fighting sprite tiles to the existing tileset, to keep from overwriting sprite hacks.

### How to use this patch:

- NOTE: There is a recent ROM build already in the output folder. There is no need to build unless you make changes.
- Download the code from GitHub (use the Code button at the top of the repository).
- Navigate to where you downloaded the code. Open the 94_fight folder.
- Open up the scripts/fight_patch.asm file in a file editor of your choice, and make adjustments to the testing variables (they are documented in there). Save your changes.
- If you do not want to make changes, the ROM is already built and is in the output folder.
- Run the build.bat file in the main 94_fight folder.
- Open the output folder. Inside there should be 2 files: a Build.txt file and the ROM (nhl94_fight_v1.bin). 
    If there is no new ROM file, the Build.txt file will list errors that occurred. Fix them and try again. Make sure to check the date on the ROM file, as if there was one from a previous build, it will still be there.
- Load the ROM up and play!

### Thanks

- Special thanks to McMarkis and AbdulBCRT for help with reverse engineering the sprite format! You can find their GitHub pages below:
    -  [McMarkis](https://github.com/Mhopkinsinc)
    -  [AbdulBCRT](https://github.com/abdulahmad)

### Contribute

- If you wish to donate or show some appreciation, please use the link below:
    - [Buy me a Coffee](https://buymeacoffee.com/chaosnhl94)

- Also, join the NHL94 community!
    - [NHL94.com](https://nhl94.com)
    - Link to NHL94 Discord - [Discord](https://discord.gg/KXJeQ6pyUc)
    - Forum post discussing fighting - [NHL94 Forums](https://forum.nhl94.com/index.php?/topic/36385-adding-fighting-in-nhl94-genesis/)
     