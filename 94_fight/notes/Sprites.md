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
Byte 4-5: bottom 11 (0-10) bits of tile data pointer, H/V flip priority (bits 11+12), palette (13-15)
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

Bytes 4-5: Data Pointer, Flip and Palette

    Data Pointer:
        This points to the starting tile for the sprite. It is an offset from the start of the Sprite Tile Data (the address is stored in Spritetiles during the Buildframelist subroutine.)
        First 11 bits (0-10) are used for the data pointer (the value is ANDed with $7FF).
        Then the top 4 bits are taken from byte 2 , divided by 2, and ORed with the above result to get the full 15 bits of the pointer.
        The result is then sign-extended long word, multiplied by $20 (32 decimal), and used as an offset to the Spritetiles.
    
        The address to the start to the sprite tiles, the sizetab value (# of tiles and layout) x 16 decimal, and the (previous sprite tiles (if more than 1 sprite in frame) + VRChar of Sort Cord) * 32 are all stored in the DMA list for VRAM transfer later on.

    Flip:
        Bits 11 and 12 are used for H and V flip of the sprite. This is used in the SetSFrame routine, when looking at attribute of the Sort Cord. If the lower nibble is 8 or higher, the sprite will be H flipped by default. If the upper nibble is odd, it will be V flipped by default. The SetSFrame will adjust for flipping it opposite if needed.

    Palette:
        The last 2 bits are used for palette. The whole word size of Bytes 4-5 is EORed with the Sort Cord attribute. Then the result is ANDed with $F800 to pass the top 5 bits.
        Bit 0 of Sort Cord attribute+1 is checked, and if not 0, then bit 14 of the result above is checked. If bit 14 is set, then bit 13 is set for team 2 color, and it is stored in the Satt table
        If bit 14 is set, the highest nibble of the data pointer will be either a 4 or a B.

Bytes 6-7: X Global
    Pixel offset of first sprite tile. Added (or subtracted) from X of the Sort Cord.


NHL94:

GetHot looks at another ROM location for SprStrHot X and Y.
Hotlist table - $A44C8 - $A4B54 ($68C long)
Pointer is SortCord frame * 2
Y Hot Spot byte is (Hotlist + frame*2 + 1)
X Hot spot byte is (Hotlist + frame*2)


addframe2:

$5DE7A - pointer list
$5DE7E = offset to frame data table? $408AA ($9E724)

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

Then it compares to previous d4 and branches if larger. If not, it will do a check if the tile is smaller, than branch. 
If it's the same, and the data is pointing at the same tiles, it will branch to the dup code.

Take d2, mult by 32 decimal. 
Add the Spritetiles address ($5DE84) to d2. d2 now holds the address of the first sprite tile.

Sprite tile data bytes:
Byte 0-1: X Global
Byte 2-3: Y Global
Byte 4-5: Tile offset
Byte   6: Used when setting palette 
Byte   7: Sizetab byte    


NHL94 addresses:

$5B1C-$76B2: SPAList ($1B96 long)
$5DE84-$9E724: Sprite tiles ($408A0 long)
$9E724-$9EDC2: Frame sprite data offsets ($69E long) - first 2 bytes (0000) and last 2 bytes ($5DA6) are just used for start and end, so $69A bytes are used (845 frames)
$9EDC2-$A44CA: Sprite data bytes ($5708 long, 2785 total sprites)
$A44CA-$A4B54: Hotlist table ($68A long) - this is missing data for the last 8 frames? The last 8 frames are the extra arrows and stars for 3rd and 4th player (4-way play). They dont have hotspots.


NHL93 addresses (v1.1 ROM):
$4D8E-$6446: SPAList ($16B8 long)
$3A3B0-$6FAF0: Sprite tiles ($35740 long)
$6FAF0-$70006: Frame sprite data offsets ($516 long) - first 2 bytes (0000) and last 2 bytes (490E) are just used for start and end, so $512 bytes are used (649 frames)
$70006-$743FE: Sprite data bytes ($43F8 long, 2175 total sprites)
$743FE-$74910: Hotlist table ($512 long) 

$3A3A6 - pointer list
$3A3A6 + 4 = offset to frame data table $3574A ($6FAF0)
$3A3B0 - Spritetiles

addframe2 is exactly like NHL94

-----------------------------------------
Path to retrieve the frame:

Example: SPAFight (93) - $F8E

- SPAlist address into a0
- add SPA to a0 address ($4D8E+$F8E=$5D1C)
- Move SPA attribute word into d1 (word located at current a0 + $10)
- Move facedir into d0
- Mult d0 by 2
- add data at a0+d0 into a0 address (move SPF value into a0 address based on facedir and SPA)
- Move SPANum into d0 (index into animation)
- Add a0+d0 offset into d2. d2 now holds the new frame
- If new frame (SPACnt is negative), move frame time into d0, check if frame is negative (last frame). negate if needed
- d0 goes into SPAcnt
- Check if glitch is 0 (4 frame delay to switch animations)
- Move d2 into frame
- Reset glitch to 4

SPA attribute word for SPAFight - $5D1C + $10 = $5D2C. Flags are all 0
In case of SPAFight, facedir 0-2, and 3-7 have the same offset on their SPAlist
So, facedir 2 has offset of $12, facedir 3 has offset of $22
$5D1C+$12=$5D2E      $5D1C+$22=$5D3E

$5D2E - SPAfight animation frame list for facedir 0-2
$5D3E - SPAfight animation frame list for facedir 3-7

$5D2E list - $162,8,$163,8,$164,8,$165,$FFFA (frame, time) Last time is negative to denote last frame in animation
$5D3E list - $162,8,$163,8,$164,8,$16A,$FFFA


Now, addframe2 goes into play.

Frame $162:
$162 AND $7FF = $162
$162 * 2 = $2C4
$6FAF0 + $2C4 = $6FDB4

Data at $6FDB4 = $2B46
Data at $6FDB4 + 2 = $2B66
Difference is $20
$20 / 8 = 4. 4 - 1 = 3. 3 sprites in frame
$6FAF0 + $2B46 = $72636, the location of the sprite data bytes

Sprite 1:

$FFF7 - X global    (-9)
$FFE2 - Y global    (-30)
$0698 - Tile offset
$40 - Used for palette
$07  - Sizetab byte (2x4 sprite)

Tile data offset - $698 * $20 (32 decimal) = $D300
Tile data starts at $3A3B0 + $D300 = $476B0

Sprite 2:

$0007 - X global    (7)
$FFE2 - Y global    (-30)
$18DA - Tile offset
$40 - Used for palette
$00 - Sizetab byte (1x1 sprite)

Tile data offset - $18DA * $20 = $31B40
Tile data starts at $3A3B0 + $31B40 = $6BEF0

Sprite 3:

$FFEF   (-17)
$FFFA   (-6)
$18D9
$40
$00

$18D9 * $20 = $31B20
$3A3B0 + $31B20 = $6BED0

-------------------------------------------------------

Moving tables in NHL94:

SPAList, Frame sprite data offsets, Sprite data bytes, Hotlist table need to be moved.
Spritetiles can probably stay, and new tiles will be added in the space that is freed up.
Frame sprite data offsets will need to be updated and shifted based on how many frames are added.

ROM subroutines that need to be patched:
   - GetHot (the HotList table location needs updating)
   - addframe2 (this might need updating if I decide to move the Spritetiles to free space)
   - updateanim (the SPAList table location needs updating)
 ROM locations that need to be patched:
   - The offset to the Frame data offset table needs to be changed (this is at longword $5DE7E)

SPA from 93 that need to be ported over to 94:

SPAfight    $F8E - frames 
SPAfhigh    $1004
SPAflow     $1036
SPAfgrab    $FC0
SPAfhith    $1068
SPAfhitl    $108A
SPAfheld     $FE2
SPAffall    $10CE
SPAbfall    $10AC

$F8E
$FC0
$FE2
$1004
$1036
$1068
$108A
$10AC
$10CE


Adding data from NHL93 to 94:

- Add the necessary SPA and SPF data to the end of SPAlist. Change frame labels of added SPA and SPF. - done
- Add frame Hotspots XY to HotList - done
- Add new sprite tiles to Spritetiles, get starting addresses of the tiles so they can be converted for the sprite data bytes - done
- Add sprite data bytes, update tile offset - done
- Add frames to frame table, update all frame offsets - done
- Update the SPAs in the code for the required animations
- Change SPFgloves to point to the right frame (SPFgloves is $161, set at $16E7C in 94) - done

Spritetiles:
- 4bpp format (1 byte per 2 pixels)
- Tile size is 8x8 pixels (64 pixels, 32 bytes per tile)

- 24 empty frames in 94 (353-376 decimal)
- 24 fighting frames in 93 (353-376 decimal)
- Frame 353 is the gloves


SPAList_Fight.bin:

0000 - SPAfight - $1B96
0032 - SPAfgrab - $1BC8
0054 - SPAfheld - $1BEA
0076 - SPAfhigh - $1C0C
00A8 - SPAflow  - $1C3E
00DA - SPAfhith - $1C70
00FC - SPAfhitl - $1C92
011E - SPAffall - $1CB4
0140 - SPAbfall - $1CD6

Hotlist_Fight.bin:

Starts with frame $161 (SPFgloves), ends with frame $178 (part of $SPAbfall)

New Frame designation start: (93 to new 94)
Frame 353 - Frame 846 ($34E)
Frame 353 - Frame 847 ($34F)

