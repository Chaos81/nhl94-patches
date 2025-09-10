InitSaveRAM:                            ; CODE XREF: Begin+5A   p
                move.l  #VBcount,(vbint).l
                move    #$2500,sr
                clr.w   (ValidSRAM).w   ; ??
                jsr     (ReadJoy1).l    ; get joypad buttons held
                move.w  d3,d0           ; d3 = buttons held
                movea.l #$200000,a0     ; move SRAM address into a0
                move.w  #$E,d3          ; move 14 dec into d3
                move.w  #2,d4           ; move 2 into d4
                cmp.b   #$E0,d0         ; Start+A+C button held down
                beq.w   _setiterator    ; branch if held down
                cmp.b   #$B0,d0         ; Start+B+C buttons held down
                beq.w   _setiterator2   ; branch if held down
                moveq   #0,d0           ; move 0 into d0
                move.l  #$2000,d1       ; $2000 into d1
                movea.l #$FFFF0000,a0   ; start of RAM into a0
                bsr.w   ReadSRAM        ; Writes SRAM to RAM
                bsr.w   ValidateSRAM
                tst.w   (ValidSRAM).w
                bpl.w   _ex
                bsr.w   ClearSRAM
                moveq   #0,d0
                move.l  #$2000,d1
                movea.l #$FFFF0000,a0
                bsr.w   ReadSRAM        ; Writes SRAM to RAM
                bsr.w   ValidateSRAM
_ex:                                    ; CODE XREF: InitSaveRAM+52   j
                rts
; ---------------------------------------------------------------------------
_setiterator:                           ; CODE XREF: InitSaveRAM+2C   j
                move.w  #$1FFF,d2
_SRAMloop:                              ; CODE XREF: InitSaveRAM+92   j
                move.w  #1,d1
                move.w  #7,d0
_setto80:                               ; CODE XREF: InitSaveRAM+8A   j
                move.w  d1,(a0)
                cmp.b   1(a0),d1
                bne.w   _loadcolor
                lsl.w   #1,d1
                dbf     d0,_setto80
                adda.w  #2,a0
                dbf     d2,_SRAMloop
                movea.l #$200000,a0
                move.l  #$120034,(a0)+
                move.l  #$560078,(a0)+
                move.w  #$E0,d3
                move.w  #$20,d4 ; ' '
_loadcolor:                             ; CODE XREF: InitSaveRAM+84   j
                                        ; InitSaveRAM+E4   j ...
                move.w  d3,d0           ; move d3 (color of flashing screen) to d0
_flashscreen:                           ; CODE XREF: InitSaveRAM+CC   j
                move.l  #$C0000000,(VDP_CTRL).l
                move.w  d0,d1
                and.w   d3,d1
                move.w  d1,(VDP_DATA).l
                bsr.w   sub_1A140
                sub.w   d4,d0
                bra.s   _flashscreen
; ---------------------------------------------------------------------------
_setiterator2:                          ; CODE XREF: InitSaveRAM+34   j
                move.w  #3,d1
_SRAMloop2:                             ; CODE XREF: InitSaveRAM+DA   j
                adda.w  #1,a0
                lsl.l   #8,d0
                move.b  (a0)+,d0
                dbf     d1,_SRAMloop2
                cmp.l   #$12345678,d0
                bne.s   _loadcolor      ; branch if not equal (screen flashes red)
                move.w  #$E0,d3
                move.w  #$20,d4 ; ' '
                bra.s   _loadcolor      ; branch (screen flashes green)
; End of function InitSaveRAM


; Write data from a0 into SaveRAM
; d1 = iterator
; d0 = start of where to write data
WriteSRAM:                              ; CODE XREF: ClearSRAM+28   p
                                        ; ClearSRAM+3E   p ...
                movem.l d0-d2/a0-a1,-(sp)
                movea.l #$200000,a1
                add.l   d0,d0
                subq.l  #1,d1
                clr.w   d2
loc_1A1F4:                              ; CODE XREF: WriteSRAM+18   j
                move.b  (a0)+,d2
                move.w  d2,(a1,d0.w)
                addq.w  #2,d0
                dbf     d1,loc_1A1F4
                movem.l (sp)+,d0-d2/a0-a1
                rts
; End of function WriteSRAM


; move into a0 location and increment
; d1 = # of bytes to grab (loop iterator)
; d0 = start of data
ReadSRAM:                               ; CODE XREF: InitSaveRAM+46   p
                                        ; InitSaveRAM+68   p ...
                movem.l d0-d2/a0-a1,-(sp)
                movea.l #$200000,a1
                add.l   d0,d0
                subq.l  #1,d1
loc_1A252:                              ; CODE XREF: ReadSRAM+16   j
                move.b  1(a1,d0.w),d2
                move.b  d2,(a0)+
                addq.w  #2,d0
                dbf     d1,loc_1A252
                movem.l (sp)+,d0-d2/a0-a1
                rts
; End of function ReadSRAM