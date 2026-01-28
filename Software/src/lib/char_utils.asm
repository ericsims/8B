; ###
; char_utils.asm begin
; ###

#once

#bank rom
;;
; @function
; @brief print character to UART
; @section description
; static function
;;
static_uart_putc:
    ; TODO: check if UART is ready
    load a, .char
    store a, UART
    ret

#bank ram
    .char: #res 1 ; char to print to uart


#bank rom
;;
; @function
; @brief print newline '\n' character to UART
; @section description
; static function
;;
static_uart_print_newline:
    store #"\n", static_uart_putc.char
    call static_uart_putc
    ret


#bank rom
;;
; @function
; @brief print hex prefix '0x' to UART
; @section description
; static function
;;
static_uart_print_hex_prefix:
    store #"0", static_uart_putc.char
    call static_uart_putc
    store #"x", static_uart_putc.char
    call static_uart_putc
    ret


#bank rom
;;
; @function
; @brief print null terminated string to UART
; @section description
; static function
; TODO: this function doesn't check if the UART is ready to send
;;
static_uart_print:
    ; load current char
    loadw hl, .data_pointer
.loop:
    load a, (hl)
    ; check if char is 0
    add a, #0x00
    jmz .done
    
    ; put c
    store a, static_uart_putc.char
    call static_uart_putc
    
    addw hl, #0x01
    jmp .loop
    
    .done:
    ret
    
#bank ram
    .data_pointer: #res 2 ; pointer to begining of string. MSB, LSB


#bank rom
;;
; @function
; @brief converts one nibble of number to string
; @section description
; takes a 1 byte params and converts it to hex char
;     _______________________
; -5 |_______.param8_c_______|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
; @param .param8_c input number
; @return out_char
;;
itoa_hex_nibble:
    .param8_c = -5
    .init:
    __prologue
    ; mask nibble
    load b, (BP), .param8_c
    and b, #0x0F
    ; if .param8_c is >= than 10, handle .hex, otherwise handle DEC
    load a, b
    sub a, #0x0A
    jnc .hex

    .dec:
    add b, #0x30 ; add '0'
    jmp .done
    .hex:
    add b, #(0x41-0x0A) ; add 'A'

    .done:
    ; result in b register
    __epilogue
    ret


#bank rom
;;
; @function
; @brief prints number to UART in hex format
; @section description
; takes a 1 byte unsigned integer and prints it to UART in hex format
;    _______________________
; -5 |_______.param8_c_______|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
; @param .param8_c input number
;;
uart_print_itoa_hex:
    .param8_c = -5
    .init:
    __prologue
    .msn:
    ; handle most signifcant nibble
    load a, (BP), .param8_c
    ; rshift x4 just keep upper 4 bits
    rshift a
    rshift a
    rshift a
    rshift a
    ; send nibble to itoa_hex_nibble function
    push a
    call itoa_hex_nibble
    ; send ascii char to static_uart_putc function
    pop a
    store b, static_uart_putc.char
    call static_uart_putc
    .lsn:
    ; handle least significan nibble
    load a, (BP), .param8_c
    ; send byte to itoa_hex_nibble function
    ; this function already masks for lower 4 bits
    push a
    call itoa_hex_nibble
    ; send ascii char to static_uart_putc function
    pop a
    store b, static_uart_putc.char
    call static_uart_putc
    .done:
    __epilogue
    ret

;;
; @function
; @brief prints memory to uart
; @section description
; takes a address pointer and length
; @param .param16_ptr data address
; @param .param8_len length
;    _______________________
; -7 |      .param16_ptr     |
; -6 |_______________________|
; -5 |______.param8_len______|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
;  0 |_______.local8_n_______|
; @param .param8_c input number
;;
uart_dump_mem:
    .param16_ptr = -7
    .param8_len = -5
    .local8_n = 0
    .init:
        __prologue
        push #0x00

    .loop:
        ; load address pointer and offset
        loadw hl, (BP), .param16_ptr
        load a, (BP), .local8_n
        addw hl, a

        ; load mem value into b
        load b, (hl)
        push b
        call uart_print_itoa_hex
        pop b
        store #" ", static_uart_putc.char
        call static_uart_putc

        load a, (BP), .param8_len
        load b, (BP), .local8_n
        sub a, b
        jmz .done
        add b, #0x01
        store b, (BP), .local8_n
        jmp .loop

    .done:
    call static_uart_print_newline
    pop a
    __epilogue
    ret


