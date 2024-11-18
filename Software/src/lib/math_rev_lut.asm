; ###
; math_rev_lut.asm begin
; ###
#once

#bank ram
rev_lut_ptr: #res 2

#bank rom
;;
; @function
; @brief reverse lookup table
; @section description
; reverse lookup table
; calls static_add32
; TODO: add return pointer
; TODO: broken. off by one error changed when stack inverted!
; @param param8_result return
; @param param16_val input
; @return void
;
;     _______________________
; -9 |____.param8_result_____|
; -8 |     .param16_val      |
; -7 |_______________________|
; -6 |   .param16_lut_addr   |
; -5 |_______________________|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
;  0 |           ~           | additional ephemeral  stack usage for subcalls

;;
 _rev_lut:
    .param8_result    =  -9
    .param16_val      =  -8
    .param16_lut_addr =  -6

    .init:
        __prologue

    .init_ptr:
        load a, (BP), .param16_lut_addr
        store a, rev_lut_ptr
        load a, (BP), .param16_lut_addr+1
        store a, rev_lut_ptr+1

        ; save val value, and sign extend
        storew #0x0000, static_y_32
        load a, (BP), .param16_val
        store a, static_y_32+2
        load a, (BP), .param16_val
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
        __store_local a, .param8_result

        loadw hl, rev_lut_ptr
        addw hl, #0x03
        storew hl, rev_lut_ptr

        jmp .do_compare

    .done:
        __epilogue
        ret

; ###
; math_rev_lut.asm end
; ###