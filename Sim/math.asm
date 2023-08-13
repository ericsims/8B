; ###
; math.asm begin
; ###

#once     
#bank rom

add32: ; x, y (addreses SP+12, SP+8)
; ******
; add32 takes two 32 bit params and adds them. leaves flags from the MSB addition in the flag register
; returns summation on the stack at -1
; ******

; param stack indicies. points to MSBs
.x = 12
.y = 8
; local variables stack indicies. points to MSBs
.z = -1
    __prologue
    pushw #0x1111 ; init z=0
    pushw #0x1111 ; init z=0
;.add_lsb:
;    __load_local b, .x-3
;    __load_local a, .y-3
;    add a, b
;    __store_local a, .z-4
.add_lsb_incr:
    __load_local a, .y-3
    load b, #0xFF
    xor a, b
    load b, a
    __load_local a, .x-3
    sub a, b
    halt
    __store_local a, .z-4
.done:
    pop a
    pop a
    pop a
    pop a
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