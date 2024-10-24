; ###
; char_utils.asm begin
; ###

#once

#bank rom

;;
; @function
; @brief print character to UART
; @section description
; static function
;;
static_uart_putc:
    ; TODO: check if UART is ready
    load a, .char
    store a, UART
    ret

#bank ram
    .char:      ; char to print to uart
        #res 1


#bank rom
;;
; @function
; @brief print newline '\n' character to UART
; @section description
; static function
;;
static_uart_print_newline:
    store #"\n", static_uart_putc.char
    call static_uart_putc
    ret


#bank rom
;;
; @function
; @brief print hex prefix '0x' to UART
; @section description
; static function
;;
static_uart_print_hex_prefix:
    store #"0", static_uart_putc.char
    call static_uart_putc
    store #"x", static_uart_putc.char
    call static_uart_putc
    ret


#bank rom
;;
; @function
; @brief print null terminated string to UART
; @section description
; static function
; TODO: this function doesn't check if the UART is ready to send
;;
static_uart_print:
    ; load current char
    loadw hl, .data_pointer
    load a, (hl)
    ; check if char is 0
    add a, #0x00
    jmz .done
    
    ; put c
    store a, static_uart_putc.char
    call static_uart_putc
    
    ; loadw hl, .data_pointer ; dont need to load again
    addw hl, #0x01
    storew hl, .data_pointer        
    jmp static_uart_print
    
    .done:
    ret
    
#bank ram
    .data_pointer:  ; pointer to begining of string. MSB, LSB
        #res 2


#bank rom
;;
; @function
; @brief converts one nibble of number to string
; @section description
; takes a 1 byte params and converts it to hex char
;     _______________________
; -5 |_______.param8_c_______|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
; @param .param8_c input number
; @return out_char
;;
itoa_hex_nibble:
    .param8_c = -5
    .init:
    __prologue
    ; mask nibble
    load b, (BP), .param8_c
    and b, #0x0F
    ; store a, (hl) ; could use __store_local a, .param8_c, but addr still in hl
    ; if .param8_c is >= than 10, handle .hex, otherwise handle DEC
    load a, b
    sub a, #0x0A
    jnc .hex

    .dec:
    add b, #0x30 ; add '0'
    jmp .done
    .hex:
    add b, #(0x41-0x0A) ; add 'A'

    .done:
    ; result in b register
    __epilogue
    ret


#bank rom
;;
; @function
; @brief prints number to UART in hex format
; @section description
; takes a 1 byte unsigned integer and prints it to UART in hex format
;    _______________________
; -5 |_______.param8_c_______|
; -4 |___________?___________| RESERVED
; -3 |___________?___________|    .
; -2 |___________?___________|    .
; -1 |___________?___________| RESERVED
; @param .param8_c input number
;;
uart_print_itoa_hex:
    .param8_c = -5
    .init:
    __prologue
    .msn:
    ; handle most signifcant nibble
    __load_local a, .param8_c
    ; rshift x4 just keep upper 4 bits
    rshift a
    rshift a
    rshift a
    rshift a
    ; send nibble to itoa_hex_nibble function
    push a
    call itoa_hex_nibble
    ; send ascii char to static_uart_putc function
    pop a
    store b, static_uart_putc.char
    call static_uart_putc
    .lsn:
    ; handle least significan nibble
    __load_local a, .param8_c
    ; send byte to itoa_hex_nibble function
    ; this function already masks for lower 4 bits
    push a
    call itoa_hex_nibble
    ; send ascii char to static_uart_putc function
    pop a
    store b, static_uart_putc.char
    call static_uart_putc
    .done:
    __epilogue
    ret