# custom_patch.py
# Applies fight patch to a custom ROM, without making modifications to the existing mods
# Current Version - 1.0
# Version 0.1 - Initial version
# Version 1.0 - Public release

import sys
from binascii import b2a_hex, hexlify
from pathlib import Path, PureWindowsPath
import os
from shutil import copy2, move
import subprocess

def menu():
    print("-------------------------- chaos' Custom ROM Patch Tool Version 1.0 --------------------------")
    print("This script will prepare the data for applying the fight patch to an existing NHL'94 ROM. It \n"
          "will ask you to choose a ROM, then it will make a copy of it, extract the necessary data for \n"
          "the sprite patch, and modify the data. Afterwards, you can run the buildfight.bat file to apply \n"
          "the expansion and SRAM fix, fight, and sprite patches and build the ROM.")
    print("\n" * 1)
    print("This patch is compatible with ANY NHL94 ROM (the regular 28 team, 30 team or 32 team ROMs).")
    print("----------------------------------------------------------------------------------------------")
    print("\n")
    input("Press any key to continue...")

    print("Choose an option:")
    print("1 - Run (extract frame assets to separate files, and add the fight assets)")
    print("2 - Exit")
    choice = input("Type your choice and press ENTER: ")

    return choice

def getrom():
    # Ask for ROM, make a temporary copy

    print("-------------------------------------------------------------------------------------------")
    file = input("Drag ROM file here and press ENTER: ")
    file = file.replace("'", "\'")
    file = file.replace("\\", "/")   
    file = file.replace("\"", "")

    temp_path = 'temp/temp.bin'

    copy2(file, temp_path)

    return temp_path

def delete(file):
    # Delete file if it exists

    if os.path.exists(file):
        os.remove(file)
        print("Existing " + file + " deleted.")

def runpatch(file):
    # Run fight_patchc.asm on file

    # Run batch file to build ROM

    try:
        # Example for cross-platform file listing
        subprocess.run('buildc.bat', check=True)

    except subprocess.CalledProcessError as e:
        print(f"Command failed with return code {e.returncode}")
        print("STDOUT:", e.stdout)
        print("STDERR:", e.stderr)
    
    except FileNotFoundError:
        print("The command was not found. Check your OS or command path.")


def getSPAList(file):
    # Retrieve SPAList from ROM

    # Table pointer = $5B1C in default ROM, but to future proof, we will read location from updateanim subroutine

    with open(file, 'rb') as f:
        # Get offset to table
        f.seek(int('aefc', 16))     # location to read from updateanim
        tblloc = f.read(4).hex()

        # Unfortunately, there is no way to tell the length without it given. So for now, I will use the length of the list from the default ROM
        # This will need to be done a different way in the future
        # Default Length = 7062 bytes, which we will read in 22 byte chunks
        length = 7062
        count = 0
        SPAlist = []

        print("SPA Table Location: " + tblloc)
        f.seek(int(tblloc, 16))

        while count < length:
            SPAlist.append(f.read(22))
            count = count + 22
    
    # print ("SPAList:" )
    # for chunk in SPAlist:
        # print(chunk)
    return SPAlist

def getFrmDataOffsets(file, data):
    # Get Frame Data offset table from ROM

    # Table pointer = $5DE7A + offset at 4 bytes in default ROM, but to future proof, we will read location from addframe2 subroutine

    with open(file, 'rb') as f:
        # Get offset to table 
        f.seek(int('167d0', 16))    # location to read from addframe2
        offset = f.read(4).hex()
        f.seek(int(offset, 16) + 4) # Skip palette offset
        offset2 = f.read(4).hex()
        tableoff = int(offset, 16) + int(offset2, 16)
        print('Frame Data Table Location: ' + hex(tableoff))

        # Get table

        table = []
        f.seek(tableoff)
        table.append(f.read(2).hex())   # First 2 bytes are 00 00 (Frame 0 doesn't exist)
        length = f.read(2).hex()        # Frame 1 offset = size of table, since frame data start right after the table
        table.append(length)

        print('Length of table: ' + str(int(length, 16)))
        #print('Frame 1 data offset: ' + length)
        length = (int(length, 16)) / 2  # Each frame offset is 2 bytes
        count = 2

        while count < length:
            frmoff = f.read(2).hex()
            #print('Frame ' + str(count) + ' data offset: ' + frmoff)
            table.append(frmoff)
            count += 1

    # Store return variables in a dict
    data.update({'sprtbloff': int(offset, 16), 'frmtbloff': int(offset2, 16), 'frmtbl': table})

    # Copy into file

    # with open('FrmDataOff.bin', 'wb+') as w:
        # Iterate through table and write to file
    #    for frame in table:
    #        w.write(bytes.fromhex(frame))
            # Update table to save frame data addresses
    #    print('Write to file successful.')

