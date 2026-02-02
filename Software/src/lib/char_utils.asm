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
    move .char, UART
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
    ; TODO: check if UART is ready
    store #"\n", UART
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
    test a
    jmz .done
    
    ; put c
    ; TODO: check if UART is ready
    store a, UART
    
    addw hl, #0x01
    jmp .loop
    
    .done:
    ret
    
#bank ram
    .data_pointer: #res 2 ; pointer to begining of string. MSB, LSB

#bank rom
;;
; @function
; @brief print null terminated string to UART
; @section description
; static function
; TODO: this function doesn't check if the UART is ready to send
;;
static_uart_print_len:
    ; load current char
    loadw hl, static_uart_print.data_pointer
    load b, .data_len
.loop:
    load a, (hl)
    ; check if char is 0
    test a
    jmz .done
    test b
    jmz .done
    sub b, #0x01
    
    ; put c
    ; TODO: check if UART is ready
    store a, UART
    
    addw hl, #0x01
    jmp .loop
    
    .done:
    ret
    
#bank ram
    .data_len: #res 1 ; max length

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
    sub b, #0x0A
    jnc .hex

    .dec:
    add b, #(0x30+0x0A) ; add '0'
    ; result in b register
    __epilogue
    ret

    .hex:
    add b, #(0x41-0x0A+0x0A) ; add 'A'
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
; @param .param8_c input number
;;
uart_dump_mem:
    .param16_ptr = -7
    .param8_len = -5
    .local8_n = 0
    .init:
        __prologue

    .loop_row:
        ; check if loop has reached end of length
        load a, (BP), .param8_len
        test a
        jmz .done ; len=0
        sub a, #1
        store a, (BP), .param8_len

        ; print the label
        load b, (BP), .param16_ptr
        push b
        call uart_print_itoa_hex
        pop b
        load b, (BP), .param16_ptr+1
        push b
        call uart_print_itoa_hex
        pop b

        store #":", static_uart_putc.char
        call static_uart_putc
        store #" ", static_uart_putc.char
        call static_uart_putc

        ; print out contents in hex
        push #0x10
        loadw hl, (BP), .param16_ptr
        ..loop_col:
            ; print mem contents
            load b, (hl)
            pushw hl
            push b
            call uart_print_itoa_hex
            pop b
            popw hl

            store #" ", static_uart_putc.char
            call static_uart_putc

            addw hl, #1
            pop a
            sub a, #1
            jmz ..end_of_col
            push a
            jmp ..loop_col
        ..end_of_col:

        store #" ", static_uart_putc.char
        call static_uart_putc

        ; print out contents in ASCII
        push #0x10
        loadw hl, (BP), .param16_ptr
        ..loop_col_ascii:

            ; print mem contents
            load a, (hl)
            pushw hl
            push a
            call isprintable
            pop a
            popw hl
            
            store #".", static_uart_putc.char
            test b ; is this char printable?
            jmz ...skip_char
            store a, static_uart_putc.char
            ...skip_char:

            call static_uart_putc

            addw hl, #1
            pop a
            sub a, #1
            jmz ..end_of_col_ascii
            push a
            jmp ..loop_col_ascii
        ..end_of_col_ascii:
        storew hl, (BP), .param16_ptr

        call static_uart_print_newline

        jmp .loop_row

    .done:
    call static_uart_print_newline
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

    ; 0x09-0x0D are all white space chars
    load b, a
    sub a, #0x09
    jmn .is_not_whitespace ; not whitesapce if < 0x09
    sub a, #(0x0D-0x09+1)
    jnn .is_not_whitespace ; not a digit if > 0x0D

    .is_whitespace:
    load b, #1
    __epilogue
    ret

    .is_not_whitespace:
    load b, #0
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

    ; test for both capitol and lower case E
    ; bitmasking to remove bit 7 will convert
    load b, a
    or b, #0x20
    sub b, #"e"
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
        test b
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


#bank rom
;;
; @function
; @brief returns 1 if character is a printable ascii character
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
isprintable:
    .param8_char = -5
    .init:
    __prologue
    load b, #0
    load a, (BP), .param8_char

    ; printable ASCII from 0x20 to 0x7E, inclusive
    sub a, #0x20
    jmn .done ; not printable if < 0x20
    sub a, #(0x7E-0x20)+1
    jnn .done ; not printable if > 0x7E

    load b, #1
    .done:
    __epilogue
    ret