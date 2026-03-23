; ###
; lib_w5300.asm begin
; ###

#once

; ==========================================
; Mode and Indirect Registers
; ==========================================
W5300_MR0 = ETH + 0x000 ; Mode Register (MSB)
W5300_MR1 = ETH + 0x001 ; Mode Register (LSB)
    W5300_MR1_RST_POS = 7 ; S/W Reset
W5300_IDM_AR0 = ETH + 0x002 ; Indirect Mode Address Registe (MSB)
W5300_IDM_AR1 = ETH + 0x003 ; Indirect Mode Address Registe (LSB)
W5300_IDM_DR0 = ETH + 0x004 ; Indirect Mode Data Register (MSB)
W5300_IDM_DR1 = ETH + 0x005 ; Indirect Mode Data Register (LSB)


; ==========================================
; Common Registers
; ==========================================
W5300_IR0 = ETH + 0x002 ; Interrupt Register (MSB)
W5300_IR1 = ETH + 0x003 ; Interrupt Register (LSB)
W5300_IMR0 = ETH + 0x004 ; Interrupt Mask Register (MSB)
W5300_IMR1 = ETH + 0x005 ; Interrupt Mask Register (LSB)
W5300_SHAR0 = ETH + 0x008 ; Source Hardware Address Register byte 0
W5300_SHAR1 = ETH + 0x009 ; Source Hardware Address Register byte 1
W5300_SHAR2 = ETH + 0x00A ; Source Hardware Address Register byte 2
W5300_SHAR3 = ETH + 0x00B ; Source Hardware Address Register byte 3
W5300_SHAR4 = ETH + 0x00C ; Source Hardware Address Register byte 4
W5300_SHAR5 = ETH + 0x00D ; Source Hardware Address Register byte 5
W5300_GAR0 = ETH + 0x010 ; Gateway Address Registe byte 0
W5300_GAR1 = ETH + 0x011 ; Gateway Address Registe byte 1
W5300_GAR2 = ETH + 0x012 ; Gateway Address Registe byte 2
W5300_GAR3 = ETH + 0x013 ; Gateway Address Registe byte 3
W5300_SUBR0 = ETH + 0x014 ; Subnet Mask Register byte 0
W5300_SUBR1 = ETH + 0x015 ; Subnet Mask Register byte 1
W5300_SUBR2 = ETH + 0x016 ; Subnet Mask Register byte 2
W5300_SUBR3 = ETH + 0x017 ; Subnet Mask Register byte 3
W5300_SIPR0 = ETH + 0x018 ; Source IP Address Register byte 0
W5300_SIPR1 = ETH + 0x019 ; Source IP Address Register byte 1
W5300_SIPR2 = ETH + 0x01A ; Source IP Address Register byte 2
W5300_SIPR3 = ETH + 0x01B ; Source IP Address Register byte 3
W5300_RTR0 = ETH + 0x01C ; Retransmission Timeout-value Register (MSB)
W5300_RTR1 = ETH + 0x01D ; Retransmission Timeout-value Register (LSB)
W5300_RCR1 = ETH + 0x01F ; Retransmission Retry-count Register
W5300_TMSR0 = ETH + 0x020 ; Transmit Memory Size Register of SOCKET0
W5300_TMSR1 = ETH + 0x021 ; Transmit Memory Size Register of SOCKET1
W5300_TMSR2 = ETH + 0x022 ; Transmit Memory Size Register of SOCKET2
W5300_TMSR3 = ETH + 0x023 ; Transmit Memory Size Register of SOCKET3
W5300_TMSR4 = ETH + 0x024 ; Transmit Memory Size Register of SOCKET4
W5300_TMSR5 = ETH + 0x025 ; Transmit Memory Size Register of SOCKET5
W5300_TMSR6 = ETH + 0x026 ; Transmit Memory Size Register of SOCKET6
W5300_TMSR7 = ETH + 0x027 ; Transmit Memory Size Register of SOCKET7
W5300_RMSR0 = ETH + 0x028 ; Receive Memory Size Register of SOCKET0
W5300_RMSR1 = ETH + 0x029 ; Receive Memory Size Register of SOCKET1
W5300_RMSR2 = ETH + 0x02A ; Receive Memory Size Register of SOCKET2
W5300_RMSR3 = ETH + 0x02B ; Receive Memory Size Register of SOCKET3
W5300_RMSR4 = ETH + 0x02C ; Receive Memory Size Register of SOCKET4
W5300_RMSR5 = ETH + 0x02D ; Receive Memory Size Register of SOCKET5
W5300_RMSR6 = ETH + 0x02E ; Receive Memory Size Register of SOCKET6
W5300_RMSR7 = ETH + 0x02F ; Receive Memory Size Register of SOCKET7
W5300_MTYPER0 = ETH + 0x030 ; Memory Block Type Register (MSB)
W5300_MTYPER1 = ETH + 0x031 ; Memory Block Type Register (LSB)
W5300_PATR0 = ETH + 0x032 ; PPPoE Authentication Register (MSB)
W5300_PATR1 = ETH + 0x033 ; PPPoE Authentication Register (LSB)

