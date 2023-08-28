; ###
; math.asm begin
; ###

#once
#bank rom

add32: ; x, y, result pointer, (SP+14, SP+10, SP+6)
    ; ******
    ; add32 takes two 32 bit params and adds them.
    ; returns 32bit summation to result pointer. carry flag is left in b register.
    ; WARNGING: this funciton contamintes the x var
    ; ******

    ; param stack indicies. points to MSBs
    .x = 14 ; 11 thru 14
    .y = 10 ; 7 thru 10
    .res_addr = 6 ; 5 thru 6
    ; local variables stack indicies. points to MSBs
    .cf = 0
    .z = -1 ; -1 thru -4
    __prologue
    push #0x00    ; init cf=0
    pushw #0x1111 ; init z=0
    pushw #0x1111 ; init z=0


    .add_byte1:
        __load_local b, .x-3
        __load_local a, .y-3
        add a, b
        jmc .handle_first_carry1
        __store_local a, .z-3
        jmp .add_byte2
    .handle_first_carry1:
        __store_local a, .z-3
        __load_local a, .x-2
        load b, #0x01
        add a, b
        jmc .handle_first_carry2
        __store_local a, .x-2
        jmp .add_byte2
    .handle_first_carry2:
        __store_local a, .x-2
        __load_local a, .x-1
        load b, #0x01
        add a, b
        jmc .handle_first_carry3
        __store_local a, .x-1
        jmp .add_byte2
    .handle_first_carry3:
        __store_local a, .x-1
        __load_local a, .x
        load b, #0x01
        add a, b
        jmc .handle_first_carry4
        __store_local a, .x
        jmp .add_byte2
    .handle_first_carry4:
        __store_local a, .x
        load a, #0x01
        __store_local a, .cf


    .add_byte2:
        __load_local b, .x-2
        __load_local a, .y-2
        add a, b
        jmc .handle_second_carry2
        __store_local a, .z-2
        jmp .add_byte3
    .handle_second_carry2:
        __store_local a, .z-2
        __load_local a, .x-1
        load b, #0x01
        add a, b
        jmc .handle_second_carry3
        __store_local a, .x-1
        jmp .add_byte3
    .handle_second_carry3:
        __store_local a, .x-1
        __load_local a, .x
        load b, #0x01
        add a, b
        jmc .handle_second_carry4
        __store_local a, .x
        jmp .add_byte3
    .handle_second_carry4:
        __store_local a, .x
        load a, #0x01
        __store_local a, .cf


    .add_byte3:
        __load_local b, .x-1
        __load_local a, .y-1
        add a, b
        jmc .handle_third_carry3
        __store_local a, .z-1
        jmp .add_byte4
    .handle_third_carry3:
        __store_local a, .z-1
        __load_local a, .x
        load b, #0x01
        add a, b
        jmc .handle_third_carry4
        __store_local a, .x
        jmp .add_byte4
    .handle_third_carry4:
        __store_local a, .x
        load a, #0x01
        __store_local a, .cf


    .add_byte4:
        __load_local b, .x
        __load_local a, .y
        add a, b
        jmc .handle_fourth_carry4
        __store_local a, .z
        jmp .done
    .handle_fourth_carry4:
        __store_local a, .z
        load a, #0x01
        __store_local a, .cf


    .done:
        ; save the 4 bytes off to the resultant array location
        __load_local a, .res_addr
        push a
        __load_local a, .res_addr-1
        push a
        popw hl
        addw hl, #0x03
        pop a
        store a, (hl)

        __load_local a, .res_addr
        push a
        __load_local a, .res_addr-1
        push a
        popw hl
        addw hl, #0x02
        pop a
        store a, (hl)

        __load_local a, .res_addr
        push a
        __load_local a, .res_addr-1
        push a
        popw hl
        addw hl, #0x01
        pop a
        store a, (hl)

        __load_local a, .res_addr
        push a
        __load_local a, .res_addr-1
        push a
        popw hl
        pop a
        store a, (hl)

        pop b ; save cf to b register

        __epilogue
  
