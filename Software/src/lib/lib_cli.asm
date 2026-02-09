; ###
; cli.asm begin
; ###

#once


#bank rom
cli_table:
    ; struct
    .CMD_POS = 0
    .HELP_POS = .CMD_POS+2
    .JMP_POS = .HELP_POS+2
    ; consts
    .ENTRY_SIZE = .JMP_POS+2
    .NUM_ENTRIES = (._end - cli_table) / .ENTRY_SIZE
    ; entries
    .test2:
        ..cmd_str_ptr: #d16 cli_strings.test2_cmd
        ..help_str_ptr: #d16 cli_strings.test2_help
        ..jmp: #d16 cli_parse_cmd.test2
    .test1:
        ..cmd_str_ptr: #d16 cli_strings.test1_cmd
        ..help_str_ptr: #d16 cli_strings.test1_help
        ..jmp: #d16 cli_parse_cmd.test1
    .mount:
        ..cmd_str_ptr: #d16 cli_strings.mount_cmd
        ..help_str_ptr: #d16 cli_strings.mount_help
        ..jmp: #d16 fs_read_mbr
    .rtn_code_cmd:
        ..cmd_str_ptr: #d16 cli_strings.rtn_code_cmd
        ..help_str_ptr: #d16 cli_strings.rtn_code_help
        ..jmp: #d16 cli_parse_cmd.print_return_code
    .help_cmd:
        ..cmd_str_ptr: #d16 cli_strings.help_cmd
        ..help_str_ptr: #d16 cli_strings.help_help
        ..jmp: #d16 cli_parse_cmd.print_help
    .call_cmd:
        ..cmd_str_ptr: #d16 cli_strings.call_cmd
        ..help_str_ptr: #d16 cli_strings.call_help
        ..jmp: #d16 cli_parse_cmd.call
    .dump_cmd:
        ..cmd_str_ptr: #d16 cli_strings.dump_cmd
        ..help_str_ptr: #d16 cli_strings.dump_help
        ..jmp: #d16 cli_parse_cmd.dump
    .print_cmd:
        ..cmd_str_ptr: #d16 cli_strings.print_cmd
        ..help_str_ptr: #d16 cli_strings.print_help
        ..jmp: #d16 cli_parse_cmd.print
    .write32_cmd:
        ..cmd_str_ptr: #d16 cli_strings.write32_cmd
        ..help_str_ptr: #d16 cli_strings.write32_help
        ..jmp: #d16 cli_parse_cmd.write32
    .write16_cmd:
        ..cmd_str_ptr: #d16 cli_strings.write16_cmd
        ..help_str_ptr: #d16 cli_strings.write16_help
        ..jmp: #d16 cli_parse_cmd.write16
    .write8_cmd:
        ..cmd_str_ptr: #d16 cli_strings.write8_cmd
        ..help_str_ptr: #d16 cli_strings.write8_help
        ..jmp: #d16 cli_parse_cmd.write8
    .read32_cmd:
        ..cmd_str_ptr: #d16 cli_strings.read32_cmd
        ..help_str_ptr: #d16 cli_strings.read32_help
        ..jmp: #d16 cli_parse_cmd.read32
    .read16_cmd:
        ..cmd_str_ptr: #d16 cli_strings.read16_cmd
        ..help_str_ptr: #d16 cli_strings.read16_help
        ..jmp: #d16 cli_parse_cmd.read16
    .read8_cmd:
        ..cmd_str_ptr: #d16 cli_strings.read8_cmd
        ..help_str_ptr: #d16 cli_strings.read8_help
        ..jmp: #d16 cli_parse_cmd.read8
    ._end:
