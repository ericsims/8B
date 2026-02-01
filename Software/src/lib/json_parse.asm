; ###
; json_parse.asm begin
; ###
#once

#bank rom


;;
; @function
; @brief ?
; @section description
;      _________________________
; -12 |    .param16_json_str    |
; -11 |_________________________|
; -10 | .param16_search_key_str |
;  -9 |_________________________|
;  -8 |  .param16_key_str_buf   |
;  -7 |_________________________|
;  -6 | .param16_value_str_buf  |
;  -5 |_________________________|
;  -4 |____________?____________| RESERVED
;  -3 |____________?____________|    .
;  -2 |____________?____________|    .
;  -1 |____________?____________| RESERVED
;
; @param .param16_json_str ptr to JSON input string 
; @param .param16_search_key_str ptr to null terminated key string to search for
; @param .param16_key_str_buf ptr to string buffer used to store the parsed key
; @param .param16_value_str_buf ptr to string buffer used to store the parsed value
;;
json_parse:
    .param16_json_str = -12
    .param16_search_key_str = -10
    .param16_key_str_buf = -8
    .param16_value_str_buf = -6

    __prologue
    loadw hl, (BP), .param16_json_str
    pushw hl ; param16_json_str
    
    loadw hl, (BP), .param16_search_key_str
    pushw hl ; param16_search_key_str

    loadw hl, (BP), .param16_key_str_buf
    pushw hl ; param16_key_str_buf_base
    pushw hl ; param16_key_str_buf

    loadw hl, (BP), .param16_value_str_buf
    pushw hl ; param16_value_str_buf

    push #0 ; param8_isarr

    call json_parse_loop

    dealloc 11
    __epilogue
    ret



;;
; @function
; @brief inner loop for recursing through json string to find token
; @section description
;      __________________________
; -15 |    .param16_json_str    |
; -14 |_________________________|
; -13 | .param16_search_key_str |
; -12 |_________________________|
; -11 |.param16_key_str_buf_base|
; -10 |_________________________|
;  -9 |  .param16_key_str_buf   |
;  -8 |_________________________|
;  -7 | .param16_value_str_buf  |
;  -6 |_________________________|
;  -5 |______.param8_isarr______|
;  -4 |____________?____________| RESERVED
;  -3 |____________?____________|    .
;  -2 |____________?____________|    .
;  -1 |____________?____________| RESERVED
;   0 |______.local8_type_______|
;   1 |___.local8_name_offset___|
;   2 |______.local8_arr_n______|
;   3 |_______.local8_rtn_______|
;   4 |   .local16_match_ptr    |
;   5 |_________________________|
;   6 |____.local8_match_len____|
;

