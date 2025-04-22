; fight_patch.asm - Add Fighting to NHL94 Genesis
; Created by chaos with help from McMarkis
; Current Version - 0.1
; Version History:
;   Version 0.1 - Initial version

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
;   - doinput (for fightinput)
;   - checkcx (for checkfight)
;
; Note: These subroutines will need some code to be moved in order to hijack, because of the JSR instruction size. The removed code will be run in the new subroutines:
; fightinput: This is called at 0xB25E (bne.w fightinput). A JSR will be needed here.
;    - So, the previous code line needs to be added to the fightinput code (0xB258 - btst #0, $63(a3) ; fighting in progress)
;
; checkfight: This is called at 0x13B1E (bsr.w checkfight). A JSR will be needed here.
;    - The previous 2 lines of code are also bsrs (checkint and checkcheck). These 3 can be combined into a small subroutine, all turned into jsrs.
;
;
;--Patch Equates--
doinput_patch 	equ ($B258)		; Address in doinput to patch code
fightinput	    equ ($105000)	; Address in ROM where the new code will be patched in
checkcx_patch   equ ($13B16)    ; Address in checkcx to patch code