cli_strings:
    .test1_cmd: #d "TEST1\0"
    .test1_help: #d "  returns 1\0"
    .test2_cmd: #d "TEST2\0"
    .test2_help: #d "  returns 2\0"
    .rtn_code_cmd: #d "$?\0"
    .rtn_code_help: #d " prints return code of last cli command\0"
    .help_cmd: #d "HELP\0"
    .help_help: #d "  prints this help\0"
    .read8_cmd: #d "READ8\0"
    .read8_help: #d " <ADDR16> read byte at address\0"
    .read16_cmd: #d "READ16\0"
    .read16_help: #d " <ADDR16> read half word at address\0"
    .read32_cmd: #d "READ32\0"
    .read32_help: #d " <ADDR16> read word at address\0"
    .write8_cmd: #d "WRITE8\0"
    .write8_help: #d " <ADDR16> <VAL8> write byte to address\0"
    .write16_cmd: #d "WRITE16\0"
    .write16_help: #d " <ADDR16> <VAL16> write half word to address\0"
    .write32_cmd: #d "WRITE32\0"
    .write32_help: #d " <ADDR16> <VAL32> word word to address\0"
    .dump_cmd: #d "DUMP\0"
    .dump_help: #d " <ADDR16> <LEN8> dumps memory at addr of LEN8*16\0"
    .print_cmd: #d "PRINT\0"
    .print_help: #d " <ADDR16> prints null terminated string at address\0"
    .call_cmd: #d "CALL\0"
    .call_help: #d " <ADDR16> calls subroutine at address. Preserves return code\0"
    .mount_cmd: #d "MOUNT\0"
    .mount_help: #d " mounts SDCARD FAT16 filesystem\0"


#bank ram
return_code: #res 1

;;
; @function
; @brief ?
; @section description
;      _______________________
;  -6 |  .param16_string_ptr  |
;  -5 |_______________________|
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;   0 |____.local8_cmd_num____|
;   1 |   .local16_tbl_ptr    |
;   2 |_______________________|
;   3 |.local16_next_token_ptr|
;   4 |_______________________|
;   5 |   .local16_rtn_addr   |
;   6 |_______________________|
;   7 |           .           | local params for individual cmd cli_parse_cmd
;   8 |           .           |
;   9 |           .           |
;
; @param .param16_string_ptr pointer to string buffer containing commands/params
;;
#bank rom
cli_parse_cmd:
    .param16_string_ptr = -6
    .local8_cmd_num = 0
    .local16_tbl_ptr = 1
    .local16_next_token_ptr = 3
    .init:
        __prologue
        push #cli_table.NUM_ENTRIES ; start at last entry
        pushw #cli_table._end - cli_table.ENTRY_SIZE ; start at last entry

    .split_string:
        push #" "
        loadw hl, (BP), .param16_string_ptr
        pushw hl
        pushw #0
        call strtok
        popw hl ; discard current token pointer
        popw hl
        pop a ; discard delim
        pushw hl ; store string_ptr on stack as local16_next_token_ptr

    .search_cmd:
        loadw hl, (BP), .param16_string_ptr
        pushw hl
        loadw hl, (BP), .local16_tbl_ptr
        ; addw hl, #cli_table.CMD_POS ; CMD_POS = 0
        #assert(cli_table.CMD_POS == 0) ; check that CMD_POS = 0, to skip computing offset
        loadw hl, (hl)
        pushw hl
        call strcmp
        dealloc 4
        test b
        jmz .cmd_found
    .search_next_table_entry:
        load a, (BP), .local8_cmd_num
        sub a, #1
        jmz .no_cmd_found
        store a, (BP), .local8_cmd_num
        loadw hl, (BP), .local16_tbl_ptr
        subw hl, #cli_table.ENTRY_SIZE
        storew hl, (BP), .local16_tbl_ptr
        jmp .search_cmd
    .no_cmd_found:
        load b, #-2
        store b, return_code
        jmp .done
    .cmd_found:
        loadw hl, (BP), .local16_tbl_ptr
        addw hl, #cli_table.JMP_POS
        loadw hl, (hl) ; load hl with the command address
        call hl ; call the subroutine
        store b, return_code ; save off the return code for later
    .done:
        dealloc 5
        __epilogue
        ret

