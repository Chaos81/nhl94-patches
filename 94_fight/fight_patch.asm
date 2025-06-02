; fight_patch.asm - Add Fighting to NHL94 Genesis
; Created by chaos with help from McMarkis and AbdulBCRT
; Current Version - 0.2
; Version History:
;   Version 0.1 - Initial version
;   Version 0.2 - Added modifications due to Fight sprites addition
;   Version 0.3 - Fix bugs with SetSPA jsrs

;--MACROS--
	include	scripts\macros.mac

;--Load ROM from rom directory--
	org 0
		incbin rom\nhl94_sprite.bin    ; Currently using the expanded ROM, until I create a macro to do it automatically

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
;
;--Patch Equates--
doinputPatch 	equ $B258		; Address in doinput to patch code
checkcxPatch   	equ $13B16    	; Address in checkcx to patch code
asstabPatch		equ $18DCC		; Address for assfight on asstab to patch code
newCode			equ $105000		; Address in ROM where the new code will be patched in

;--NHL 94 Equates--
checkint		equ $13BD6		
checkcheck		equ $13CC4		
playeracc		equ $10BC2		
SetSPA			equ $1073A		
assinsert		equ $10658		
AddPenalty2		equ $11F62		
setd0player		equ $15322		
assnothing		equ $CBE4
getpde			equ $1575A
randomd0		equ $11086
sfx				equ $11132
printz			equ $11B92
eraser			equ $1197E
setInjuryType	equ $144AC
skateto			equ $103C8
check4check		equ $EACE
sroot			equ $110BE
box             equ $18A56
lcfound2        equ $BB36
Framer          equ $119B8
print           equ $11BA4
strstuff        equ $18A90


afight			equ $14			; assfight offset on asstab
afwatch			equ $15			; assfwatch offset on asstab
pfaceoff		equ $1B			; puckfaceoff offset on asstab
punflip			equ $1A			; puckunflip offset on asstab

PenFighting		equ $26			; PenFighting offset on PenaltyList
PenInst			equ $2A			; PenInst offset on PenaltyList

;--SPA Equates--
;SPAfight		equ $5D0		; Set to SPAskate, 93 original $F8E
;SPAfhigh		equ $B24		; Set to SPAsweepcheck, 93 original $1004
;SPAflow		equ $C2C		; Set to SPAhipchkr, 93 original $1036
;SPAfgrab		equ $1122		; Set to SPAhold, 93 original $FC0
;SPAfhith		equ $11E6		; Set to SPAtoddle, 93 original $1068
;SPAfhitl		equ $11E6		; Set to SPAtoddle, 93 original $108A
;SPAfheld		equ $6C6		; Set to SPAstop, 93 original $FE2
;SPAffall		equ $1776		; Set to SPAfallr?, 93 original $10CE
;SPAbfall		equ $17E8		; Set to SPAfalll?, 93 original $10AC

; SPAList_Fight.bin SPA values:

SPAfight        equ $1B96
SPAfgrab        equ $1BC8
SPAfheld        equ $1BEA
SPAfhigh        equ $1C0C
SPAflow         equ $1C3E
SPAfhith        equ $1C70
SPAfhitl        equ $1C92
SPAffall        equ $1CB4
SPAbfall        equ $1CD6

;--SPF Equates
; SPFfight		equ $2A			; Set to SPFskate?, 93 original $162
SPFfight        equ $34F        ; Set to Frame 847 based on the modified FrmSprData 

;--RAM variables--
tmstruct		equ $FFFFC6CE			; Start of Home Team Struct
HmChksFor		equ $FFFFC7EA			; Home Team ChksFor array start
SortCords		equ $FFFFB04A			; Start of Sprite Structs

pflags			equ $62					; Player struct flags
pflags2 		equ $63

gmode			equ $FFFFC2EA			; Game mode flags
sflags			equ $FFFFC2EC			; Status flags

collflag		equ $FFFFBFA0			; Collision flag

crowdlevel		equ $FFFFB89C			; Crowd level
CwdExciteLvl	equ $FFFFB8A2


PenCntDwn		equ $FFFFC3E6			; RAM Location
PenBuf			equ $FFFFC3A4
ChkCnt			equ $FFFFC46E			; Check counts
InjCntDown		equ $FFFFC3EC

