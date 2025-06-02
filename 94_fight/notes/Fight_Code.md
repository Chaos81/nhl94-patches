; controller processing for fighting
; Need PenCntDwn, xc1 RAM locations, rtss, playeracc, SetSPA ROM addresses
; called in doinput


fightinput:                             ; CODE XREF: doinput+5C   j
                tst.w   $44(a3)         ; test temp3
                bmi.w   rtss            ; exit if fight over
                tst.w   (PenCntDwn).w   ; test PenCntDwn
                bmi.w   rtss            ; exit if fight over
                cmpi.w  #$F8E,$58(a3)   ; #SPAfight to SPA
                beq.w   rtss            ; exit if this player is not in ready position
                move.w  d0,d2           ; dpad input
                move.w  d1,-(sp)        ; new button presses
                btst    #3,d2           ; test bit 3 in d2
                bne.w   _noa            ; branch if not zero
                andi.w  #7,d2           ; pass first 3 bits of d2
                bsr.w   playeracc       ; move player
_noa:                                   ; CODE XREF: fightinput+22   j
                move.w  (xc1).w,d0      ; keep the players face to face and in range of xc1
                                        ; move x scroll lock coord to d0
                addi.w  #$C,d0          ; add 12 dec to d0
                cmpi.w  #2,$54(a3)      ; compare 2 to facedir
                bne.w   _0
                subi.w  #$18,d0         ; sub 24 dec from d0
_0:                                     ; CODE XREF: fightinput+3C   j
                sub.w   (a3),d0         ; sub Xpos from d0
                move.w  $28(a3),d1      ; move Xvel to d1
                eor.w   d0,d1           ; EOR d0 with d1
                bpl.w   _ind
                tst.w   d0              ; test d0
                bpl.w   _1              ; branch if positive
                neg.w   d0              ; negate d0
_1:                                     ; CODE XREF: fightinput+52   j
                muls.w  $28(a3),d0      ; mult Xvel with d0
                asr.l   #4,d0           ; divide by 16
                sub.w   d0,$28(a3)      ; sub d0 from Xvel
_ind:                                   ; CODE XREF: fightinput+4C   j
                move.w  (sp)+,d1        ; pop from stack
                bset    #1,$63(a3)      ; set animation in progress
                bne.w   rtss            ; exit if already set
                move.w  d1,d2           ; move d1 into d2
                move.w  #$1004,d1       ; #SPAfhigh into d1
                btst    #5,d2           ; check C button press
                bne.w   SetSPA          ; If pressed, start hit high anim
                move.w  #$1036,d1       ; #SPAflow
                btst    #4,d2           ; B button check
                bne.w   SetSPA          ; If pressed, start hit low anim
                move.w  #$FC0,d1        ; #SPAfgrab
                btst    #6,d2           ; A button pressed
                bne.w   SetSPA          ; If pressed, start grab anim
                bclr    #1,$63(a3)      ; clear anim in progress if none
                rts
; End of function fightinput


;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; look for start of fight between players a2 and a3
; need gmode, puck's pflags, puckx, crowdlevel, CwdExciteLvl, sflags, puckc, yc1, collflag RAM locations
; need rtss, assinsert, ROM addresses
; need assfwatch asstab offset
; need to figure out what FFC602, offset $1A2 RAM location is for
checkfight:                             ; CODE XREF: checkcx+104   p
                cmpi.w  #$A,$32(a3)     ; compare impact to 10 dec
                blt.w   rtss            ; exit if less
                cmpi.w  #$A,$32(a2)     ; compare a2 impact to 10 dec
                blt.w   rtss            ; exit if less than
                btst    #5,$62(a3)      ; check if a3 locked in animation
                bne.w   rtss            ; exit if so
                btst    #5,$62(a2)      ; check if a2 locked in anim
                bne.w   rtss            ; exit if so
                btst    #4,$63(a3)      ; check if a3 caused a penalty
                bne.w   rtss            ; exit if so
                btst    #4,$63(a2)      ; check if a2 caused penalty
                bne.w   rtss            ; exit if so
                tst.w   $34(a3)         ; check if a3 goalie
                beq.w   rtss            ; exit if so
                tst.w   $34(a2)         ; check if a2 goalie
                beq.w   rtss            ; exit if so
                btst    #0,(gmode).w    ; check if clock stopped
                bne.w   rtss            ; exit if so
                btst    #4,(gmode).w    ; check if highlight
                bne.w   rtss            ; exit if so
                btst    #0,(byte_FFB7AD).w ; checks fight bit of puck's pflags
                bne.w   rtss            ; exit if set
                movem.l d0-d4/a0-a3,-(sp)
                movea.w #(puckx-M68K_RAM),a0 ; puck player struct
                move.w  $36(a0),d0      ; move assnum into d0
                cmpi.b  #$1B,$38(a0,d0.w) ; compare pfaceoff to puck's assignment
                beq.w   _ex             ; exit if puck on faceoff
                moveq   #$28,d0 ; '('   ; 40 dec into d0
                sub.w   (ChkCnt).w,d0   ; ??
                bpl.w   _cont           ; branch if d0 positive
                clr.w   d0
