# nhl94-patches
 Patches for adding/changing the NHL94 ROM

 94_expand - A python script that takes the original Genesis NHL94 ROM (nhl94.bin) and expands it to 2MB (nhl94_2MB.bin) while also removing the checksum and updating the ROM Header.

 94_fight - WIP. A patch to the original NHL94 Genesis ROM to add the fighting code from NHLPA93.

## 94_expand - Version 0.1

A python script that takes the original Genesis NHL94 ROM (nhl94.bin) and expands it to 2MB (nhl94_2MB.bin) while also removing the checksum and updating the ROM Header.



## 94_fight patch - Version 0.6 (currently in testing phase, not a finalized patch)

- Add testing variables for fight conditions. These can be edited in the fight_patch.asm file.

## How to use this patch:

- Download the code from GitHub (use the Code button at the top of the repository).
- Navigate to where you downloaded the code. Open the 94_fight folder.
- Open up the fight_patch.asm file in a file editor of your choice, and make adjustments to the testing variables (they are documented in there). Save your changes.
- Run the build.bat file in the main 94_fight folder.
- Open the output folder. Inside there should be 2 files: a Build.txt file and the ROM (nhl94_fgt_v0.6.bin). 
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
     