glovecords		equ $FFFFBEE2			; coord of glove/sticks (fighting)

xc1				equ $FFFFBF8E			; RAM Location for screen locks				
yc1				equ $FFFFBF90		

puckx			equ $FFFFB74A			; RAM puck x location (start of puck struct)
puckc			equ $FFFFB7AA			; RAM puck carrier SCNum

OptPen			equ $FFFFD056			; Penalty option: 0 = Off, 1 = On, 2 = On, no offsides

VDP_CNTR		equ $00C00008			; Frame counter


;------------
;--Patches--
;------------

; NOTE: - org needs to be tabbed once!

; Patch doinput subroutine - need to replace 10 bytes
	org doinputPatch			; Set to patch location
	jmp chkfightinput			; JMP to new code (6 bytes long)
back:
	nop							; Take up 4 bytes of space
	nop



; Patch checkcx subroutine
	org checkcxPatch			; Set to patch location need to replace 12 bytes 
	jsr 	cxchecks			; JSR to the new code (6 bytes long)
	bra.w		*+4				; Branch to the next 94 code (at $13B22) (4 bytes long)
	dc.w	$0					; pad 2 bytes with 00

; Patch assfight and assfwatch on asstab
	org asstabPatch
	dc.l assfight
	dc.l assfwatch

;------------
;--New code--
;------------

	org	newCode				; $105000

chkfightinput:				; Check if fighting flag is set, if so, continue to fightinput
	btst #0, pflags2(a3)	; Check fighting flag
	bne.w fightinput		; Branch to fightinput if set
	jmp back                ; JMP back to doinput

cxchecks:					; Checks for interference, checking players, and fighting
	jsr	checkint			; Check for interference
	jsr	checkcheck			; Check for various contact events
	jsr	checkfight			; Check for fighting
	rts
	
rtss:						; Used for exiting some subroutines early
	rts

fightinput:                 
; controller processing for fighting

; from doinput:
; d0 = dpad
; d1 = new buttons
; d2 = changed buttons
; d3 = held buttons
; d4 = controller 0/2

	tst.w   $44(a3)         ; test temp3
	bmi.w   rtss            ; exit if fight over
	tst.w   (PenCntDwn).w   ; test PenCntDwn
	bmi.w   rtss            ; exit if fight over
	cmpi.w  #SPAfight,$58(a3)   ; #SPAfight to SPA
	beq.w   rtss            ; exit if this player is not in ready position
	move.w  d0,d2           ; dpad input
	move.w  d1,-(sp)        ; new button presses
	btst    #3,d2           ; test bit 3 in d2
	bne.w   .noa            ; branch if not zero
	andi.w  #7,d2           ; pass first 3 bits of d2
	jsr	   	playeracc       ; move player

.noa:                                   
	move.w  (xc1).w,d0      ; keep the players face to face and in range of xc1
							; move x scroll lock coord to d0
	addi.w  #$C,d0          ; add 12 dec to d0
	cmpi.w  #2,$54(a3)      ; compare 2 to facedir
	bne.w   .0
	subi.w  #$18,d0         ; sub 24 dec from d0

.0:                                     
	sub.w   (a3),d0         ; sub Xpos from d0
	move.w  $28(a3),d1      ; move Xvel to d1
	eor.w   d0,d1           ; EOR d0 with d1
	bpl.w   .ind
	tst.w   d0              ; test d0
	bpl.w   .1              ; branch if positive
	neg.w   d0              ; negate d0

.1:                                     
	muls.w  $28(a3),d0      ; mult Xvel with d0
	asr.l   #4,d0           ; divide by 16
	sub.w   d0,$28(a3)      ; sub d0 from Xvel

.ind:                                  
	move.w  (sp)+,d1        ; pop from stack
	bset    #1,$63(a3)      ; set animation in progress
	bne.w   rtss            ; exit if already set
	move.w  d1,d2           ; move d1 into d2
	move.w  #SPAfhigh,d1    ; #SPAfhigh into d1
	btst    #5,d2           ; check C button press
	bne.w   SPAjump         ; If pressed, start hit high anim
	move.w  #SPAflow,d1     ; #SPAflow
	btst    #4,d2           ; B button check
	bne.w   SPAjump         ; If pressed, start hit low anim
	move.w  #SPAfgrab,d1    ; #SPAfgrab
	btst    #6,d2           ; A button pressed
	bne.w   SPAjump         ; If pressed, start grab anim
	bclr    #1,$63(a3)      ; clear anim in progress if none
	rts

