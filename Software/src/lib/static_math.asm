; ###
; static_math.asm begin
; ###

#once

#bank ram
static_x_32: ; input x
    #res 4
static_y_32: ; input y
    #res 4
static_z_32: ; input z
    #res 4
static_cf: ; carry flag
    #res 1

#bank rom

static_abs8: ; x=abs(x)
    ; ******
    ; static_abs8 returns the abosslute value of an 8 bit input
    ; WARNGING: this funciton contamintes the x input var
    ; ******

    .check_sign:
        load a, static_x_32+3
        and a, #0x80
        jmz .done
    .negate:
        load a, static_x_32+3
        xor a, #0xFF ; flip bits
        add a, #0x01 ; add one
        store a, static_x_32+3
    .done:
        ret


static_negate32: ; x=-x
    ; ******
    ; static_negate32 takes a 32 bit params and returns the twos compliment oppsite.
    ; returns 32bit value of -x in static_z_32. leaves carry flag in flags register
    ; WARNGING: this funciton contamintes the x input var
    ; ******

    ; invert LSB to MSB
    .byte3:
        ; byte 3 invert and add one
        load a, static_x_32+3
        xor a, #0xFF
        add a, #0x01
        store a, static_x_32+3
        ; save cf to b reg
        load b, #0x00
        jnc .byte2
        load b, #0x01
    .byte2:
        ; byte 2 invert and add one
        load a, static_x_32+2
        xor a, #0xFF
        add a, b
        store a, static_x_32+2
        ; save cf to b reg
        load b, #0x00
        jnc .byte1
        load b, #0x01
    .byte1:
        ; byte 1 invert and add one
        load a, static_x_32+1
        xor a, #0xFF
        add a, b
        store a, static_x_32+1
        ; save cf to b reg
        load b, #0x00
        jnc .byte0
        load b, #0x01
    .byte0:
        ; byte 0 invert and add one
        load a, static_x_32
        xor a, #0xFF
        add a, b
        store a, static_x_32
        ; leave cf in flags
    .done:
        ret



static_add32: ; z=x+y
    ; ******
    ; static_add32 takes two 32 bit params and adds them.
    ; returns 32bit summation in static_z_32. carry flag is left in static_cf.
    ; WARNGING: this funciton contamintes the x input var
    ; ******
    .add_byte1:
        load b, static_x_32+3
        load a, static_y_32+3
        add a, b
        store a, static_z_32+3
        jmc .handle_first_carry1
        jmp .add_byte2
    .handle_first_carry1:
        load a, static_x_32+2
        add a, #0x01
        store a, static_x_32+2
        jmc .handle_first_carry2
        jmp .add_byte2
    .handle_first_carry2:
        load a, static_x_32+1
        add a, #0x01
        store a, static_x_32+1
        jmc .handle_first_carry3
        jmp .add_byte2
    .handle_first_carry3:
        load a, static_x_32
        add a, #0x01
        store a, static_x_32
        jmc .handle_first_carry4
        jmp .add_byte2
    .handle_first_carry4:
        store #0x01, static_cf


    .add_byte2:
        load b, static_x_32+2
        load a, static_y_32+2
        add a, b
        store a, static_z_32+2
        jmc .handle_second_carry2
        jmp .add_byte3
    .handle_second_carry2:
        load a, static_x_32+1
        add a, #0x01
        store a, static_x_32+1
        jmc .handle_second_carry3
        jmp .add_byte3
    .handle_second_carry3:
        load a, static_x_32
        add a, #0x01
        store a, static_x_32
        jmc .handle_second_carry4
        jmp .add_byte3
    .handle_second_carry4:
        store #0x01, static_cf


    .add_byte3:
        load b, static_x_32+1
        load a, static_y_32+1
        add a, b
        store a, static_z_32+1
        jmc .handle_third_carry3
        jmp .add_byte4
    .handle_third_carry3:
        load a, static_x_32
        add a, #0x01
        store a, static_x_32
        jmc .handle_third_carry4
        jmp .add_byte4
    .handle_third_carry4:
        store #0x01, static_cf


    .add_byte4:
        load b, static_x_32
        load a, static_y_32
        add a, b
        store a, static_z_32
        jmc .handle_fourth_carry4
        jmp .done
    .handle_fourth_carry4:
        store #0x01, static_cf

    .done:
        ret

; ###
; static_math.asm end
; ###