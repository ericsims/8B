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
;  0 |           ~           | additional ephemeral  stack usage for subcalls

;;
cos:
    .param16_res = -7
    .param8_val = -5

    .init:
        __prologue

    .check_quadrant:
        load a, (BP), .param8_val
        test a
        jnn .q_12
    .q_34:
        sub a, #192
        jmn .quadrant_3
        jmp .quadrant_4
    .q_12:
        load a, (BP), .param8_val
        sub a, #64
        jmn .quadrant_1
        sub a, #64
        jmn .quadrant_2

    
    .quadrant_4:
        ; compute position in lut based on input value
        load a, #0
        load b, (BP), .param8_val
        sub a, b
        loadw hl, #.lut
        addw hl, a
        addw hl, a ; lut is 16 bits per result, so add offset twice

        ; store result
        loadw hl, (hl)
        storew hl, (BP), .param16_res

        jmp .done

    .quadrant_3:
        ; compute position in lut based on input value
        load a, (BP), .param8_val
        sub a, #128
        loadw hl, #.lut
        addw hl, a
        addw hl, a ; lut is 16 bits per result, so add offset twice

        ; store result
        loadw hl, (hl)
        storew hl, (BP), .param16_res

        ; two's compliment of results
        load a, (BP), .param16_res
        xor a, #0xFF
        store a, (BP), .param16_res
        load a, (BP), .param16_res+1
        xor a, #0xFF
        store a, (BP), .param16_res+1
        loadw hl, (BP), .param16_res
        addw hl, #1
        storew hl, (BP), .param16_res
        
        jmp .done

    .quadrant_2:
        ; compute position in lut based on input value
        load a, #128
        load b, (BP), .param8_val
        sub a, b
        loadw hl, #.lut
        addw hl, a
        addw hl, a ; lut is 16 bits per result, so add offset twice

        ; store result
        loadw hl, (hl)
        storew hl, (BP), .param16_res

        ; two's compliment of results
        load a, (BP), .param16_res
        xor a, #0xFF
        store a, (BP), .param16_res
        load a, (BP), .param16_res+1
        xor a, #0xFF
        store a, (BP), .param16_res+1
        loadw hl, (BP), .param16_res
        addw hl, #1
        storew hl, (BP), .param16_res

        jmp .done

    .quadrant_1:
        ; compute position in lut based on input value
        load a, (BP), .param8_val
        loadw hl, #.lut
        addw hl, a
        addw hl, a ; lut is 16 bits per result, so add offset twice

        ; store result
        loadw hl, (hl)
        storew hl, (BP), .param16_res

    .done:
        __epilogue
        ret

    .lut: #d inchexstr("_cos_lut.dat")