; cmd subroutines
.test1:
    load b, #1
    ret

.test2:
    load b, #2
    ret

.print_return_code:
    load a, return_code
    push a
    call uart_print_itoa_hex
    pop a
    call static_uart_print_newline
    load b, #0
    ret

;      _______________________
;   7 |___..local8_cmd_num____|
;   8 |  ..local16_tbl_ptr    |
;   9 |_______________________|
.print_help:
    ..local8_cmd_num = 7
    ..local16_tbl_ptr = 8
    ..init:
        push #cli_table.NUM_ENTRIES ; start at last entry
        pushw #cli_table._end - cli_table.ENTRY_SIZE ; start at last entry
    
    ..print_cmd:
        loadw hl, (BP), ..local16_tbl_ptr
        ; addw hl, #cli_table.CMD_POS ; CMD_POS = 0
        #assert(cli_table.CMD_POS == 0) ; check that CMD_POS = 0, to skip computing offset
        loadw hl, (hl)
        storew hl, static_uart_print.data_pointer
        call static_uart_print
        loadw hl, (BP), ..local16_tbl_ptr
        addw hl, #cli_table.HELP_POS
        loadw hl, (hl)
        storew hl, static_uart_print.data_pointer
        call static_uart_print
        call static_uart_print_newline
    ..search_next_table_entry:
        load a, (BP), ..local8_cmd_num
        sub a, #1
        jmz ..done
        store a, (BP), ..local8_cmd_num
        loadw hl, (BP), ..local16_tbl_ptr
        subw hl, #cli_table.ENTRY_SIZE
        storew hl, (BP), ..local16_tbl_ptr
        jmp ..print_cmd
    ..done:
        dealloc 3
        load b, #0
        ret

;      _________________________
;   7 |   ..local32_atoi_res    |
;   8 |                         |
;   9 |                         |
;  10 |_________________________|
;  11 |__..local8_delim_char____|
;  12 |..local16_next_token_ptr |
;  13 |_________________________|
;  14 |  ..local16_token_ptr    |
;  15 |_________________________|
.read8:
    ..local32_atoi_res = 7
    ..init:
        alloc 4 ; atoi_res
    
    ..find_param:
        push #" "
        loadw hl, (BP), .local16_next_token_ptr
        pushw hl        
        pushw #0
        call strtok
        test b
        jnz ..error ; expect last token, b=0

        ; compute address of atoi_res
        loadw hl, BP
        addw hl, #..local32_atoi_res
        pushw hl

        ; convert addressing string to int
        call atoi_hex
        popw hl
        sub b, #16
        jnz ..error ; expect 16 bit address

        ; load 16 bit address
        loadw hl, (BP), ..local32_atoi_res+2
        ; load character at address
        load a, (hl)

        ; print character
        push a
        call uart_print_itoa_hex
        call static_uart_print_newline
        pop a

        load b, #0
        jmp ..done

    ..error:
        load b, #-1
    ..done:
        dealloc 9
        ret

;      _________________________
;   7 |   ..local32_atoi_res    |
;   8 |                         |
;   9 |                         |
;  10 |_________________________|
;  11 |__..local8_delim_char____|
;  12 |..local16_next_token_ptr |
;  13 |_________________________|
;  14 |  ..local16_token_ptr    |
;  15 |_________________________|
.read16:
    ..local32_atoi_res = 7
    ..init:
        alloc 4 ; atoi_res
    
    ..find_param:
        push #" "
        loadw hl, (BP), .local16_next_token_ptr
        pushw hl        
        pushw #0
        call strtok
        test b
        jnz ..error ; expect last token, b=0

        ; compute address of atoi_res
        loadw hl, BP
        addw hl, #..local32_atoi_res
        pushw hl

        ; convert addressing string to int
        call atoi_hex
        popw hl
        sub b, #16
        jnz ..error ; expect 16 bit address

        ; load 16 bit address
        loadw hl, (BP), ..local32_atoi_res+2
        ; load 2 characters at address
        load a, (hl)
        push a
        
        addw hl, #1
        load a, (hl)
        push a

        ; print character
        call uart_print_itoa_hex16
        call static_uart_print_newline
        dealloc 2

        load b, #0
        jmp ..done

    ..error:
        load b, #-1
    ..done:
        dealloc 9
        ret

