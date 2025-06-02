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
                self.framelist = []

def getFrmData(file, sprdata, hotdata):
# Get Data associated with frames
# # of sprites in frame = ((Next Frame offset - Current Frame offset) / 8)

       
        frmdata = []
        count = 0
        sprcount = 0
        sprlist = []
        sprites = 0
        size = os.path.getsize(file)    # size of file
        numframes = (size) / 2 - 2   # # of frames (first frame and last frame are not real)

        with open(file, 'rb') as f:
                f.seek(2)       # skip first 2 bytes (0000)
                while count < numframes:
                        # print ('Frame ' + str(count + 1) + ': ')
                        offset = f.read(2).hex()
                        nextoff = f.read(2).hex()
                        numsprites = int(((int(nextoff, 16) - int(offset, 16)) / 8))
                        sprtotal = numsprites
                        # print('Sprites: ' + str(numsprites))
                        sprites += numsprites
                        sprlist = []
                        while numsprites != 0:
                                # Retrieve sprite data, store in list
                                spr = sprdata[sprcount]
                                sprlist.append(spr)
                                # print(sprlist)
                                sprcount += 1
                                numsprites -= 1
                        # Retrieve hotspot data
                        hotspot = hotdata[count]
                        
                        # Store sprite data and hotspots in frmdata list
                       
                        frmdata.append(dict({'Offset': offset, 'Sprites': sprtotal, 'Sprite Data': sprlist, 'Hotspot Data': hotspot}))
                        
                        # Set variables for next run
                        
                        count += 1
                        f.seek(-2, 1)   # move back 2 bytes on seek
        # print(frmdata)
        
        return frmdata

                

                

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
        numsprites = (size) / 8        # # of sprite data in file
        with open(file, 'rb') as f:
                while count < numsprites:        
                        xoff = f.read(2).hex()
                        yoff = f.read(2).hex()
                        toff = f.read(2).hex()
                        flippal = f.read(1).hex()
                        sizetab = f.read(1)
                        layout = tilelayout[int.from_bytes(sizetab, "big")]
                        sprbytes = dict({'Xoffset': xoff, 'Yoffset': yoff, 'TilePtr': toff, 'HVFlippal': flippal, 
                                'Sizetab': sizetab.hex(), 'Layout': layout})
                        # print('Sprite Data ' + str(count) + ': '+ str(sprbytes))
                        sprdata.append(sprbytes)
                        count += 1
                       
        return sprdata

def getHotData(file):
# Get HotSpot data for each frame
# Byte 0 - X HotSpot
# Byte 1 - Y HotSpot

        hotdata = []
        size = os.path.getsize(file)    # size of file
        numhot = size / 2
        count = 1
        # print('# of HotSpots: ' + str(numhot))

        with open(file, 'rb') as f:
                while count <= numhot:
                        xhot = f.read(1).hex()
                        yhot = f.read(1).hex()
                        hot = dict({'XHot': xhot, 'YHot': yhot})
                        hotdata.append(hot)
                        #print('Frame ' + str(count) + ': ' + str(hot))
                        count += 1
        return hotdata

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

                        # Add frame to framelist, keep list unique
                        if frame not in animlist.framelist:
                                animlist.framelist.append(frame)                   
                
                # Insert into facedir list
                animlist.facedir.append(SPFlist)

