# custom_patch.py
# Applies fight patch to a custom ROM, without making modifications to the existing mods
# Version 0.1 - Initial version

from tkinter import Tk
from tkinter.filedialog import askopenfilename
from tkinter.filedialog import asksaveasfilename
import sys
from binascii import b2a_hex, hexlify
from pathlib import Path
import os
from shutil import copy2
import struct

def menu():
    print("------------------------ chaos' Custom ROM Fight Patch Version 0.1 ------------------------")
    print("This script will apply the fight and sprite patches to an existing custom ROM. It will"
          " ask you to choose a ROM, then it will make a copy of it, and apply the patches to the copy."
          " The ROM will be expanded to 3MB in size to provide space for the new patch code."
          " This patch is compatible with any 30 or 32 team ROM.")
    print("-------------------------------------------------------------------------------------------")
    print("\n")
    input("Press any key to continue...")

    print("Choose an option:")
    print("1 - Apply all patches")
    print("2 - Exit")
    choice = input("Type your choice and press ENTER: ")

    return choice

def getrom():
    # Ask for ROM, make a temporary copy

    print("-------------------------------------------------------------------------------------------")
    file = input("Drag ROM file here and press ENTER: ") 
    temp = 'temp.bin'
    copy2(file, temp)

    return temp

def getFrmDataOffsets(file):
    # Get Frame Data offset table from ROM

    # Table pointer = $5DE7A + offset at 4 bytes

    with open(file, 'rb') as f:
        # Get offset to table
        offset = int('5de7a', 16)
        f.seek(offset + 4)
        offset2 = f.read(4).hex()
        tableoff = offset + int(offset2, 16)
        print('Frame Data Table Location: ' + hex(tableoff))

        # Get table

        table = []
        f.seek(tableoff)
        table.append(f.read(2).hex())   # First 2 bytes are 00 00 (Frame 0 doesn't exist)
        length = f.read(2).hex()        # Frame 1 offset = size of table, since frame data start right after the table
        table.append(length)

        print('Length of table: ' + str(int(length, 16)))
        print('Frame 1 data offset: ' + length)
        length = (int(length, 16)) / 2  # Each frame offset is 2 bytes
        count = 2

        while count < length:
            frmoff = f.read(2).hex()
            print('Frame ' + str(count) + ' data offset: ' + frmoff)
            table.append(frmoff)
            count += 1

    return (offset, table)

    # Copy into file

    # with open('FrmDataOff.bin', 'wb+') as w:
        # Iterate through table and write to file
    #    for frame in table:
    #        w.write(bytes.fromhex(frame))
            # Update table to save frame data addresses
    #    print('Write to file successful.')



          


def getHotData(file):
    # Get HotSpot data for each frame
    # Byte 0 - X HotSpot
    # Byte 1 - Y HotSpot

    hotdata = []
    count = 1
    numhot = 0   
    with open(file, 'rb') as f:
        while count <= numhot:
                xhot = f.read(1).hex()
                yhot = f.read(1).hex()
                hot = dict({'XHot': xhot, 'YHot': yhot})
                hotdata.append(hot)
                #print('Frame ' + str(count) + ': ' + str(hot))
                count += 1
    return hotdata

def extractdata(file):
    # Extract needed sprite and frame data from file

    # Retrieve Frame Data Offsets

    getFrmDataOffsets(file)

    # Retrieve Hot Spot Data

    # getHotData(file)


def main():
    choice = menu()

    if choice == '1':
        file = getrom()
        extractdata(file)
    else:
        exit()
    input("Press a key to exit...")
    exit()

if __name__ == '__main__':
    main()