; ###
; math.asm begin
; ###

#once

#bank rom

;;
; @function
; @brief takes two 32 bit params and commputs the sum
; @section description
; takes two 32 bit params and adds them
; returns 32bit summation to result pointer. carry flag is left in b register.
; @param .param32_z
; @param .param32_x
; @param .param32_y
; @return carry_flag
;
;      ________________________
; -14 |    .param16_outp      |
; -13 |_______________________|
; -12 |   .param32_x_temp     |
; -11 |                       |
; -10 |                       |
; -9  |_______________________|
; -8  |      .param32_y       |
; -7  |                       |
; -6  |                       |
; -5  |_______________________|
; -4  |___________?___________| RESERVED
; -3  |___________?___________|    .
; -2  |___________?___________|    .
; -1  |___________?___________| RESERVED
;  0  |______.local8_cf_______|
;  1  |      .local32_x       |
;  2  |                       |
;  3  |                       |
;  4  |_______________________|
;  5  |      .local32_z       |
;  6  |                       |
;  7  |                       |
;  8  |_______________________|
;;
add32: ; x, y, result pointer, (SP+14, SP+10, SP+6)
    ; ******
    ; add32 takes two 32 bit params and adds them.
    ; WARNGING: this funciton contamintes the x var
    ; ******

    ; param stack indicies. points to MSBs
    .param16_outp = -14
    .param32_x_temp = -12
    .param32_y = -8
    ; local variables stack indicies. points to MSBs
    .local8_cf = 0
    .local32_x = 1
    .local32_z = 5
    .init:
        __prologue
        push #0x00    ; init cf=0
        ; init localx with paramx
        load a, (BP), .param32_x_temp
        push a
        load a, (BP), .param32_x_temp+1
        push a
        load a, (BP), .param32_x_temp+2
        push a
        load a, (BP), .param32_x_temp+3
        push a
        __push32 #0x0000_0000 ; init local z = 0



    .add_byte1:
        load b, (BP), .local32_x+3
        load a, (BP), .param32_y+3
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
        load a, (BP), .param32_y+2
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
        load a, (BP), .param32_y+1
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
        load a, (BP), .param32_y
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

        pop a
        pop a
        pop a
        pop a

        pop b ; save cf to b register

        __epilogue
; **********************************
  
multiply8_fast: ; x, y, result pointer, (SP+8, SP+7, SP+6))
    ; ******
    ; multiply8_fast takes two unsigned 8 bit params and multiplies them.
    ; returns 16bit summation to result pointer
    ; ******

    ;    _______________________
    ; 8 |_______.param8_x_______|
    ; 7 |_______.param8_y_______|
    ; 6 |   .param16_res_addr   |
    ; 5 |_______________________|
    ; 4 |___________?___________| RESERVED
    ; 3 |___________?___________|    .
    ; 2 |___________?___________|    .
    ; 1 |___________?___________| RESERVED
    ; 0 |______.local8_cf_______|
    ;-1 |      .param16_z       |
    ;-2 |_______________________|
    ;-3 |__.local8_multiplier___|
    ;-4 |______.local8_n________|
    ;-5 |_.local8_overflow_temp_|

    ; param stack indicies. points to MSBs
    .param8_x = 8
    .param8_y = 7
    .param16_res_addr = 6 ; 5 thru 6
    ; local variables stack indicies. points to MSBs
    .local8_cf = 0
    .param16_z = -1
    .multipiler = -3
    .local8_n = -4
    .local8_overflow_temp = -5
    __prologue
    push #0x00    ; init cf=0
    pushw #0x00   ; init z=0
    __load_local a, .param8_y
    push a        ;  init multipiler=.param8_y
    push #0x08    ; init n=0
    push #0x00    ; init overflow_temp=0
    jmp .skip_load_mult

    .mult:
        __store_local a, .local8_n ; save iteration
        __load_local a, .multipiler
    .skip_load_mult:
        rshift a
        jnc .next_skip_add; if no bit in ones place, jump to next interation
        __load_local a, .param8_x
        __load_local b, .param16_z
        add a, b
        jnc .next
        __store_local a, .param16_z
        load a, #0x80
        __store_local a, .local8_overflow_temp
        jmp .next_skip_add
    .next:
        __store_local a, .param16_z
    .next_skip_add:
        __load_local a, .param16_z
        rshift a
        jnc .no_carry
    .carry:
        __store_local a, .param16_z
        __load_local a, .param16_z-1
        rshift a
        load b, #0x80
        add a, b
        __store_local a, .param16_z-1
        jmp .checkdone
    .no_carry:
        __store_local a, .param16_z
        __load_local a, .param16_z-1
        rshift a
        __store_local a, .param16_z-1
    .checkdone:
        ; right shift muliplier
        __load_local a, .multipiler
        rshift a
        store a, (hl) ; same as __store_local a, .multipiler

        ; add overflow bit back to z
        __load_local a, .param16_z
        __load_local b, .local8_overflow_temp
        add a, b
        __store_local a, .param16_z
        load a, #0x00
        __store_local a, .local8_overflow_temp


        __load_local a, .local8_n ; load iteration
        load b, #0x01
        sub a, b
        jnz .mult
    .done:
        pop a ; discared overflow_temp
        pop a ; discared n
        pop a ; discared multiplier
        __load_local a, .param16_res_addr
        push a
        __load_local a, .param16_res_addr-1
        push a
        popw hl
        addw hl, #0x01
        pop a
        store a, (hl)

        __load_local a, .param16_res_addr
        push a
        __load_local a, .param16_res_addr-1
        push a
        popw hl
        pop a
        store a, (hl)

        pop a; discard cf

        __epilogue
