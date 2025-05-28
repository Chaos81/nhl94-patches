; sprite_patch.asm - Add sprites from NHL93 to NHL94 Genesis
; Created by chaos with help from McMarkis and AbdulBCRT
; Current Version - 0.1
; Version History:
;   Version 0.1 - Initial version - relocate 94 tables that will be modified

;--MACROS--
	include	scripts\macros.mac

;--Load ROM from rom directory--
	org 0
		incbin rom\nhl94_2MB.bin    ; Currently using the expanded ROM, until I create a macro to do it automatically

;--Remove Checksum Code--
	include	scripts\patch_checksum.asm      ; Patches Checksum jmp in ROM

;-----------
;--Equates--
;-----------
; These patch equates are used for patching the existing code.
; ROM subroutines that need to be patched:
;   - GetHot (the HotList table location needs updating)
;   - addframe2 (this might need updating if I decide to move the Spritetiles to free space)
;   - updateanim (the SPAList table location needs updating)
; ROM locations that need to be patched:
;   - The offset to the Frame data offset table needs to be changed (this is at longword $5DE7E)
; 
; The above changes should allow the game to work like normal.
; The amount of space to move the default above tables is:
; SPAList - $1B96
; Spritetiles - $408A0
; Frame sprite data offsets - $69E
; Sprite data bytes - $5706
; Hotlist table - $68C
; Total (excluding Spritetiles) - $7FC6
; Total (including Spritetiles) - $48866
;
;
;--Patch Equates--
GetHotPatch     equ $106F4      ; Move instruction to modify in GetHot
updateanimPatch equ $AEFA       ; Move instruction to modify in updateanim
frmdataPatch    equ $5DE7E      ; dc.l location for offset to Frame Data table
moveLoc         equ $105A00     ; New location for tables

;--------------------------------------------

    org moveLoc                 ; arbitrary start position
SPAList
        ;incbin 94_Tables\SPAList.bin
        incbin 94_Tables\SPAListFight.bin
FrmSprDataOff
        ;incbin 94_Tables\FrmSprDataOff.bin
        incbin 94_Tables\FrmSprDataOff_Fight.bin
SprData
        incbin 94_Tables\SprData.bin
HotList
        ;incbin 94_Tables\Hotlist.bin
        incbin 94_Tables\Hotlist_FightAdj.bin


; Now, patch the ROM

    org GetHotPatch
    movea.l #HotList, a1        ; Replace move instruction with new one

    org updateanimPatch
    movea.l #SPAList, a0        ; Replace move instruction with new one

    org frmdataPatch
    dc.l FrmSprDataOff-$5DE7A   ; Calculate new offset and store it