; @param .param16_json_str ptr to JSON input string 
; @param .param16_search_key_str ptr to null terminated key string to search for
; @param .param16_key_str_buf_base ptr to string buffer used to store the parsed key
; @param .param16_key_str_buf ptr to location in .param16_key_str_buf_base. Initially should be same as param16_key_str_buf_base
; @param .param16_value_str_buf ptr to string buffer used to store the parsed value
; @param .param8_isarr is the current object being parsed an array? 0=no, 1=yes
;;
json_parse_loop:
    .param16_json_str = -15
    .param16_search_key_str = -13
    .param16_key_str_buf_base = -11
    .param16_key_str_buf = -9
    .param16_value_str_buf = -7
    .param8_isarr = -5
    .local8_type = 0
        ; 0: key
        ; 1: string
        ; 2: number
        ; -1: any type
    .local8_name_offset = 1;
    .local8_arr_n = 2;
    .local8_rtn = 3;
        ; 0: no match found
        ; -1: parse error
        ; -2: match found, haven't determined type
        ; 1: found string
        ; 2: found number
    .local16_match_ptr = 4;
    .local8_match_len = 6;

    .init:
        __prologue
        loadw hl, (BP), .param16_json_str
        push #0 ; type = 0
        push #0 ; name_offset = 0
        push #0 ; arr_n = 0
        push #0 ; err = 0
        pushw #0 ; match_ptr = 0
        push #0 ; match_len = 0
        
        ; if this is an array, change expected type to value, and init name
        call .__arr_update_name_and_incr ; no calling convention

    .tokenizer_init:
        ; if array, expect another value, otherwise expect a key
        store #0, (BP), .local8_type

        load b, (BP), .param8_isarr
        test b
        jmz .tokenize
        
        ;if array set type to 1
        store #-1, (BP), .local8_type
        jmp .tokenize

    ; tokenize function is main loop. it will discard white space until a token is found
    .tokenize:
        ; load a reg with character
        load a, (hl)

        ; test end of string
        test a
        jmz .done

        pushw hl ; save pointer on stack

        ; discard white space
        push a
        call isspace
        pop a

        popw hl ; restore pointer from stack
        addw hl, #0x01
        test b
        jmz .token_found
        jmp .tokenize

    ; token_found is a big if/else for the type of tokens
    .token_found:    
        ; check if this token is a key. this token is only accepted if the tokenizer is expecting a key, and not a value
        ..check_key:
            ; check if we are expecting key
            load b, (BP), .local8_type
            test b
            jnz ...next_test
            ; check for quote
            load b, a
            sub b, #0x22 ; double quote
            jnz ...next_test
            store #-1, (BP), .local8_type
            ; zero the destination pointer offset
            store #0, (BP), .local8_name_offset

            ...save_key:
                ; check if current char is a double quote, which would be end of string
                load a, (hl)
                load b, a
                sub b, #0x22 ; double quote
                jmz ...end_of_key
                ; store hl reg (next char pointer) to stack briefly
                pushw hl
                ; compute desintation address for this character, then store
                load b, (BP), .local8_name_offset
                loadw hl, (BP), .param16_key_str_buf
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
                ; zero terminate key string
                load b, (BP), .local8_name_offset
                loadw hl, (BP), .param16_key_str_buf
                addw hl, b
                store #0, (hl)
                
                ; check if current key matches search key
                loadw hl, (BP), .param16_search_key_str
                pushw hl
                loadw hl, (BP), .param16_key_str_buf_base
                pushw hl
                call strcmp
                dealloc 4
                test b
                jnz ....strings_dont_match
                ; strings match!
                store #-2, (BP), .local8_rtn
                jmp ....done
                ....strings_dont_match:
                store #0, (BP), .local8_rtn
                ....done:
                popw hl
                jmp .tokenize
            ...next_test:

        ; check if the token is a ':'. this changes the tokenizer to assume the next token is a value not a key
        ..check_value:
            load b, a
            sub b, #":"
            jnz ...next_test

            store #-1, (BP), .local8_type
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
                loadw hl, (BP), .param16_key_str_buf
                addw hl, b
                add b, #1
                store b, (BP), .local8_name_offset
                store #".", (hl)
                
                ; recurse into new object
                loadw hl, (BP), .param16_search_key_str
                pushw hl  ; key
                loadw hl, (BP), .param16_key_str_buf_base
                pushw hl  ; base_name_ptr
                loadw hl, (BP), .param16_key_str_buf
                load b, (BP), .local8_name_offset
                addw hl, b
                pushw hl ; name_ptr
                loadw hl, (BP), .param16_value_str_buf
                pushw hl ; value_ptr
                push #0 ; is_arr
                call json_parse_loop
                dealloc 9 ; discard params
                popw hl
                ; test return code
                store b, (BP), .local8_rtn 
                test b
                jnz .done ; negative code is an error, positve means match was found. exit search
                jmp .tokenizer_init
            ...next_test:

        ; test for the end of an object '}' or end of array ']' this will cause this function to return to allow the recusion to complete
        ..check_obj_end:
            load b, a
            or b, #0x20 ; convert ']' to '}'
            sub b, #"}"
            jnz ...next_test
            ...end_object:
                jmp .done
            ...next_test:

        ; test for the start of an array '['
        ..check_arr:
            load b, a
            sub b, #"["
            jnz ...next_test
            ...new_arr:
                pushw hl

                ; storew #.type_arr_str, static_uart_print.data_pointer
                ; call static_uart_print
                
                ; recurse into new object
                loadw hl, (BP), .param16_search_key_str
                pushw hl  ; key
                loadw hl, (BP), .param16_key_str_buf_base
                pushw hl ; base_name_ptr
                loadw hl, (BP), .param16_key_str_buf
                load b, (BP), .local8_name_offset
                addw hl, b
                pushw hl ; name_ptr
                loadw hl, (BP), .param16_value_str_buf
                pushw hl ; value_ptr
                push #1 ; is_arr
                call json_parse_loop
                dealloc 9 ; discard params
                popw hl
                ; test return code
                store b, (BP), .local8_rtn 
                test b
                jnz .done ; negative code is an error, positve means match was found. exit search
                jmp .tokenizer_init
            ...next_test:
    
        ; test for a " character to determine this is a string type
        ..check_string:
            load b, a
            sub b, #0x22 ; double quote
            jnz ...next_test

            ; check if the key matched, otherwise skip this string
            load b, (BP), .local8_rtn
            test b
            jmz ...skip_string

            ; save string
            store #1, (BP), .local8_rtn ; found type string
            storew hl, (BP), .local16_match_ptr
            store #0, (BP), .local8_match_len

            ...save_string:
                load a, (hl)
                load b, a
                addw hl, #0x01
                sub b, #0x22 ; double quote
                jmz ...end_of_string
                ; copy char
                pushw hl
                load b, (BP), .local8_match_len
                loadw hl, (BP), .param16_value_str_buf
                addw hl, b
                store a, (hl)
                add b, #1
                store b, (BP), .local8_match_len
                popw hl
                jmp ...save_string
            ...end_of_string:
                loadw hl, (BP), .param16_value_str_buf
                load b, (BP), .local8_match_len
                addw hl, b
                store #0, (hl)
                jmp .done
            
            ...skip_string:
                load a, (hl)
                addw hl, #0x01
                sub a, #0x22 ; double quote
                jmz .tokenizer_init ; end of string
                jmp ...skip_string
            ...next_test:

        ; test for a number digit character to determine this is a number
        ..check_number:
            pushw hl
            push a
            call isjsondigit
            pop a
            popw hl
            test b
            jmz ...next_test

            ; check if the key matched, otherwise skip this number
            load b, (BP), .local8_rtn
            test b
            jmz ...skip_number

            store #2, (BP), .local8_rtn ; found type number
            subw hl, #1
            storew hl, (BP), .local16_match_ptr
            store #0, (BP), .local8_match_len
            
            ...save_number:
                load a, (hl)
                pushw hl
                push a
                call isjsondigit
                pop a
                popw hl
                test b
                jmz ...end_of_number
                pushw hl
                load b, (BP), .local8_match_len
                loadw hl, (BP), .param16_value_str_buf
                addw hl, b
                store a, (hl)
                add b, #1
                store b, (BP), .local8_match_len
                popw hl
                addw hl, #0x01
                jmp ...save_number
            ...end_of_number:
                loadw hl, (BP), .param16_value_str_buf
                load b, (BP), .local8_match_len
                addw hl, b
                store #0, (hl)
                jmp .done
            ...skip_number:
                load a, (hl)
                pushw hl
                push a
                call isjsondigit
                pop a
                popw hl
                test b
                jmz .tokenizer_init
                addw hl, #0x01
                jmp ...skip_number
            ...next_test:

        ; fall though, this is not an expected token
        ..default:
            store #-1, (BP), .local8_rtn
            jmp .done ; error out

    .done:
        storew hl, (BP), .param16_json_str
        load b, (BP), .local8_rtn
        dealloc 7
        __epilogue
        ret
    
    ; helper functions with no calling convention
    .__arr_update_name_and_incr:
        push a
        pushw hl
        load a, (BP), .param8_isarr
        test a
        jmz ..done

        ; add '[NN]'
        load b, (BP), .local8_name_offset
        loadw hl, (BP), .param16_key_str_buf
        addw hl, b

        ; assume length of string added
        add b, #4
        store b, (BP), .local8_name_offset
        
        store #"[", (hl)
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

        store #"]", (hl)
        addw hl, #1
        
        store #0, (hl)

        ; check if current key matches search key
        loadw hl, (BP), .param16_search_key_str
        pushw hl
        loadw hl, (BP), .param16_key_str_buf_base
        pushw hl
        call strcmp
        dealloc 4
        test b
        jnz ..strings_dont_match
        ; strings match!
        store #-2, (BP), .local8_rtn
        jmp ..done
        ..strings_dont_match:
        store #0, (BP), .local8_rtn
        
        ..done:
        popw hl
        pop a
        ret
    
#include "./char_utils.asm"