_cont:                                  ; CODE XREF: checkfight+86   j
                lsr.w   #2,d0           ; divide by 2
                addi.w  #$A,d0          ; add 10 dec to d0
                bsr.w   ChkFightValue
                exg     a2,a3
                bsr.w   ChkFightValue
                exg     a2,a3
                btst    #0,$63(a3)      ; check if fight bit set
                beq.w   _ex             ; branch if not
                clr.w   (ChkCnt).w      ; ??
                moveq   #$19,d0         ; # of players on team
                movea.w #(unk_FFC602-M68K_RAM),a0
_loop:                                  ; CODE XREF: checkfight+B8   j
                clr.b   $1A2(a0)        ; clears some offset for both away and home teams(loops 26 times)
                                        ; when I use this offset in 94, it leads to ChksFor array
                clr.b   (a0)+
                dbf     d0,_loop
                addi.w  #$3E8,(crowdlevel).w ; add 1000 dec to crowd
                addi.w  #$23,(CwdExciteLvl).w ; '#' ; add to crowd excite lvl
                bclr    #2,(sflags).w   ; clear pass dir mode
                bclr    #3,(sflags).w   ; clear shot dir mode
                move.w  $52(a3),(puckc).w ; move SCnum of a3 into puckc
                move.w  $14(a3),d1      ; Ypos into d0
                add.w   $14(a2),d1      ; add Ypos to d1
                asr.w   #1,d1           ; divide by 2
                move.w  d1,(yc1).w      ; move d1 into y scroll lock coord
                bset    #6,(sflags).w   ; set scroll lock
                moveq   #2,d1           ; 2 into d1
                move.w  (a3),d0         ; Xpos
                cmp.w   (a2),d0         ; compare Xpos of a2 to a3
                blt.w   _o1             ; branch if a3 Xpos is less than a2 Xpos
                eori.w  #7,d1           ; sets d1 to 5
_o1:                                    ; CODE XREF: checkfight+F4   j
                move.w  d1,$54(a3)      ; d1 into facedir
                eori.w  #7,d1           ; EOR with d1. This part is making players face each other
                move.w  d1,$54(a2)      ; d1 into facedir
                move.l  a3,-(sp)        ; push a3 to stack
                bsr.w   SF              ; start fight subroutine
                exg     a2,a3
                bsr.w   SF
                movea.w #(unk_FFB04A-M68K_RAM),a3 ; Start of Player Structs
                move.l  #$15,d0         ; assfwatch - assignment for other players to watch the fight
                moveq   #$B,d1          ; # of player structs to iterate through
_0:                                     ; CODE XREF: checkfight+144   j
                btst    #0,$63(a3)      ; check if player fighting
                bne.w   _next           ; if so, branch
                tst.w   $34(a3)         ; check if goalie
                beq.w   _next           ; if so, branch
                btst    #2,$63(a3)      ; check if player unavailable
                bne.w   _next           ; if so, branch
                bsr.w   assinsert