; End of function fightinput	 
		
checkfight:                 
; look for start of fight between players a2 and a3

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
	btst    #0,puckx+pflags2 ; checks fight bit of puck's pflags
	bne.w   rtss            ; exit if set
	movem.l d0-d4/a0-a3,-(sp)
	movea.l #puckx,a0 		; puck player struct
	move.w  $36(a0),d0      ; move assnum into d0
	cmpi.b  #pfaceoff,$38(a0,d0.w) ; compare pfaceoff to puck's assignment
	beq.w   .ex             ; exit if puck on faceoff
;	moveq   #$28,d0 	   	; 40 dec into d0
	moveq	#$1, d0			; for testing purposes
	sub.w   ChkCnt,d0   	; Sub CheckCnt from d0
	bpl.w   .cont           ; branch if d0 positive
	clr.w   d0
.cont:                                
	lsr.w   #2,d0           ; divide by 2
	addi.w  #$A,d0          ; add 10 dec to d0
	bsr.w   ChkFightValue
	exg     a2,a3
	bsr.w   ChkFightValue
	exg     a2,a3
	btst    #0,$63(a3)      ; check if fight bit set
	beq.w   .ex             ; branch if not
	clr.w   (ChkCnt).w      ; Clear ChkCnt
	moveq   #$19,d0         ; # of players on team
	move 	#HmChksFor,a0	; Home Team player ChksFor
.loop:                                  
	clr.b   $364(a0)        ; clears ChksF array
							; when I use this offset in 94, it leads to ChksFor array
	clr.b   (a0)+
	dbf     d0,.loop

	addi.w  #$3E8,(crowdlevel).w ; add 1000 dec to crowd
	addi.w  #$23,(CwdExciteLvl).w ; add to crowd excite lvl
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
	blt.w   .o1             ; branch if a3 Xpos is less than a2 Xpos
	eori.w  #7,d1           ; sets d1 to 5
.o1:                                   
	move.w  d1,$54(a3)      ; d1 into facedir
	eori.w  #7,d1           ; EOR with d1. This part is making players face each other
	move.w  d1,$54(a2)      ; d1 into facedir
	move.l  a3,-(sp)        ; push a3 to stack
	bsr.w   SF              ; start fight subroutine
	exg     a2,a3
	bsr.w   SF
	move 	#SortCords,a3 	; Start of Player Structs
	move.l  #afwatch,d0         ; assfwatch - assignment for other players to watch the fight
	moveq   #$B,d1          ; # of player structs to iterate through
.0:                                
	btst    #0,$63(a3)      ; check if player fighting
	bne.w   .next           ; if so, branch
	tst.w   $34(a3)         ; check if goalie
	beq.w   .next           ; if so, branch
	btst    #2,$63(a3)      ; check if player unavailable
	bne.w   .next           ; if so, branch
	jsr 	assinsert
.next:                                  							
	adda.w  #$80,a3         ; move to next player struct
	dbf     d1,.0
	movea.l #puckx,a3
	bset    #0,$63(a3)      ; set puck's fight flag
	move.l  #punflip,d0     ; pnothing - assignment for puck not doing anything
	jsr   	assinsert		; insert new assignment
	st      (collflag).w	; set collflag
	movea.l (sp)+,a3        ; pop off stack original a3 value
.ex:                                
							
	movem.l (sp)+,d0-d4/a0-a3
	rts
; End of function checkfight

; start fight?
; Need AddPenalty2, setd0player, assinsert, SetSPA ROM addresses

SF:                                   	
; start fight

	move.w  $52(a2),$2E(a3) ; move SCnum into impactp of a3
	move.l  #PenFighting,d0 ; #PenFighting
	jsr   	AddPenalty2
	move.w  $52(a3),d0      ; SCnum of a3 into d0
	jsr   	setd0player
	move.l  #afight,d0      ; assfight assignment
	jsr   	assinsert		; insert new assignment
	bclr    #3,4(a3)        ; clear attribute
	move.w  #$FC00,d1       ; -400 dec into d1
	cmpi.w  #2,$54(a3)      ; compare to facedir
	beq.w   .sf2            ; branch if equal
	bset    #3,4(a3)        ; set attribute
	neg.w   d1              ; negate d1
