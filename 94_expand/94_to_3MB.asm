; 94_to_3MB.asm - Expand an NHL94 ROM to 3MB, patch SRAM access
; Created by chaos 
; Current Version - 0.1
; Version History:
;   Version 0.1 - Initial version

;--MACROS--
	include	scripts\macros.mac

;--Load ROM from rom directory--
	org 0
		incbin rom\temp.bin                 ; Copy temp.bin into new file

;--Pad the file to 3MB--
    freespace:
        dcb.b   $300000-*, $FF              ; Pad file with FF up to 3MB size, change to 400000 to pad to 4MB

;--Remove Checksum Code--
	include	scripts\patch_checksum.asm      ; Patches Checksum jmp in ROM

;-----------
;--Equates--
;-----------
; These patch equates are used for patching the existing code.
; ROM subroutines that need to be patched:
;   - InitSaveRAM ($1A050) - Looks like it loads to Save RAM and tests it
;   - ReadSaveRAM ($1A244) - Read from Save RAM
;   - WriteSaveRAM ($1A1E4) - Writes to Save RAM
;
; Note: These subroutines will need some code to be moved in order to hijack, because of the JSR instruction size. The removed code will be run in the new subroutines:
; InitSaveRAM: This is called during the Begin subroutine, when the game first loads.
;				It writes to Save RAM to test, or clears all Save RAM when a button combination is pressed.
;		- This will need to be re-written and a JSR added in its original location.
;
; ReadSaveRAM: This is called to access Save RAM.
;		- This will need to be re-written and a JSR added in its original location.
;
; WriteSaveRAM: This is called to write to Save RAM.
;		- This will need to be re-written and a JSR added in its original location.
;
;
;--Patch Equates--
initSRAMPatch	equ $1A050		; addresses to patch in JSR
readSRAMPatch	equ $1A244		
writeSRAMPatch	equ $1A1E4

;--NHL 94 Equates--
ReadJoy1		equ $11340
ClearRAM		equ $1A14E

;--RAM Variables--
vbint			equ $FFFFB03A