;      _________________________
;   7 |   ..local32_atoi_res    |
;   8 |                         |
;   9 |                         |
;  10 |_________________________|
;  11 |__..local8_delim_char____|
;  12 |..local16_next_token_ptr |
;  13 |_________________________|
;  14 |  ..local16_token_ptr    |
;  15 |_________________________|
.read32:
    ..local32_atoi_res = 7
    ..init:
        alloc 4 ; atoi_res
    
    ..find_param:
        push #" "
        loadw hl, (BP), .local16_next_token_ptr
        pushw hl        
        pushw #0
        call strtok
        test b
        jnz ..error ; expect last token, b=0

        ; compute address of atoi_res
        loadw hl, BP
        addw hl, #..local32_atoi_res
        pushw hl

        ; convert addressing string to int
        call atoi_hex
        popw hl
        sub b, #16
        jnz ..error ; expect 16 bit address

        ; load 16 bit address
        loadw hl, (BP), ..local32_atoi_res+2
        ; load 4 characters at address
        load a, (hl)
        push a
        
        addw hl, #1
        load a, (hl)
        push a
        
        addw hl, #1
        load a, (hl)
        push a
        
        addw hl, #1
        load a, (hl)
        push a
        ; print character
        call uart_print_itoa_hex32
        call static_uart_print_newline
        dealloc 4

        load b, #0
        jmp ..done

    ..error:
        load b, #-1
    ..done:
        dealloc 9
        ret


;      _________________________
;   7 |   ..local32_atoi_res1   |
;   8 |                         |
;   9 |                         |
;  10 |_________________________|
;  11 |   ..local32_atoi_res2   |
;  12 |                         |
;  13 |                         |
;  14 |_________________________|
;  15 |__..local8_delim_char____|
;  16 |..local16_next_token_ptr |
;  17 |_________________________|
;  18 |  ..local16_token_ptr    |
;  19 |_________________________|
.write8:
    ..local32_atoi_res1 = 7
    ..local32_atoi_res2 = 11
    ..init:
        alloc 8 ; atoi_res1 and atoi_res2
    
    ..find_addr:
        push #" "
        loadw hl, (BP), .local16_next_token_ptr
        pushw hl        
        pushw #0
        call strtok
        sub b, #1
        jnz ..error ; expect more tokens, b=1

        ; compute address of atoi_res
        loadw hl, BP
        addw hl, #..local32_atoi_res1
        pushw hl

        ; convert addressing string to int
        call atoi_hex
        popw hl
        sub b, #16
        jnz ..error ; expect 16 bit address
        
    ..find_val:
        call strtok
        test b
        jnz ..error ; expect no more tokens, b = 0

        ; compute address of atoi_res
        loadw hl, BP
        addw hl, #..local32_atoi_res2
        pushw hl

        ; convert value string to int
        call atoi_hex
        popw hl
        sub b, #8
        jnz ..error ; expect 8 bit value

        ; load 16 bit address and len
        loadw hl, (BP), ..local32_atoi_res1+2
        load a, (BP), ..local32_atoi_res2+3
        
        ; write value
        store a, (hl)

        load b, #0
        jmp ..done

    ..error:
        load b, #-1
    ..done:
        dealloc 13
        ret


