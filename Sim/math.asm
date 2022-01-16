; ###
; math.asm begin
; ###

    
#bank rom
multiply: ; x, y (addreses SP+6, SP+5)
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
    
    
multiply16: ; x, y, z (return)
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