; ###
; char_utils.asm begin
; ###

#once


;;
; @function
; @brief static memcpy function
; @section description
; static memcpy copies from source to destination
;;
#bank rom
static_memcpy:
    .copy:
        loadw hl, .len
        subw hl, #1
        jmc .done
        storew hl, .len

        move (.src_ptr), (.dst_ptr)
        
        loadw hl, .src_ptr
        addw hl, #1
        storew hl, .src_ptr
        loadw hl, .dst_ptr
        addw hl, #1
        storew hl, .dst_ptr
        jmp .copy
    .done:
        ret

#bank ram
    .src_ptr: #res 2
    .dst_ptr: #res 2
    .len: #res 2

;;
; @function
; @brief print character to UART
; @section description
; static function
;;
#bank rom
static_uart_putc:
    ; TODO: check if UART is ready
    move .char, UART
    ret

#bank ram
    .char: #res 1 ; char to print to uart

;;
; @function
; @brief returns character in UART FIFO. returns 0 if no characters available.
; @section description
;;
#bank rom
uart_getc:
    load b, UART ; reading UART returns character, otherwise returns zero
    ret


;;
; @function
; @brief print newline '\n' character to UART
; @section description
; static function
;;
#bank rom
static_uart_print_newline:
    ; TODO: check if UART is ready
    store #"\n", UART
    ret


;;
; @function
; @brief print hex prefix '0x' to UART
; @section description
; static function
;;
#bank rom
static_uart_print_hex_prefix:
    store #"0", static_uart_putc.char
    call static_uart_putc
    store #"x", static_uart_putc.char
    call static_uart_putc
    ret


;;
; @function
; @brief print null terminated string to UART
; @section description
; static function
; TODO: this function doesn't check if the UART is ready to send
;;
#bank rom
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



;;
; @function
; @brief print null terminated string to UART
; @section description
; static function
; TODO: this function doesn't check if the UART is ready to send
;;
#bank rom
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
#bank rom
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


;;
; @function
; @brief converts hex character to a single nibble number. returns -1 if an error
; @section description
;
;     _______________________
; -5 |_______.param8_c_______|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
; @param .param8_c input char
; @return out_num, -1 on error
;;
#bank rom
atoi_hex_nibble:
    .param8_char = -5
    .init:
    __prologue
    load b, #-1
    load a, (BP), .param8_char

    ; digits are 0x30 to 0x39 in ASCII
    sub a, #0x30
    jmn .check_hex ; not a digit if < 0x30
    sub a, #0x39-0x30+1
    jnn .check_hex ; not a digit if > 0x39
    ; this is a decimal digit
    add a, #0x39-0x30+1
    load b, a
    __epilogue
    ret
    
    .check_hex:
    ; 'A'-'F' are 0x41 to 0x46 in ASCII
    load a, (BP), .param8_char
    sub a, #0x41
    jmn .done ; not a hex digit if < 0x41
    sub a, #0x46-0x41+1
    jnn .done ; not a hex digit if > 0x46
    add a, #0x46-0x41+1+0x0A
    
    load b, a
    .done:
    __epilogue
    ret

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
#bank rom
uart_print_itoa_hex:
    .param8_c = -5
    .init:
        __prologue
    .convert:
        load a, (BP), .param8_c
        call .__msn
        load a, (BP), .param8_c
        call .__lsn
    .done:
        __epilogue
        ret
    ; helper functions for each nibble
    .__msn:
        ; most signficant nibble
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
        ret
    .__lsn:
        ; leas significant nibble
        ; send byte to itoa_hex_nibble function
        ; this function already masks for lower 4 bits
        push a
        call itoa_hex_nibble
        ; send ascii char to static_uart_putc function
        pop a
        store b, static_uart_putc.char
        call static_uart_putc
        ret

;;
; @function
; @brief prints number to UART in hex format
; @section description
; takes a 2 byte unsigned integer and prints it to UART in hex format
;     _______________________
; -6 |       .param16_c      |
; -5 |_______________________|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
; @param .param16_c input number
;;
#bank rom
uart_print_itoa_hex16:
    .param8_c = -6
    .init:
        __prologue

    load a, (BP), .param8_c
    call uart_print_itoa_hex.__msn
    load a, (BP), .param8_c
    call uart_print_itoa_hex.__lsn
    load a, (BP), .param8_c+1
    call uart_print_itoa_hex.__msn
    load a, (BP), .param8_c+1
    call uart_print_itoa_hex.__lsn

    .done:
        __epilogue
        ret
    