_next:                                  ; CODE XREF: checkfight+126   j
                                        ; checkfight+12E   j ...
                adda.w  #$80,a3         ; move to next player struct
                dbf     d1,_0
                movea.w #(puckx-M68K_RAM),a3
                bset    #0,$63(a3)      ; set puck's fight flag
                move.l  #$1A,d0         ; pnothing - assignment for puck not doing anything
                bsr.w   assinsert
                st      (collflag).w
                movea.l (sp)+,a3        ; pop off stack original a3 value
_ex:                                    ; CODE XREF: checkfight+7C   j
                                        ; checkfight+A4   j
                movem.l (sp)+,d0-d4/a0-a3
                rts
; End of function checkfight

;;;;;;;;;;;;;;;;;;;;;;;;;;;;->

; start fight?
; Need AddPenalty2, setd0player, assinsert, SetSPA ROM addresses

SF:                                     ; CODE XREF: checkfight+10A   p
                                        ; checkfight+110   p
                move.w  $52(a2),$2E(a3) ; move SCnum into impactp of a3
                move.l  #$26,d0 ; '&'   ; #PenFighting
                bsr.w   AddPenalty2
                move.w  $52(a3),d0      ; SCnum of a3 into d0
                bsr.w   setd0player
                move.l  #$14,d0         ; assfight assignment
                bsr.w   assinsert
                bclr    #3,4(a3)        ; clear attribute
                move.w  #$FC00,d1       ; -400 dec into d1
                cmpi.w  #2,$54(a3)      ; compare to facedir
                beq.w   _sf2            ; branch if equal
                bset    #3,4(a3)        ; set attribute
                neg.w   d1              ; negate d1
_sf2:                                   ; CODE XREF: SF+32   j
                move.w  d1,$28(a3)      ; move d1 into Xvel
                bset    #2,$63(a3)      ; set unavailable
                bset    #1,$63(a3)      ; set animation in progress
                bset    #5,$63(a3)      ; set no player coll
                bclr    #5,$62(a3)      ; clear animation lock
                move.w  #$F8E,d1        ; #SPAfight
                bra.w   SetSPA
; End of function SF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ChkFightValue:                          ; CODE XREF: checkfight+92   p
                                        ; checkfight+98   p
                cmp.b   $74(a3),d0      ; checks fight value with d0
                bhi.w   rtss            ; exit if d0 is higher
                cmpi.b  #2,$74(a2)      ; compare if fight value is 2
                blt.w   rtss            ; exit if less
                clr.w   d1
                move.b  $66(a2),d1      ; a2's player roster offset into d1
                movea.w #(byte_FFC4E6-M68K_RAM),a0 ; Home Team bytes
                btst    #6,$62(a2)      ; check which team a2 is on
                beq.w   loc_10594       ; branch if home
                adda.w  #$1A2,a0        ; add for away team offset (FFC688)
loc_10594:                              ; CODE XREF: ChkFightValue+22   j
                adda.w  d1,a0           ; add playernum to team byte address
                move.b  $11C(a0),d1     ; not sure what's happening here
                asl.b   #1,d1
                neg.b   d1
                addi.b  #$10,d1
                cmp.b   $74(a2),d1      ; compare a2's fight value to d1
                bgt.w   rtss            ; exit if d1 is greater than
                bset    #0,$63(a2)      ; set fight bit a2
                bset    #0,$63(a3)      ; set fight bit a3
                bne.w   rtss            ; exit if set already
                tst.w   (word_FFCAE0).w ; This is OptPen
                beq.w   rtss
                move.w  (VDP_CNTR).l,d0 ; a little randomness with the frame counter
                andi.w  #3,d0           ; pass first 2 bits
                bne.w   rtss            ; exit if first 2 bits of frame counter aren't 0
                movea.l a3,a4
                moveq   #5,d0           ; set loop iterator
                movea.w #(unk_FFB04A-M68K_RAM),a3 ; Home Player structs
                btst    #6,$62(a4)      ; check which team a4 (a3 is on)
                beq.w   _playerloop     ; branch if home
                adda.w  #$300,a3        ; add offset to Away structs
