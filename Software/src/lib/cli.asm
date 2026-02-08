; ###
; cli.asm begin
; ###

#once


#bank rom
cli_table:
    ; struct
    .CMD_POS = 0
    .HELP_POS = .CMD_POS+2
    .PARAMS_POS = .HELP_POS+2
    .JMP_POS = .PARAMS_POS+1
    ; consts
    .ENTRY_SIZE = .JMP_POS+2
    .NUM_ENTRIES = (._end - cli_table) / .ENTRY_SIZE
    ; entries
    .test1:
        ..cmd_str_ptr: #d16 cli_strings.test1_cmd
        ..help_str_ptr: #d16 cli_strings.test1_help
        ..params: #d8 0
        ..jmp: #d16 test1
    .test2:
        ..cmd_str_ptr: #d16 cli_strings.test2_cmd
        ..help_str_ptr: #d16 cli_strings.test2_help
        ..params: #d8 0
        ..jmp: #d16 test2
    .rtn_code_cmd:
        ..cmd_str_ptr: #d16 cli_strings.rtn_code_cmd
        ..help_str_ptr: #d16 cli_strings.rtn_code_help
        ..params: #d8 0
        ..jmp: #d16 print_return_code
    .help_cmd:
        ..cmd_str_ptr: #d16 cli_strings.help_cmd
        ..help_str_ptr: #d16 cli_strings.help_help
        ..params: #d8 0
        ..jmp: #d16 print_help
    .dump_cmd:
        ..cmd_str_ptr: #d16 cli_strings.dump_cmd
        ..help_str_ptr: #d16 cli_strings.dump_help
        ..params: #d8 2
        ..jmp: #d16 dump
    .print_cmd:
        ..cmd_str_ptr: #d16 cli_strings.print_cmd
        ..help_str_ptr: #d16 cli_strings.print_help
        ..params: #d8 1
        ..jmp: #d16 print
    .read32_cmd:
        ..cmd_str_ptr: #d16 cli_strings.read32_cmd
        ..help_str_ptr: #d16 cli_strings.read32_help
        ..params: #d8 1
        ..jmp: #d16 read32
    .read16_cmd:
        ..cmd_str_ptr: #d16 cli_strings.read16_cmd
        ..help_str_ptr: #d16 cli_strings.read16_help
        ..params: #d8 1
        ..jmp: #d16 read16
    .read8_cmd:
        ..cmd_str_ptr: #d16 cli_strings.read8_cmd
        ..help_str_ptr: #d16 cli_strings.read8_help
        ..params: #d8 1
        ..jmp: #d16 read8
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
    .dump_cmd: #d "DUMP\0"
    .dump_help: #d " <ADDR16> <LEN8> dumps memory at addr of LEN8*16\0"
    .print_cmd: #d "PRINT\0"
    .print_help: #d " <ADDR16> prints null terminated string at address\0"


#bank ram
return_code: #res 1

#bank rom
test1:
    load b, #1
    ret

test2:
    load b, #2
    ret

print_return_code:
    load a, return_code
    push a
    call uart_print_itoa_hex
    pop a
    call static_uart_print_newline
    load b, #0
    ret

;      _______________________
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;   0 |____.local8_cmd_num____|
;   1 |   .local16_tbl_ptr    |
;   2 |_______________________|
print_help:
    .local8_cmd_num = 0
    .local16_tbl_ptr = 1
    .init:
        __prologue
        push #cli_table.NUM_ENTRIES ; start at last entry
        pushw #cli_table._end - cli_table.ENTRY_SIZE ; start at last entry
    
    .print_cmd:
        loadw hl, (BP), .local16_tbl_ptr
        ; addw hl, #cli_table.CMD_POS ; CMD_POS = 0
        #assert(cli_table.CMD_POS == 0) ; check that CMD_POS = 0, to skip computing offset
        loadw hl, (hl)
        storew hl, static_uart_print.data_pointer
        call static_uart_print
        loadw hl, (BP), .local16_tbl_ptr
        addw hl, #cli_table.HELP_POS
        loadw hl, (hl)
        storew hl, static_uart_print.data_pointer
        call static_uart_print
        call static_uart_print_newline
    .search_next_table_entry:
        load a, (BP), .local8_cmd_num
        sub a, #1
        jmz .done
        store a, (BP), .local8_cmd_num
        loadw hl, (BP), .local16_tbl_ptr
        subw hl, #cli_table.ENTRY_SIZE
        storew hl, (BP), .local16_tbl_ptr
        jmp .print_cmd
    .done:
        dealloc 3
        load b, #0
        __epilogue
        ret

read8:
    load b, #-1
    ret

read16:
    load b, #-1
    ret

read32:
    load b, #-1
    ret

dump:
    load b, #-1
    ret

print:
    load b, #-1
    ret

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
;
; @param .param16_string_ptr pointer to string buffer containing commands/params
;;
cli_parse_cmd:
    .param16_string_ptr = -6
    .local8_cmd_num = 0
    .local16_tbl_ptr = 1
    .init:
        __prologue
        push #cli_table.NUM_ENTRIES ; start at last entry
        pushw #cli_table._end - cli_table.ENTRY_SIZE ; start at last entry

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
        load b, #-1
        store b, return_code
        jmp .done
    .cmd_found:
        loadw hl, (BP), .local16_tbl_ptr
        addw hl, #cli_table.JMP_POS
        loadw hl, (hl) ; load hl with the command address
        call hl ; call the subroutine
        store b, return_code ; save off the return code for later
    .done:
        dealloc 3
        __epilogue
        ret

#include "./char_utils.asm"