#bank rom
;;
; @function
; @brief returns 1 if character is whitespace
; @section description
; takes a 1 byte ASCII character
;     _______________________
; -5 |_____.param8_char______|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
; @param .param8_char input character
;;
isspace:
    .param8_char = -5
    .init:
    __prologue
    load a, (BP), .param8_char

    ; test Space
    load b, a
    sub b, #0x20
    jmz .is_whitespace

    ; test Horizontal Tab
    load b, a
    sub b, #0x09
    jmz .is_whitespace

    ; test Line Feed
    load b, a
    sub b, #0x0A
    jmz .is_whitespace
    
    ; test Vertical Tab
    load b, a
    sub b, #0x0B
    jmz .is_whitespace
    
    ; test 	Form Feed
    load b, a
    sub b, #0x0C
    jmz .is_whitespace
    
    ; test Carriage Return
    load b, a
    sub b, #0x0D
    jmz .is_whitespace

    ; char is not whitespace
    load b, #0
    jmp .done

    .is_whitespace:
    load b, #1
    jmp .done

    .done:
    __epilogue
    ret



#bank rom
;;
; @function
; @brief returns 1 if character is a numeral digit
; @section description
; takes a 1 byte ASCII character
;     _______________________
; -5 |_____.param8_char______|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
; @param .param8_char input character
;;
isdigit:
    .param8_char = -5
    .init:
    __prologue
    load b, #0
    load a, (BP), .param8_char

    ; digits are 0x30 to 0x39 in ASCII
    sub a, #0x30
    jmn .done ; not a digit if < 0x30
    sub a, #0x0A
    jnn .done ; not a digit if > 0x39

    load b, #1
    .done:
    __epilogue
    ret


#bank rom
;;
; @function
; @brief returns 1 if character is a numeral digit '0'-'9', '.', '-', '+', 'e', and 'E'
; @section description
; takes a 1 byte ASCII character
;     _______________________
; -5 |_____.param8_char______|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
; @param .param8_char input character
;;
isjsondigit:
    .param8_char = -5
    .init:
    __prologue
    load a, (BP), .param8_char
    load b, a

    ; digits are 0x30 to 0x39 in ASCII
    sub b, #0x30
    jmn .continue_test ; not a digit if < 0x30
    sub b, #0x0A
    jnn .continue_test ; not a digit if > 0x39

    jmp .is_a_digit

    .continue_test:
    load b, a
    sub b, #"."
    jmz .is_a_digit

    load b, a
    sub b, #"-"
    jmz .is_a_digit

    load b, a
    sub b, #"+"
    jmz .is_a_digit

    load b, a
    sub b, #"e"
    jmz .is_a_digit

    load b, a
    sub b, #"E"
    jmz .is_a_digit

    .is_not_a_digit:
    load b, #0
    __epilogue
    ret
    .is_a_digit:
    load b, #1
    __epilogue
    ret


#bank rom
;;
; @function
; @brief returns 0 if strings are the same
; @section description
; takes a 2 string pointers and compares the contents
;     _______________________
; -8 |   .param16_str1_in    |
; -7 |_______________________|
; -6 |   .param16_str2_in    |
; -5 |_______________________|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
;  0 |     .param16_str1     |
;  1 |_______________________|
;  2 |     .param16_str2     |
;  3 |_______________________| 
; @param .param8_char input character
;;
strcmp:
    .param16_str1_in = -8
    .param16_str2_in = -6
    .param16_str1 = 0
    .param16_str2 = 2
    .init:
        __prologue
        ; copy inputs to local variables
        loadw hl, (BP), .param16_str1_in
        pushw hl
        loadw hl, (BP), .param16_str2_in
        pushw hl

    .test:
        ; load character from str1
        loadw hl, (BP), .param16_str1
        load a, (hl)
        ; increment and store pointer
        addw hl, #1
        storew hl, (BP), .param16_str1

        ; load character from str2
        loadw hl, (BP), .param16_str2
        load b, (hl)
        ; increment and store pointer
        addw hl, #1
        storew hl, (BP), .param16_str2

        ; test for mismatch
        sub a, b
        jnz .mismatch
        
        ; test for end of string.
        sub b, #0
        jmz .done

        ; loop
        jmp .test


    .mismatch:
        load b, #1
        ; fall through to done

    .done:
        dealloc 4
        __epilogue
        ret