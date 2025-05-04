Sprites.anim file:

Stored in NHL92 at $3D5EE, it is $34B7E bytes in size. Last byte at $7216B (Start of Crowd.anim at $7216C).

First 2 bytes (41 41), ignore.
Next 2 bytes (02 24) = Number of frames - 1 (so $225 total frames, or 549 decimal).

Buildframelist - makes a table in ram of each frames starting point
    so as to have random access to sprite graphics

First frame data starts at byte 6. This address is saved in the #framelist.

Frame data struct:
SprStratt - offset $A: attribute flags
SprStrhot - offset $C: hotspot data (24 bytes)
SprStrnum - offset $24: # of sprites in this frame
SprStrdat - offset $26: start of sprite tile data bytes (8 bytes per sprite)

Sprite Tile Data Bytes:
Byte 0-1: Y Global position
Byte 2-3: sizetab and top 4 bits of tile data pointer
Byte 4-5: bottom 11 bits of tile data pointer, and palette selection
Byte 6-7: X Global position

Bytes 0-1: Y Global
    Pixel offset of first sprite tile. Added (or subtracted) from Y of the Sort Cord.


Bytes 2-3: Sizetab bytes

    Byte 2: 
        Upper nibble used for the top 4 bits of tile data pointer (more later).
        Bottom nibble used as an index to the sizetab table.

    Sizetab table:

    Lists # of tiles in the sprite, and is linked to their layout:

    Index   |   Value   |   Tile Layout (XY)
    0           1           1x1
    1           2           1x2
    2           3           1x3
    3           4           1x4
    4           2           2x1
    5           4           2x2
    6           6           2x3
    7           8           2x4
    8           3           3x1
    9           6           3x2
    A           9           3x3
    B           C           3x4
    C           4           4x1
    D           8           4x2
    E           C           4x3
    F           10          4x4

Byte 3: Not used, always 00

Bytes 4-5: Data Pointer and Palette

    Data Pointer:
        This points to the starting tile for the sprite. It is an offset from the start of the Sprite Tile Data (the address is stored in Spritetiles during the Buildframelist subroutine.)
        First 11 bits are used for the data pointer (the value is ANDed with $7FF).
        Then the top 4 bits are taken from byte 2 , divided by 2, and ORed with the above result to get the full 15 bits of the pointer.
        The result is then sign-extended long word, multiplied by $20 (32 decimal), and used as an offset to the Spritetiles.

        The address to the start to the sprite tiles, the sizetab value (# of tiles and layout) x 16 decimal, and the (previous sprite tiles (if more than 1 sprite in frame) + VRChar of Sort Cord) * 32 are all stored in the DMA list for VRAM transfer later on.



    Palette:
        The last 5 bits are used for palette. The whole word size of Bytes 4-5 is EORed with the Sort Cord attribute. Then the result is ANDed with $F800 to pass the top 5 bits.
        Bit 0 of Sort Cord attribute+1 is checked, and if not 0, then bit 14 of the result above is checked. If bit 14 is set, then bit 13 is set for team 2 color, and it is stored in the Satt table
        If bit 14 is set, the highest nibble of the data pointer will be either a 4 or a B.

Bytes 6-7: X Global
    Pixel offset of first sprite tile. Added (or subtracted) from X of the Sort Cord.


NHL94:

GetHot accesses another ROM location for SprStrHot X and Y.
Hotlist table - $A44C8 - $A4B53 ? ($68C long?)
Pointer is SortCord frame * 2
Y Hot Spot byte is (Hotlist + frame*2 + 1)
X Hot spot byte is (Hotlist + frame*2)


addframe2:

$5DE7A - pointer list
$5DE7A + 4 = offset to frame data table? $408AA ($9E724?)

Move frame into d4, pass top 5 bits.
EOR d4 with attribute (used for palette later)
Frame back into d4, pass first 11 bits
Move address $5DE7A into a2
Add long word at offset 4 to a2 address ($408AA) - $5DE7A+$408AA = $9E724
Add d4 (frame) to itself
Compare data at 2+a2 ($9E726 - $69E) to d4. Might be max length 
Exit if d4 greater than
Move data at 2+a2+d4 into d5
Sub data at a2+d4 from d5.
Divide d5 by 8, and subtract 1. d5 now has # of sprites in frame (SprStrNum)?
Add data at a2+d4 to a2 (moves to the SprStrdat)

Then it checks if frame is the same as old frame, and will update old frame if on the last sprite in the frame.

a2 now at the Sprite tile data bytes (SprStrdat)
Move bytes 4-5 into d2 (tile pointer)
Move byte 7 into d4 (sizetab byte)
Use d4 as index to sizetab table, and put # tiles into d4

Then it compare to previous d4 and branches if larger. If not, it will do a check if the tile is smaller, than branch. 
If it's the same, and the data is pointing at the same tiles, it will branch to the dup code.

Take d2, mult by 32 decimal. 
Add the Spritetiles address ($5DE84) to d2. d2 now holds the address of the first sprite tile.

Sprite tile data bytes:
Byte 0-1: X Global
Byte 2-3: Y Global
Byte 4-5: Tile offset
Byte   6: Used when setting palette 
Byte   7: Sizetab byte    

$5DE84-$9E724?: Sprite tiles
$9E724-$9EDC2 : Frame sprite data offsets
$9EDC2: Start of sprite data bytes


NHL93:

$3A3A6 - pointer list
$3A3A6 + 4 = offset to frame data table? $3574A ($6FAF0)\
$3A3B0 - Spritetiles

addframe2 is exactly like NHL94

SPAList:

NHL93 - $4D8E
NHL94 - $5B1C