def modFrmSprData(file, frmdata):
# Collect frame data for fight frames (frames 353-376) and modify the FrmSprDataOff_Fight.bin accordingly
        
        count = 352     # Starting fight frame (glove/stick sprites)
        countend = 375  # Ending of fight frames
        spritecnt = 0
        framecnt = 0

        with open(file, 'rb+') as f:
                f.seek(-2, 2)   # move to last 2 bytes of file
                while count <= countend:
                        off = int.from_bytes(f.read(2), "big")  # offset of this frame
                        data = frmdata[count]
                        sprites = data['Sprites']  # get sprite count
                        newoff = off + (sprites * 8)  # 8 bytes per sprite
                        #print('Frame: ' + str(count))
                        #print('# of Sprites: ' + str(sprites))
                        #print('Current Offset: ' + hex(off))
                        #print('New Offset: ' + hex(newoff))
                        f.write(newoff.to_bytes(2, "big"))
                        f.seek(-2, 2)
                        count += 1
                        framecnt += 1
                        spritecnt += sprites
                
                print ('Total new frames: ' + str(framecnt))

                # Now, update the frame table offsets since the table got larger by spritecnt sprites
                f.seek(2) # skip first 2 bytes in file (0000)
                addtooff = framecnt * 2 # 2 bytes per frame
                while chunk := f.read(2):
                        off = int.from_bytes(chunk, "big")
                        newoff = off + addtooff
                        print('Old Offset: ' + hex(off))
                        print('New Offset: ' + hex(newoff))
                        f.seek(-2, 1) # move to beginning of read bytes so we can overwrite
                        f.write(newoff.to_bytes(2, "big"))


def modSprTileData(file, newfile, sprtilelist):
# Retrieve Sprite Tile Data for sprites on tile list, add to new file
# Data is 4bpp (2 pixels/byte). A standard 1x1 tile (8x8 pixels) = 32 bytes
# Will create an updated tile offset and store it in a dict with the old tile offset

        sprmod = []
        sizetab = [1,2,3,4,2,4,6,8,3,6,9,12,4,8,12,16]
        sprtile94 = 8261  # Length of 94 spritetiles (Spritetiles.bin) / 32
        count = 0

        with open(file, 'rb') as f, open(newfile, 'rb+') as w:
                f.seek(0)  # initial position
                w.seek(0)  # initial position
                for tileinfo in sprtilelist:
                        # Cycle through tile offsets, grab data from file, add to newfile
                        ptr =  tileinfo[0] * 32  # ptr * 32
                        size = sizetab[tileinfo[1]] * 32  # num of tiles * 32 bytes
                        f.seek(ptr)
                        tile = f.read(size)
                        pos = w.tell()
                        newptr = sprtile94 + (pos / 32)  # new offset
                        sprmod.append((tileinfo[0], int(newptr)))  # add tuple of pointers to be used to update frame sprite data
                        size = w.write(tile)
                        
                        # print('Sprite Tile starting at ' + hex(ptr) + ' written to new file at position ' + hex(pos))
                        # print('New Sprite Tile offset: ' + str(newptr))
                        count += 1

        print('Total Sprites added: ' + str(count))
        return sprmod

def modSprData(file, frmdata, sprmod):
# Cycle through Sprite data, save in file with new tile offset
# Sprite tile data bytes:
# Byte 0-1: X Global
# Byte 2-3: Y Global
# Byte 4-5: Tile offset
# Byte   6: Used when setting palette 
# Byte   7: Sizetab byte 

        startfrm = 352 
        endfrm = 375
        count = startfrm
        bytecnt = 0
        sprcount = 0
       
        with open(file, 'rb+') as f:
                f.seek(0)
                while count <= endfrm:  # Cycle through frames for updating
                        data = frmdata[count]                      
                        # Cycle through sprite data bytes
                        for sprite in data['Sprite Data']:
                                sprbytes = bytearray()  # Init sprbytes
                                ptr = int(sprite['TilePtr'], 16)  # Convert to int to make it easier to compare
                                # print('Old Ptr: ' + str(ptr))
                                newptr = 0
                                
                                # Cycle through sprmod to match up tile offset
                                for offsets in sprmod:
                                       
                                        if ptr == (offsets[0]):
                                                newptr = hex(offsets[1])[2:]  # Remove the 0x in front of hex string
                                                # print('New Ptr: ' + str(newptr))
                                
                                # Insert sprite data bytes into file
                                sprbytes += bytearray.fromhex(sprite['Xoffset'])
                                sprbytes += bytearray.fromhex(sprite['Yoffset'])
                                sprbytes += bytearray.fromhex(newptr)
                                sprbytes += bytearray.fromhex(sprite['HVFlippal'])
                                sprbytes += bytearray.fromhex(sprite['Sizetab'])
                                print(sprbytes.hex())
                                f.write(sprbytes)
                                bytecnt += 1
                        count += 1
                print('Total Sprite Data Sets Added: ' + str(bytecnt))


