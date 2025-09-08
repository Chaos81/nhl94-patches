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
;   - sub_1A050 - many spots (looks like it loads to Save RAM and tests it)
;   - AccessSaveRAM ($1A244) - Read from Save RAM
;   - WriteSaveRAM ($1A1E4) - Writes to Save RAM
;
; Note: These subroutines will need some code to be moved in order to hijack, because of the JSR instruction size. The removed code will be run in the new subroutines:
; fightinput: This is called at 0xB25E (bne.w fightinput). A JSR will be needed here.
;    - So, the previous code line needs to be added to the fightinput code (0xB258 - btst #0, $63(a3) ; fighting in progress)
;
; checkfight: This is called at 0x13B1E (bsr.w checkfight). A JSR will be needed here.
;    - The previous 2 lines of code are also bsrs (checkint and checkcheck). These 3 can be combined into a small subroutine, all turned into jsrs.
;
; To display the Fighting attribute in the Team Rosters and Edit Lines screens, the Attribute headers from NHLPA93 need to be copied in and 
; referenced. The headers contain data used by the code to look up the attribute for display. Also, the math for displaying the Fighting 
; attribute needs to be changed at $8E3E.
;
; The pointers to the Attribute Header strings need to be updated as well. There are 2 spots for the Team Rosters and Edit Lines, 
; and 2 spots for Shootout Mode. The Shootout Mode pointers point to + $16 from the start of the header strings.
;
;--Patch Equates--
doinputPatch 	equ $B258		; Address in doinput to patch code
checkcxPatch   	equ $13B16    	; Address in checkcx to patch code
asstabPatch		equ $18DCC		; Address for assfight on asstab to patch code
fgtdispPatch	equ $8E3E		; Address to change math for Fighting attribute display
attdispPatch1	equ $84DA		; Pointers to update to new Attrib Disp strings
attdispPatch2	equ $8BD6
attdispPatch3	equ $FC85C		
attdispPatch4	equ $FC88E
newCode			equ $105000		; Address in ROM where the new code will be patched in

