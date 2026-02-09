; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

    store #0, line_pos

print_boot_msg:
    storew #boot_msg_str, static_uart_print.data_pointer
    call static_uart_print

new_line:
    store #">", static_uart_putc.char
    call static_uart_putc

wait_for_char:
    call uart_getc
    test b
    jmz wait_for_char ; loop if buffer is empty

check_for_newline:
    load a, b
    sub a, #"\n" ; check if this is a newline
    jnz save_char
    call static_uart_print_newline
    ; found a newline char
    loadw hl, #line_buf
    load a, line_pos
    addw hl, a
    store #0, (hl) ; null terminate string
    store #0, line_pos ; reset line buffer
    
call_prog:
    pushw #line_buf
    call cli_parse_cmd
    popw hl
    load a, b
    sub a, #-2 ; command not found
    jmz .cmd_not_found

    load a, b
    sub a, #-1 ; command not found
    jmz .cmd_error
    jmp new_line ; otherwise successful. loop

    .cmd_not_found:
        storew #cmd_not_found_str, static_uart_print.data_pointer
        call static_uart_print
        jmp new_line ; loop
    .cmd_error:
        storew #cmd_error_str, static_uart_print.data_pointer
        call static_uart_print
        jmp new_line ; loop

save_char:
    loadw hl, #line_buf
    load a, line_pos
    addw hl, a
    store b, (hl) ; save char into line_buf

    add a, #1
    store a, line_pos ; increment line_pos

    store b, static_uart_putc.char ; echo character to console
    call static_uart_putc
    jmp wait_for_char ; loop
    ; TODO check line length!

end:
    halt

; constants
boot_msg_str: #d "CLI LOADER V0.1\n\0"
cmd_not_found_str: #d "CMD NOT FOUND\n\0"
cmd_error_str: #d "CMD ERR\n\0"

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"
#include "../src/lib/lib_cli.asm"

; global vars
#bank ram
line_buf: #res 32
line_pos: #res 1
STACK_BASE: #res 0