; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    call init_graphics
    call w5300_init
    call dns_init

    ; call print_net_info

    call get_server_ip

    call get_time

    call parse_time

    call print_time

    halt

init_graphics:
    call ra8876_init

    ; set active window
    pushw #0x0000 ; x
    pushw #0x0000 ; y
    pushw #TFT_SCREEN_WIDTH ; width
    pushw #TFT_SCREEN_HEIGHT ; height
    call ra8876_set_active_window_xywh
    dealloc 8

    ; clear screen
    pushw #0x0000 ; x0
    pushw #0x0000 ; y0
    pushw #TFT_SCREEN_WIDTH ; x1
    pushw #TFT_SCREEN_HEIGHT ; y1
    pushw #COLOR65K_BLACK
    call ra8876_draw_sqaure_fill
    dealloc 10

    ret


get_server_ip:
    __push32 #0 ; placeholder on stack for IP address
    pushw #TIME_API_SERVER
    call dns_lookup
    dealloc 2
    
    ; save IP from stack to global var
    popw hl
    storew hl, server_ip+2
    popw hl
    storew hl, server_ip
    
    ; check return code of dns lookp
    test b
    jnz .error

    ret

    .error:
        push b
        
        storew #.error_str1, static_uart_print.data_pointer
        call static_uart_print

        storew #TIME_API_SERVER, static_uart_print.data_pointer
        call static_uart_print

        storew #.error_str2, static_uart_print.data_pointer
        call static_uart_print

        call uart_print_itoa_hex

        call static_uart_print_newline


        ; return with dns lookup error in b reg
        pop b
        ret

    .error_str1: #d "error looking up \0"
    .error_str2: #d ". returned: \0"


get_time:
    ; for now just hard code using socket 0
    store #Sn_CR_CLOSE, W5300_SOCK0+Sn_CR ; close existing socket if open
    store #Sn_MR1_TCP, W5300_SOCK0+Sn_MR1 ; set mode TCP
    store #Sn_CR_OPEN, W5300_SOCK0+Sn_CR ; open socket
    ; TODO: wait for SSR to go non zero?

    load a, W5300_SOCK0+Sn_SSR1
    assert a, #Sn_SSR1_SOCK_INIT ; SSR should be TCP mode

    ; load ip address
    move server_ip, W5300_SOCK0+Sn_DIPR0 ; set IP
    move server_ip+1, W5300_SOCK0+Sn_DIPR1 ; set IP
    move server_ip+2, W5300_SOCK0+Sn_DIPR2 ; set IP
    move server_ip+3, W5300_SOCK0+Sn_DIPR3 ; set IP

    storew #80, W5300_SOCK0+Sn_DPORTR0; set port

    store #Sn_CR_CONNECT, W5300_SOCK0+Sn_CR ; connect

    loadw hl, #0
    .wait_for_connection:
        load a, W5300_SOCK0+Sn_SSR1
        sub a, #Sn_SSR1_SOCK_ESTABLISHED
        jmz ..connected
        addw hl, #1
        jnc .wait_for_connection
        jmp .error_conn_timeout
        ..connected:
            storew #.str_connected, static_uart_print.data_pointer
            call static_uart_print


    ; add string to FIFO
    load a, #(.conn_string.end-.conn_string)
    loadw hl, #.conn_string
    .copy:
        load b, (hl)
        store b, W5300_SOCK0+Sn_TX_FIFOR0
        addw hl, #1
        load b, (hl)
        store b, W5300_SOCK0+Sn_TX_FIFOR1
        addw hl, #1
        sub a, #2
        jnc .copy

    store #0, W5300_SOCK0+Sn_TX_WRSR1 
    storew #(.conn_string.end-.conn_string), W5300_SOCK0+Sn_TX_WRSR2 ; set tx length, without null termination

    store #Sn_CR_SEND, W5300_SOCK0+Sn_CR ; send


    loadw hl, #response_buffer ; init pointer to buf in hl reg

    .wait_for_data:
        ; check if there is data in RX buffer. Sn_RX_RSR is non-zero
        load a, #0
        load b, W5300_SOCK0+Sn_RX_RSR1
        or a, b
        load b, W5300_SOCK0+Sn_RX_RSR2
        or a, b
        load b, W5300_SOCK0+Sn_RX_RSR3
        or a, b
        test a
        jnz .save_data
        
        ; check if socket has been terminated
        load a, W5300_SOCK0+Sn_SSR1
        sub a, #Sn_SSR1_SOCK_ESTABLISHED
        jnz .closed

        jmp .wait_for_data

    .save_data:
        ; there is data
        load a, W5300_SOCK0+Sn_RX_FIFOR0
        store a, (hl)
        ; store a, static_uart_putc.char
        test a
        jmz .closed ; if received a 0x00
        addw hl, #1

        ; call static_uart_putc

        load a, W5300_SOCK0+Sn_RX_FIFOR1
        store a, (hl)
        ; store a, static_uart_putc.char
        test a
        jmz .closed ; if received a 0x00
        ; call static_uart_putc
        addw hl, #1

        jmp .wait_for_data

    .closed:
        storew #.str_done, static_uart_print.data_pointer
        call static_uart_print
        
        store #Sn_CR_CLOSE, W5300_SOCK0+Sn_CR ; close
        ret

    .error_conn_timeout:
        storew #.str_err_timeout, static_uart_print.data_pointer
        call static_uart_print
        store #Sn_CR_CLOSE, W5300_SOCK0+Sn_CR ; close
        load b, #1
        ; assert b, #0
        ret

    .str_connected: #d "connected\n\0"
    .str_done: #d "\ndone\n\0"
    .str_err_timeout: #d "err: connection timeout\n\0"
    .conn_string: #d "GET /api/json/est/now HTTP/1.1\nAccept: application/json\nHost:worldclockapi.com\nConnection: close\n\n"
    ..end:


parse_time:
    .find_body:
        loadw hl, #response_buffer ; init pointer to buf in hl reg
        ..loop:
            storew hl, response_start_of_body
            load a, (hl)
            test a
            jmz .done ; reached end of string before finding json body
            
            sub a, #"{"
            jmz .parse_json
            addw hl, #1
            jmp ..loop
    
    .parse_json:
        pushw response_start_of_body
        pushw #.str_currentDateTime
        pushw #json_key_buf
        pushw #json_value_buf
        call json_parse
        dealloc 8
        assert b, #1 ; expecting a string

    .done:
        ret
    
    .str_currentDateTime: #d ".currentDateTime\0"


print_time:
    pushw #400
    pushw #200
    call ra8876_set_text_cursor_pos
    dealloc 4

    pushw #APP_COLOR_GREEN
    call ra8876_set_foreground_color_16bpp
    dealloc 2
    
    call ra8876_enable_text_mode
    call ra8876_text_chroma_key_enable
    call ra8876_set_text_size_32

    pushw #json_value_buf
    call ra8876_put_string
    dealloc 2

    call ra8876_enable_graphics_mode

    ret

; constants
APP_COLOR_GREEN = 0x4669
APP_COLOR_YELLOW = 0xDE60
BORDER_PIXEL_WIDTH = 8
BORDER_PIXEL_HEIGHT = 8
TIME_API_SERVER: #d "worldclockapi.com\0"

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"
#include "../src/lib/lib_ra8876.asm"
#include "../src/lib/lib_W5300.asm"
#include "../src/lib/lib_dns.asm"
#include "../src/lib/json_parse.asm"

; global vars
#bank ram
server_ip: #res 4
response_buffer: #res 1024
response_start_of_body: #res 2
json_key_buf: #res 128
json_value_buf: #res 128
STACK_BASE: #res 0