; Menu Patch made by McMarkis, modified by chaos to be included in fight_patch.asm
;   Version 0.1 - Initial modification

;--MACROS--
	include	menu_patch\scripts\macros.mac

;--CONFIGURATION--  (set to 0, don't need 99 min OT, ROM already expanded and checksum removed)
ExpandROM = 0			; Expand ROM to 2MB (0 = No, 1 = Yes)
RemoveChecksum = 0		; Remove the Checksum validation in the 94 rom (0 = No, 1 = Yes)
Set99MinOvertime = 0	; Set 99 Min OT (0 = No, 1 = Yes)
;--END CONFIGURATION--	
	
;-----------
;--Equates--
;-----------
;--Patch Equates--
;NewCodeAddress			equ ($0FFB10)					; Address in ROM where the new code will be added (this is added at the end of fight_patch.asm, so no need to use this)
NewMenuRAM  			equ $FFFFDF00					; Address in RAM where the new menu items will be stored
NewMenuRamOffset  		equ NewMenuRAM-OptPlayMode-18  	; Calculates Offset for the NewMenuRamm starting address.
MenuItemsCount 			equ (MenuEnd-MenuStart)/16  	; Calculates the number of menu items from menuitems.asm
ScrollableItemsCount	equ (MenuItemsCount-6)			; Number of scrollable items in the menu
OptFight        		equ NewMenuRAM+0				; Address in RAM where the Fighting Mode is stored

;--NHL 94 Equates--
word_FFD422		equ $FFFFD422	; RAM Address of the scrolling menu item
OptPlayMode		equ $FFFFD048	; RAM Address of the Play Mode Option
	
;-----------------------------
;-- Actual Patch Assembly Code
;-----------------------------

;--Handles Checksum and Rom Expansion--
;	include	scripts\utilities.asm                           ; (not needed)
	
; New Code That gets added to the ROM
;	org NewCodeAddress								        ; <-- Location in ROM to place new Menu Items + SubMenu Items + New Code - not needed since it is at end of fight_patch.asm
		include	menu_patch\scripts\menu\menuitems.asm		; <-- Main Menu Items
		include menu_patch\scripts\menu\submenuitems.asm	; <-- Sub Menu Items
		include menu_patch\scripts\menu\menulengths.asm		; <-- Main Menu Lengths
		include menu_patch\scripts\menu\menulengths2.asm	; <-- Main Menu Lengths for Fourway Play (MultiTap)
		include menu_patch\scripts\menu\writenewmenuram.asm	; <-- Code to Write New Menu RAM Addresses
		include menu_patch\scripts\menu\readnewmenuram.asm	; <-- Code to Read New Menu RAM Addresses				
;		include menu_patch\scripts\fighting\fighting.asm	; <-- Code to add the Fighting (not needed, added to end of fight_patch code)
		
; Hijack Code needs to be after the new code so it doesn't mess up assembler org values
		include menu_patch\scripts\menu\menuhijack.asm		; <-- Code to Hijack Old Menu Items and SubMenu Items		
;		include scripts\fighting\fightinghijack.asm		    ; <-- Code to Hijack for fighting (not needed, added to end of fight_patch code)