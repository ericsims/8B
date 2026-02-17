; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:


    storew #str_init, static_uart_print.data_pointer
    call static_uart_print

    call w5300_init
    assert b, #0

    call print_net_info



    storew #str_connecting_a, static_uart_print.data_pointer
    call static_uart_print
    push conn_ip
    call uart_print_itoa_hex
    pop a
    store #".", static_uart_putc.char
    call static_uart_putc
    push conn_ip+1
    call uart_print_itoa_hex
    pop a
    store #".", static_uart_putc.char
    call static_uart_putc
    push conn_ip+2
    call uart_print_itoa_hex
    pop a
    store #".", static_uart_putc.char
    call static_uart_putc
    push conn_ip+3
    call uart_print_itoa_hex
    pop a
    storew #str_connecting_b, static_uart_print.data_pointer
    call static_uart_print
    pushw conn_port
    call uart_print_itoa_hex16
    popw hl
    storew #str_connecting_c, static_uart_print.data_pointer
    call static_uart_print

    ; for now just hard code using socket 0
    store #Sn_CR_CLOSE, W5300_SOCK0+Sn_CR ; close existing socket if open
    store #Sn_MR1_UDP, W5300_SOCK0+Sn_MR1 ; set mode TCP
    store #Sn_CR_OPEN, W5300_SOCK0+Sn_CR ; open socket
    ; TODO: wait for SSR to go non zero?

    load a, W5300_SOCK0+Sn_SSR1
    assert a, #Sn_SSR1_SOCK_UDP ; SSR should be UDP mode

    ; load ip address
    move conn_ip, W5300_SOCK0+Sn_DIPR0 ; set IP
    move conn_ip+1, W5300_SOCK0+Sn_DIPR1 ; set IP
    move conn_ip+2, W5300_SOCK0+Sn_DIPR2 ; set IP
    move conn_ip+3, W5300_SOCK0+Sn_DIPR3 ; set IP

    movew conn_port, W5300_SOCK0+Sn_DPORTR0; set port

    ; store #Sn_CR_CONNECT, W5300_SOCK0+Sn_CR ; connect

    ; loadw hl, #0
    ; .wait_for_connection:
    ;     load a, W5300_SOCK0+Sn_SSR1
    ;     sub a, #Sn_SSR1_SOCK_ESTABLISHED
    ;     jmz ..connected
    ;     addw hl, #1
    ;     jnc .wait_for_connection
    ;     jmp error_conn_timeout
    ;     ..connected:
    ;         storew #str_connected, static_uart_print.data_pointer
    ;         call static_uart_print


    ; add string to FIFO
    load a, #(conn_string.end-conn_string)
    loadw hl, #conn_string
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
    storew #(conn_string.end-conn_string), W5300_SOCK0+Sn_TX_WRSR2 ; set tx length, without null termination

    store #Sn_CR_SEND, W5300_SOCK0+Sn_CR ; send

    ; .wait_for_data:
    ;     ; check if there is data in RX buffer. Sn_RX_RSR is non-zero
    ;     load a, #0
    ;     load b, W5300_SOCK0+Sn_RX_RSR1
    ;     or a, b
    ;     load b, W5300_SOCK0+Sn_RX_RSR2
    ;     or a, b
    ;     load b, W5300_SOCK0+Sn_RX_RSR3
    ;     or a, b
    ;     test a
    ;     jnz .print_data
        
    ;     ; check if socket has been terminated
    ;     load a, W5300_SOCK0+Sn_SSR1
    ;     sub a, #Sn_SSR1_SOCK_ESTABLISHED
    ;     jnz .closed

    ;     jmp .wait_for_data

    ; .print_data:
    ;     ; there is data
    ;     load a, W5300_SOCK0+Sn_RX_FIFOR0
    ;     store a, static_uart_putc.char
    ;     test a
    ;     jmz .closed ; if received a 0x00
    ;     call static_uart_putc

    ;     load a, W5300_SOCK0+Sn_RX_FIFOR1
    ;     store a, static_uart_putc.char
    ;     test a
    ;     jmz .closed ; if received a 0x00
    ;     call static_uart_putc

    ;     jmp .wait_for_data

    .closed:
        storew #str_done, static_uart_print.data_pointer
        call static_uart_print
        
        store #Sn_CR_CLOSE, W5300_SOCK0+Sn_CR ; close
        halt

error_conn_timeout:
    storew #str_err_timeout, static_uart_print.data_pointer
    call static_uart_print
    store #Sn_CR_CLOSE, W5300_SOCK0+Sn_CR ; close
    load b, #1
    ; assert b, #0
    halt



; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_w5300.asm"

#bank rom
conn_ip: #d8 0, 0, 0, 0 ;  ip addr for example.org
conn_port: #d16 8080 ;  port 80
conn_string: #d "hi to you\n\0"
.end:


str_init: #d "initializing...\n\0"
str_connecting_a: #d "connecting to \0"
str_connecting_b: #d " on port \0"
str_connecting_c: #d "...\n\0"
str_connected: #d "connected\n\0"
str_done: #d "\ndone\n\0"
str_err_timeout: #d "err: connection timeout\n\0"

; global vars
#bank ram
STACK_BASE: #res 1024