; ###
; char_utils.asm begin
; ###

#once

#bank rom

; UART print char
#bank rom
static_uart_putc:
    ; TODO: check if UART is ready
    load a, .char
    store a, UART
    ret
#bank ram
    .char:      ; char to print to uart
        #res 1

; ****************************


; UART print "\n" new line
#bank rom
static_uart_print_newline:
    store #"\n", static_uart_putc.char
    call static_uart_putc
    ret

; ****************************

; UART print "0x" prefix
#bank rom
static_uart_print_hex_prefix:
    store #"0", static_uart_putc.char
    call static_uart_putc
    store #"x", static_uart_putc.char
    call static_uart_putc
    ret

; ****************************




; UART print until '\0'
; TODO: this function doesn't check if the UART is ready to send
#bank rom
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

; ****************************

#bank rom
itoa_hex_nibble:
    ; ******
    ; itoa_hex takes a 1 byte params and converts it to hex char.
    ; contaminates c var with new char
    ; ******

    ;    _______________________
    ; 5 |_______.param8_c_______|
    ; 4 |___________?___________| RESERVED
    ; 3 |___________?___________|    .
    ; 2 |___________?___________|    .
    ; 1 |___________?___________| RESERVED



    .param8_c = 5
    .init:
    __prologue
    ; mask nibble
    __load_local a, .param8_c
    and a, #0x0F
    ; store a, (hl) ; could use __store_local a, .param8_c, but addr still in hl
    ; if .param8_c is >= than 10, handle .hex, otherwise handle DEC
    load b, a
    sub b, #0x0A
    jnc .hex

    .dec:
    add a, #0x30 ; add '0'
    jmp .done
    .hex:
    add a, #(0x41-0x0A) ; add 'A'

    .done:
    store a, (hl)
    __epilogue
; ****************************

#bank rom
uart_print_itoa_hex:
    ; ******
    ; itoa_hex takes a 1 byte param and prints to console.
    ; ******

    ;    _______________________
    ; 5 |_______.param8_c_______|
    ; 4 |___________?___________| RESERVED
    ; 3 |___________?___________|    .
    ; 2 |___________?___________|    .
    ; 1 |___________?___________| RESERVED
    ; 0 |_________~char~________| ephemeral  char passed to itoa_hex_nibble, then discarded



    .param8_c = 5
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
    store a, static_uart_putc.char
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
    store a, static_uart_putc.char
    call static_uart_putc
    .done:
    __epilogue

; ****************************


; ###
; char_utils.asm begin
; ###