script_dir = os.path.dirname(__file__)
SPAList_path = os.path.join(script_dir, '93_Tables/SPAList.bin')
FrmData_path = os.path.join(script_dir, '93_Tables/FrmSprDataOff.bin')
Hotlist_path = os.path.join(script_dir, '93_Tables/Hotlist.bin')
SprData_path = os.path.join(script_dir, '93_Tables/SprData.bin')
Sprtile_path = os.path.join(script_dir, '93_Tables/Spritetiles.bin')

FrmDataMod_path = os.path.join(script_dir, '93_Tables/FrmSprDataOff_Fight.bin')
SprTileMod_path = os.path.join(script_dir, '93_Tables/Spritetiles_Fight.bin')
SprDataMod_path = os.path.join(script_dir, '93_Tables/SprData_Fight.bin')

print ("get_sprites.py Version 0.2")

# Collect SPAList and store it in list of dicts

# Collect Sprite data and store it in a list of dicts
sprdata = getSprData(SprData_path)

# Collect hotspot data and store it in list of dicts
hotdata = getHotData(Hotlist_path)

# Collect frame data and store it in a list of dicts
frmdata = getFrmData(FrmData_path, sprdata, hotdata)

# Modify the Frame Sprite Offset File for Fighting
# modFrmSprData(FrmDataMod_path, frmdata)

spainput = 0

while spainput != 'exit':
        # Input needed
        frmlist = []
        fightlist = ['0F8E', '0FC0', '0FE2', '1004', '1036', '1068', '108A', '10AC', '10CE']

        sprtilelist = []

        spainput = input('What is the SPA value? (type exit to quit)-> $')
        if spainput == 'exit':
                raise SystemExit

        # First, get the frames from the SPAList
        print('Frame 161: ')
        print('Frame Data: ')
        glvframe = frmdata[352]
        print(glvframe)
        for sprdata in glvframe['Sprite Data']:
                # Add sprite tile to tile list, keep list unique
                        tiledata = int(sprdata['TilePtr'], 16), int(sprdata['Sizetab'], 16)
                        if tiledata not in sprtilelist:
                                sprtilelist.append(tiledata) 
        print('Sprite Tiles used in this frame: ')
        print(sprtilelist) 
        
        with open(SPAList_path, 'rb') as f:
                for spa in fightlist:
                        data = []
                        animlist = Anim(spa)
                        print('Offset: ' + str(animlist.offset))
                        # f.seek(offset + int(facedir)*2)       # seek to current location + offset + facedir*2
                        
                        getFrames(f, animlist)
                        count = 0
                        for dir in animlist.facedir:
                                print('SPF list for SPA: $' + str(spa) + ' and Direction: ' + str(count))
                                print(dir)
                                count+=1
                        print('Frames used in this list: ')
                        for frame in animlist.framelist:        # Print frame data for each frame used in animation
                                print('Frame: ' + frame)
                                data = frmdata[int(frame, 16) - 1]      # frmdata[0] = Frame 1
                                print('Frame Data: ' + str(data))
                                
                                # Look for unique sprite tiles

                                for sprdata in data['Sprite Data']:
                                        # Add sprite tile to tile list, keep list unique
                                        tiledata = int(sprdata['TilePtr'], 16), int(sprdata['Sizetab'], 16)
                                        if tiledata not in sprtilelist:
                                                sprtilelist.append(tiledata)

                                
                # print('Unique Sprite Tile Count: ')
                # print(len(sprtilelist))
                # print('Unique Sprite Tiles Pointers: ')
                sprtilelist.sort()
                # print(sprtilelist)
                sprmod = modSprTileData(Sprtile_path, SprTileMod_path, sprtilelist)
                modSprData(SprDataMod_path, frmdata, sprmod)






        


        