;;
; @function
; @brief prints number to UART in hex format
; @section description
; takes a 3 byte unsigned integer and prints it to UART in hex format
;     _______________________
; -7 |       .param16_c      |
; -6 |                       |
; -5 |_______________________|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
; @param .param16_c input number
;;
#bank rom
uart_print_itoa_hex24:
    .param8_c = -7
    .init:
        __prologue

    load a, (BP), .param8_c
    call uart_print_itoa_hex.__msn
    load a, (BP), .param8_c
    call uart_print_itoa_hex.__lsn
    load a, (BP), .param8_c+1
    call uart_print_itoa_hex.__msn
    load a, (BP), .param8_c+1
    call uart_print_itoa_hex.__lsn
    load a, (BP), .param8_c+2
    call uart_print_itoa_hex.__msn
    load a, (BP), .param8_c+2
    call uart_print_itoa_hex.__lsn

    .done:
        __epilogue
        ret

;;
; @function
; @brief prints number to UART in hex format
; @section description
; takes a 4 byte unsigned integer and prints it to UART in hex format
;     _______________________
; -8 |       .param16_c      |
; -7 |                       |
; -6 |                       |
; -5 |_______________________|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
; @param .param16_c input number
;;
#bank rom
uart_print_itoa_hex32:
    .param8_c = -8
    .init:
        __prologue

    load a, (BP), .param8_c
    call uart_print_itoa_hex.__msn
    load a, (BP), .param8_c
    call uart_print_itoa_hex.__lsn

    load a, (BP), .param8_c+1
    call uart_print_itoa_hex.__msn
    load a, (BP), .param8_c+1
    call uart_print_itoa_hex.__lsn
    
    load a, (BP), .param8_c+2
    call uart_print_itoa_hex.__msn
    load a, (BP), .param8_c+2
    call uart_print_itoa_hex.__lsn

    load a, (BP), .param8_c+3
    call uart_print_itoa_hex.__msn
    load a, (BP), .param8_c+3
    call uart_print_itoa_hex.__lsn

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
#bank rom
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
#bank rom
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
#bank rom
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

    

;;
; @function
; @brief returns 1 if character is a numeral hex digit '0'-'9','A'-'F'
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
#bank rom
ishexdigit:
    .param8_char = -5
    .init:
    __prologue
    load b, #0
    load a, (BP), .param8_char

    ; digits are 0x30 to 0x39 in ASCII
    sub a, #0x30
    jmn .check_hex ; not a digit if < 0x30
    sub a, #0x39-0x30+1
    jnn .check_hex ; not a digit if > 0x39
    ; this is a decimal digit
    load b, #1
    __epilogue
    ret
    
    .check_hex:
    ; 'A'-'F' are 0x41 to 0x46 in ASCII
    load a, (BP), .param8_char
    sub a, #0x41
    jmn .done ; not a hex digit if < 0x41
    sub a, #0x46-0x41+1
    jnn .done ; not a hex digit if > 0x46
    
    load b, #1
    .done:
    __epilogue
    ret


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
#bank rom
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


;;
; @function
; @brief returns 0 if strings are the same
; @section description
; takes a 2 string pointers and compares the contents
;     _______________________5
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
#bank rom
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
#bank rom
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



;;
; @function
; @brief converts string to integer
; @section description
; takes a pointer to a null terminated string, and returns a signed 32bit number to the result pointer
; return is number of bits of return type, negative for error 
;     _______________________
; -8 |  .param16_string_ptr  |
; -7 |_______________________|
; -6 |  .param16_result_ptr  |
; -5 |_______________________|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
;  0 |___.local8_bits_count__|
;  1 |____.local8_str_len____|
; @param .param16_string_ptr input string pointer
; @param .param16_result_ptr pointer to result location
; @return num_bytes number of bits of return type, negative for error 
;;
#bank rom
atoi_hex:
    .param16_string_ptr = -8
    .param16_result_ptr = -6
    .local8_bits_count = 0
    .local8_str_len = 1
    .init:
        __prologue
        push #0
        push #0

    ; TODO: handle "-" or "+"

    loadw hl, (BP), .param16_string_ptr
    load b, #0
    .find_length:
        load a, (hl)
        test a
        jmz .found_end ; null termination
        add b, #1
        addw hl, #1
        jmp .find_length
    .found_end:
        store b, (BP), .local8_str_len
        load a, b
        sub a, #9 ; if length is greater than 8, return error
        jnn .error
        subw hl, #1
        storew hl, (BP), .param16_string_ptr
    .convert:
        ; load b, (BP), .local8_str_len
        ; b reg already contains .local8_str_len
        test b
        jmz .done ; end of str
        loadw hl, (BP), .param16_string_ptr
        load a, (hl)
        push a
        call atoi_hex_nibble
        pop a
        test b
        jmn .error ; b<0, this isn't a digit!
        ; this is a digit
        ; compute desination address
        push b
        load a, #3
        load b, (BP), .local8_bits_count
        rshift b
        rshift b
        rshift b
        jnc ..lower_nibble; if we carried out a bit, then this must be the lower nibble
        sub a, b
        loadw hl, (BP), .param16_result_ptr
        addw hl, a
        ; x |= b<<4
        pop b
        lshift b
        lshift b
        lshift b
        lshift b
        load a, (hl)
        or a, b
        store a, (hl)
        jmp ..continue
        ..lower_nibble:
        sub a, b
        loadw hl, (BP), .param16_result_ptr
        addw hl, a
        pop b
        store b, (hl)
        ..continue:

        ; increment number of bits
        load b, (BP), .local8_bits_count
        add b, #4
        store b, (BP), .local8_bits_count
        
        ; decrement remaining string length
        load b, (BP), .local8_str_len
        sub b, #1
        store b, (BP), .local8_str_len

            
    .next_char:
        loadw hl, (BP), .param16_string_ptr
        subw hl, #1
        storew hl, (BP), .param16_string_ptr
        jmp .convert

    .done:
        load b, (BP), .local8_bits_count
        dealloc 2
        __epilogue
        ret
    
    .error:
        dealloc 2
        load b, #-1
        __epilogue
        ret






