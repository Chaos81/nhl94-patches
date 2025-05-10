# get_sprites.py
# Retrieve sprites from NHL93 given the SPA value
# Version 0.1 - Initial version

import os


def getFrames(f, offset):
# Retrieve frame list from SPAlist
        list_off = f.read(2)
        SPFlist = []
        time = 0
        print('Offset to SPF list (hex): ' + list_off.hex())
        
        # Create a list of dicts with frame, time keys
        f.seek(offset)
        f.seek(int.from_bytes(list_off, "big"), 1)
        while time >= 0:       
                frame = f.read(2).hex()
                time = f.read(2)
                time = int.from_bytes(time, "big", signed=True)
                SPFlist.append(dict({'frame': frame, 'time': time}))
        
        return SPFlist


script_dir = os.path.dirname(__file__)
print(script_dir)
SPAList_path = os.path.join(script_dir, '93_Tables/SPAList.bin')


print ("get_sprites.py Version 0.1")
spa = 0

while spa != 'exit':
        # Input needed
        spa = input('What is the SPA value? (type exit to quit)-> $')
        if spa == 'exit':
                raise SystemExit
        facedir = input('What direction is the player facing (0-7)? -> ')

        # First, get the frames from the SPAList

        with open(SPAList_path, 'rb') as f:
                offset = int(spa, 16)
                print('Offset: ' + str(offset))
                f.seek(offset + int(facedir)*2)       # seek to current location + offset + facedir*2
                SPFList = getFrames(f, offset)
                print('SPF list for SPA: $' + str(spa) + ' and Direction: ' + str(facedir))
                print(SPFList)

                