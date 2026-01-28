; ###
; json.asm begin
; ###

#once

#bank rom
;;
; @function
; @brief ?
; @section description
;      _______________________
; -11 |    .param16_str_in    |
; -10 |_______________________|
;  -9 |.param16_base_name_ptr |
;  -8 |_______________________|
;  -7 |   .param16_name_ptr   |
;  -6 |_______________________|
;  -5 |_____.param8_isarr_____|
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;   0 |_____.local8_type______|
;   1 |__.local8_name_offset__|
;   2 |_____.local8_arr_n_____|
;   3 |______.local8_err______|
;
; @param .param16_str_in pointer to string
;;
json_print:
    .param16_str_in = -11
    .param16_base_name_ptr= -9
    .param16_name_ptr= -7
    .param8_isarr = -5
    .local8_type = 0
        ; 0: key
        ; nonzero: value
    .local8_name_offset = 1;
    .local8_arr_n = 2;
    .local8_err = 3;

    .init:
        __prologue
        loadw hl, (BP), .param16_str_in
        push #0 ; type = 0
        push #0 ; name_offset = 0
        push #0 ; arr_n = 0
        push #0 ; arr_n = 0
        
        ; if this is an array, change expected type to value, and init name
        call .__arr_update_name_and_incr ; no calling convention

    .tokenizer_init:
        ; if array, expect another value, otherwise expect a key
        load b, #0
        store b, (BP), .local8_type

        load b, (BP), .param8_isarr
        add b, #0
        jmz .tokenize
        
        ;if array set type to 1
        load b, #1
        store b, (BP), .local8_type
        jmp .tokenize

    ; tokenize function is main loop. it will discard white space until a token is found
    .tokenize:
        ; load a reg with character
        load a, (hl)

        ; test end of string
        add a, #0x00
        jmz .done

        pushw hl ; save pointer on stack

        ; discard white space
        push a
        call isspace
        pop a

        popw hl ; restore pointer from stack
        addw hl, #0x01
        add b, #0x00
        jmz .token_found
        jmp .tokenize

    ; token_found is a big if/else for the type of tokens
    .token_found:    
        ; check if this token is a key. this token is only accepted if the tokenizer is expecting a key, and not a value
        ..check_key:
            ; check if we are expecting key
            load b, (BP), .local8_type
            add b, #0
            jnz ...next_test
            ; check for quote
            load b, a
            sub b, #0x22 ; double quote
            jnz ...next_test
            push a
            pushw hl
            storew #.type_key_str, static_uart_print.data_pointer
            ; call static_uart_print
            popw hl
            pop a
            load b, #1
            store b, (BP), .local8_type
            ; zero the destination pointer offset
            load b, #0
            store b, (BP), .local8_name_offset

            ...save_key:
                ; check if current char is a double quote, which would be end of string
                load a, (hl)
                load b, a
                sub b, #0x22 ; double quote
                jmz ...end_of_key
                ; store hl reg (current char pointer) to stack briefly
                pushw hl
                ; compute desintation address for this character, then store
                load b, (BP), .local8_name_offset
                loadw hl, (BP), .param16_name_ptr
                addw hl, b
                store a, (hl)
                ; increment offset
                add b, #1
                store b, (BP), .local8_name_offset
                ; restore current character pointer
                popw hl
                addw hl, #0x01
                jmp ...save_key
            ...end_of_key:
                addw hl, #0x01
                pushw hl
                push a
                ; zero terminate key string
                load b, (BP), .local8_name_offset
                loadw hl, (BP), .param16_name_ptr
                addw hl, b
                load b, #0
                store b, (hl)
                pop a
                popw hl
                jmp .tokenize
            ...next_test:

        ; check if the token is a ':'. this changes the tokenizer to assume the next token is a value not a key
        ..check_value:
            load b, a
            sub b, #":"
            jnz ...next_test
            
            load b, #1
            load b, (BP), .local8_type

            addw hl, #0x01
            jmp .tokenize
            ...next_test:

        ; check if the token is a ','. this changes the tokenizer to assume the next token is a value is a key
        ..check_continuation:
            load b, a
            sub b, #","
            jnz ...next_test

            ; backspace last 4 chars of key name
            load b, (BP), .local8_name_offset
            sub b, #4
            store b, (BP), .local8_name_offset

            call .__arr_update_name_and_incr ; no calling convention
            jmp .tokenizer_init
            ...next_test:
            
        ; these following types are all for values

        ; test for the start of an object '{' this will cause this function to recurse into the object
        ..check_obj:
            load b, a
            sub b, #"{"
            jnz ...next_test
            ...new_object:
                pushw hl
                ; add '.' to key string
                load b, (BP), .local8_name_offset
                loadw hl, (BP), .param16_name_ptr
                addw hl, b
                add b, #1
                store b, (BP), .local8_name_offset
                load b, #"."
                store b, (hl)

                storew #.type_obj_str, static_uart_print.data_pointer
                ;call static_uart_print
                
                ; recurse into new object
                loadw hl, (BP), .param16_base_name_ptr
                pushw hl
                loadw hl, (BP), .param16_name_ptr
                load b, (BP), .local8_name_offset
                addw hl, b
                pushw hl
                push #0
                call json_print
                dealloc 5 ; discard params
                popw hl
                ; test return code
                add b, #0
                jmz ....no_error
                load b, #1
                store b, (BP), .local8_err 
                ....no_error:

                jmp .tokenizer_init
            ...next_test:

        ; test for the end of an object '}' this will cause this function to return to allow the recusion to complete
        ..check_obj_end:
            load b, a
            sub b, #"}"
            jnz ...next_test
            ...end_object:
                ; addw hl, #0x01
                push a
                pushw hl
                storew #.type_obj_end_str, static_uart_print.data_pointer
                ;call static_uart_print
                popw hl
                pop a
                jmp .done
            ...next_test:

        ; test for the start of an array '['
        ..check_arr:
            load b, a
            sub b, #"["
            jnz ...next_test
            ...new_arr:
                pushw hl

                storew #.type_arr_str, static_uart_print.data_pointer
                ;call static_uart_print
                
                ; recurse into new object
                loadw hl, (BP), .param16_base_name_ptr
                pushw hl
                loadw hl, (BP), .param16_name_ptr
                load b, (BP), .local8_name_offset
                addw hl, b
                pushw hl
                push #1
                call json_print
                dealloc 5 ; discard params
                popw hl
                ; test return code
                add b, #0
                jmz ....no_error
                load b, #1
                store b, (BP), .local8_err 
                ....no_error:

                jmp .tokenizer_init
            ...next_test:

        ; test for the end of an array ']' this will cause this function to return to allow the recusion to complete
        ..check_arr_end:
            load b, a
            sub b, #"]"
            jnz ...next_test
            ...end_arr:
                addw hl, #0x01
                push a
                pushw hl
                storew #.type_arr_end_str, static_uart_print.data_pointer
                ;call static_uart_print
                popw hl
                pop a
                jmp .done
            ...next_test:
    
        ; test for a " character to determine this is a string type
        ..check_string:
            load b, a
            sub b, #0x22 ; double quote
            jnz ...next_test
            push a
            pushw hl

            ; print key
            loadw hl, (BP), .param16_base_name_ptr
            storew hl, static_uart_print.data_pointer
            call static_uart_print
            store #":", static_uart_putc.char
            call static_uart_putc
            store #" ", static_uart_putc.char
            call static_uart_putc


            storew #.type_str_str, static_uart_print.data_pointer
            call static_uart_print
            popw hl
            pop a
            load b, #1
            store b, (BP), .local8_type
            ...save_string:
                load a, (hl)
                load b, a
                sub b, #0x22 ; double quote
                jmz ...end_of_string
                store a, static_uart_putc.char
                call static_uart_putc
                addw hl, #0x01
                jmp ...save_string
            ...end_of_string:
                addw hl, #0x01
                call static_uart_print_newline
                jmp .tokenizer_init
            ...next_test:

        ; test for a number digit character to determine this is a number
        ..check_number:
            pushw hl
            push a
            call isjsondigit
            pop a
            popw hl
            add b, #0
            jmz ...next_test

            halt
            push a
            pushw hl

            ; print key
            loadw hl, (BP), .param16_base_name_ptr
            storew hl, static_uart_print.data_pointer
            call static_uart_print
            store #":", static_uart_putc.char
            call static_uart_putc
            store #" ", static_uart_putc.char
            call static_uart_putc

            storew #.type_num_str, static_uart_print.data_pointer
            call static_uart_print
            popw hl
            pop a
            load b, #1
            store b, (BP), .local8_type
            ...save_number:
                pushw hl
                push a
                call isjsondigit
                pop a
                popw hl
                add b, #0
                jmz ...end_of_number
                store a, static_uart_putc.char
                call static_uart_putc
                load a, (hl)
                addw hl, #0x01
                jmp ...save_number
            ...end_of_number:
                subw hl, #0x01
                call static_uart_print_newline
                jmp .tokenizer_init
            ...next_test:

        ; fall though, this is not an expected token
        ..continue:
            load b, #1
            store b, (BP), .local8_err
            store a, static_uart_putc.char
            call static_uart_putc
            store #"*", static_uart_putc.char
            call static_uart_putc
            jmp .tokenize

    .done:
        storew hl, (BP), .param16_str_in
        load b, (BP), .local8_err
        dealloc 4
        __epilogue
        ret
    
    ; helper functions with no calling convention
    .__arr_update_name_and_incr:
        pushw hl
        load a, (BP), .param8_isarr
        add a, #0
        jmz ..done

        ; add '[NN]'
        load b, (BP), .local8_name_offset
        loadw hl, (BP), .param16_name_ptr
        addw hl, b

        ; assume length of string added
        add b, #4
        store b, (BP), .local8_name_offset
        
        load b, #"["
        store b, (hl)
        addw hl, #1

        pushw hl
        load a, (BP), .local8_arr_n
        ; rshift x4 just keep upper 4 bits
        rshift a
        rshift a
        rshift a
        rshift a
        push a
        call itoa_hex_nibble
        pop a
        popw hl
        store b, (hl)
        addw hl, #1

        pushw hl
        load a, (BP), .local8_arr_n
        push a
        ; increment array index, while we have it in a reg
        add a, #1
        store a, (BP), .local8_arr_n
        call itoa_hex_nibble
        pop a
        popw hl
        store b, (hl)
        addw hl, #1

        load b, #"]"
        store b, (hl)
        addw hl, #1
        
        load b, #0
        store b, (hl)
        
        ..done:
            popw hl
            ret


    .type_obj_str: #d "NEW OBJ\n\0"
    .type_obj_end_str: #d "END OBJ\n\0"
    .type_str_str: #d "STR \0"
    .type_num_str: #d "NUM \0"
    .type_key_str: #d "KEY \0"
    .type_arr_str: #d "ARR \0"
    .type_arr_end_str: #d "END ARR\n\0"

#include "./char_utils.asm"