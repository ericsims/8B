; ###
; cordic.asm begin
; ###

#once

#bank rom

;;
; @function
; @brief takes two 32 bit params and commputs the sum
; @section description
; takes two 32 bit params and adds them
; returns 32bit summation to result pointer. carry flag is left in b register.
; @param .param16_outp result pointer
; @param .param32_x
; @param .param32_y
; @return carry_flag
;
;      _______________________
;-10  |    .param16_outp      |
; -9  |_______________________|
; -8  |      .param32_x       |
; -7  |                       |
; -6  |                       |
; -5  |_______________________|
; -4  |___________?___________| RESERVED
; -3  |___________?___________|    .
; -2  |___________?___________|    .
; -1  |___________?___________| RESERVED
;  0  |      .local32_x       |
;  1  |                       |
;  2  |                       |
;  3  |_______________________|
;  4  |      .local32_y       |
;  5  |                       |
;  6  |                       |
;  7  |_______________________|
;  8  |    .local32_x_next    |
;  9  |                       |
; 10  |                       |
; 11  |_______________________|
; 12  |    .local32_y_next    |
; 13  |                       |
; 14  |                       |
; 15  |_______________________|
; 16  |      .local32_z       |
; 17  |                       |
; 18  |                       |
; 19  |_______________________|
; 20  |_____.local8_iter______|
;;
cordic_sin:
    ; param stack indicies. points to MSBs
    .param16_outp = -10
    .param32_x = -8
    ; local variables stack indicies. points to MSBs
    .local32_x = 0
    .local32_y = 4
    .local32_x_next = 8
    .local32_y_next = 12
    .local32_z = 16
    .local8_iter = 20

    .init:
        __prologue
        __push32 #cordic_sin_x ; .local32_x
        __push32 #0 ; .local32_y
        __push32 #0 ; .local32_x_next
        __push32 #0 ; .local32_y_next
        ; init .local32_z with input
        load a, (BP), .param32_x
        push a
        load a, (BP), .param32_x+1
        push a
        load a, (BP), .param32_x+2
        push a
        load a, (BP), .param32_x+3
        push a

        push #16 ; .local8_iter
        halt
    
    .iter:
    ; if z >= 0:
    ;     x_next = x - (y >> i)
    ;     y_next = y + (x >> i)
    ;     z -= table[i]
    ; else:
    ;     x_next = x + (y >> i)
    ;     y_next = y - (x >> i)
    ;     z += table[i]
    ; x = x_next
    ; y = y_next

    load a, (BP), .local32_z ; check sign of z
    add a, #0x00
    jmn .zneg
    .zpos:

    .zneg:
        
    

    .done:
        pop a
        pop a
        pop a
        pop a
        pop a
        pop a
        pop a
        pop a
        pop a
        pop a
        pop a
        pop a
        pop a
        pop a
        pop a
        pop a
        pop a
        pop a
        pop a
        pop a
        pop a

        __epilogue
        ret



cordic_sin_coeffs: #d inchexstr("./cordic_sin_coeffs.dat")
cordic_sin_x = 0x00009B75

#include "math.asm"

; ###
; cordic.asm end
; ###
