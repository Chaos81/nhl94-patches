;Ram Address $FFDF00 is the new base address for the new menu items.
ReadNewMenuRam:
    cmp.w   #16,d7
    ble     .read_old_base
    move.w  d7,-(sp)                    ; Push d7 onto the stack
    add.w   #NewMenuRamOffset,d7        ; Add $EB8 to d7 to get the new base address
    move.w  (a2,d7.w),d3
    move.w  (sp)+,d7                    ; Restore d7 from the stack
    bra     .exit    

.read_old_base
    move.w  (a2,d7.w),d3

.exit
    cmpi.w  #2,(OptPlayMode).w          ; Run old hijacked instrucion
    rts                                 ; Return to the calling function we jumped from

ReadNewMenuRam2:    
    cmp.w   #16,d7
    ble     .read_old_base
    move.w  d7,-(sp)                    ; Push d7 onto the stack
    add.w   #NewMenuRamOffset,d7        ; Add $EB8 to d7 to get the new base address
    move.w  (a0,d7.w),d3                ; Different from ReadNewMenuRam its using a0 instead of a2
    move.w  (sp)+,d7                    ; Restore d7 from the stack
    bra     .exit

.read_old_base
    move.w  (a0,d7.w),d3                

.exit
    movea.l #SubMenuItems,a0            ; Run old hijacked instrucion
    rts                                 ; Return to the calling function we jumped from