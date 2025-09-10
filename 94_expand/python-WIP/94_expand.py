# 94_expand.py
# Version 0.1 - Initial version
# Version 0.2 - Add options and dialog
# Increase 94 ROM to 2MB or 3MB, update ROM header, remove checksum, update save RAM stuff if needed (3MB)

import os, shutil
from tkinter.filedialog import askopenfilename, asksaveasfilename

def pad_binary_file(size):
    # Expands ROM from 1MB to 2MB or 3MB (pads with FF). Checks ROM size before expanding

    rom = askopenfilename("Choose the ROM to expand: ")
    
    file_size = os.path.getsize(rom)
    print("File size - " + str(file_size))
    
    block_size = 1048576 # 1MB
    
    
    if file_size == 1048576:    # 1MB ROM
        print("ROM size = 1MB")
        padding_needed = block_size * (size)

    elif file_size == 2097152:  # 2MB ROM
        print("ROM size = 2MB")
        padding_needed = block_size * (size)
        if size == 1:
            print('ROM is already expanded to 2MB.')
            return
    else:
        print('This ROM is the incorrect size (not a 1MB or 2MB ROM). Please double check and try again.')   
        return
    
    file = 'temp.bin'
    shutil.copy(rom, file)  # Make a copy of the ROM 
    with open(file, 'ab') as f: # Open at the end of the file
        f.write(bytes.fromhex('FF') * padding_needed)
        print(f"File '{file}' padded to " + str(size+1) + " MB.")
    
    # Now, update header and remove checksum

    with open(file, 'rb+') as f:

        if size == 1:   # 1MB ROM changed to 2MB

            f.seek(416)  # 1A0 - ROM Address range
            f.write(bytes.fromhex('00 00 00 00 00 1F FF FF'))  # 1FFFFF = 2MB ROM range
            print(f"File '{file}' ROM header updated to 2MB ROM address range.")
        
        elif size == 2:  # 1MB or 2MB ROM changed to 3MB
            f.seek(437)  # 1A0 - ROM Address range
            f.write(bytes.fromhex('20 00 00 00 00 2F FF FF'))  # 2FFFFF = 3MB ROM range
            f.seek()
            print(f"File '{file}' ROM header updated to 3MB ROM address range.")

            # Update SRAM address range

            f.seek(416)  # 1B5 - SRAM Address range
            f.write(bytes.fromhex('00 00 00 00 00 2F FF FF'))  # 2FFFFF = 3MB ROM range
            f.seek()
            print(f"File '{file}' ROM header updated to 3MB ROM address range.")
        
        f.seek(1047242) # FFACA - Checksum
        f.write(bytes.fromhex('4E 75')) # Remove checksum check
        print(f"File '{file}' checksum check removed.")
        

if __name__ == "__main__":

    welcome = "----------------------------- 94 Expand ver. 0.2 -----------------------------\n" \
            "This program will take an NHL94 ROM and expand it to either 2MB or 3MB.\n" \
            "It will adjust the ROM header and remove the checksum check.\n" \
            "It will also adjust the Save RAM location to the 4MB range with the 3MB option, \n" \
            "and also update the ROM to use the new Save RAM location." \
            "----------------------------------- Options ----------------------------------- " \
            "1 - Expand to 2MB (no adjustment to Save RAM)" \
            "2 - Expand to 3MB (adjustments needed to Save RAM)" \
            "3 - Exit"
    
    print(welcome)
    
    ok = False
    while ok is False:
        choice = ('Make a selection: ')
        if choice == '1':
            size = 2
            pad_binary_file(size)
            ok = True
        elif choice == '2':
            size = 3
            pad_binary_file(size)
            ok = True
        elif choice == '3':
            exit()
        else:
            print('Invalid choice. Try again!')
    
    ex = ('Press any key to exit....')
    if ex:
        exit()
    