.sf2:                                   
	move.w  d1,$28(a3)      ; move d1 into Xvel
	bset    #2,$63(a3)      ; set unavailable
	bset    #1,$63(a3)      ; set animation in progress
	bset    #5,$63(a3)      ; set no player coll
	bclr    #5,$62(a3)      ; clear animation lock
	move.w  #SPAfight,d1    ; #SPAfight
	jmp   	SetSPA			; set animation
; End of function SF


ChkFightValue:
; Lines commented for testing purposes                          
;	cmp.b   $74(a3),d0      ; checks fight value with d0
;	bhi.w   rtss            ; exit if d0 is higher
;	cmpi.b  #2,$74(a2)      ; compare if fight value is 2
;	blt.w   rtss            ; exit if less
	clr.w   d1
	move.b  $66(a2),d1      ; a2's player roster offset into d1
	move 	#tmstruct,a0 	; Home Team bytes			
	btst    #6,$62(a2)      ; check which team a2 is on
	beq.w   .cont       	; branch if home
	adda.w  #$364,a0        ; add for away team struct
.cont:                              
	adda.w  d1,a0           ; add playernum to team byte address
	move.b  $11C(a0),d1     ; moving player's ChksFor into d1
	asl.b   #1,d1			; mult by 2
	neg.b   d1				; negate d1
	addi.b  #$10,d1			; add $10 to d1
	cmp.b   $74(a2),d1      ; compare a2's fight value to d1
;	bgt.w   rtss            ; exit if d1 is greater than
	bset    #0,$63(a2)      ; set fight bit a2
	bset    #0,$63(a3)      ; set fight bit a3
	bne.w   rtss            ; exit if set already
	tst.w   (OptPen).w 		; Check if penalties are off
	beq.w   rtss			; exit if so
	move.w  (VDP_CNTR).l,d0 ; a little randomness with the frame counter
	andi.w  #3,d0           ; pass first 2 bits
;	bne.w   rtss            ; exit if first 2 bits of frame counter aren't 0
	movea.l a3,a4
	moveq   #5,d0           ; set loop iterator
	move 	#SortCords,a3 	; Home Player structs
	btst    #6,$62(a4)      ; check which team a4 (a3 is on)
	beq.w   .playerloop     ; branch if home
	adda.w  #$300,a3        ; add offset to Away player structs
.playerloop:                           							
	cmpa.w  a3,a4           ; check if a3 and a4 are the same player
	beq.w   .endloop        ; branch if so
	tst.w   $34(a3)         ; check if goalie
	ble.w   .endloop        ; branch if goalie or there's no goalie
	btst    #4,$63(a3)      ; check if player caused a penalty
	bne.w   .endloop        ; branch if so
	btst    #2,$63(a3)      ; check if player unavailable
	bne.w   .endloop        ; branch if so
	move.w  #PenInst,d0 	; Instigating Penalty
	jsr   	AddPenalty2
	movea.l a4,a3
	rts

.endloop:                               
	adda.w  #$80,a3         ; move to next player struct
	dbf     d0,.playerloop  ; decrement d0, loop
	movea.l a4,a3
	rts
; End of function ChkFightValue


assfight:
; fighting logic
; a3 = player  

	btst    #5,$62(a3)      ; check if animation lock
	bne.w   rtss            ; exit if so
	tst.w   (PenCntDwn).w   ; Check penalty count
	bpl.w	.new            ; branch if positive or zero
    jmp   	assnothing      ; assnothing if negative (countdown over)
.new:
	bclr    #1,$62(a3)      ; clear new assignment
	beq.w   .nna            ; branch if this was already cleared (not first time through)
	jsr   	getpde          ; get player's energy level
	move.b  $74(a3),d1      ; move fight value into d1
	ext.w   d1              ; word extend d1 (to pad it with FF)
	mulu.w  d1,d0           ; mult d1 with d0 (energy level)
	lsr.w   #8,d0           ; divide by 256
	lsr.w   #4,d0           ; divide by 16
	cmp.w   #5,d0           ; compare to 5
	bgt.w   .gt        		; branch if greater than
	moveq   #5,d0           ; min d0 is 5