;      _________________________
;   7 |   ..local32_atoi_res1   |
;   8 |                         |
;   9 |                         |
;  10 |_________________________|
;  11 |   ..local32_atoi_res2   |
;  12 |                         |
;  13 |                         |
;  14 |_________________________|
;  15 |__..local8_delim_char____|
;  16 |..local16_next_token_ptr |
;  17 |_________________________|
;  18 |  ..local16_token_ptr    |
;  19 |_________________________|
.write16:
    ..local32_atoi_res1 = 7
    ..local32_atoi_res2 = 11
    ..init:
        alloc 8 ; atoi_res1 and atoi_res2
    
    ..find_addr:
        push #" "
        loadw hl, (BP), .local16_next_token_ptr
        pushw hl        
        pushw #0
        call strtok
        sub b, #1
        jnz ..error ; expect more tokens, b=1

        ; compute address of atoi_res
        loadw hl, BP
        addw hl, #..local32_atoi_res1
        pushw hl

        ; convert addressing string to int
        call atoi_hex
        popw hl
        sub b, #16
        jnz ..error ; expect 16 bit address
        
    ..find_val:
        call strtok
        test b
        jnz ..error ; expect no more tokens, b = 0

        ; compute address of atoi_res
        loadw hl, BP
        addw hl, #..local32_atoi_res2
        pushw hl

        ; convert value string to int
        call atoi_hex
        popw hl
        sub b, #16
        jnz ..error ; expect 16 bit value

        ; load 16 bit address
        loadw hl, (BP), ..local32_atoi_res1+2
        ; write MSB
        load a, (BP), ..local32_atoi_res2+2
        store a, (hl)
        ; write LSB
        addw hl, #1
        load a, (BP), ..local32_atoi_res2+3
        store a, (hl)

        load b, #0
        jmp ..done

    ..error:
        load b, #-1
    ..done:
        dealloc 13
        ret



;      _________________________
;   7 |   ..local32_atoi_res1   |
;   8 |                         |
;   9 |                         |
;  10 |_________________________|
;  11 |   ..local32_atoi_res2   |
;  12 |                         |
;  13 |                         |
;  14 |_________________________|
;  15 |__..local8_delim_char____|
;  16 |..local16_next_token_ptr |
;  17 |_________________________|
;  18 |  ..local16_token_ptr    |
;  19 |_________________________|
.write32:
    ..local32_atoi_res1 = 7
    ..local32_atoi_res2 = 11
    ..init:
        alloc 8 ; atoi_res1 and atoi_res2
    
    ..find_addr:
        push #" "
        loadw hl, (BP), .local16_next_token_ptr
        pushw hl        
        pushw #0
        call strtok
        sub b, #1
        jnz ..error ; expect more tokens, b=1

        ; compute address of atoi_res
        loadw hl, BP
        addw hl, #..local32_atoi_res1
        pushw hl

        ; convert addressing string to int
        call atoi_hex
        popw hl
        sub b, #16
        jnz ..error ; expect 16 bit address
        
    ..find_val:
        call strtok
        test b
        jnz ..error ; expect no more tokens, b = 0

        ; compute address of atoi_res
        loadw hl, BP
        addw hl, #..local32_atoi_res2
        pushw hl

        ; convert value string to int
        call atoi_hex
        popw hl
        sub b, #32
        jnz ..error ; expect 32 bit value

        ; load 16 bit address
        loadw hl, (BP), ..local32_atoi_res1+2
        ; write byte 0
        load a, (BP), ..local32_atoi_res2
        store a, (hl)
        ; write byte 1
        addw hl, #1
        load a, (BP), ..local32_atoi_res2+1
        store a, (hl)
        ; write byte 2
        addw hl, #1
        load a, (BP), ..local32_atoi_res2+2
        store a, (hl)
        ; write byte 3
        addw hl, #1
        load a, (BP), ..local32_atoi_res2+3
        store a, (hl)

        load b, #0
        jmp ..done

    ..error:
        load b, #-1
    ..done:
        dealloc 13
        ret
    
