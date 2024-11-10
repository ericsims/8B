; ###
; cordic.asm begin
; ###

#once

#bank rom

;;
; @function
; @brief computes sin(x)
; @section description
; computes sin(x)
; takes a 32 bit (16 bit fractional) signed input and returns the sine of this value to the location pointed to be the outp param
; referneces:
;  - https://github.com/francisrstokes/githublog/blob/main/2024/5/10/cordic.md
;  - https://en.wikipedia.org/wiki/CORDIC
;  - https://www.drdobbs.com/microcontrollers-cordic-methods/184404244
; @param .param16_outp result pointer
; @param .param32_x input value
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
; 21  |__.local8_shift_iter___|
; 22  |  .local16_table_ptr   |
; 23  |_______________________|
; 24  |  .local32_table_val   |
; 25  |                       |
; 26  |                       |
; 27  |_______________________|
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
    .local8_shift_iter = 21
    .local16_table_ptr = 22
    .local32_table_val = 24

    .init:
        __prologue
        __push32 #cordic_sin_x ; .local32_x
        __push32 #0 ; .local32_y
        __push32 #0 ; .local32_x_next
        __push32 #0 ; .local32_y_next
        ; init .local32_z with input
        loadw hl, (BP), .param32_x
        pushw hl
        loadw hl, (BP), .param32_x+2
        pushw hl
        pushw #0 ; .local8_iter, .local8_shift_iter
        pushw #cordic_sin_coeffs ;.local16_table_ptr
        __push32 #0 ; .local32_table_val
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

    ; right shift y and x first. use the x_next and y_next as placeholder
    load b, (BP), .local8_iter
    store b, (BP), .local8_shift_iter

    loadw hl, (BP), .local32_x
    pushw hl
    loadw hl, (BP), .local32_x+2
    pushw hl
    .shift_x:
    load b, (BP), .local8_shift_iter
    add b, #0
    jmz .done_shift_x
    call rshift_32
    load b, (BP), .local8_shift_iter
    sub b, #1
    store b, (BP), .local8_shift_iter
    .done_shift_x:
    popw hl
    storew hl, (BP), .local32_x_next+2
    popw hl
    storew hl, (BP), .local32_x_next


    load b, (BP), .local8_iter
    store b, (BP), .local8_shift_iter

    loadw hl, (BP), .local32_y
    pushw hl
    loadw hl, (BP), .local32_y+2
    pushw hl
    .shift_y:
    load b, (BP), .local8_shift_iter
    add b, #0
    jmz .done_shift_y
    call rshift_32
    load b, (BP), .local8_shift_iter
    sub b, #1
    store b, (BP), .local8_shift_iter
    .done_shift_y:
    popw hl
    storew hl, (BP), .local32_y_next+2
    popw hl
    storew hl, (BP), .local32_y_next
    halt
    ; load coeff table value
    loadw hl, (BP), .local16_table_ptr
    load a, (hl)
    store a, (BP), .local32_table_val
    addw hl, #1
    load a, (hl)
    store a, (BP), .local32_table_val+1
    addw hl, #1
    load a, (hl)
    store a, (BP), .local32_table_val+2
    addw hl, #1
    load a, (hl)
    store a, (BP), .local32_table_val+3


    halt

    load a, (BP), .local32_z ; check sign of z
    add a, #0
    jmn .zneg
    .zpos:

    .zneg:
        
    .store:
        loadw hl, (BP), .local32_x_next
        storew hl, (BP), .local32_x
        loadw hl, (BP), .local32_x_next+2
        storew hl, (BP), .local32_x+2
        loadw hl, (BP), .local32_y_next
        storew hl, (BP), .local32_y
        loadw hl, (BP), .local32_y_next+2
        storew hl, (BP), .local32_y+2

        loadw hl, (BP), .local16_table_ptr
        addw hl, #0x04
        storew hl, (BP), .local16_table_ptr

    .done:
        popw hl
        popw hl

        popw hl

        popw hl

        popw hl
        popw hl

        popw hl
        popw hl

        popw hl
        popw hl

        popw hl
        popw hl

        popw hl
        popw hl
        
        __epilogue
        ret



cordic_sin_coeffs: #d inchexstr("./cordic_sin_coeffs.dat")
cordic_sin_x = 0x00009B75

#include "math.asm"

; ###
; cordic.asm end
; ###