.gt:                           
	move.w  d0,$44(a3)      ; move into temp3 - strength
	clr.w   $42(a3)         ; clear temp2
	move.w  #$FFFF,$46(a3)  ; move FFFF into temp4
	cmpi.w  #2,$54(a3)      ; compare 2 to facedir
	bne.w   .nna            ; branch if not equal
	move.w  #$5A,$46(a3)	; move 90 dec into temp4
.nna:                                   
							
	sub.w   d7,$46(a3)      ; sub frames elapsed from temp4
	bcc.w   .nna2           ; branch if carry
;	bsr.w   banner          ; ???? - I believe this sets up fight banner
.nna2:                           
	tst.w   $44(a3)         ; test temp3
	bmi.w   rtss            ; branch if negative
	move.w  $2E(a3),d0      ; move impactp into d0 (past impact player)
	asl.w   #7,d0           ; mult by 128 (size of player struct)
	move 	#SortCords,a0 	; player struct start
	adda.w  d0,a0           ; add d0 to a0 address (offset to impactp player struct)
	move.w  (a3),d0         ; Xpos into d0
	add.w   (a0),d0         ; add a0 Xpos to d0
	asr.w   #1,d0           ; divide by 2
	move.w  d0,(xc1).w      ; store d0
	btst    #3,$62(a3)      ; test if joy controlled
	bne.w   .j              ; branch if so
	bset    #1,$63(a3)      ; set anim in progress
	bne.w   .j              ; branch if already set
	move.w  (a3),d0         ; move Xpos into d0
	sub.w   (a0),d0         ; sub a0 Xpos
	move.w  $28(a3),d1      ; move Xvel into d1
	asr.w   #8,d1           ; divide by 256
	add.w   d1,d0           ; add d1 to d0
	move.w  $28(a0),d1      ; Xvel of a0 into d1
	asr.w   #8,d1           ; divide by 256
	sub.w   d1,d0           ; sub d1 from d0
	cmp.w   #$14,d0         ; compare to 20 dec
	bgt.w   .j              ; branch if greater than
	cmp.w   #$FFEC,d0       ; compare to -20 dec
	blt.w   .j              ; branch if less than
	moveq   #8,d0           ; move 8 into d0
	jsr   	randomd0        ; RNG d0
	cmp.w   #2,d0           ; compare to 2
	bls.w   .lt        		; branch if less than
	andi.w  #1,d0           ; pass first bit of d0
.lt:                            
	asl.w   #1,d0           ; mult by 2
	lea     .a1(pc),a1      ; choose punch type
	move.w  (a1,d0.w),d1    ; move SPA into d1
	jsr   	SetSPA          ; set animation
.j:                                     
							
	bsr.w   chkhit
	cmpi.w  #SPAfheld,$58(a3)   ; #SPAfheld
	beq.w   .njc
	cmpi.w  #SPAfight,$58(a3)   ; #SPAfight
	beq.w   .jc
	btst    #3,$62(a3)      ; check if joy controlled
	bne.w   .jc             ; branch if so
.njc:                                   
	move.w  (xc1).w,d0      ; move into d0
	addi.w  #$A,d0          ; add 10 to d0
	cmpi.w  #2,$54(a3)      ; compare 2 to facedir
	bne.w   .0
	subi.w  #$14,d0         ; sub 20 from d0
.0:                                 
	sub.w   (a3),d0         ; Sub Xpos from d0
	asl.w   #5,d0           ; mult by 32
	add.w   d0,$28(a3)      ; add d0 to Xvel
.jc:                                   
	move.w  (yc1).w,d1      ; move y sroll lock into d1
	sub.w   $14(a3),d1      ; sub Ypos from d1
	asl.w   #8,d1           ; mult by 256
	cmp.w   #$1000,d1       ; compare to 4096 dec
	blt.w   .y1             ; branch if less than
	move.w  #$1000,d1       ; move 4096 into d1
.y1:                                    
	cmp.w   #$F000,d1       ; compare to -$1000
	bgt.w   .y2
	move.w  #$F000,d1       ; move -$1000 into d1
.y2:                                   
	move.w  d1,$2A(a3)      ; move d1 into Yvel
	rts
; End of function assfight
; ---------------------------------------------------------------------------
.a1:
	dc.w SPAfgrab          	; SPAfgrab
	dc.w SPAfhigh           ; SPAfhigh
	dc.w SPAflow            ; SPAflow


