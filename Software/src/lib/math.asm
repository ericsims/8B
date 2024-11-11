; ###
; math.asm begin
; ###

#once

#bank rom

;;
; @function
; @brief takes two 32 bit params and commputes the sum
; @section description
; takes two 32 bit params and adds them
; returns 32bit summation to result pointer. carry flag is left in b register.
; @param .param16_inp_x pointer to 32 bit input value x
; @param .param16_inp_y pointer to 32 bit input value y
; @param .param16_outp pointer to 32 bit result location
; @return carry_flag
;
;      ________________________
; -10 |    .param16_inp_x     |
;  -9 |_______________________|
;  -8 |    .param16_inp_y     |
;  -7 |_______________________|
;  -6 |     .param16_outp     |
;  -5 |_______________________|
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;   0 |______.local8_cf_______|
;   1 |      .local32_x       |
;   2 |                       |
;   3 |                       |
;   4 |_______________________|
;   5 |      .local32_y       |
;   6 |                       |
;   7 |                       |
;   8 |_______________________|
;   9 |      .local32_z       |
;  10 |                       |
;  11 |                       |
;  12 |_______________________|
;;
add32:
    ; param stack indicies. points to MSBs
    .param16_inp_x = -10
    .param16_inp_y = -8
    .param16_outp = -6
    ; local variables stack indicies. points to MSBs
    .local8_cf = 0
    .local32_x = 1
    .local32_y = 5
    .local32_z = 9
    .init:
        __prologue
        push #0x00    ; init cf=0
        ; init localx with paramx
        loadw hl, (BP), .param16_inp_x
        load a, (hl)
        push a
        addw hl, #1
        load a, (hl)
        push a
        addw hl, #1
        load a, (hl)
        push a
        addw hl, #1
        load a, (hl)
        push a
        ; init localy with paramy
        loadw hl, (BP), .param16_inp_y
        load a, (hl)
        push a
        addw hl, #1
        load a, (hl)
        push a
        addw hl, #1
        load a, (hl)
        push a
        addw hl, #1
        load a, (hl)
        push a
        __push32 #0x0000_0000 ; init local z = 0



    .add_byte1:
        load b, (BP), .local32_x+3
        load a, (BP), .local32_y+3
        add a, b
        jmc .handle_first_carry1
        store a, (BP), .local32_z+3
        jmp .add_byte2
    .handle_first_carry1:
        store a, (BP), .local32_z+3
        load a, (BP), .local32_x+2
        load b, #0x01
        add a, b
        jmc .handle_first_carry2
        store a, (BP), .local32_x+2
        jmp .add_byte2
    .handle_first_carry2:
        store a, (BP), .local32_x+2
        load a, (BP), .local32_x+1
        load b, #0x01
        add a, b
        jmc .handle_first_carry3
        store a, (BP), .local32_x+1
        jmp .add_byte2
    .handle_first_carry3:
        store a, (BP), .local32_x+1
        load a, (BP), .local32_x
        load b, #0x01
        add a, b
        jmc .handle_first_carry4
        store a, (BP), .local32_x
        jmp .add_byte2
    .handle_first_carry4:
        store a, (BP), .local32_x
        load a, #0x01
        store a, (BP), .local8_cf


    .add_byte2:
        load b, (BP), .local32_x+2
        load a, (BP), .local32_y+2
        add a, b
        jmc .handle_second_carry2
        store a, (BP), .local32_z+2
        jmp .add_byte3
    .handle_second_carry2:
        store a, (BP), .local32_z+2
        load a, (BP), .local32_x+1
        load b, #0x01
        add a, b
        jmc .handle_second_carry3
        store a, (BP), .local32_x+1
        jmp .add_byte3
    .handle_second_carry3:
        store a, (BP), .local32_x+1
        load a, (BP), .local32_x
        load b, #0x01
        add a, b
        jmc .handle_second_carry4
        store a, (BP), .local32_x
        jmp .add_byte3
    .handle_second_carry4:
        store a, (BP), .local32_x
        load a, #0x01
        store a, (BP), .local8_cf


    .add_byte3:
        load b, (BP), .local32_x+1
        load a, (BP), .local32_y+1
        add a, b
        jmc .handle_third_carry3
        store a, (BP), .local32_z+1
        jmp .add_byte4
    .handle_third_carry3:
        store a, (BP), .local32_z+1
        load a, (BP), .local32_x
        load b, #0x01
        add a, b
        jmc .handle_third_carry4
        store a, (BP), .local32_x
        jmp .add_byte4
    .handle_third_carry4:
        store a, (BP), .local32_x
        load a, #0x01
        store a, (BP), .local8_cf


    .add_byte4:
        load b, (BP), .local32_x
        load a, (BP), .local32_y
        add a, b
        jmc .handle_fourth_carry4
        store a, (BP), .local32_z
        jmp .done
    .handle_fourth_carry4:
        store a, (BP), .local32_z
        load a, #0x01
        store a, (BP), .local8_cf


    .done:
        ; save the 4 bytes off to the resultant array location
        loadw hl, (BP), .param16_outp
        addw hl, #0x03 ; LSB on top of stack
        pop a
        store a, (hl)

        subw hl, #0x01
        pop a
        store a, (hl)

        subw hl, #0x01
        pop a
        store a, (hl)

        subw hl, #0x01
        pop a
        store a, (hl)

        popw hl
        popw hl

        popw hl
        popw hl

        pop b ; save cf to b register

        __epilogue
        ret
        

