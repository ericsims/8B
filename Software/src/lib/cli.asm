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
    move .char, UART
    ret

#bank ram
    .char: #res 1 ; char to print to uart


#bank rom
;;
; @function
; @brief print newline '\n' character to UART
; @section description
; static function
;;
static_uart_print_newline:
    ; TODO: check if UART is ready
    store #"\n", UART
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
.loop:
    load a, (hl)
    ; check if char is 0
    test a
    jmz .done
    
    ; put c
    ; TODO: check if UART is ready
    store a, UART
    
    addw hl, #0x01
    jmp .loop
    
    .done:
    ret
    
#bank ram
    .data_pointer: #res 2 ; pointer to begining of string. MSB, LSB

#bank rom
;;
; @function
; @brief print null terminated string to UART
; @section description
; static function
; TODO: this function doesn't check if the UART is ready to send
;;
static_uart_print_len:
    ; load current char
    loadw hl, static_uart_print.data_pointer
    load b, .data_len
.loop:
    load a, (hl)
    ; check if char is 0
    test a
    jmz .done
    test b
    jmz .done
    sub b, #0x01
    
    ; put c
    ; TODO: check if UART is ready
    store a, UART
    
    addw hl, #0x01
    jmp .loop
    
    .done:
    ret
    
#bank ram
    .data_len: #res 1 ; max length

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
    .init:
    __prologue

    .done:
    __epilogue
    ret