chkhit:
; part of fight to see if player is hit
; a3 = player

	movem.l d0/a0-a3,-(sp)
	move.w  6(a3),d0        ; move alice frame number into d0
	cmp.w   8(a3),d0        ; compare old frame to d0
	beq.w   .ex
	cmp.w   #SPFfight+2,d0  ; compare SPFfight+2 to d0
	beq.w   .dropped        ; branch if equal
	move.w  (a3),d0         ; Xpos into d0
	sub.w   (a0),d0         ; sub a0 Xpos
	cmp.w   #$16,d0         ; compare to 22 dec
	bgt.w   .ex             ; exit if greater than (too far away)
	cmp.w   #$FFEA,d0       ; compare to -22 dec
	blt.w   .ex             ; exit if less than (too far away)
	move.w  $14(a3),d0      ; Ypos into d0
	sub.w   $14(a0),d0      ; sub a0 Ypos
	cmp.w   #8,d0           ; compare to 8
	bgt.w   .ex             ; exit if greater than (too far away)
	cmp.w   #$FFF8,d0       ; compare to -8
	blt.w   .ex             ; exit if less than (too far away)
	move.w  6(a3),d0        ; move frame into d0
	cmp.w   #SPFfight+6,d0        ; compare SPFfight+6
	beq.w   .hithigh        ; branch if equal
	cmp.w   #SPFfight+6+5,d0        ; compare SPFfight+6+5
	beq.w   .hithigh        ; branch if equal
	cmp.w   #SPFfight+7,d0        ; compare SPFfight+7
	beq.w   .hitlow         ; branch if equal
	cmp.w   #SPFfight+7+5,d0        ; compare SPFfight+7+5
	beq.w   .hitlow         ; branch if equal
	cmp.w   #SPFfight+4,d0        ; compare SPFfight+4
	beq.w   .grab           ; branch if equal
	cmp.w   #SPFfight+4+5,d0        ; compare SPFfight+4+5
	beq.w   .grab           ; branch if equal
.ex:                               
	movem.l (sp)+,d0/a0-a3
	rts
.dropped:                              
	bclr    #5,$63(a3)      ; clear no player coll
	move.w  (xc1).w,d0      ; move x scroll lock coord into d0
	cmp.w   #$5A,d0    		; compare $5A to d0 (90 dec)
	blt.w   .chkneg         ; branch if less than
	moveq   #$5A,d0    		; move $5A into d0
.chkneg:                               
	cmp.w   #$FFA6,d0       ; compare -$5A to d0
	bgt.w   .drcont
	moveq   #$FFFFFFA6,d0   ; move -$5A into d0
.drcont:                               
	asr.w   #2,d0           ; divide by 4
	bne.w   .dr0            ; branch if not zero
	addq.w  #1,d0           ; add 1 to d0
.dr0:                                   
	move.b  d0,(glovecords).w ; move d0 into glovecords
	move.w  (yc1).w,d0      ; move y scroll lock coord into d0
	asr.w   #2,d0           ; divide by 4
	move.b  d0,(glovecords+1).w ; move d0 into glovecords +1
	bra.s   .ex             ; exit
.grab:                                  
	exg     a0,a3           ; swap a0 and a3
	bset    #1,$63(a3)      ; set animation in progress
	move.w  #SPAfheld,d1        ; #SPAfheld
	jsr   	SetSPA
	bra.s   .ex
.hithigh:                               
	exg     a0,a3           ; swap a0 and a3
	bsr.w   CwdFight        ; add to crowd
	bset    #1,$63(a3)      ; set animation in progress
	subq.w  #1,$44(a3)      ; sub 1 from temp3
	bmi.w   .FightFall       ; branch if minus
	move.w  #SPAfhith,d1       ; #SPAfhith
	jsr   	SetSPA          ; set animation
	move.w  #9,-(sp)        ; #SFXhithigh
	jsr   	sfx
	bra.s   .ex
.hitlow:                                
	exg     a0,a3           ; swap a0 and a3
	bsr.w   CwdFight
	bset    #1,$63(a3)      ; set animation in progress
	subq.w  #1,$44(a3)      ; sub 1 from temp3
	bmi.w   .FightFall       ; branch if minus
	move.w  #SPAfhitl,d1       ; #SPAfhitl
	jsr   	SetSPA          ; set animation
	move.w  #$A,-(sp)       ; #SFXhitlow
	jsr   	sfx             ; make SFX
	bra.w   .ex

