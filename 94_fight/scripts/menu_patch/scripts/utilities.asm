; Utilities.asm
; This file contains various utility functions for the 94 ROM

; Remove the Checksum validation in the 94 rom	
	IF RemoveChecksum		
		org $300
			NOP
			NOP
			NOP
	ENDIF
	
;Expand ROM to 2MB
	IF ExpandROM
		org $FFFFF
			FILL_FF $100000			
	ENDIF