; **********************************

multiply_repeat_add: ; x, y (addreses SP+6, SP+5)
    ; param stack indicies
    .param8_x = 6
    .param8_y = 5
    ; local variables stack indicies
    .local8_y = 0
    .param8_z = -1
    __prologue

    push #0x00 ; init .local32_y = 0
    push #0x00 ; init z=0

    __load_local b, .param8_x
    __load_local a, .param8_y
    add a, #0
    jmz .done
    __store_local a, .local8_y
    .run:
        __load_local a, .param8_z
        add a, b
        __store_local a, .param8_z
        
        __load_local a, .local8_y
        sub a, #1
        jmz .done
        __store_local a, .local8_y

        jmp .run
    .done:
        pop a ; save z to a reg
        pop b ; discard y_local
        __epilogue

; **********************************   

multiply16_repeat_add: ; x, y, z (return)
    ; param stack indicies
    .param8_x = 8
    .param8_y = 7
    .param16_z = 5 ; word allocates 5, 6
    ; local variables stack indicies
    .local8_y = 0
        __prologue   

        ; TODO: check and swap params to make this faster
        push #0x00 ; init .local8_y = 0

        __load_local b, .param8_x
        __load_local a, .param8_y
        add a, #0
        jmz .done
        __store_local a, .local8_y
    .run:
        __load_local a, .param16_z
        add a, b
        jmc .carry
        __store_local a, .param16_z
        jmp .decrement

    .carry:
        __store_local a, .param16_z
        __load_local a, .param16_z+1
        add a, #0x01
        __store_local a, .param16_z+1

    .decrement:
        __load_local a, .local8_y
        sub a, #1
        jmz .done
        __store_local a, .local8_y

        jmp .run
    .done:
        pop b ; discard y_local
        __epilogue

; **********************************

rshift_32: ; x, (SP+8,7,6,5)
    ; ******
    ; rshift_32 takes a 32 bit params and right shifts by 1.
    ; saves result inplace. leaves CF in b register
    ; WARNGING: this funciton contamintes the x var
    ; ******

    ;    _______________________
    ; 8 |      .param32_x       |
    ; 7 |                       |
    ; 6 |                       |
    ; 5 |_______________________|
    ; 4 |___________?___________| RESERVED
    ; 3 |___________?___________|    .
    ; 2 |___________?___________|    .
    ; 1 |___________?___________| RESERVED
    ; 0 |_______.local8_n_______|
    ;-1 |_____.local8_carry_____|
    ;-2 |__.local8_last_carry___|


    .param32_x = 8
    .local8_n = 0
    .local8_carry = -1
    .local8_last_carry = -2
    .init:
    __prologue
    push #0x00 ; n = 0
    push #0x00 ; carry = 0
    push #0x00 ; last_carry = 0
    .loop:
    __load_local b, .local8_n
    ; load paramter byte into a reg
    loadw hl, BP
    subw hl, b
    addw hl, #.param32_x
    load a, (hl)
    ; TODO: use pushw to save a cople clock cycles
    ; pushw hl ; save the hl adress for later in .store, saves on redoing this math 

    ; right shift and then check carry flag
    rshift a

    ; save temp carry value
    load b, #0x00
    jnc .save_carry
    load b, #0x01
    .save_carry:
    __store_local b, .local8_carry

    ; carry over last bit, if necessay
    __load_local b, .local8_last_carry
    add b, #0x00
    jmz .store ; skip carrying if last_carry is zero
    or a, #0x80 ; set high bit from rshift carry
    .store:
    ; TODO: use popw to save a cople clock cycles
    ; popw hl ; pop saved address
    ; set destination ptr in hl
    __load_local b, .local8_n
    loadw hl, BP
    subw hl, b
    addw hl, #.param32_x

    store a, (hl)
    .update_last_carry:
    __load_local a, .local8_carry
    __store_local a, .local8_last_carry

    ; check if iterated over entire 32b word
    .check_done:
    __load_local b, .local8_n
    add b, #0x01
    __store_local b, .local8_n
    sub b, #0x04
    jmz .done
    jmp .loop
    .done:
    pop b ; save last_carry in b reg
    pop a ; discard carry
    pop a ; discard n
    __epilogue

; **********************************

; ###
; math.asm end
; ###