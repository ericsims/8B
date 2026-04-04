#once

;;
; @function
; @brief unsigned multiply of 4 bit number using look up table
; @section description
;
;     _______________________
; -6 |_______.param8_x_______|
; -5 |_______.param8_y_______|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED

;;
#bank rom
umult4:
    .param8_x = -6
    .param8_y = -5

    .init:
        __prologue

    
    .load_result:        
        ; offset = (x << 8) | (y & 0xF)
        load a, (BP), .param8_x
        lshift a
        lshift a
        lshift a
        lshift a

        load b, (BP), .param8_y
        and b, #0xF

        or a, b

        loadw hl, #.lut
        addw hl, a

        ; load result from lut
        load b, (hl)

    .done:
        __epilogue
        ret

    .lut: #d inchexstr("_umult4_lut.dat")


;;
; @function
; @brief signed multiply of 4 bit numbers using look up table
; @section description
;
;     _______________________
; -6 |_______.param8_x_______|
; -5 |_______.param8_y_______|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
;  0 |______.local8_neg______|

;;
#bank rom
mult4:
    .param8_x = -6
    .param8_y = -5
    .local8_neg = 0

    .init:
        __prologue
        push #0
    
    .x_sign:
        ; invert x if negative
        load a, (BP), .param8_x
        test a
        jnn ..positive
        ; x is negative, take two's compliment
        xor a, #0xFF ; invert
        add a, #1 ; and add 1
        store #1, (BP), .local8_neg ; result is negative
        ..positive:
        push a
    .y_sign:
        ; invert y if negative
        load a, (BP), .param8_y
        test a
        jnn ..positive
        ; y is negative, take two's compliment
        xor a, #0xFF ; invert
        add a, #1 ; and add 1
        load b, (BP), .local8_neg
        xor b, #1
        store b, (BP), .local8_neg ; flip sign of result
        ..positive:
        push a
    .multiply:
        call umult4
        dealloc 2
    .check_sign:
        load a, (BP), .local8_neg
        test a
        jmz .done ; result should be postive
    .flip_sign:
        xor b, #0xFF ; invert result
        add b, #1 ; and add 1

    .done:
        dealloc 1
        __epilogue
        ret
;;
; @function
; @brief unsigned multiply of 8 bit numbers using karatsuba
; @section description
;
;     _______________________
; -8 |     .param16_res      |
; -7 |_______________________|
; -6 |_______.param8_x_______|
; -5 |_______.param8_y_______|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
;  0 |_______.local8_x0______|
;  1 |_______.local8_x1______|
;  2 |_______.local8_y0______|
;  3 |_______.local8_y1______|
;  4 |_______.local8_z0______|
;  5 |_______.local8_z1______|
;  6 |_______.local8_z2______|

;;
umult8:
    .param8_x = -6
    .param8_y = -5
    .param16_res = -8
    .local8_x0 = 0
    .local8_x1 = 1
    .local8_y0 = 2
    .local8_y1 = 3
    .local8_z0 = 4
    .local8_z1 = 5
    .local8_z2 = 6

    .init:
        __prologue
        alloc 7

    ; first split the 8 bit input into two 4 bit numbers
    .x0:
        load a, (BP), .param8_x
        and a, #0xF
        store a, (BP), .local8_x0
    .x1:
        load a, (BP), .param8_x
        rshift a
        rshift a
        rshift a
        rshift a
        store a, (BP), .local8_x1
    .y0:
        load a, (BP), .param8_y
        and a, #0xF
        store a, (BP), .local8_y0
    .y1:
        load a, (BP), .param8_y
        rshift a
        rshift a
        rshift a
        rshift a
        store a, (BP), .local8_y1
    
    ; compute the partials
    .z0:
        ; z0 = x0 * y0
        load a, (BP), .local8_x0
        push a
        load a, (BP), .local8_y0
        push a
        call umult4
        dealloc 2
        store b, (BP), .local8_z0
    .z2:
        ; z2 = x1 * y1
        load a, (BP), .local8_x1
        push a
        load a, (BP), .local8_y1
        push a
        call umult4
        dealloc 2
        store b, (BP), .local8_z2
    .z4:
        ; z4 = (x1 - x0)*(y1 - y0)
        load a, (BP), .local8_x1
        load b, (BP), .local8_x0
        sub a, b ; x1 - x0
        push a
        load a, (BP), .local8_y1
        load b, (BP), .local8_y0
        sub a, b ; y1 - y0
        push a
        call mult4
        dealloc 2
    .z1:
        ; z1 = z2 + z0 - z4
        load a, (BP), .local8_z0
        sub a, b ; z0 - z4
        load b, (BP), .local8_z2
        add a, b ; + z2
        ; handle overflow of 8 bit z1
        jnc ..store
        store a, (BP), .local8_z1
        add b, #(1<<4)
        store b, (BP), .local8_z2
        ..store:
        store a, (BP), .local8_z1
    .sum:
        ; xy = z2 << 8 + z1 << 4 + z0
        ; xy = (z2 + z1 >> 4) << 8 + (z1 << 4 + z0)
        ..upper:
            load a, (BP), .local8_z2
            load b, (BP), .local8_z1
            rshift b
            rshift b
            rshift b
            rshift b
            add a, b
            store a, (BP), .param16_res
            load a, #0
            store a, (BP), .param16_res+1
        ..lower:
            load b, (BP), .local8_z1
            lshift b
            lshift b
            lshift b
            lshift b
            load a, (BP), .local8_z0
            loadw hl, (BP), .param16_res
            addw hl, a
            addw hl, b
        ..save:
            storew hl, (BP), .param16_res    
    
    .done:
        dealloc 7
        __epilogue
        ret