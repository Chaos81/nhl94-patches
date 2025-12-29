; 94_to_3MB.asm - Expand an NHL94 ROM to 3MB, patch SRAM access
; Created by chaos 
; Current Version - 1.0
; Version History:
;   Version 0.1 - Initial version
;   Version 1.0 - Official version, update ROM header


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
;   - ReadSRAM ($1A244) - Read from Save RAM
;   - WriteSRAM ($1A1E4) - Writes to Save RAM
;
; Note: These subroutines will need some code to be moved in order to hijack, because of the JSR instruction size. The removed code will be run in the new subroutines:
; InitSRAM: This is called during the Begin subroutine, when the game first loads.
;				It writes to Save RAM to test, or clears all Save RAM when a button combination is pressed.
;		- This will need to be re-written and a JSR added in its original location.
;
; ReadSRAM: This is called to access Save RAM.
;		- This will need to be re-written and a JSR added in its original location.
;
; WriteSRAM: This is called to write to Save RAM.
;		- This will need to be re-written and a JSR added in its original location.
;
;
;--Patch Equates--
updateROMadd    equ $1A0        ; address to update ROM address limits
initSRAMPatch	equ $1A050		; addresses to patch in JSR
readSRAMPatch	equ $1A244		
writeSRAMPatch	equ $1A1E4
newExpandCode   equ $1F9A00     ; this code needs to be in the bottom 2MB

;--NHL 94 Equates--
ReadJoy1		equ $11340
ValidateSRAM	equ $1A14E
ClearSRAM		equ $1A19C
vcountwaitjsr	equ $1A140
VBcount         equ $1A148

;--RAM Variables--
vbint			equ $FFFFB03A	; address of vblank interrupt code
ValidSRAM		equ $FFFFD458	; Flag if SRAM is OK

;--VDP Registers--
VDP_CTRL		equ $00C00004	; VDP control register
VDP_DATA		equ $00C00000	; VDP data

;--SRAM Bank Switching Register--
SRAMlock        equ $A130F1     ; Hardware register for SRAM<->ROM bank switching of $200000 range




;------------
;--Patches--
;------------

; NOTE: - org needs to be tabbed once!

; updateROMadd - update address space in ROM header
    org updateROMadd
    dc.l $000000
    dc.l $02FFFF

; initSRAMPatch - this code is transferred and a JMP is put in place
    org initSRAMPatch
    jmp InitSaveRAM

; readSRAMPatch - this code is transferred and a JMP is put in place
    org readSRAMPatch
    jmp ReadSRAM

; writeSRAMPatch - this code is transferred and a JMP is put in place
    org writeSRAMPatch
    jmp WriteSRAM


;------------
;--New code--
;------------

    org newExpandCode       ; 1F9A00 - Free space in 32-team ROM (2MB)

InitSaveRAM:                            
    move.l  #VBcount,(vbint).l
    move    #$2500,sr
    clr.w   (ValidSRAM).w   ; Flag for good SRAM
    jsr     ReadJoy1        ; get joypad buttons held
    move.w  d3,d0           ; d3 = buttons held
    move.b  #1, (SRAMlock)  ; set flag for SRAM bank switch (SRAM on)
    movea.l #$200000,a0     ; move SRAM address into a0
    move.w  #$E,d3          ; move 14 dec into d3
    move.w  #2,d4           ; move 2 into d4
    cmp.b   #$E0,d0         ; Start+A+C button held down
    beq.w   .setiterator    ; branch if held down
    cmp.b   #$B0,d0         ; Start+B+C buttons held down
    beq.w   .setiterator2   ; branch if held down
    moveq   #0,d0           ; move 0 into d0
    move.l  #$2000,d1       ; $2000 into d1
    movea.l #$FFFF0000,a0   ; start of RAM into a0
    move.b  #0, (SRAMlock)  ; set flag for SRAM bank switch (SRAM off)
    bsr.w   ReadSRAM        ; Writes SRAM to RAM
    jsr     ValidateSRAM
    tst.w   (ValidSRAM).w
    bpl.w   .ex
    jsr     ClearSRAM
    moveq   #0,d0
    move.l  #$2000,d1
    movea.l #$FFFF0000,a0
    bsr.w   ReadSRAM        ; Writes SRAM to RAM
    jsr     ValidateSRAM

.ex:                                    
    rts

.setiterator:                           
    move.w  #$1FFF,d2
    move.b  #1, (SRAMlock)  ; set flag for SRAM bank switch (SRAM on)

.SRAMloop:                              
    move.w  #1,d1
    move.w  #7,d0
.setto80:                              
    move.w  d1,(a0)
    cmp.b   1(a0),d1
    bne.w   .loadcolor
    lsl.w   #1,d1
    dbf     d0,.setto80
    adda.w  #2,a0
    dbf     d2,.SRAMloop
    movea.l #$200000,a0
    move.l  #$120034,(a0)+
    move.l  #$560078,(a0)+
    move.b  #0, (SRAMlock)  ; set flag for SRAM bank switch (SRAM off)
    move.w  #$E0,d3
    move.w  #$20,d4

.loadcolor:                             
                            
    move.w  d3,d0           ; move d3 (color of flashing screen) to d0

.flashscreen:                           
    move.l  #$C0000000,(VDP_CTRL).l
    move.w  d0,d1
    and.w   d3,d1
    move.w  d1,(VDP_DATA).l
    jsr     vcountwaitjsr
    sub.w   d4,d0
    bra.s   .flashscreen

.setiterator2:                          
    move.w  #3,d1
    move.b  #1, (SRAMlock)  ; set flag for SRAM bank switch (SRAM on)

.SRAMloop2:                            
    adda.w  #1,a0
    lsl.l   #8,d0
    move.b  (a0)+,d0
    dbf     d1,.SRAMloop2
    cmp.l   #$12345678,d0
    bne.s   .loadcolor      ; branch if not equal (screen flashes red)
    move.b  #0, (SRAMlock)  ; set flag for SRAM bank switch (SRAM off)
    move.w  #$E0,d3
    move.w  #$20,d4
    bra.s   .loadcolor      ; branch (screen flashes green)

; End of function InitSaveRAM


WriteSRAM:                              
; Write data from a0 into SaveRAM
; d1 = iterator
; d0 = start of where to write data

    movem.l d0-d2/a0-a1,-(sp)
    move.b  #1, (SRAMlock)  ; set flag for SRAM bank switch (SRAM on)
    movea.l #$200000,a1
    add.l   d0,d0
    subq.l  #1,d1
    clr.w   d2
.loop:                             
    move.b  (a0)+,d2
    move.w  d2,(a1,d0.w)
    addq.w  #2,d0
    dbf     d1,.loop
    move.b  #0, (SRAMlock)  ; set flag for SRAM bank switch (SRAM off)
    movem.l (sp)+,d0-d2/a0-a1
    rts

; End of function WriteSRAM


ReadSRAM:       
; move into a0 location and increment
; d1 = # of bytes to grab (loop iterator)
; d0 = start of data                        
                                       
    movem.l d0-d2/a0-a1,-(sp)
    move.b  #1, (SRAMlock)  ; set flag for SRAM bank switch (SRAM on)
    movea.l #$200000,a1
    add.l   d0,d0
    subq.l  #1,d1
.loop:                              
    move.b  1(a1,d0.w),d2
    move.b  d2,(a0)+
    addq.w  #2,d0
    dbf     d1,.loop
    move.b  #0, (SRAMlock)  ; set flag for SRAM bank switch (SRAM off)
    movem.l (sp)+,d0-d2/a0-a1
    rts

; End of function ReadSRAM