;;
; @function
; @brief get length of null terminated string, up to 255 characters
; @section description
;
;     _______________________
; -6 |   .param16_src_ptr    |
; -5 |_______________________|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
; @param .param16_src_ptr source address
; @ return string length, up to 255 characters
;;
#bank rom
strlength:
    .param16_src_ptr = -6
    .init:
        __prologue
    
        loadw hl, (BP), .param16_src_ptr
        load b, #0
    .copy:
        load a, (hl)
        test a
        jmz .done

        add b, #1
        jmc .err_overflow
        addw hl, #1
        jmp .copy
    .done:
        __epilogue
        ret
        
    .err_overflow:
        load b, #0xFF
        jmp .done

;;
; @function
; @brief copy null terminated string
; @section description
;
;     _______________________
; -8 |   .param16_dst_ptr    |
; -7 |_______________________|
; -6 |   .param16_src_ptr    |
; -5 |_______________________|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
; @param .param16_dst_ptr destination address
; @param .param16_src_ptr source address
;;
#bank rom
strcpy:
    .param16_dst_ptr = -8
    .param16_src_ptr = -6
    .init:
        __prologue
    
    .copy:
        ; load char from string
        loadw hl, (BP), .param16_src_ptr
        load a, (hl)
        addw hl, #1
        storew hl, (BP), .param16_src_ptr
        
        ; copy char
        loadw hl, (BP), .param16_dst_ptr
        store a, (hl)
        addw hl, #1
        storew hl, (BP), .param16_dst_ptr

        ; fall through if null char, otherwise loop
        test a
        jnz .copy
    .done:
        __epilogue
        ret

;;
; @function
; @brief split string on token
; @section description
; The strtok() function breaks a string into a sequence of zero or
; more nonempty tokens. On the first call to strtok(), the string
; to be parsed should be specified in str. String pointer is modified
; to move pointer forward to token, so recalling strtok will continue
; to the subsequent token.
;
;     _______________________
; -9 |__.param8_delim_char___|
; -8 |  .param16_string_ptr  |
; -7 |_______________________|
; -6 |  .param16_match_ptr   |
; -5 |_______________________|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
; @param .param8_delim_char
; @return -1=empty string, 0=found last token, 1=found token, more remaining
;;
#bank rom
strtok:
    .param8_delim_char = -9
    .param16_string_ptr = -8
    .param16_match_ptr = -6
    .init:
        __prologue
        ; load delimiter
        load b, (BP), .param8_delim_char
        loadw hl, (BP), .param16_string_ptr
        storew hl, (BP), .param16_match_ptr
    
    .check_empty_string:
        ; load char from string
        load a, (hl)
        ; test for null termination
        test a
        jmz .empty_string
    .check_char:
        ; load char from string
        load a, (hl)
        ; test for null termination
        test a
        jmz .end_of_string
        ; compare char with delimiter
        sub a, b
        jmz .token_found
        ; check next char
        addw hl, #1
        storew hl, (BP), .param16_string_ptr
        jmp .check_char
    .empty_string:
        load b, #-1
        jmp .done
    .end_of_string:
        load b, #0
        jmp .done
    .token_found:
        store #"\0", (hl)
        addw hl, #1
        storew hl, (BP), .param16_string_ptr
        load b, #1
    .done:
        __epilogue
        ret