;;
; @function
; @brief takes two unsigned 8 bit params and multiplies for a 16 bit unsigned result
; @section description
; takes two 8 bit unsigned fparamtesr
; returns 16bit product to result pointer. carry flag is left in b register.
; TODO: carry flag
; @param .param8_x multiplicand
; @param .param8_y multiplicand
; @param .param16_res_addr result pointer
; @return carry_flag
;
;     _______________________
; -8 |_______.param8_x_______|
; -7 |_______.param8_y_______|
; -6 |   .param16_res_addr   |
; -5 |_______________________|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
;  0 |______.local8_cf_______|
;  1 |      .local16_z       |
;  2 |_______________________|
;  3 |__.local8_multiplier___|
;  4 |______.local8_n________|
;  5 |_.local8_overflow_temp_|
;;
mult8: ; x, y, result pointer, (SP+8, SP+7, SP+6))
    ; param stack indicies. points to MSBs
    .param8_x = -8
    .param8_y = -7
    .param16_res_addr = -6
    ; local variables stack indicies. points to MSBs
    .local8_cf = 0
    .local16_z = 1
    .local8_multiplier = 3
    .local8_n = 4
    .local8_overflow_temp = 5
    __prologue
    push #0x00    ; init cf=0
    pushw #0x00   ; init z=0
    load a, (BP), .param8_y
    push a        ;  init multiplier=.param8_y
    push #0x08    ; init n=0
    push #0x00    ; init overflow_temp=0
    jmp .skip_load_mult

    .mult:
        store a, (BP), .local8_n ; save iteration
        load a, (BP), .local8_multiplier
    .skip_load_mult:
        rshift a
        jnc .next_skip_add; if no bit in ones place, jump to next interation
        load a, (BP), .param8_x
        load b, (BP), .local16_z
        add a, b
        jnc .next
        store a, (BP), .local16_z
        load a, #0x80
        store a, (BP), .local8_overflow_temp
        jmp .next_skip_add
    .next:
        store a, (BP), .local16_z
    .next_skip_add:
        load a, (BP), .local16_z
        rshift a
        jnc .no_carry
    .carry:
        store a, (BP), .local16_z
        load a, (BP), .local16_z+1
        rshift a
        add a, #0x80
        store a, (BP), .local16_z+1
        jmp .checkdone
    .no_carry:
        store a, (BP), .local16_z
        load a, (BP), .local16_z+1
        rshift a
        store a, (BP), .local16_z+1
    .checkdone:
        ; right shift muliplier
        load a, (BP), .local8_multiplier
        rshift a
        store a, (BP), .local8_multiplier

        ; add overflow bit back to z
        load a, (BP), .local16_z
        load b, (BP), .local8_overflow_temp
        add a, b
        store a, (BP), .local16_z
        load a, #0x00
        store a, (BP), .local8_overflow_temp


        load a, (BP), .local8_n ; load iteration
        sub a, #0x01
        jnz .mult
    .done:
        pop a ; discared overflow_temp
        pop a ; discared n
        pop a ; discared multiplier

        loadw hl, (BP), .param16_res_addr
        addw hl, #0x01
        pop a
        store a, (hl)

        subw hl, #0x01
        pop a
        store a, (hl)

        pop b; return cf in b register

        __epilogue
        ret