_playerloop:                            ; CODE XREF: ChkFightValue+74   j
                                        ; ChkFightValue+AE   j
                cmpa.w  a3,a4           ; check if a3 and a4 are the same player
                beq.w   _endloop        ; branch if so
                tst.w   $34(a3)         ; check if goalie
                ble.w   _endloop        ; branch if goalie or there's no goalie
                btst    #4,$63(a3)      ; check if player caused a penalty
                bne.w   _endloop        ; branch if so
                btst    #2,$63(a3)      ; check if player unavailable
                bne.w   _endloop        ; branch if so
                move.w  #$2A,d0 ; '*'
                bsr.w   AddPenalty2
                movea.l a4,a3
                rts
; ---------------------------------------------------------------------------
_endloop:                               ; CODE XREF: ChkFightValue+7E   j
                                        ; ChkFightValue+86   j ...
                adda.w  #$80,a3         ; move to next player struct
                dbf     d0,_playerloop  ; decrement d0, loop
                movea.l a4,a3
                rts
; End of function ChkFightValue

;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; fighting logic
; a3 = player
assfight:                               ; DATA XREF: ROM:000151F2   o
                btst    #5,$62(a3)      ; check if animation lock
                bne.w   rtss            ; exit if so
                tst.w   (PenCntDwn).w   ; Check penalty count
                bmi.w   assnothing      ; assnothing if negative (might be check for pen off)
                bclr    #1,$62(a3)      ; clear new assignment
                beq.w   _nna            ; branch if this was already cleared (not first time through)
                bsr.w   getpde          ; get player's energy level
                move.b  $74(a3),d1      ; move fight value into d1
                ext.w   d1              ; word extend d1 (to pad it with FF)
                mulu.w  d1,d0           ; mult d1 with d0 (energy level)
                lsr.w   #8,d0           ; divide by 256
                lsr.w   #4,d0           ; divide by 16
                cmp.w   #5,d0           ; compare to 5
                bgt.w   loc_A5C0        ; branch if greater than
                moveq   #5,d0           ; min d0 is 5
loc_A5C0:                               ; CODE XREF: assfight+30   j
                move.w  d0,$44(a3)      ; move into temp3 - strength
                clr.w   $42(a3)         ; clear temp2
                move.w  #$FFFF,$46(a3)  ; move FFFF into temp4
                cmpi.w  #2,$54(a3)      ; compare 2 to facedir
                bne.w   _nna            ; branch if not equal
                move.w  #$5A,$46(a3) ; 'Z' ; move 90 dec into temp4
_nna:                                   ; CODE XREF: assfight+18   j
                                        ; assfight+4A   j
                sub.w   d7,$46(a3)      ; sub frames elapsed from temp4
                bcc.w   _nna2           ; branch if carry
                bsr.w   sub_A8C4        ; ???? - I believe this sets up fight banner
_nna2:                                  ; CODE XREF: assfight+58   j
                tst.w   $44(a3)         ; test temp3
                bmi.w   rtss            ; branch if negative
                move.w  $2E(a3),d0      ; move impactp into d0 (past impact player)
                asl.w   #7,d0           ; mult by 128 (size of player struct)
                movea.w #(unk_FFB04A-M68K_RAM),a0 ; player struct start
                adda.w  d0,a0           ; add d0 to a0 address (offset to impactp player struct)
                move.w  (a3),d0         ; Xpos into d0
                add.w   (a0),d0         ; add a0 Xpos to d0
                asr.w   #1,d0           ; divide by 2
                move.w  d0,(xc1).w      ; store d0
                btst    #3,$62(a3)      ; test if joy controlled
                bne.w   _j              ; branch if so
                bset    #1,$63(a3)      ; set anim in progress
                bne.w   _j              ; branch if already set
                move.w  (a3),d0         ; move Xpos into d0
                sub.w   (a0),d0         ; sub a0 Xpos
                move.w  $28(a3),d1      ; move Xvel into d1
                asr.w   #8,d1           ; divide by 256
                add.w   d1,d0           ; add d1 to d0
                move.w  $28(a0),d1      ; Xvel of a0 into d1
                asr.w   #8,d1           ; divide by 256
                sub.w   d1,d0           ; sub d1 from d0
                cmp.w   #$14,d0         ; compare to 20 dec
                bgt.w   _j              ; branch if greater than
                cmp.w   #$FFEC,d0       ; compare to -20 dec
                blt.w   _j              ; branch if less than
                moveq   #8,d0           ; move 8 into d0
                bsr.w   randomd0        ; RNG d0
                cmp.w   #2,d0           ; compare to 2
                bls.w   loc_A652        ; branch if less than
                andi.w  #1,d0           ; pass first bit of d0