multiply8_fast: ; x, y, result pointer, (SP+8, SP+7, SP+6))
    ; ******
    ; multiply8_fast takes two unsigned 8 bit params and multiplies them.
    ; returns 16bit summation to result pointer
    ; ******

    ; param stack indicies. points to MSBs
    .x = 8
    .y = 7
    .res_addr = 6 ; 5 thru 6
    ; local variables stack indicies. points to MSBs
    .cf = 0
    .z = -1
    .mulipiler = -3
    .n = -4
    .overflow_temp = -5
    __prologue
    push #0x00    ; init cf=0
    pushw #0x00    ; init z=0
    __load_local a, .y
    push a         ;  init mulipiler=.y
    push #0x08    ; init n=0
    push #0x00    ; init overflow_temp=0
    jmp .skip_load_mult

    .mult:
        __store_local a, .n ; save iteration
        __load_local a, .mulipiler
    .skip_load_mult:
        rshift a
        jnc .next_skip_add; if no bit in ones place, jump to next interation
        __load_local a, .x
        __load_local b, .z
        add a, b
        jnc .next
        __store_local a, .z
        load a, #0x80
        __store_local a, .overflow_temp
        jmp .next_skip_add
    .next:
        __store_local a, .z
    .next_skip_add:
        __load_local a, .z
        rshift a
        jnc .no_carry
    .carry:
        __store_local a, .z
        __load_local a, .z-1
        rshift a
        load b, #0x80
        add a, b
        __store_local a, .z-1
        jmp .checkdone
    .no_carry:
        __store_local a, .z
        __load_local a, .z-1
        rshift a
        __store_local a, .z-1
    .checkdone:
        ; right shift muliplier
        __load_local a, .mulipiler
        rshift a
        __store_local a, .mulipiler

        ; add overflow bit back to z
        __load_local a, .z
        __load_local b, .overflow_temp
        add a, b
        __store_local a, .z
        load a, #0x00
        __store_local a, .overflow_temp


        __load_local a, .n ; load iteration
        load b, #0x01
        sub a, b
        jnz .mult
    .done:
        pop a ; discared overflow_temp
        pop a ; discared n
        pop a ; discared multiplier
        __load_local a, .res_addr
        push a
        __load_local a, .res_addr-1
        push a
        popw hl
        addw hl, #0x01
        pop a
        store a, (hl)

        __load_local a, .res_addr
        push a
        __load_local a, .res_addr-1
        push a
        popw hl
        pop a
        store a, (hl)

        pop a; discard cf

        __epilogue


multiply_repeat_add: ; x, y (addreses SP+6, SP+5)
; param stack indicies
.x = 6
.y = 5
; local variables stack indicies
.y_local = 0
.z = -1
    __prologue

    ; TODO: check and swap params to make this faster

    push #0x00 ; init .y_local = 0
    push #0x00 ; init z=0

    __load_local b, .x
    __load_local a, .y
    add a, #0
    jmz .done
    __store_local a, .y_local
.run:
    __load_local a, .z
    add a, b
    __store_local a, .z
    
    __load_local a, .y_local
    sub a, #1
    jmz .done
    __store_local a, .y_local

    jmp .run
.done:
    pop a ; save z to a reg
    pop b ; discard y_local
    __epilogue
    
    
multiply16_repeat_add: ; x, y, z (return)
; param stack indicies
.x = 8
.y = 7
.z = 5 ; word allocates 5, 6
; local variables stack indicies
.y_local = 0
    __prologue   

    ; TODO: check and swap params to make this faster
    push #0x00 ; init .y_local = 0

    __load_local b, .x
    __load_local a, .y
    add a, #0
    jmz .done
    __store_local a, .y_local
.run:
    __load_local a, .z
    add a, b
    jmc .carry
    __store_local a, .z
    jmp .decrement

.carry:
    __store_local a, .z
    __load_local a, .z+1
    add a, #0x01
    __store_local a, .z+1

.decrement:
    __load_local a, .y_local
    sub a, #1
    jmz .done
    __store_local a, .y_local

    jmp .run
.done:
    pop b ; discard y_local
    __epilogue


; ###
; math.asm end
; ###