;;
; @function
; @brief takes a 32bit word and righth shifts by one
; @section description
; takes a 32bit word and right shifts by one
; @param .param16_inp pointer to 32 bit input value
; @param .param16_outp pointer to 32 bit output result
; @return carry_flag
;
;      _______________________
;  -8 |     .param16_inp      |
;  -7 |_______________________|
;  -6 |     .param16_outp     |
;  -5 |_______________________|
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;   0 |_______.local8_n_______|
;   1 |_____.local8_carry_____|
;   2 |__.local8_last_carry___|
;;
rshift_32:
    .param16_inp = -8
    .param16_outp = -6
    .local8_n = 0
    .local8_carry = 1
    .local8_last_carry = 2
    .init:
        __prologue
        push #0x00 ; n = 0
        push #0x00 ; carry = 0
        push #0x00 ; last_carry = 0

        ; preserve sign
        loadw hl, (BP), .param16_inp
        load b, (hl)
        and b, #0x80
        jmz .loop
        load b, #0x01
        store b, (BP), .local8_last_carry
    .loop:
        ; load parameter byte into a reg
        loadw hl, (BP), .param16_inp
        load b, (BP), .local8_n
        addw hl, b
        load a, (hl)

        ; right shift and then check carry flag
        rshift a

        ; save temp carry value
        load b, #0x00
        jnc .save_carry
        load b, #0x01
    .save_carry:
        store b, (BP), .local8_carry

        ; carry over last bit, if necessay
        load b, (BP), .local8_last_carry
        add b, #0x00
        jmz .store ; skip carrying if last_carry is zero
        or a, #0x80 ; set high bit from rshift carry
    .store:
        ; set destination ptr in hl
        loadw hl, (BP), .param16_outp
        load b, (BP), .local8_n
        addw hl, b
        store a, (hl)
    .update_last_carry:
        load a, (BP), .local8_carry
        store a, (BP), .local8_last_carry

    ; check if iterated over entire 32b word
    .check_done:
        load b, (BP), .local8_n
        add b, #0x01
        store b, (BP), .local8_n
        sub b, #0x04
        jmz .done
        jmp .loop
    .done:
        pop b ; save last_carry in b reg
        pop a ; discard carry
        pop a ; discard n
        __epilogue
        ret


;;
; @function
; @brief takes a 32 bit value and computes the two's compliment. Returns to result pointer.
; @section description
; takes a 32 bit number and returns the two's comlement 32 bit signed number to the result pointer.
; *outp = -(*x)
; @param .param16_inp pointer to 32 bit input value
; @param .param16_outp pointer to 32 bit output result
; @return none
;      _______________________
;  -8 |     .param16_inp      |
;  -7 |_______________________|
;  -6 |     .param16_outp     |
;  -5 |_______________________|
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;   0 |      .local32_x       |
;   1 |                       |
;   2 |                       |
;   3 |_______________________|
;;
negate32:
    .param16_inp = -8
    .param16_outp = -6
    .local32_x = 0

    .init:
        __prologue
        loadw hl, (BP), .param16_inp
        load b, (hl)
        push b
        addw hl, #1
        load b, (hl)
        push b
        addw hl, #1
        load b, (hl)
        push b
        addw hl, #1
        load b, (hl)
        push b

        loadw hl, (BP), .param16_outp
        addw hl, #3
        

    ; invert LSB to MSB
    .byte3:
        ; byte 3 invert and add one
        load a, (BP), .local32_x+3
        xor a, #0xFF
        add a, #0x01
        store a, (hl)
        ; save cf to b reg
        load b, #0x00
        jnc .byte2
        load b, #0x01
    .byte2:
        subw hl, #1
        ; byte 2 invert and add one
        load a, (BP), .local32_x+2
        xor a, #0xFF
        add a, b
        store a, (hl)
        ; save cf to b reg
        load b, #0x00
        jnc .byte1
        load b, #0x01
    .byte1:
        subw hl, #1
        ; byte 1 invert and add one
        load a, (BP), .local32_x+1
        xor a, #0xFF
        add a, b
        store a, (hl)
        ; save cf to b reg
        load b, #0x00
        jnc .byte0
        load b, #0x01
    .byte0:
        subw hl, #1
        ; byte 0 invert and add one
        load a, (BP), .local32_x
        xor a, #0xFF
        add a, b
        store a, (hl)
    .done:
        popw hl
        popw hl
        __epilogue
        ret

; ###
; math.asm end
; ###