loc_A652:                               ; CODE XREF: assfight+C0   j
                asl.w   #1,d0           ; mult by 2
                lea     _a1(pc),a1      ; choose punch type
                move.w  (a1,d0.w),d1    ; move SPA into d1
                bsr.w   SetSPA          ; set animation
_j:                                     ; CODE XREF: assfight+84   j
                                        ; assfight+8E   j ...
                bsr.w   chkhit
                cmpi.w  #$FE2,$58(a3)   ; #SPAfheld
                beq.w   _njc
                cmpi.w  #$F8E,$58(a3)   ; #SPAfight
                beq.w   _jc
                btst    #3,$62(a3)      ; check if joy controlled
                bne.w   _jc             ; branch if so
_njc:                                   ; CODE XREF: assfight+E0   j
                move.w  (xc1).w,d0      ; move into d0
                addi.w  #$A,d0          ; add 10 to d0
                cmpi.w  #2,$54(a3)      ; compare 2 to facedir
                bne.w   _0
                subi.w  #$14,d0         ; sub 20 from d0
_0:                                     ; CODE XREF: assfight+106   j
                sub.w   (a3),d0         ; Sub Xpos from d0
                asl.w   #5,d0           ; mult by 32
                add.w   d0,$28(a3)      ; add d0 to Xvel
_jc:                                    ; CODE XREF: assfight+EA   j
                                        ; assfight+F4   j
                move.w  (yc1).w,d1      ; move y sroll lock into d1
                sub.w   $14(a3),d1      ; sub Ypos from d1
                asl.w   #8,d1           ; mult by 256
                cmp.w   #$1000,d1       ; compare to 4096 dec
                blt.w   _y1             ; branch if less than
                move.w  #$1000,d1       ; move 4096 into d1
_y1:                                    ; CODE XREF: assfight+124   j
                cmp.w   #$F000,d1       ; compare to -$1000
                bgt.w   _y2
                move.w  #$F000,d1       ; move -$1000 into d1
_y2:                                    ; CODE XREF: assfight+130   j
                move.w  d1,$2A(a3)      ; move d1 into Yvel
                rts
; End of function assfight
; ---------------------------------------------------------------------------
_a1:            dc.w $1004              ; DATA XREF: assfight+CA   o
                                        ; SPAfgrab
                dc.w $1036              ; SPAfhigh
                dc.w $FC0               ; SPAflow


;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; part of fight to see if player is hit
; a3 = player
chkhit:                                 ; CODE XREF: assfight:_j   p
                movem.l d0/a0-a3,-(sp)
                move.w  6(a3),d0        ; move alice frame number into d0
                cmp.w   8(a3),d0        ; compare old frame to d0
                beq.w   _ex
                cmp.w   #$164,d0        ; compare SPFfight+2 to d0
                beq.w   _dropped        ; branch if equal
                move.w  (a3),d0         ; Xpos into d0
                sub.w   (a0),d0         ; sub a0 Xpos
                cmp.w   #$16,d0         ; compare to 22 dec
                bgt.w   _ex             ; exit if greater than (too far away)
                cmp.w   #$FFEA,d0       ; compare to -22 dec
                blt.w   _ex             ; exit if less than (too far away)
                move.w  $14(a3),d0      ; Ypos into d0
                sub.w   $14(a0),d0      ; sub a0 Ypos
                cmp.w   #8,d0           ; compare to 8
                bgt.w   _ex             ; exit if greater than (too far away)
                cmp.w   #$FFF8,d0       ; compare to -8
                blt.w   _ex             ; exit if less than (too far away)
                move.w  6(a3),d0        ; move frame into d0
                cmp.w   #$168,d0        ; compare SPFfight+6
                beq.w   _hithigh        ; branch if equal
                cmp.w   #$16D,d0        ; compare SPFfight+6+5
                beq.w   _hithigh        ; branch if equal
                cmp.w   #$169,d0        ; compare SPFfight+7
                beq.w   _hitlow         ; branch if equal
                cmp.w   #$16E,d0        ; compare SPFfight+7+5
                beq.w   _hitlow         ; branch if equal
                cmp.w   #$166,d0        ; compare SPFfight+4
                beq.w   _grab           ; branch if equal
                cmp.w   #$16B,d0        ; compare SPFfight+4+5
                beq.w   _grab           ; branch if equal
