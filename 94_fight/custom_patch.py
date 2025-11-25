# custom_patch.py
# Applies fight patch to a custom ROM, without making modifications to the existing mods
# Version 0.1 - Initial version


from importlib.resources import path
import sys
from binascii import b2a_hex, hexlify
from pathlib import Path
import os
from shutil import copyfile
import struct

def main():
    print("------------------------ chaos' Custom ROM Fight Patch Version 0.1 ------------------------")
    print("This script will apply the fight and sprite patches to an existing custom ROM. It will"
          " ask you to choose a ROM, then it will make a copy of it, and apply the patches to the copy."
          " The ROM will be expanded to 3MB in size to provide space for the new patch code.")
    print("-------------------------------------------------------------------------------------------")
    print("\n")
    input("Press any key to continue...")


if __name__ == '__main__':
    main()