.FightFall:                              
	movem.l a1,-(sp)        ; push to stack
	move #PenBuf,a1 		; PenBuf
.cont:                                
	addq.w  #2,a1           ; add 2 to a1
	cmpi.b  #$26,(a1)  		; compare 26 to a1
	bne.s   .cont
	move.b  1(a1),d0        ; move 1(a1) into d0
	andi.w  #$F,d0          ; pass first 4 bits of d0
	cmp.w   $52(a0),d0      ; compare SCnum to d0
	bne.s   .cont           ; branch if not equal
	move.b  #$28,(a1)  		; move 40 dec into a1 position
	movem.l (sp)+,a1        ; pop from stack
	move.w  #$3C,(PenCntDwn).w ; move 60 dec into PenCntDown
	move.w  #$FFFF,$44(a0)  ; move -1 into temp3
	addi.w  #$258,(crowdlevel).w ; add to crowd
	addi.w  #$1E,(CwdExciteLvl).w ; add to crowd excite
	moveq   #$3C,d0    		; move 60 dec into d0
	jsr   	randomd0        ; RNG
	cmp.b   $75(a0),d0      ; compare Chk value to d0
;	bgt.w   .fall        	; branch if greater than
	bra.w 	.fall			; Added in to skip fight injury part	
; This part has to do with injury from fight. Will need to be tested later

	move.w  #$B4,(PenCntDwn).w ; move 180 dec into PenCntDwn - the rest of this might have to do with injured player
	bset    #6,$63(a3)      ; set player caused a penalty? (not in 92)
	move.w  #SPAffall,d1       ; #SPAffall
	jsr   	SetSPA          ; set animation
	bsr.w   clear       	; clears banner?
	movea.w a3,a2           ; move a3 address into a2
	jsr   	setInjuryType	; Set injury for player
	move.w  #$112C,$66(a0,d1.w)	; ??? - changes player status to $112C
	move.w  #3,(InjCntDown).w	; set InjCntDown
	bra.w   .ex
.fall:                              
	move.w  #SPAbfall,d1    ; #SPAbfall?
	jsr   	SetSPA          ; set animation
	move #tmstruct,a2		; Team struct
	move.w  #$B,-(sp)       ; #SFXcrowdcheer
	btst    #6,$62(a3)      ; check if home or away
	bne.w   .3              ; branch if away
	lea     $364(a2),a2     ; Set to away tmstruct
	move.w  #$C,(sp)        ; #SFXcrowdboo
.3:                                     
	jsr   	sfx
	bra.w   .ex
; End of function chkhit

CwdFight:
; Add to crowd level, adjust fighter's X velocity

	addi.w  #$50,(crowdlevel).w ; 'P' ; add to crowd level
	addi.w  #$A,(CwdExciteLvl).w
	moveq   #5,d0
	add.w   $44(a0),d0      ; add temp3 to d0
	mulu.w  #$1F4,d0        ; mult d0 by 500 dec
	cmpi.w  #2,$54(a3)      ; compare 2 to facedir
	bne.w   .xveladj        ; branch if not equal
	neg.w   d0              ; negate d0
.xveladj:                             
	add.w   d0,$28(a3)      ; add d0 to Xvel
	rts
; End of function CwdFight

clear:                              
	jsr   	printz		; printz
	ori.b   #0,d6
	btst    d0,d0
	moveq   #$28,d0 
	moveq   #5,d1
	move.w  #$7FF,d2
	jsr   	eraser		; eraser
; End of function clear

assfwatch:
; Assignment for player who is watching fight

	btst    #5,$62(a3)		; check if anim lock
	bne.w   rtss			; exit if so
	btst    #3,$62(a3)		; check if joystick controlled
	bne.w   rtss			; exit if so
	bclr    #1,$62(a3)		; clear new assignment
	beq.w   .nna			; jump if it was already cleared
	clr.w   $40(a3)			; clear temp1
