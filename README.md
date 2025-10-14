# nhl94-patches
 Patches for adding/changing the NHL94 ROM

 94_expand - WIP. A patch to expand any NHL94 ROM to 3MB or 4MB.

 94_fight - WIP. A patch to the original NHL94 Genesis ROM to add the fighting code from NHLPA93.

## 94_expand - Version 0.1 (currently in testing phase, not a finalized patch)

94_to_3MB.bat - Patch to expand to 3MB
94_to_4MB.bat - Patch to expand to 4MB

Currently, the ROM you want to patch needs to be copied to the 94_expand folder and renamed as "temp.bin" (no quotes).
I plan on making a python script to make this process easier.

Expanding is easy, as it just pads the ROM to the size with $FF bytes. The hard part is dealing with SRAM (Save RAM).

SRAM is mapped to $200000 address range in the Genesis/MegaDrive (2MB range). A hardware flag can be used to switch out SRAM for ROM data and vice-versa when needed.
The script modifies the 94 code that writes or reads to SRAM to use this flag, and moves this modified code to a new location.
The location needs to be in the lower 2MB, so free space is needed. The code currently is place at $1F9A00 (which looks like empty space in a 32-team ROM), and takes up about 400 bytes.


## 94_fight patch - Version 0.9 (currently in testing phase, not a finalized patch)

A patch that adds the NHLPA93 sprites and fight code to the NHL94 ROM.

Current version updates:
    - Added menu option for fighting (Off, On, On - Arcade Mode) thanks to McMarkis - [NHL94 Gens Patches](https://github.com/Mhopkinsinc/NHL94-Gens-Patches/tree/main)
    - Added Arcade Mode - more fights (lower # of total checks (10), lower Fgt attribute needed (6 vs. 10), less minimum checks needed, slightly higher chance of game injury

Previous version updates:
    - Fixed a bug that caused a problem with momentum transfer after a check

    - Adjust minimum total checks and minimum checks for based on length of period - < 2 min, 2-7 min, 7-20 min, >= 20 min
    - Adjust Fight attribute display to be similar to NHLPA93 (0-100 scale, no curve applied like other 94 attributes)

    - Modified patch to move code into the upper 2MB ROM range (using a 3MB or 4MB ROM for patching now). This allows compatibility with ROM hacks.
    - Instead of overwriting the whole Sprite tileset, modify to only add the fighting sprite tiles to the existing tileset, to keep from overwriting sprite hacks.

### How to use this patch:

- Download the code from GitHub (use the Code button at the top of the repository).
- Navigate to where you downloaded the code. Open the 94_fight folder.
- Open up the fight_patch.asm file in a file editor of your choice, and make adjustments to the testing variables (they are documented in there). Save your changes.
- If you do not want to make changes, the ROM is already built and is in the output folder.
- Run the build.bat file in the main 94_fight folder.
- Open the output folder. Inside there should be 2 files: a Build.txt file and the ROM (nhl94_fgt_v0.9.bin). 
    If there is no new ROM file, the Build.txt file will list errors that occurred. Fix them and try again. Make sure to check the date on the ROM file, as if there was one from a previous build, it will still be there.
- Load the ROM up and play!


### Thanks

- Special thanks to McMarkis and AbdulBCRT for help with reverse engineering the sprite format! You can find their GitHub pages below:
    -  [McMarkis](https://github.com/Mhopkinsinc)
    -  [AbdulBCRT](https://github.com/abdulahmad)

### Contribute

- Join the NHL94 community!
    - [NHL94.com](https://nhl94.com)
    - Link to NHL94 Discord - [Discord](https://discord.gg/KXJeQ6pyUc)
    - Forum post discussing fighting - [NHL94 Forums](https://forum.nhl94.com/index.php?/topic/36385-adding-fighting-in-nhl94-genesis/)
     