_ex:                                    ; CODE XREF: chkhit+C   j
                                        ; chkhit+20   j ...
                movem.l (sp)+,d0/a0-a3
                rts
; ---------------------------------------------------------------------------
_dropped:                               ; CODE XREF: chkhit+14   j
                bclr    #5,$63(a3)      ; clear no player coll
                move.w  (xc1).w,d0      ; move x scroll lock coord into d0
                cmp.w   #$5A,d0 ; 'Z'   ; compare $5A to d0 (90 dec)
                blt.w   _chkneg         ; branch if less than
                moveq   #$5A,d0 ; 'Z'   ; move $5A into d0
_chkneg:                                ; CODE XREF: chkhit+8C   j
                cmp.w   #$FFA6,d0       ; compare -$5A to d0
                bgt.w   _drcont
                moveq   #$FFFFFFA6,d0   ; move -$5A into d0
_drcont:                                ; CODE XREF: chkhit+96   j
                asr.w   #2,d0           ; divide by 4
                bne.w   _dr0            ; branch if not zero
                addq.w  #1,d0           ; add 1 to d0
_dr0:                                   ; CODE XREF: chkhit+9E   j
                move.b  d0,(glovecords).w ; move d0 into glovecords
                move.w  (yc1).w,d0      ; move y scroll lock coord into d0
                asr.w   #2,d0           ; divide by 4
                move.b  d0,(glovecords+1).w ; move d0 into glovecords +1
                bra.s   _ex             ; exit
; ---------------------------------------------------------------------------
_grab:                                  ; CODE XREF: chkhit+6C   j
                                        ; chkhit+74   j
                exg     a0,a3           ; swap a0 and a3
                bset    #1,$63(a3)      ; set animation in progress
                move.w  #$FE2,d1        ; #SPAfheld
                bsr.w   SetSPA
                bra.s   _ex
; ---------------------------------------------------------------------------
_hithigh:                               ; CODE XREF: chkhit+4C   j
                                        ; chkhit+54   j
                exg     a0,a3           ; swap a0 and a3
                bsr.w   CwdFight        ; add to crowd
                bset    #1,$63(a3)      ; set animation in progress
                subq.w  #1,$44(a3)      ; sub 1 from temp3
                bmi.w   FightFall       ; branch if minus
                move.w  #$1068,d1       ; #SPAfhith
                bsr.w   SetSPA          ; set animation
                move.w  #9,-(sp)        ; #SFXhithigh
                bsr.w   sfx
                bra.s   _ex
; ---------------------------------------------------------------------------
_hitlow:                                ; CODE XREF: chkhit+5C   j
                                        ; chkhit+64   j
                exg     a0,a3           ; swap a0 and a3
                bsr.w   CwdFight
                bset    #1,$63(a3)      ; set animation in progress
                subq.w  #1,$44(a3)      ; sub 1 from temp3
                bmi.w   FightFall       ; branch if minus
                move.w  #$108A,d1       ; #SPAhitl
                bsr.w   SetSPA          ; set animation
                move.w  #$A,-(sp)       ; #SFXhitlow
                bsr.w   sfx             ; make SFX
                bra.w   _ex
; End of function chkhit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CwdFight:                               ; CODE XREF: chkhit+C8   p
                                        ; chkhit+EE   p
                addi.w  #$50,(crowdlevel).w ; 'P' ; add to crowd level
                addi.w  #$A,(CwdExciteLvl).w
                moveq   #5,d0
                add.w   $44(a0),d0      ; add temp3 to d0
                mulu.w  #$1F4,d0        ; mult d0 by 500 dec
                cmpi.w  #2,$54(a3)      ; compare 2 to facedir
                bne.w   _xveladj        ; branch if not equal
                neg.w   d0              ; negate d0
