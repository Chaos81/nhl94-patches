; credits_patch.asm - Patch ROM and insert new credits
; Created by chaos
; Current Version - 1.0
; Version History:
;   Version 1.0  - Initial version

; Format: length - length (word size) of text, including the 2 bytes for the length


;-----------
;--Equates--
;-----------
; These patch equates are used for patching the existing code.

textLoc     equ $5776       ; start of scrolling text, $3A6 size, can be longer now since SPAList has been moved

;------------
;--Patches--
;------------

; NOTE: - org needs to be tabbed once!

    org textLoc
        incbin data/scroll_text.bin