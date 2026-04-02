#once

#bank rom
;;
; @function
; @brief cos lookup using binary radians
; @section description
; @param param16_res return
; @param param8_val input
; @return void
;
;     _______________________
; -7 |     .param16_res      |
; -6 |_______________________|
; -5 |______.param8_val______|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED

;;
cos:
    .param16_res = -7
    .param8_val = -5

    .init:
        __prologue

    .check_quadrant:
        load a, (BP), .param8_val
        push a
        test a
        jnn .q_12
    .q_34:
        sub a, #0xC0
        jmn .quadrant_3
        jmp .quadrant_4
    .q_12:
        sub a, #0x40
        jmn .quadrant_1
        sub a, #0x40
        jmn .quadrant_2

    
    .quadrant_4:
        ; q2 is reverse of q1
        pop b
        load a, #0
        sub a, b

        call ._load_result
        jmp .done

    .quadrant_3:
        ; q3 is negative version of q1
        pop a
        sub a, #0x80

        call ._load_result
        call ._twos_compliment
        jmp .done

    .quadrant_2:
        ; q2 is reverse and negative version of q1
        pop b
        load a, #0x80
        sub a, b

        call ._load_result
        call ._twos_compliment
        jmp .done

    .quadrant_1:
        pop a
        call ._load_result

    .done:
        __epilogue
        ret

    ; helper functions
    ._load_result:
        loadw hl, #.lut
        lshift a ; multiply offset value by two, since output is 16 bits
        addw hl, a

        ; load result from lut
        loadw hl, (hl)

        ; store result
        storew hl, (BP), .param16_res
        ret

    ._twos_compliment:
        ; two's compliment of result
        load a, (BP), .param16_res
        xor a, #0xFF
        store a, (BP), .param16_res
        load a, (BP), .param16_res+1
        xor a, #0xFF
        store a, (BP), .param16_res+1
        loadw hl, (BP), .param16_res
        addw hl, #1
        storew hl, (BP), .param16_res
        ret

    .lut: #d inchexstr("_cos_lut.dat")



#bank rom
;
; @function
; @brief cos lookup using binary radians
; @section description
; @param param16_res return
; @param param8_val input
; @return void
;
;     _______________________
; -7 |     .param16_res      |
; -6 |_______________________|
; -5 |______.param8_val______|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED

;;
sin:
    .param16_res = -7
    .param8_val = -5

    .init:
        __prologue

        alloc 2
        load a, (BP), .param8_val
        sub a, #0x40 ; phase shift sin by pi/2 to get cos
        push a
    
    .subcall:
        call cos
        pop a
        popw hl
        storew hl, (BP), .param16_res
    
    .done:
        __epilogue
        ret