def getFrmData(file, data):
    # Get Frame Data, store in list

    start = data['sprtbloff']
    off = data['frmtbloff']
    table = data['frmtbl']
    offset = start + off    # Start of frame data table
    frmdata = []

    # Find Length of table

    totalframes = len(table) - 2    # Remember, first item and last item do not exist as a real frame
    print("Total Frames: " + str(totalframes))
    
    frame = 1
    with open(file, "rb") as f:
        while frame <= totalframes:
            # Calculate how much sprite data in frame by calculating difference between frame offset and next frame's offset
            current = int(table[frame], 16)
            next = int(table[frame+1], 16)
            numdata = next - current
            
            f.seek(offset + current)
            dataread = f.read(numdata)
            frmdata.append(dataread)
            frame += 1
    

    #print("Frame Data:")
    # for fdata in frmdata:
    #    print(fdata.hex(sep=' '))

    data.update({'frmdata': frmdata})
    

def getHotData(file, data):
    # Get HotSpot data for each frame
    # Byte 0 - X HotSpot
    # Byte 1 - Y HotSpot

    hotdata = []
    count = 0
    numhot = 0
    emptyframe = 1   
    with open(file, 'rb') as f:

        # Read Hotlist location from ROM
        f.seek(int('106f6', 16))        # Hotlist pointer location
        tblloc = f.read(4).hex()

        # Calculate # of frames based on frame list - Default 94 has 845 frames
        length = len(data['frmtbl']) - 2   # Remember, first and last entry in the frame list are not actual frames

        if (length == 845):
            length = length - 8         # Last 8 frames do not have hot spots in default ROM!!
            emptyframe = bytearray(2)
        
        f.seek(int(tblloc, 16))
        while count <= length:
                hot = f.read(2)
                hotdata.append(hot)
                #print('Frame ' + str(count) + ': ' + str(hot))
                count += 1

    # Add empty hotspot frames for the last 8 frames if needed

    if (emptyframe != 1):
        count = 1
        while count <= 8:
            hotdata.append(emptyframe)
            count += 1


    data.update({'hottbl': hotdata})

def extractdata(file, info):
    # Extract needed sprite and frame data from file
    data = dict()

    # Retrieve SPAList

    SPAlist = getSPAList(file)
    # Retrieve Frame Data Offsets

    getFrmDataOffsets(file, data)

    # Retrieve Frame Data

    getFrmData(file, data)
    
    # Retrieve Hot Spot Data

    getHotData(file, data)

    info.append(SPAlist)
    info.append(data)
    