_xveladj:                               ; CODE XREF: CwdFight+1C   j
                add.w   d0,$28(a3)      ; add d0 to Xvel
                rts
; End of function CwdFight

;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FightFall:                              ; CODE XREF: chkhit+D6   j
                                        ; chkhit+FC   j
                movem.l a1,-(sp)        ; push to stack
                movea.w #(unk_FFC26E-M68K_RAM),a1 ; PenBuf
_cont:                                  ; CODE XREF: FightFall+E   j
                                        ; FightFall+1C   j
                addq.w  #2,a1           ; add 2 to a1
                cmpi.b  #$26,(a1) ; '&' ; compare 26 to a1
                bne.s   _cont
                move.b  1(a1),d0        ; move 1(a1) into d0
                andi.w  #$F,d0          ; pass first 4 bits of d0
                cmp.w   $52(a0),d0      ; compare SCnum to d0
                bne.s   _cont           ; branch if not equal
                move.b  #$28,(a1) ; '(' ; move 40 dec into a1 position
                movem.l (sp)+,a1        ; pop from stack
                move.w  #$3C,(PenCntDwn).w ; '<' ; move 60 dec into PenCntDown
                move.w  #$FFFF,$44(a0)  ; move -1 into temp3
                addi.w  #$258,(crowdlevel).w ; add to crowd
                addi.w  #$1E,(CwdExciteLvl).w ; add to crowd excite
                moveq   #$3C,d0 ; '<'   ; move 60 dec into d0
                bsr.w   randomd0        ; RNG
                cmp.b   $75(a0),d0      ; compare Chk value to d0
                bgt.w   loc_A884        ; branch if greater than
                move.w  #$B4,(PenCntDwn).w ; move 180 dec into PenCntDwn - the rest of this might have to do with injured player
                bset    #6,$63(a3)      ; set player caused a penalty? (not in 92)
                move.w  #$10CE,d1       ; #SPAffall
                bsr.w   SetSPA          ; set animation
                bsr.w   sub_A8AE        ; ???
                movea.w a3,a2           ; move a3 address into a2
                bsr.w   sub_1034A
                move.w  #$112C,$66(a0,d1.w)
                move.w  #3,(word_FFC2B8).w
                bra.w   _ex
; ---------------------------------------------------------------------------
loc_A884:                               ; CODE XREF: FightFall+48   j
                move.w  #$10AC,d1       ; #SPAbfall?
                bsr.w   SetSPA          ; set animation
                movea.w #(byte_FFC4E6-M68K_RAM),a2
                move.w  #$B,-(sp)       ; #SFXcrowdcheer
                btst    #6,$62(a3)      ; check if home or away
                bne.w   _3              ; branch if away
                lea     $1A2(a2),a2     ; ??
                move.w  #$C,(sp)        ; #SFXcrowdboo
_3:                                     ; CODE XREF: FightFall+90   j
                bsr.w   SFX
                bra.w   _ex
; End of function FightFall

;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sub_A8AE:                               ; CODE XREF: FightFall+60   p
                bsr.w   sub_E1C6
                ori.b   #0,d6
                btst    d0,d0
                moveq   #$28,d0 ; '('
                moveq   #5,d1
                move.w  #$7FF,d2
                bra.w   sub_DFD0
; End of function sub_A8AE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;

assfwatch:                              ; DATA XREF: ROM:000151F6   o
                btst    #5,$62(a3)
                bne.w   rtss
                btst    #3,$62(a3)
                bne.w   rtss
                bclr    #1,$62(a3)
                beq.w   loc_A9DA
                clr.w   $40(a3)
loc_A9DA:                               ; CODE XREF: assfwatch+1A   j
                sub.w   d7,$40(a3)
                bpl.w   loc_AA42
                addi.w  #$3C,$40(a3) ; '<'
                move.w  (a3),d0
                sub.w   (xc1).w,d0
                move.w  $14(a3),d1
                sub.w   (yc1).w,d1
                movem.w d0-d1,-(sp)
                muls.w  d0,d0
                muls.w  d1,d1
                add.l   d1,d0
                bsr.w   sub_D7F6
                move.w  d0,d2
                bne.w   loc_AA0C
                moveq   #1,d2
