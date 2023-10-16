; ###
; math_rev_lut.asm begin
; ###
#once

#bank ram
    rev_lut_ptr:
        #res 2

#bank rom

 _rev_lut: ; result, val, rev_lut_addr
    ; ******
    ; _rev_lut takes a result_val placeholder, a 16 bit val, and an address pointer to the beginning of the lut
    ; returns 8 bit value from the lut in results
    ; call satic_add32
    ; ******

    ;    _______________
    ; 9 |____.result____|
    ; 8 |     .val      |
    ; 7 |_______________|
    ; 6 |   .res_addr   |
    ; 5 |_______________|
    ; 4 |_______?_______| RESERVED
    ; 3 |_______?_______|    .
    ; 2 |_______?_______|    .
    ; 1 |_______?_______| RESERVED
    ;   |       ~       | additional ephemeral  stack usage for subcalls

    .result   =  9
    .val      =  8
    .res_addr =  6

    .init:
        __prologue

    .init_ptr:
        loadw hl, BP
        addw hl, #{.res_addr}
        load a, (hl)
        store a, rev_lut_ptr
        subw hl, #0x01
        load a, (hl)
        store a, rev_lut_ptr+1

        ; save val value, and sign extend
        storew #0x0000, static_y_32
        loadw hl, BP
        addw hl, #{.val}
        load a, (hl)
        store a, static_y_32+2
        subw hl, #0x01
        load a, (hl)
        store a, static_y_32+3

    .do_compare:
        ; save x value, and sign extend
        storew #0xFFFF, static_x_32
        loadw hl, rev_lut_ptr
        load a, (hl)
        store a, static_x_32+2
        addw hl, #0x01
        load a, (hl)
        store a, static_x_32+3

        ; do comparison
        call static_add32
        
        load a, static_z_32 ; grab MSB of result
        add a, #0x01
        jmc .done; result is neg

    .incr_addr_ptr:
        ; TODO, i dont really need to load this every cycle
        ; load y
        loadw hl, rev_lut_ptr
        addw hl, #0x02
        load a, (hl)
        __store_local a, .result

        loadw hl, rev_lut_ptr
        addw hl, #0x03
        storew hl, rev_lut_ptr

        jmp .do_compare

    .done:
        __epilogue



; sqrt: ; result, val
;     ; ******
;     ; sqrt takes a result_val placeholder, and 16 bit val
;     ; returns 8 bit value from the lut in results
;     ; calls _rev_lut
;     ; ******

;     ;    _______________
;     ; 7 |____.result____|
;     ; 6 |     .val      |
;     ; 5 |_______________|
;     ; 4 |_______?_______| RESERVED
;     ; 3 |_______?_______|    .
;     ; 2 |_______?_______|    .
;     ; 1 |_______?_______| RESERVED
;     ;   |       ~       | additional ephemeral  stack usage for subcalls

;     .result  = 7
;     .val     = 6

;     .init:
;     __prologue

;     .do_sqrt:
;     loadw hl, BP
;     addw hl, #{.result}
;     load a, (hl)
;     push a ; result placeholder
    
;     subw hl, #0x01
;     load a, (hl)
;     push a ;val msb
;     subw hl, #0x01
;     load a, (hl)
;     push a ;val lsb

;     ; lut address
;     pushw #lut_sqrt

;     call _rev_lut

;     popw hl
;     popw hl
;     pop a

;     __store_local a, .result

;     .done:
;     __epilogue

#ruledef
{
    call sqrt => asm
    {
        pushw #lut_sqrt
        call _rev_lut
        popw hl
    }
    call ln => asm
    {
        pushw #lut_ln
        call _rev_lut
        popw hl
    }
}




lut_sqrt: #d inchexstr("../../lib_dev/Math/rev_lookup_sqrt.dat")
lut_ln: #d inchexstr("../../lib_dev/Math/rev_lookup_ln.dat")

; ###
; math_rev_lut.asm end
; ###