def updatedata(info):
    # Update collected data by adding fighting data

    script_dir = os.path.dirname(__file__)
    SPAListfight_path = os.path.join(script_dir, 'data\94_Tables\Fight\Added_Data\SPAList_Fight.bin')
    HotListfight_path = os.path.join(script_dir, 'data\94_Tables\Fight\Added_Data\Hotlist_Fight.bin')
    FrmDatafight_path = os.path.join(script_dir, 'data\94_Tables\Fight\Added_Data\SprData_Fight.bin')
    FrmTablefight_path = os.path.join(script_dir, 'data\94_Tables\Fight\Added_Data\FrameTable_Fight.bin')

    SPAlist = info[0]
    data = info[1]

    # First, update SPAList

    with open(SPAListfight_path, "rb") as f:
        while chunk := f.read(10):
            SPAlist.append(chunk)

    #print("New SPAList:")
    #print(SPAlist)

    # Next, update HotList

    with open(HotListfight_path, "rb") as f:
        while chunk := f.read(2):
            data['hottbl'].append(chunk)

    #print("New HotList:")
    #print(data['hottbl'])

    # Then, update the Frame Data. Since this data is fixed, the pointers are already updated with the sprite tiles being located right after the default ROM ones
    # In the future, sprite tiles should be added first, then the pointers here should be updated accordingly

    with open(FrmDatafight_path, "rb") as f:
        while chunk := f.read(8):
            data['frmdata'].append(chunk)

    # Finally, update the Frame table (we are adding 24 frames, *2 = 48 or $30)
    # The frames stored in the file are already updated to add the $30, so we will add them after the loop

    frameadd = 48
    for i in range(len(data['frmtbl'])):
        if i != 0:      # Skip frame 0 (not real)
            new = int(data['frmtbl'][i], 16) + frameadd
            new = format(new, '04x')
            data['frmtbl'][i] = new
    
    # Add the new fighting frame offsets to the list

    with open(FrmTablefight_path, "rb") as f:
        while chunk := f.read(2):
            data['frmtbl'].append(chunk.hex())

    #print(data['frmtbl'])

    info[0] = SPAlist
    info[1] = data

def exportdata(info):
    # Export data to files

    script_dir = os.path.dirname(__file__)
    SPAListfight_path = os.path.join(script_dir, 'data\Custom_Tables\Fight\SPAListFight.bin')
    HotListfight_path = os.path.join(script_dir, 'data\Custom_Tables\Fight\HotlistFight.bin')
    FrmDatafight_path = os.path.join(script_dir, 'data\Custom_Tables\Fight\SprDataFight.bin')
    FrmTablefight_path = os.path.join(script_dir, 'data\Custom_Tables\Fight\FrmSprDataOffFight.bin')

    # Remove old files if they exist

    delete(SPAListfight_path)
    delete(HotListfight_path)
    delete(FrmDatafight_path)
    delete(FrmTablefight_path)

    SPAlist = info[0]
    data = info[1]

    # First, export SPAList

    with open(SPAListfight_path, "wb") as f:
        print("New SPAListFight.bin created.")
        for chunk in SPAlist:
            f.write(chunk)

    # Next, export HotList

    with open(HotListfight_path, "wb") as f:
        print("New HotListFight.bin created.")
        for chunk in data['hottbl']:
            f.write(chunk)
    
    # Next, export Frame Data

    with open(FrmDatafight_path, "wb") as f:
        print("New SprDataFight.bin created.")
        for chunk in data['frmdata']:
            f.write(chunk)

    # Finally, export Frame Table

    with open(FrmTablefight_path, "wb") as f:
        print("New FrmSprDataOffFight.bin created.")
        for chunk in data['frmtbl']:
            chunk = bytearray.fromhex(chunk)
            f.write(chunk)

    print("\n" * 2)
    print("Writing to files finished!")
    

def main():

    # Set working directory
    
    script_path = Path(__file__).resolve()
    script_dir = script_path.parent
    os.chdir(script_dir)

    choice = menu()

    if choice == '1':
        info = []
        file = getrom()
        extractdata(file, info)
        updatedata(info)
        exportdata(info)
        #runpatch(file)

        print("\n" * 2)
        print("Patch application is complete. Please exit this program and run the 'buildfight.bat' \n"
              "file to insert the modified frame and sprite data to the ROM and apply the patches. \n"
              "Once run, the completed ROM file will be located in the output folder. There will \n"
              "also be a build.log file showing errors in the assembly if necessary. \n\n"
              "Enjoy the fight patch!!")

    else:
        exit()
    input("Press a key to exit...")
    exit()

if __name__ == '__main__':
    main()