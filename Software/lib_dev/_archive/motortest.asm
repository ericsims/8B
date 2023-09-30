#include "CPU.asm"

#bank ram
motor_distance_ptr:
    #res 1
delay_ptr:
    #res 1

#bank rom
init:
    sti 50, motor_distance_ptr
    cal drive_dis_dbl
    sti 0xFF, delay_ptr
    cal delay
    sti 0xFF, delay_ptr
    cal delay
    sti 50, motor_distance_ptr
    cal drive_dis_dbl
    hlt



drive_dis_dbl:
    lda motor_distance_ptr
    sta MOT_ENC
    sti 0x01, MOT_CTRL
loop_drive_dis_dbl:
    lda MOT_CTRL
    lbi 0x00
    add
    jnz loop_drive_dis_dbl
    sti 0x20, delay_ptr
    cal delay
    sti 0x01, MOT_CTRL
    ret



delay: ; decr a until 0
    lda delay_ptr
    lbi 0x01
    sub
    sta delay_ptr
    jmz ret
    jmp delay
    
    
    
ret:
    ret
    
   