;      _________________________
;   7 |   ..local32_atoi_res1   |
;   8 |                         |
;   9 |                         |
;  10 |_________________________|
;  11 |   ..local32_atoi_res2   |
;  12 |                         |
;  13 |                         |
;  14 |_________________________|
;  15 |__..local8_delim_char____|
;  16 |..local16_next_token_ptr |
;  17 |_________________________|
;  18 |  ..local16_token_ptr    |
;  19 |_________________________|
.dump:
    ..local32_atoi_res1 = 7
    ..local32_atoi_res2 = 11
    ..init:
        alloc 8 ; atoi_res1 and atoi_res2
    
    ..find_addr:
        push #" "
        loadw hl, (BP), .local16_next_token_ptr
        pushw hl        
        pushw #0
        call strtok
        sub b, #1
        jnz ..error ; expect more tokens, b=1

        ; compute address of atoi_res
        loadw hl, BP
        addw hl, #..local32_atoi_res1
        pushw hl

        ; convert addressing string to int
        call atoi_hex
        popw hl
        sub b, #16
        jnz ..error ; expect 16 bit address
        
    ..find_len:
        call strtok
        test b
        jnz ..error ; expect no more tokens, b = 0

        ; compute address of atoi_res
        loadw hl, BP
        addw hl, #..local32_atoi_res2
        pushw hl

        ; convert addressing string to int
        call atoi_hex
        popw hl
        sub b, #8
        jnz ..error ; expect 8 bit len

        ; load 16 bit address and len
        loadw hl, (BP), ..local32_atoi_res1+2
        pushw hl
        load a, (BP), ..local32_atoi_res2+3
        push a

        ; call uart dump
        call uart_dump_mem
        dealloc 3

        load b, #0
        jmp ..done

    ..error:
        load b, #-1
    ..done:
        dealloc 13
        ret

.print:
    ..local32_atoi_res = 7
    ..init:
        alloc 4 ; atoi_res
    
    ..find_param:
        push #" "
        loadw hl, (BP), .local16_next_token_ptr
        pushw hl        
        pushw #0
        call strtok
        test b
        jnz ..error ; expect last token, b=0

        ; compute address of atoi_res
        loadw hl, BP
        addw hl, #..local32_atoi_res
        pushw hl

        ; convert addressing string to int
        call atoi_hex
        popw hl
        sub b, #16
        jnz ..error ; expect 16 bit address

        ; load 16 bit address
        loadw hl, (BP), ..local32_atoi_res+2
        storew hl, static_uart_print.data_pointer
        call static_uart_print
        call static_uart_print_newline

        load b, #0
        jmp ..done

    ..error:
        load b, #-1
    ..done:
        dealloc 9
        ret


;      _________________________
;   7 |   ..local32_atoi_res    |
;   8 |                         |
;   9 |                         |
;  10 |_________________________|
;  11 |__..local8_delim_char____|
;  12 |..local16_next_token_ptr |
;  13 |_________________________|
;  14 |  ..local16_token_ptr    |
;  15 |_________________________|
.call:
    ..local32_atoi_res = 7
    ..init:
        alloc 4 ; atoi_res
    
    ..find_param:
        push #" "
        loadw hl, (BP), .local16_next_token_ptr
        pushw hl        
        pushw #0
        call strtok
        test b
        jnz ..error ; expect last token, b=0

        ; compute address of atoi_res
        loadw hl, BP
        addw hl, #..local32_atoi_res
        pushw hl

        ; convert addressing string to int
        call atoi_hex
        popw hl
        sub b, #16
        jnz ..error ; expect 16 bit address

        ; load 16 bit address
        loadw hl, (BP), ..local32_atoi_res+2
        
        ; call subroute at address
        call hl

        jmp ..done
    ..error:
        load b, #-1
    ..done:
        dealloc 9
        ret

#include "./char_utils.asm"
#include "./lib_fs.asm"