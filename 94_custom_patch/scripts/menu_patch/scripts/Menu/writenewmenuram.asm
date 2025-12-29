;Ram Address $FFDF00 is the new base address for the new menu items.
WriteNewMenuRam:
    cmp.w   #16,d7              ; Checks if were on the new menu items
    ble     .write_old_base     ; If not, use the old base address
    move.w  d7,-(sp)            ; Push d7 onto the stack    
    add.w   #NewMenuRamOffset,d7; Add the offset to d7 to get the new base address
    move.w  d3,(a2,d7.w)        ; Write the new menu item value to the new base address
    move.w  (sp)+,d7            ; Restore d7 from the stack
    bra     .return             ; Return to the calling function we jumped from    

.write_old_base:
    move.w  d3,(a2,d7.w)        ; Write the the old menu item to the old base address

.return:
    tst.w d2                    ; Run old hijacked instrucion
    rts                         ; Return to the calling function we jumped from