.nna:                               
	sub.w   d7,$40(a3)		; sub d7 (elapsed frames) from temp1
	bpl.w   .skate			; branch if positive
	addi.w  #$3C,$40(a3)	; add 60 dec to temp1
	move.w  (a3),d0			; move Xpos into d0
	sub.w   (xc1).w,d0		; sub scroll lock from d0
	move.w  $14(a3),d1		; move Ypos into d1
	sub.w   (yc1).w,d1		; sub scroll lock from d1
	movem.w d0-d1,-(sp)		; push to stack
	muls.w  d0,d0			; square d0
	muls.w  d1,d1			; square d1
	add.l   d1,d0			; add d1 and d0
	jsr   	sroot			; square root to find hypotenuse
	move.w  d0,d2			; move d0 into d2
	bne.w   .n0				; branch if not 0
	moveq   #1,d2			; move d1 into d2
.n0:                               
	movem.w (sp)+,d0-d1		; pop from stack
	muls.w  #$50,d0			; mult d0 by 80 dec 
	divs.w  d2,d0			; divide d2 into d0
	add.w   (xc1).w,d0		; add scroll lock to d0
	move.w  #$7E,d3			; move 126 into d3	
	cmp.w   d3,d0			; compare d3 to d0 - this is determining what side of scroll lock player is on
	blt.w   .lt				; branch if less than
	move.w  d3,d0			; move d3 into d0
.lt:                               
	neg.w   d3				; negate d3
	cmp.w   d3,d0			; compare d3 to d0
	bgt.w   .gt				; branch if d0 greater than
	move.w  d3,d0			; move d3 into d0
.gt:                               
	move.w  d0,$44(a3)		; move d0 into temp3
	muls.w  #$50,d1			; mult d1 by 80 dec
	divs.w  d2,d1			; divide d2 into d1
	add.w   (yc1).w,d1		; add scroll lock to d1
	move.w  d1,$46(a3)		; move d1 into temp4
.skate:                               
	move.w  $44(a3),d0		; temp3 into d0 (X destination)
	move.w  $46(a3),d1		; temp4 into d1 (Y destination)
	lea     rtss(pc),a0		; no extra collision routine
	jsr   	skateto			; skate to position
	jmp   	check4check		; look for checks
; End of function assfwatch

SPAjump:
    jmp SetSPA              ; jump to SetSPA

;;;;;;;;;;;;;;;;;;;;;;;;;;;

banner:                               
                movem.l d0-d3/a0-a4,-(sp)
                movea.w tmstruct,a2 ; Move home team struct into a2
                jsr     lcfound2    ; Find line change line
                adda.w  #$300,a2    ; Move to Away team struct
                jsr     lcfound2    ; Find line change line
                jsr     box         ; Make banner box
                movea.w PenBuf,a0   ; Move Pen Buffer into a0
                clr.w   d2          ; clear d2
.n0:                              
                tst.w   (a0)+       ; Test a0
                bne.s   .n0         ; branch if not 0
                move.b  -3(a0),d0   ; move a0-3 data into d0
                clr.b   d3          ; clear d3
                bsr.w   sub_A95A    ; Get name of player?
                neg.b   d3          ; negate d3
                move.b  -5(a0),d0   ; move a0-5 data into d0
                bsr.w   sub_A95A    ; Get name of player?
                
                jsr   printz        ; print string following JSR
                dc.b    0
                dc.b    6
                dc.b    $BF
                dc.b    $F
                dc.b    $1
                dc.b    $0

                btst    d0,d0
                move.w  d2,d0
                lsr.w   #1,d2
                sub.w   d2,(printx).w
                moveq   #5,d1
                jsr   Framer
                move.w  #2,(printy).w
                tst.b   d3
                bmi.w   loc_A92A
                move.w  #4,(printy).w
loc_A92A:                              
                move.b  -3(a0),d0
                bsr.w   sub_A95A
                jsr   print
                eori.w  #6,(printy).w
                move.b  -5(a0),d0
                bsr.w   sub_A95A
                jsr   print
                jsr   printz
                ori.b   #$F,a0
                bchg    d1,0(a6,d7.w*2)
                movem.l (sp)+,d0-d3/a0-a4
                rts
; End of function banner
->>>>

sub_A95A:                              
                movea.w #(SortCords),a1
                andi.w  #$F,d0
                asl.w   #7,d0
                add.b   $74(a1,d0.w),d3
                movea.w tmstruct,a2
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