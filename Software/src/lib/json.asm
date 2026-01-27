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
; -10 |    .param16_str_in    |
;  -9 |_______________________|
;  -8 |.param16_base_name_ptr |
;  -7 |_______________________|
;  -6 |   .param16_name_ptr   |
;  -5 |_______________________|
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;   0 |_____.local8_type______|
;   1 |__.local8_name_offset__|
;
; @param .param16_str_in pointer to string
;;
json_print:
    .param16_str_in = -10
    .param16_base_name_ptr= -8
    .param16_name_ptr= -6
    .local8_type = 0
        ; 0: key
        ; 1: value
    .local8_name_offset = 1;
    .init:
        __prologue
        loadw hl, (BP), .param16_str_in
        push #0
        push #0

    ; tokenize function is main loop. it will discard white space until a token is found
    .tokenize:
        load a, (hl)

        ; test end of string
        sub a, #0x00
        jmz .done

        pushw hl ; save pointer on stack

        ; discard white space
        push a
        call isspace
        pop a
        popw hl ; restore pointer from stack
        addw hl, #0x01
        sub b, #0x00
        jmz .token_found
        jmp .tokenize

    ; token_found is a bit if/else for the type of tokens we are expecting
    .token_found:    

        ; check if this token is a key. this token is only accepted if the tokenizer is expecting a key, and not a value
        ..check_key:
            ; check if we are expecting key
            load b, (BP), .local8_type
            sub b, #0
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
                ; print key
                loadw hl, (BP), .param16_base_name_ptr
                storew hl, static_uart_print.data_pointer
                call static_uart_print
                store #":", static_uart_putc.char
                call static_uart_putc
                store #" ", static_uart_putc.char
                call static_uart_putc
                ; continue tokenization
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
            
            load b, #0
            load b, (BP), .local8_type

            addw hl, #0x01
            jmp .tokenize
            ...next_test:

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
                call json_print
                dealloc 4 ; discard nameptr, base name ptr
                popw hl

                ; reset tokenizer
                load b, #0
                store b, (BP), .local8_type

                jmp .tokenize
            ...next_test:

        ; test for the end of an object '}' this will cause this function to return to allow the recusion to complete
        ..check_obj_end:
            load b, a
            sub b, #"}"
            jnz ...next_test
            ...end_object:
                addw hl, #0x01
                push a
                pushw hl
                storew #.type_obj_end_str, static_uart_print.data_pointer
                ;call static_uart_print
                popw hl
                pop a
                jmp .done
            ...next_test:

        ; these following types are all for values
        ; test for a " character to determine this is a string type
        ..check_string:
            load b, a
            sub b, #0x22 ; double quote
            jnz ...next_test
            push a
            pushw hl
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
                ; reset tokenizer
                load b, #0
                store b, (BP), .local8_type
                jmp .tokenize
            ...next_test:

        ; fall though, this is not an expected token
        ..continue:
            store a, static_uart_putc.char
            call static_uart_putc
            store #"*", static_uart_putc.char
            call static_uart_putc
            jmp .tokenize

    .done:
        storew hl, (BP), .param16_str_in
        dealloc 2
        __epilogue
        ret

    .type_obj_str: #d "NEW OBJ\n\0"
    .type_obj_end_str: #d "END OBJ\n\0"
    .type_str_str: #d "STR \0"
    .type_key_str: #d "KEY \0"
