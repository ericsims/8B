;unsigned itoa for a single byte, base 10
#bank rom
uitoa_b:
    store #0x00, .buffer+0 ; zero out buffer
    store #0x00, .buffer+1
    store #0x00, .buffer+2
    store #0x00, .buffer+3
    store #0x00, .byte_counter ; zero out byte counter

    .digit_loop:
        load a, .input_byte ; 
        store a, mult_A
        store #10, mult_B
        call divide ; divide input_byte by 10. result will be stored to mult_res and remainder in mult_A
        load a, mult_A ; remainder
        load b, #0x30 ; load '0' in ASCII
        add a, b
        store a, mult_A ; use mult_A as scratch registor for ascii representation of remainder
                
        load a, #.buffer[7:0]+3 ; load buffer pointer TODO: this only works if the buffer doesn't cross an 8bit address boundry!!
        load b, .byte_counter
        sub a, b
        push a
        load a, #0x80
        push a
        
        load a, mult_A  ; save ascii encoded remainder to buffer
        popw hl
        store a, (hl)
        ;ssa
        
        load a, .byte_counter ; increment byte counter
        load b, #0x01
        add a, b
        store a, .byte_counter
        
        load a, mult_res ; save devision result back to input_byte and process next digit_loop
        store a, .input_byte
        
        load a, .input_byte; check if input_byte is non-zero
        load b, #0x00
        add a, b
        jmz .break_digit_loop
        
        jmp .digit_loop
        
        
    .break_digit_loop:    
    
    .shift_buffer:
        store #0x00, .shift_counter ; zero out shift counter
        load a, .buffer+0 ; load first byte in buffer
        load b, #0x00
        add a, b
        jnz .done ; if the first byte is non zero, the the buffer is left aligned

        
    .shift_buffer_loop:
        ;save destination ptr to store a,ck
        load a, #.buffer[7:0] ; load buffer pointer TODO: this only works if the buffer doesn't cross an 8bit address boundry!!
        load b, ldb .shift_counter
        add a, b
        push a
        load a, #0x80
        push a
        
        load a, .shift_counter
        load b, #0x01
        add a, b
        store a, .shift_counter
        
        ; save source ptr to store a,ck
        load a, #.buffer[7:0] ; load buffer pointer TODO: this only works if the buffer doesn't cross an 8bit address boundry!!
        load b, .shift_counter
        add a, b
        push a
        load a, #0x80
        push a
        
        popw hl 
        load a, (hl)
        ;lsa ; load buffer[shift_counter+1] to A
        
        popw hl 
        store a, (hl)
        ;ssa ; save buffer[shift_counter+1] to buffer[shift_counter]
        
        load a, .shift_counter
        load b, #0x03
        sub a, b
        jnz .shift_buffer_loop
        
        ; null term
        ;save source ptr to store a,ck
        load a, .buffer[7:0] ; load buffer pointer TODO: this only works if the buffer doesn't cross an 8bit address boundry!!
        load b, .shift_counter
        add a, b
        push a
        load a, #0x80
        push a
        
        load a, #0x00 ; null terminate the string
        popw hl 
        store a, (hl)
        ; ssa
        
        jmp .shift_buffer
    
    .done:
        ret
    
    
#bank ram
    .input_byte:    ; input byte for itoa func
        #res 1
#align 0x800 ; ensure that this buffer is aligned and wont cross an 8bit address boundry until the TODOs above are resolved
    .buffer:        ; return buffer from itoa. maximum length is 4: 3 digits + null term.
        #res 4
    .byte_counter:  ; counter for buffer length, desicribes buffer length including null term.
        #res 1
    .shift_counter: ; internal counter for shifting buffer to be left justified
        #res 1


; UART print char
#bank rom
uart_putc:
    ; TODO: check if UART is ready
    load a, .char
    store a, UART
    ret
    
#bank ram
    .char:      ; char to print to uart
        #res 1


; UART print until '\0'
; TODO: this funciton doesn't check if the UART is ready to send
#bank rom
uart_print:
    load a, .data_pointer+1
    push a
    load a, .data_pointer
    push a
    
    popw hl
    load a, (hl)
    ;lsa
    load b, #0x00
    add a, b
    
    jmz .done
    
    store a, uart_putc.char
    call uart_putc
    
    load a, .data_pointer+1 ; increment data_pointer
    load b, #0x01
    add a, b
    store a, .data_pointer+1
    jnc .pass ; deal with carry for strings that crosses an 8bit address boundry
    load a, .data_pointer
    add a, b
    store a, .data_pointer
    
    .pass:
        
    jmp uart_print
    
    .done:
        ret
    
#bank ram
    .data_pointer:  ; pointer to begining of string. MSB, LSB
        #res 2
        
; UART print until '\0', then print '\n'
; TODO: this funciton doesn't check if the UART is ready to send      
#bank rom
uart_println:
    call uart_print
    store #"\n", uart_putc.char
    call uart_putc
    ret