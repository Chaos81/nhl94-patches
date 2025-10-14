;--------------------------------------------------------
;--This is all dynamic and shouldn't need to be changed--
;--Contains changes to original values that were moded---
;--------------------------------------------------------

;Change Old Menu Pointer to New Menu Items
	org $F807A								
		movea.l #NewCodeAddress,a1

;Change Old SubMenu Period Times Pointer to New SubMenu Item Period Times
	org $F7BB8
		cmpa.l  #PeriodLengths,a0		

;Change Old SubMenu Pointers to New SubMenu Items
	org $F7BAE
		movea.l #SubMenuItems,a0

;Change Old Menu Lengths to new Menu Lenghts
	org $F79AA
		movea.l #MenuLengths,a3

;Change Old Menu Lengths for FourWayPlay to new Menu Lenghts for FourWayPlay
	org $F79B8
		movea.l #MenuLengths2,a3

; Change the number of Sub Items to display from hex 10 to hex 16 (Adds 3 more menu items)
	org $F7B42		
		cmp.w   #MenuItemsCount*2,d7		
	
;Change compare from 3 to x scrolled items
	org $F7756		
		cmpi.w  #ScrollableItemsCount,(word_FFD422).w
		
;Move Adds x more menu items to the menu
	org $F7760
		move.w  #ScrollableItemsCount,(word_FFD422).w

;Fix the Arrow to allow a 6th scrolled item in the list
	org $F7C06
		cmpi.w  #ScrollableItemsCount,(word_FFD422).w

;Increae the number of allowed menu items from 9 to 12
	org $F7778
		cmp.w   #MenuItemsCount*2,d7 ;Get the number of menu items *2
	
;Fix Demo Mode - it skips User Records and Goalie Control, Need to fix this on the way up.	
	org $f753C
		cmp.w   #$20,d7 ; Make This a large number so its never hits.
	org $f7562
		cmp.w   #$20,d7 ; Make This a large number so its never hits.
	org $f7572
		cmp.w   #$20,d7 ; Make This a large number so its never hits.
	org $f7584
		cmp.w   #$20,d7 ; Make This a large number so its never hits.

;New Items Need to have their own RAM Values (HI JACK)
	org $F7ABA
		jsr     WriteNewMenuRam

;$F79C4 reads Menu RAM Addresses. We need to hijack this and read the new ram when d7 >= 16
	org $F79C4
		jsr     ReadNewMenuRam
		nop
		nop
;$F7BAA reads Menu RAM Addresses as well.
	org $F7BAA
		jsr     ReadNewMenuRam2
		nop
		nop

;Remove Old Menu Items (Reclaim Space)
    org $F7D04								; <-- Main Menu Items
    	FILL_FF $36C
	
	org $F80D4								; <-- Sub Menu Items
    	FILL_FF $94
