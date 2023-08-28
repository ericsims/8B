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
    ;store a, static_uart_putc.char
    ;call static_uart_putc
    ; instead of calling put c this is faster...
    store a, UART
    
    loadw hl, .data_pointer
    addw hl, #0x01
    storew hl, .data_pointer        
    jmp static_uart_print
    
    .done:
    ret
    
#bank ram
    .data_pointer:  ; pointer to begining of string. MSB, LSB
        #res 2