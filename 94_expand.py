# 94_expand.py
# Version 0.1 - Initial version
# Increase 94 ROM from 1MB to 2MB, update ROM header, remove checksum

import os, shutil

def pad_binary_file(file_path, block_size):
    # Expands ROM from 1MB to 2MB (pads with FF)

    file_size = os.path.getsize(file_path)
    padding_needed = block_size
    print("File size - " + str(file_size))
    
    if file_size != 1048576:
        print("No padding needed.")
        return # No padding needed
    else:
        file = 'nhl94_2MB.bin'
        shutil.copy(file_path, file)   
        with open(file, 'ab') as f:
            f.write(bytes.fromhex('FF') * padding_needed)
            print(f"File '{file}' padded to 2 MB.")
        
        # Now, update header and remove checksum

        with open(file, 'rb+') as f:
            f.seek(416)  # 1A0 - ROM Address range
            f.write(bytes.fromhex('00 00 00 00 00 1F FF FF'))  # 1FFFFF = 2MB ROM range
            print(f"File '{file}' ROM header updated to 2MB ROM address range.")
            
            f.seek(1047242) # FFACA - Checksum
            f.write(bytes.fromhex('4E 75')) # Remove checksum check
            print(f"File '{file}' checksum check removed.")
        

if __name__ == "__main__":
    file_path = "nhl94.bin"
    block_size = 1048576 # 1MB
    
    pad_binary_file(file_path, block_size)
    