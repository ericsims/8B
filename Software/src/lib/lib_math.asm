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
;  7 |______.local8_z1a______|
;  9 |______.local8_z1b______|
;;
umult8:
    .param16_res = -8
    .param8_x = -6
    .param8_y = -5
    .local8_x0 = 0
    .local8_x1 = 1
    .local8_y0 = 2
    .local8_y1 = 3
    .local8_z0 = 4
    .local8_z1 = 5
    .local8_z2 = 6
    .local8_z1a = 7
    .local8_z1b = 8

    .init:
        __prologue
        alloc 9

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
    .z1a:
        ; z1a = x1*y0
        load a, (BP), .local8_x1
        push a
        load a, (BP), .local8_y0
        push a
        call umult4
        dealloc 2
        store b, (BP), .local8_z1a
    .z1b:
        ; z1b = x0*y1
        load a, (BP), .local8_x0
        push a
        load a, (BP), .local8_y1
        push a
        call umult4
        dealloc 2
        store b, (BP), .local8_z1b
    .z1:
        ; z1 = z1a + z1b = x1*y0 + x0*y1
        load a, (BP), .local8_z1a
        load b, (BP), .local8_z1b
        add a, b ; z2 + z0
        jnc ..skip_z1_overflow
        load b, (BP), .local8_z2
        add b, #(1<<4) ; carry out z1 into z2
        store b, (BP), .local8_z2
        ..skip_z1_overflow:
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
        dealloc 9
        __epilogue
        ret


;;
; @function
; @brief unsigned multiply of 8 bit signed numbers using karatsuba
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
;  0 |______.local8_neg______|
;;
mult8:
    .param16_res = -8
    .param8_x = -6
    .param8_y = -5
    .local8_neg = 0

    .init:
        __prologue
        push #0

        pushw #0 ; res for umult8
    
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
        call umult8
        dealloc 2
        popw hl ; result
        storew hl, (BP), .param16_res
    .check_sign:
        load a, (BP), .local8_neg
        test a
        jmz .done ; result should be postive
    .flip_sign:
        ; invert result
        load a, (BP), .param16_res
        xor a, #0xFF
        store a, (BP), .param16_res
        load a, (BP), .param16_res+1
        xor a, #0xFF
        store a, (BP), .param16_res+1
        
        loadw hl, (BP), .param16_res
        addw hl, #1 ; and add 1
        storew hl, (BP), .param16_res

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
;-12 |     .param32_res      |
;-11 |                       |
;-10 |                       |
; -9 |_______________________|
; -8 |      .param16_x       |
; -7 |_______________________|
; -6 |      .param16_y       |
; -5 |_______________________|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
;  0 |      .local16_z0      |
;  1 |_______________________|
;  2 |      .local16_z1      |
;  3 |_______________________|
;  4 |      .local16_z2      |
;  5 |_______________________|
;  6 |     .local16_z1a      |
;  7 |_______________________|
;  8 |     .local16_z1b      |
;  9 |_______________________|

;;
umult16:
    .param32_res = -12
    .param16_x = -8
        .param8_x1 = -8
        .param8_x0 = -7
    .param16_y = -6
        .param8_y1 = -6
        .param8_y0 = -5
    .local16_z0 = 0
    .local16_z1 = 2
    .local16_z2 = 4
    .local16_z1a = 6
    .local16_z1b = 8

    .init:
        __prologue
        alloc 10
    
    ; compute the partials
    .z0:
        ; z0 = x0 * y0
        pushw #0 ; result
        load a, (BP), .param8_x0
        push a
        load a, (BP), .param8_y0
        push a
        call umult8
        dealloc 2
        popw hl
        storew hl, (BP), .local16_z0
    .z2:
        ; z2 = x1 * y1
        pushw #0 ; result
        load a, (BP), .param8_x1
        push a
        load a, (BP), .param8_y1
        push a
        call umult8
        dealloc 2
        popw hl
        storew hl, (BP), .local16_z2
    .z1a:
        ; z1a = x1*y0
        alloc 2 ; res
        load a, (BP), .param8_x1
        push a ; x
        load a, (BP), .param8_y0
        push a ; y
        call umult8
        dealloc 2
        popw hl ; res
        storew hl, (BP), .local16_z1a
    .z1b:
        ; z1a = x0*yq
        alloc 2 ; res
        load a, (BP), .param8_x0
        push a ; x
        load a, (BP), .param8_y1
        push a ; y
        call umult8
        dealloc 2
        popw hl ; res
        storew hl, (BP), .local16_z1b
    .z1:
        ; z1 = z1a + z1b = x1*y0 + x0*y1
        load a, (BP), .local16_z1a
        load b, (BP), .local16_z1b
        add a, b ; z2 + z0 (MSB)
        jnc ..skip_z1_overflow1
        load b, (BP), .local16_z2
        add b, #1 ; carry out z1 into z2
        store b, (BP), .local16_z2
        ..skip_z1_overflow1:
        push a
        load a, (BP), .local16_z1a+1
        push a
        popw hl
        load b, (BP), .local16_z1b+1
        addw hl, b ; z2 + z0 (LSB)
        jnc ..skip_z1_overflow2
        load b, (BP), .local16_z2
        add b, #1 ; carry out z1 into z2
        store b, (BP), .local16_z2
        ..skip_z1_overflow2:
        storew hl, (BP), .local16_z1
    .sum:
        ; xy = z2 << 16 + z1 << 8 + z0
        load a, (BP), .local16_z0+1
        store a, (BP), .param32_res+3 ; store z0 lsb
        
        loadw hl, (BP), .local16_z1
        load a, (BP), .local16_z0
        addw hl, a ; z1 + z0 (msb)
        storew hl, (BP), .param32_res+1 ; store z1 << 8 +z0

        loadw hl, (BP), .local16_z2
        load a, (BP), .param32_res+1
        addw hl, a ; z2 + z1 (msb)
        storew hl, (BP), .param32_res ; store z2 << 16 + z1 <<8 + z0    
    .done:
        dealloc 10
        __epilogue
        ret
    ._incr_z2_msb:
        load b, (BP), .local16_z2
        add b, #1
        store b, (BP), .local16_z2
        ret
