; ###
; math.asm begin
; ###

#once     
#bank rom

add32: ; x, y (addreses SP+12, SP+8)
; ******
; add32 takes two 32 bit params and adds them. leaves flags from the MSB addition in the flag register
; returns 32bit summation to result pointer. carry flag is left in a register.
; ******

; param stack indicies. points to MSBs
.x = 14 ; 11 thru 14
.y = 10 ; 7 thru 10
.res_addr = 6 ; 5 thru 6
; local variables stack indicies. points to MSBs
.cf = 0
.z = -1 ; -1 thru -4
    __prologue
    pushw #0x1111 ; init z=0
    pushw #0x1111 ; init z=0
    push #0x00    ; init cf=0


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

    pop a ; save cf to a register

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