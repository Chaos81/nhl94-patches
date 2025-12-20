; title_patch.asm - Patch ROM and insert new title screen in 30-32 team ROM area
; Created by chaos with help from McMarkis and AbdulBCRT
; Current Version - 0.98
; Version History:
;   Version 0.1  - Initial version

; Patch location for title screen new address - $FF10E, $FF140
; 30 team ROM title screen address $0011259C
; title screen palette $1195A6

;Layout of graphics
; Header ($A bytes long):
; 4 bytes - length of tile data + header
; 4 bytes - length of tile data + header + palette (start of tile layout)
; 2 bytes - # of tiles
; Tile data: 32 bytes per tile (8x8 pixels)
; Palette data: Length is difference of the first sets of 4 bytes in header
; Tile layout: 2 bytes per tile