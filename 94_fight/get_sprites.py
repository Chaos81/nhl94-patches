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

def getFrmData(frame, file, sprfile):
# Get Frame Data and Sprite Data for files given
# # of sprites in frame = ((Next Frame offset - Current Frame offset) / 8) -1

        frmdata = []
        count = 0

        with open(file, 'rb') as f:
                f.seek(int(frame, 16) * 2, 0)   # move to frame offset
                offset = f.read(2).hex()
                nextoff = f.read(2).hex()
                numsprites = ((int(nextoff, 16) - int(offset, 16)) / 8) - 1
                

                

def getSprData(file):
# Organize Sprite Data from the file given
# Each group of Sprite Data is 8 bytes long
#       Byte 0-1 - X Global Position
#       Byte 2-3 - Y Global Position
#       Byte 4-5 - Sprite Tile Offset
#       Byte 6   - H/V Flip priority and Palette
#       Byte 7   - Sizetab byte (Tile layout)

        tilelayout = ['1x1','1x2','1x3','1x4','2x1','2x2','2x3','2x4','3x1','3x2','3x3','3x4','4x1','4x2','4x3','4x4']
        sprdata = []
        count = 0
        size = os.path.getsize(file)    # size of file
        print(size)
        count = size / 8        # # of sprite data in file
        print(count)
        with open(file, 'rb') as f:
                while count > 1:        # last sprite data is garbage
                        xoff = f.read(2).hex()
                        yoff = f.read(2).hex()
                        toff = f.read(2).hex()
                        flippal = f.read(1).hex()
                        sizetab = f.read(1)
                        layout = tilelayout[int.from_bytes(sizetab, "big")]
                        sprbytes = dict({'Xoffset': xoff, 'Yoffset': yoff, 'TilePtr': toff, 'HVFlippal': flippal, 
                                'Sizetab': sizetab.hex(), 'Layout': layout})
                        print(sprbytes)
                        sprdata.append(sprbytes)
                        count -= 1
                        
        return sprdata

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

# Collect Sprite data and store it in a list of dicts

sprdata = getSprData(SprData_path)

# Collect frame data and store it in a list of dicts
frmdata = getFrmData(FrmData_path, SprData_path)

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


                