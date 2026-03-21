; ###
; lib_dns.asm begin
; ###

#once
#include "lib_w5300.asm"


DNS_PORT = 53

#bank ram
    DNS_IP_ADDRESS: #res 4 ; global IP address of DNS server to use
    DNS_MESSAGE_ID: #res 2 ; unique global DNS message id. increments on each request



;;
; @function dns_init
; @brief inits dns variables
;;
#bank rom
dns_init:
    ; init dns ip address with default
    movew .default_dns_ip, DNS_IP_ADDRESS
    movew .default_dns_ip+2, DNS_IP_ADDRESS+2

    ; init unique DNS message id
    storew #0, DNS_MESSAGE_ID

    ret

.default_dns_ip: #d8 208,67,222,222



;;
; @function
; @brief ?
; @section description
;      _________________________
;  -6 |    .param16_url_ptr     |
;  -5 |_________________________|
;  -4 |____________?____________| RESERVED
;  -3 |____________?____________|    .
;  -2 |____________?____________|    .
;  -1 |____________?____________| RESERVED
;   0 |    .local16_buf_ptr     |
;   1 |_________________________|
;
; @param param16_url_ptr pointer to null terminated url string
;;
#bank rom
dns_lookup:
    .param16_url_ptr = -6
    .local16_buf_ptr = 0
    .init:
        __prologue
        pushw #w5300_buf ; local16_buf_ptr

    .start_udp_conn:
        ; for now just hard code using socket 0
        store #Sn_CR_CLOSE, W5300_SOCK0+Sn_CR ; close existing socket if open
        store #Sn_MR1_UDP, W5300_SOCK0+Sn_MR1 ; set mode TCP
        store #Sn_CR_OPEN, W5300_SOCK0+Sn_CR ; open socket
        ; TODO: wait for SSR to go non zero?

        load a, W5300_SOCK0+Sn_SSR1
        assert a, #Sn_SSR1_SOCK_UDP ; SSR should be UDP mode

        ; load DNS server ip address
        move DNS_IP_ADDRESS, W5300_SOCK0+Sn_DIPR0 ; set IP
        move DNS_IP_ADDRESS+1, W5300_SOCK0+Sn_DIPR1 ; set IP
        move DNS_IP_ADDRESS+2, W5300_SOCK0+Sn_DIPR2 ; set IP
        move DNS_IP_ADDRESS+3, W5300_SOCK0+Sn_DIPR3 ; set IP

        storew #DNS_PORT, W5300_SOCK0+Sn_DPORTR0 ; set port


    .send_query:
        ;    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        ;    |                      ID                       |
        ;    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        ;    |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |
        ;    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        ;    |                    QDCOUNT                    |
        ;    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        ;    |                    ANCOUNT                    |
        ;    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        ;    |                    NSCOUNT                    |
        ;    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        ;    |                    ARCOUNT                    |
        ;    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        ; send 12 byte header
        ; all transfers into FIFO must be 16 bit, MSB first!
        movew DNS_MESSAGE_ID, W5300_SOCK0+Sn_TX_FIFOR0 ; ID
        storew #0x0100, W5300_SOCK0+Sn_TX_FIFOR0 ; flags
        storew #0x0001, W5300_SOCK0+Sn_TX_FIFOR0 ; QDCOUNT (Number of Questions) = 1
        storew #0x0000, W5300_SOCK0+Sn_TX_FIFOR0 ; ANCOUNT (Number of answer RRs) = 0, since this is a query
        storew #0x0000, W5300_SOCK0+Sn_TX_FIFOR0 ; NSCOUNT (Number of authority RRs) = 0, since this is a query
        storew #0x0000, W5300_SOCK0+Sn_TX_FIFOR0 ; ARCOUNT (Number of additional RRs) = 0, since this is a query
        
        ; send query
        ; TODO: query string is hard coded
        store #0x07, W5300_SOCK0+Sn_TX_FIFOR0
        store #"E", W5300_SOCK0+Sn_TX_FIFOR1
        store #"X", W5300_SOCK0+Sn_TX_FIFOR0
        store #"A", W5300_SOCK0+Sn_TX_FIFOR1
        store #"M", W5300_SOCK0+Sn_TX_FIFOR0
        store #"P", W5300_SOCK0+Sn_TX_FIFOR1
        store #"L", W5300_SOCK0+Sn_TX_FIFOR0
        store #"E", W5300_SOCK0+Sn_TX_FIFOR1
        store #0x03, W5300_SOCK0+Sn_TX_FIFOR0
        store #"C", W5300_SOCK0+Sn_TX_FIFOR1
        store #"O", W5300_SOCK0+Sn_TX_FIFOR0
        store #"M", W5300_SOCK0+Sn_TX_FIFOR1
        store #0, W5300_SOCK0+Sn_TX_FIFOR0

        store #0, W5300_SOCK0+Sn_TX_FIFOR1
        store #1, W5300_SOCK0+Sn_TX_FIFOR0
        store #0, W5300_SOCK0+Sn_TX_FIFOR1
        store #1, W5300_SOCK0+Sn_TX_FIFOR0

        
        store #0, W5300_SOCK0+Sn_TX_FIFOR1 ; dummy byte!

        ; storew #0x0001, W5300_SOCK0+Sn_TX_FIFOR0 ; type: TYPE_A
        ; storew #0x0001, W5300_SOCK0+Sn_TX_FIFOR0 ; class: CLASS_IN 


        store #0, W5300_SOCK0+Sn_TX_WRSR1 
        ; TODO: length is hard coded
        storew #29, W5300_SOCK0+Sn_TX_WRSR2 ; set tx length

        store #Sn_CR_SEND, W5300_SOCK0+Sn_CR ; send

    .response:
        loadw hl, #0x0FFF ; timeout duration
        ..wait_for_data:
            subw hl, #1
            jmc .timeout
            ; check if there is data in RX buffer. Sn_RX_RSR is non-zero
            load a, W5300_SOCK0+Sn_RX_RSR1
            load b, W5300_SOCK0+Sn_RX_RSR2
            or a, b
            load b, W5300_SOCK0+Sn_RX_RSR3
            or a, b
            jmz ..wait_for_data

        ..print_data:
            load a, W5300_SOCK0+Sn_RX_FIFOR0
            push a
            call uart_print_itoa_hex
            pop a
            
            store #" ", static_uart_putc.char
            call static_uart_putc

            load a, W5300_SOCK0+Sn_RX_FIFOR1
            push a
            call uart_print_itoa_hex
            pop a
            
            store #" ", static_uart_putc.char
            call static_uart_putc

            load a, W5300_SOCK0+Sn_RX_RSR1
            load b, W5300_SOCK0+Sn_RX_RSR2
            or a, b
            load b, W5300_SOCK0+Sn_RX_RSR3
            or a, b
            jnz ..print_data
        ..end_of_data:
            store #"\n", static_uart_putc.char
            call static_uart_putc


    load b, #0
    .done:
        ; increment global DNS query pointer
        loadw hl, DNS_MESSAGE_ID
        addw hl, #1
        storew hl, DNS_MESSAGE_ID

        ; close socket - not sure this matters for UDP, but we should clean up
        store #Sn_CR_CLOSE, W5300_SOCK0+Sn_CR ; close

        dealloc 2
        __epilogue
        ret

    .timeout:
        storew #.str_query_timeout, static_uart_print.data_pointer
        call static_uart_print

        load b, #-1
        jmp .done

    .str_query_timeout: #d "query timed out!\n \0"