W5300_IDR0 = ETH + 0x0FE ; W5300 ID Register (MSB)
W5300_IDR1 = ETH + 0x0FF ; W5300 ID Register (LSB)

; ==========================================
; Socket Registers
; ==========================================
W5300_SOCK0 = ETH + 0x200 ; SOCKET 0 base address
W5300_SOCK1 = ETH + 0x240 ; SOCKET 1 base address
W5300_SOCK2 = ETH + 0x280 ; SOCKET 2 base address
W5300_SOCK3 = ETH + 0x2C0 ; SOCKET 3 base address
W5300_SOCK4 = ETH + 0x300 ; SOCKET 4 base address
W5300_SOCK5 = ETH + 0x340 ; SOCKET 5 base address
W5300_SOCK6 = ETH + 0x380 ; SOCKET 6 base address
W5300_SOCK7 = ETH + 0x3C0 ; SOCKET 7 base address
; use this offsets with socket addresss. i.e. W5300_SOCK3+Sn_MR0
Sn_MR0 = 0x000 ; SOCKET Mode Register (MSB)
Sn_MR1 = 0x001 ; SOCKET Mode Register (LSB)
    Sn_MR1_CLOSE = 0x0 ; Closed
    Sn_MR1_TCP = 0x1 ; TCP
    Sn_MR1_UDP = 0x2 ; UDP
    Sn_MR1_IPRAW = 0x3 ; IP RAW
    Sn_MR1_MACRAW = 0x4 ; MAC RAW
    Sn_MR1_PPPoE = 0x5 ; PPPoE
Sn_CR = 0x003 ; SOCKET Command Register
    Sn_CR_OPEN = 0x01 ; It initializes SOCKETn and opens according to protocol type set in Sn_MR(P3:P0)
    Sn_CR_LISTEN = 0x02 ; Only valid in TCP mode. Operates SOCKETn as "TCP SERVER"
    Sn_CR_CONNECT = 0x04 ; Only valid in TCP mode. Operates SOCKETn as "TCP CLIENT"
    Sn_CR_DISCON = 0x08 ; Only valid in TCP mode. Regardless of "TCP SERVER" or “TCP CLINET”, it performs disconnect-process.
    Sn_CR_CLOSE = 0x10 ; closes SOCKETn
    Sn_CR_SEND = 0x20 ; It transmits data as big as the size of Sn_TX_WRSR
    Sn_CR_SEND_MAC = 0x21 ; Valid only in UDP. The basic operation is same as SEND
    Sn_CR_SEND_KEEP = 0x22 ; Valid only in TCP mode. Transmits KEEP ALIVE packet
    Sn_CR_RECV = 0x40 ; It notifies that the host received the data packet of SOCKETn
Sn_IMR1 = 0x005 ; SOCKET Interrupt Mask Register
Sn_IR1 = 0x007 ; SOCKET Interrupt Register
Sn_SSR1 = 0x009 ; SOCKET Status Register
    Sn_SSR1_SOCK_CLOSED = 0x00 ; SOCKETn is released
    Sn_SSR1_SOCK_INIT = 0x13 ; SOCKETn is open as TCP mode
    Sn_SSR1_SOCK_LISTEN = 0x14 ; SOCKETn operates as "TCP SERVER"
    Sn_SSR1_SOCK_ESTABLISHED = 0x17 ; TCP connection is established
    Sn_SSR1_SOCK_CLOSE_WAIT = 0x1C ; disconnect-request(FIN packet) is received from the peer
    Sn_SSR1_SOCK_UDP = 0x22 ; SOCKETn is open as UDP mode
    Sn_SSR1_SOCK_IPRAW = 0x32 ; SOCKETn is open as IPRAW mode
    Sn_SSR1_SOCK_MACRAW = 0x42 ; SOCKETn is open as MACRAW mode
    Sn_SSR1_SOCK_PPPoE = 0x4F ; SOCKETn is open as PPPoE mode
