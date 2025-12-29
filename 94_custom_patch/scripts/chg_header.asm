; chg_header.asm - Change title and serial # of ROM
; Created by chaos
; Current Version - 1.0
; Version History:
;   Version 1.0  - Initial version

;------------
;--Patches--
;------------

    org $120        
        dc.b 'NHL Hockey ''94-Fight'                ; Domestic ROM name
        dcb.b $150-*, ' '                           ; Pad the rest of the name space
    
    org $150        
        dc.b 'NHL Hockey ''94-Fight'                ; International ROM name
        dcb.b $180-*, ' '                           ; Pad the rest of the name space

    org $180
        dc.b 'GM T-50656 -0F'                       ; Serial #
