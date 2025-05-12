# get_sprites.py
# Retrieve sprites from NHL93 given the SPA value
# Version 0.1 - Initial version
# Version 0.2 - Output every facedir animation list for given SPA

import os

class Anim:
# Contains SPA value, list of facedir and the SPA attribute word
        def __init__(self, spa):
                self.spa = spa
                self.offset = int(spa, 16)
                self.facedir = []       # 8 entries(0-7 directions) of a list of dicts (frame, time keys)
                self.attrib = 0




def getFrames(f, animlist):
# Retrieve frame list for SPA, one direction at a time
        direction = [0,1,2,3,4,5,6,7]

        # First, get SPA attribute
        f.seek(animlist.offset + 16)
        animlist.attrib = f.read(2).hex()
        

        for dir in direction:   # loop through the direction array, retreive frame, time and create a list of dict
                f.seek(animlist.offset + (dir * 2))     # move to direction offset        
                list_off = f.read(2)    # read offset to SPF list
                time = 0
                SPFlist = []
                print('Offset to SPF list (hex): ' + list_off.hex())
        
                # Create a list of dicts with frame, time keys
                f.seek(animlist.offset)
                f.seek(int.from_bytes(list_off, "big"), 1)      # relative shift
                
                while time >= 0:        # retrieve frame, time groupings until the last frame (negative time)       
                        frame = f.read(2).hex()
                        time = f.read(2)
                        time = int.from_bytes(time, "big", signed=True)
                        SPFlist.append(dict({'frame': frame, 'time': time}))
                
                # Insert into facedir list
                animlist.facedir.append(SPFlist)
        


script_dir = os.path.dirname(__file__)
print(script_dir)
SPAList_path = os.path.join(script_dir, '93_Tables/SPAList.bin')
FrmData_path = os.path.join(script_dir, '93_Tables/FrmSprDataOff.bin')
Hotlist_path = os.path.join(script_dir, '93_Tables/Hotlist.bin')
SprData_path = os.path.join(script_dir, '93_Tables/SprData.bin')






print ("get_sprites.py Version 0.2")
spa = 0

while spa != 'exit':
        # Input needed
        spa = input('What is the SPA value? (type exit to quit)-> $')
        if spa == 'exit':
                raise SystemExit

        # First, get the frames from the SPAList

        with open(SPAList_path, 'rb') as f:
                animlist = Anim(spa)
                print('Offset: ' + str(animlist.offset))
                # f.seek(offset + int(facedir)*2)       # seek to current location + offset + facedir*2
                  
                getFrames(f, animlist)
                count = 0
                for dir in animlist.facedir:
                        print('SPF list for SPA: $' + str(spa) + ' and Direction: ' + str(count))
                        print(dir)
                        count+=1


                