Sn_PORTR0 = 0x00A ; SOCKET Source Port Register (MSB)
Sn_PORTR1 = 0x00B ; SOCKET Source Port Register (LSB)
Sn_DHAR0 = 0x00C ; SOCKET Destination Hardware Address Register
Sn_DHAR1 = 0x00D ; SOCKET Destination Hardware Address Register
Sn_DHAR2 = 0x00E ; SOCKET Destination Hardware Address Register
Sn_DHAR3 = 0x00F ; SOCKET Destination Hardware Address Register
Sn_DHAR4 = 0x010 ; SOCKET Destination Hardware Address Register
Sn_DHAR5 = 0x011 ; SOCKET Destination Hardware Address Register
Sn_DPORTR0 = 0x012 ; SOCKET Destination Port Register (MSB)
Sn_DPORTR1 = 0x013 ; SOCKET Destination Port Register (LSB)
Sn_DIPR0 = 0x014 ; SOCKET Destination IP 
Sn_DIPR1 = 0x015 ; SOCKET Destination IP 
Sn_DIPR2 = 0x016 ; SOCKET Destination IP 
Sn_DIPR3 = 0x017 ; SOCKET Destination IP 
Sn_MSSR0 = 0x018 ; SOCKET Maximum Segment Size (MSB)
Sn_MSSR1 = 0x019 ; SOCKET Maximum Segment Size (LSB)
Sn_KPALVTR = 0x01A ; SOCKET Keep Alive Time Register
Sn_PROTOR = 0x01B ; SOCKET Protocol Number Register
Sn_TOSR1 = 0x01D ; SOCKET TOS Register
Sn_TTLR1 = 0x01F ; SOCKET TTL Register
Sn_TX_WRSR1 = 0x021 ; SOCKET TX Write Size Register
Sn_TX_WRSR2 = 0x022 ; SOCKET TX Write Size Register
Sn_TX_WRSR3 = 0x023 ; SOCKET TX Write Size Register
Sn_TX_FSR1 = 0x025 ; SOCKET TX Free Size Register
Sn_TX_FSR2 = 0x026 ; SOCKET TX Free Size Register
Sn_TX_FSR3 = 0x027 ; SOCKET TX Free Size Register
Sn_RX_RSR1 = 0x029 ; SOCKET RX Receive Size Register
Sn_RX_RSR2 = 0x02A ; SOCKET RX Receive Size Register
Sn_RX_RSR3 = 0x02B ; SOCKET RX Receive Size Register
Sn_FRAGR1 = 0x02D ; SOCKET FLAG Register
Sn_TX_FIFOR0 = 0x02E ; SOCKET TX FIFO Register (MSB)
Sn_TX_FIFOR1 = 0x02F ; SOCKET TX FIFO Register (LSB)
Sn_RX_FIFOR0 = 0x030 ; SOCKET RX FIFO Register (MSB)
Sn_RX_FIFOR1 = 0x031 ; SOCKET RX FIFO Register (LSB)

; ==========================================
; Default Configuration
; ==========================================
MAX_SOCK_NUM = 8 ; configure max number of sockets to support. In therory, the number of sockets can be decreased and buffer sizes increased. keep at 8 for now. 
#bank rom
DEFAULT_MAC: #d8 0x00, 0x08, 0xDC, 0x12, 0x34, 0x56
DEFAULT_IP: #d8 192, 168, 11, 111
DEFAULT_SUBNET: #d8 255, 255, 255, 0
DEFAULT_GATEWAY: #d8 192, 168, 11, 1

#bank ram
w5300_buf: #res 512

#bank rom
w5300_init:

    ; TODO: clear bufs
    ; uint8_t memsize[2][MAX_SOCK_NUM] = {{8, 8, 8, 8, 0, 0, 0, 0}, {8, 8, 8, 8, 0, 0, 0, 0}};

	; for (int8_t i=0; i<MAX_SOCK_NUM; i++) {
	; 	W5300.write_SnTX_SIZE(i, memsize[0][i]);
	; 	W5300.write_SnRX_SIZE(i, memsize[1][i]);
	; }

    store #(1<<W5300_MR1_RST_POS), W5300_MR1 ; soft reset 
    
    nop
    nop
    nop
    nop

    ; check id register IDR = 0x5300
    load a, W5300_IDR0
    sub a, #0x53
    jnz .error
    load a, W5300_IDR1
    sub a, #0x00
    jnz .error

    ; set default mac address
    movew DEFAULT_MAC, W5300_SHAR0
    movew DEFAULT_MAC+2, W5300_SHAR2
    movew DEFAULT_MAC+4, W5300_SHAR4

    ; set default ip address
    movew DEFAULT_IP, W5300_SIPR0
    movew DEFAULT_IP+2, W5300_SIPR2

    ; set default subnet
    movew DEFAULT_SUBNET, W5300_SUBR0
    movew DEFAULT_SUBNET+2, W5300_SUBR2

    ; set default gateway
    movew DEFAULT_GATEWAY, W5300_GAR0
    movew DEFAULT_GATEWAY+2, W5300_GAR2

    .done:
        load b, #0
        ret

    .error:
        load b, #1
        ret

