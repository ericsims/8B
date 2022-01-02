; ###
; math.asm begin
; ###

    
#bank rom
multiply: ; x, y (addreses SP+6, SP+5)
; params
.x = 6
.y = 5
; local variables
.y_local = 0
.z = -1
    __prologue   

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
    
    


; ###
; math.asm end
; ###