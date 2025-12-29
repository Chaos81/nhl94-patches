; title_patch.asm - Patch ROM and insert new title screen to 30-team ROM location
; Created by chaos
; Current Version - 1.0
; Version History:
;   Version 1.0  - Initial version

; Patch location for title screen new address - $FF10C, $FF13E
; 30 team ROM title screen address $0011259C
; title screen palette $1195A6

;Layout of graphics
; Header ($A bytes long):
; 4 bytes - length of tile data + header
; 4 bytes - length of tile data + header + palette (start of tile layout)
; 2 bytes - # of tiles
; Tile data: 32 bytes per tile (8x8 pixels)
; Palette data: Length is difference of the first sets of 4 bytes in header
; Image size (in tiles): Start if tile layout, 2 bytes X tiles, 2 bytes Y tiles
; Tile layout: 2 bytes per tile

;-----------
;--Equates--
;-----------
; These patch equates are used for patching the existing code.

TitleScrnPtr1   equ $FF10C
TitleScrnPtr2   equ $FF13E
ShieldPtr       equ $FF17C
PAlogoPtr       equ $FF1A8
TitlePtr        equ $FF1D4
PalChange       equ $FF210

NewTitleScrn    equ $11259C
NewShield       equ $119D2C
NewPA           equ $11A52A
NewTitle        equ $11AC18

;------------
;--Patches--
;------------

; NOTE: - org needs to be tabbed once!

    org TitleScrnPtr1
        movea.l #NewTitleScrn,a0
    
    org TitleScrnPtr2
        movea.l #NewTitleScrn,a0
    
    org ShieldPtr
        movea.l #NewShield,a0
    
    org PAlogoPtr
        movea.l #NewPA,a0
    
    org TitlePtr
        movea.l #NewTitle,a0

    org NewTitleScrn
        incbin data/title_screen.bin
    
    org PalChange
        dc.b $0E
        dc.b $F0