loc_AA0C:                               ; CODE XREF: assfwatch+4E   j
                movem.w (sp)+,d0-d1
                muls.w  #$50,d0 ; 'P'
                divs.w  d2,d0
                add.w   (xc1).w,d0
                move.w  #$7E,d3 ; '~'
                cmp.w   d3,d0
                blt.w   loc_AA26
                move.w  d3,d0
loc_AA26:                               ; CODE XREF: assfwatch+68   j
                neg.w   d3
                cmp.w   d3,d0
                bgt.w   loc_AA30
                move.w  d3,d0
loc_AA30:                               ; CODE XREF: assfwatch+72   j
                move.w  d0,$44(a3)
                muls.w  #$50,d1 ; 'P'
                divs.w  d2,d1
                add.w   (yc1).w,d1
                move.w  d1,$46(a3)
loc_AA42:                               ; CODE XREF: assfwatch+26   j
                move.w  $44(a3),d0
                move.w  $46(a3),d1
                lea     rtss(pc),a0
                bsr.w   skateto
                bra.w   loc_BF26
; End of function assfwatch



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sub_A8AE:                              
                bsr.w   printz
                ori.b   #0,d6
                btst    d0,d0
                moveq   #$28,d0 ; '('
                moveq   #5,d1
                move.w  #$7FF,d2
                bra.w   eraser
; End of function sub_A8AE


sub_A8C4:                           
                movem.l d0-d3/a0-a4,-(sp)
                movea.w #(HmShots),a2
                jsr     (lcfound2).l
                adda.w  #$1A2,a2
                jsr     (lcfound2).l
                jsr     (sub_14E8C).l
                movea.w #(PenBuf),a0
                clr.w   d2
loc_A8E8:                              
                tst.w   (a0)+
                bne.s   loc_A8E8
                move.b  -3(a0),d0
                clr.b   d3
                bsr.w   sub_A95A
                neg.b   d3
                move.b  -5(a0),d0
                bsr.w   sub_A95A
                bsr.w   printz
                ori.b   #$F,d6
                btst    d0,d0
                move.w  d2,d0
                lsr.w   #1,d2
                sub.w   d2,(printx).w
                moveq   #5,d1
                bsr.w   Framer
                move.w  #2,(printy).w
                tst.b   d3
                bmi.w   loc_A92A
                move.w  #4,(printy).w
loc_A92A:                              
                move.b  -3(a0),d0
                bsr.w   sub_A95A
                bsr.w   print
                eori.w  #6,(word_FFB02A).w
                move.b  -5(a0),d0
                bsr.w   sub_A95A
                bsr.w   print
                bsr.w   printz
                ori.b   #$F,a0
                bchg    d1,0(a6,d7.w*2)
                movem.l (sp)+,d0-d3/a0-a4
                rts
; End of function sub_A8C4


sub_A95A:                              
                movea.w #(SortCords),a1
                andi.w  #$F,d0
                asl.w   #7,d0
                add.b   $74(a1,d0.w),d3
                movea.w #(HmShots),a2
                btst    #6,$62(a1,d0.w)
                beq.w   loc_A97A
                adda.w  #$1A2,a2
loc_A97A:                               
                move.b  $66(a1,d0.w),d0
                ext.w   d0
                jsr     (sub_14EC6).l
                movea.w a1,a3
                bsr.w   appendz
                ori.b   #0,d4
                movea.l $1E(a2),a1
                adda.w  4(a1),a1
                adda.w  (a1),a1
                bsr.w   appstring
                cmp.w   (a3),d2
                bgt.w   loc_A9A6
                move.w  (a3),d2
loc_A9A6:                              
                movea.w a3,a1
                move.w  (a1),d0
                lsr.w   #1,d0
                neg.w   d0
                addi.w  #$10,d0
                move.w  d0,(printx).w
                rts
; End of function sub_A95A