#bank rom
print_net_info:
    .header: ; print header
        storew #.str_network_info, static_uart_print.data_pointer
        call static_uart_print

    .mac: ; print mac address    
        storew #.str_mac, static_uart_print.data_pointer
        call static_uart_print

        load a, W5300_SHAR0
        push a
        call uart_print_itoa_hex
        pop a
        store #":", static_uart_putc.char
        call static_uart_putc
        
        load a, W5300_SHAR1
        push a
        call uart_print_itoa_hex
        pop a
        store #":", static_uart_putc.char
        call static_uart_putc
        
        load a, W5300_SHAR2
        push a
        call uart_print_itoa_hex
        pop a
        store #":", static_uart_putc.char
        call static_uart_putc
        
        load a, W5300_SHAR3
        push a
        call uart_print_itoa_hex
        pop a
        store #":", static_uart_putc.char
        call static_uart_putc
        
        load a, W5300_SHAR4
        push a
        call uart_print_itoa_hex
        pop a
        store #":", static_uart_putc.char
        call static_uart_putc
        
        load a, W5300_SHAR5
        push a
        call uart_print_itoa_hex
        pop a
        call static_uart_print_newline

    .ip: ; print ip address    
        storew #.str_ip, static_uart_print.data_pointer
        call static_uart_print

        load a, W5300_SIPR0
        push a
        call uart_print_itoa_hex
        pop a
        store #".", static_uart_putc.char
        call static_uart_putc
        
        load a, W5300_SIPR1
        push a
        call uart_print_itoa_hex
        pop a
        store #".", static_uart_putc.char
        call static_uart_putc
        
        load a, W5300_SIPR2
        push a
        call uart_print_itoa_hex
        pop a
        store #".", static_uart_putc.char
        call static_uart_putc
        
        load a, W5300_SIPR3
        push a
        call uart_print_itoa_hex
        pop a
        call static_uart_print_newline

    .done:
        ret

    .str_network_info: #d "Net Info\n\0"
    .str_mac: #d "  MAC: \0"
    .str_ip: #d "  IP: \0"

#bank rom
w5300_socket_begin:
    .init:
        __prologue

    ; for now just hard code using socket 0
    store #Sn_CR_CLOSE, W5300_SOCK0+Sn_CR ; close existing socket if open
    store #Sn_MR1_TCP, W5300_SOCK0+Sn_MR1 ; set mode TCP
    store #Sn_CR_OPEN, W5300_SOCK0+Sn_CR ; open socket
    ; TODO: wait for SSR to go non zero?

    ; Test example.org '104.18.2.24' 
    store #104, W5300_SOCK0+Sn_DIPR0 ; set IP
    store #18, W5300_SOCK0+Sn_DIPR1
    store #2, W5300_SOCK0+Sn_DIPR2
    store #24, W5300_SOCK0+Sn_DIPR3

    storew #80, W5300_SOCK0+Sn_DPORTR0; set port

    store #Sn_CR_CONNECT, W5300_SOCK0+Sn_CR ; close existing socket if open

    .done:
        __epilogue
        ret


;;
; @function
; @brief prints ip address to UART in hex format
; @section description
; takes a 4 byte IPv4 address and prints it to UART in hex format
;     _______________________
; -8 |      .param32_ip      |
; -7 |                       |
; -6 |                       |
; -5 |_______________________|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
; @param .param32_ip ip address number
;;
#bank rom
print_ip_addr:
    .param8_c = -8
    .init:
        __prologue

    load a, (BP), .param8_c
    call uart_print_itoa_hex.__msn
    load a, (BP), .param8_c
    call uart_print_itoa_hex.__lsn
    store #".", static_uart_putc.char
    call static_uart_putc

    load a, (BP), .param8_c+1
    call uart_print_itoa_hex.__msn
    load a, (BP), .param8_c+1
    call uart_print_itoa_hex.__lsn
    store #".", static_uart_putc.char
    call static_uart_putc
    
    load a, (BP), .param8_c+2
    call uart_print_itoa_hex.__msn
    load a, (BP), .param8_c+2
    call uart_print_itoa_hex.__lsn
    store #".", static_uart_putc.char
    call static_uart_putc

    load a, (BP), .param8_c+3
    call uart_print_itoa_hex.__msn
    load a, (BP), .param8_c+3
    call uart_print_itoa_hex.__lsn
    
    call static_uart_print_newline

    .done:
        __epilogue
        ret

#include "char_utils.asm"