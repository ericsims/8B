;unsigned itoa for a single byte, base 10
#bank rom
uitoa_b:
    sti 0x00, .buffer+0 ; zero out buffer
    sti 0x00, .buffer+1
    sti 0x00, .buffer+2
    sti 0x00, .buffer+3
    sti 0x00, .byte_counter ; zero out byte counter

    .digit_loop:
        lda .input_byte ; 
        sta mult_A
        sti 10, mult_B
        cal divide ; divide input_byte by 10. result will be stored to mult_res and remainder in mult_A
        lda mult_A ; remainder
        lbi 0x30 ; load '0' in ASCII
        add
        sta mult_A ; use mult_A as scratch registor for ascii representation of remainder
        
        ;sta UART
        
        lai .buffer[7:0]+3 ; load buffer pointer TODO: this only works if the buffer doesn't cross an 8bit address boundry!!
        ldb .byte_counter
        sub
        pha
        lai 0x80
        pha
        
        lda mult_A  ; save ascii encoded remainder to buffer
        ssa
        
        lda .byte_counter ; increment byte counter
        lbi 0x01
        add
        sta .byte_counter
        
        lda mult_res ; save devision result back to input_byte and process next digit_loop
        sta .input_byte
        
        lda .input_byte; check if input_byte is non-zero
        lbi 0x00
        add
        jmz .break_digit_loop
        
        jmp .digit_loop
        
        
    .break_digit_loop:    
    
    .shift_buffer:
        sti 0x00, .shift_counter ; zero out shift counter
        lda .buffer+0 ; load first byte in buffer
        lbi 0x00
        add
        jnz .done ; if the first byte is non zero, the the buffer is left aligned

        
    .shift_buffer_loop:
        ;save destination ptr to stack
        lai .buffer[7:0] ; load buffer pointer TODO: this only works if the buffer doesn't cross an 8bit address boundry!!
        ldb .shift_counter
        add
        pha
        lai 0x80
        pha
        
        lda .shift_counter
        lbi 0x01
        add
        sta .shift_counter
        
        ; save source ptr to stack
        lai .buffer[7:0] ; load buffer pointer TODO: this only works if the buffer doesn't cross an 8bit address boundry!!
        ldb .shift_counter
        add
        pha
        lai 0x80
        pha
        
        lsa ; load buffer[shift_counter+1] to A
        
        ssa ; save buffer[shift_counter+1] to buffer[shift_counter]
        
        lda .shift_counter
        lbi 0x03
        sub
        jnz .shift_buffer_loop
        
        ; null term
        ;save source ptr to stack
        lai .buffer[7:0] ; load buffer pointer TODO: this only works if the buffer doesn't cross an 8bit address boundry!!
        ldb .shift_counter
        add
        pha
        lai 0x80
        pha
        
        lai 0x00 ; null terminate the string
        ssa
        
        jmp .shift_buffer
    
    .done:
        ret
    
    
#bank ram
    .input_byte:    ; input byte for itoa func
        #res 1
    .buffer:        ; return buffer from itoa. maximum length is 4: 3 digits + null term.
        #res 4
    .byte_counter:  ; counter for buffer length, desicribes buffer length including null term.
        #res 1
    .shift_counter: ; internal counter for shifting buffer to be left justified
        #res 1

; UART print until '\0'
; TODO: this funciton doesn't check if the UART is ready to send
#bank rom
uart_print:
    lda .data_pointer+1
    pha
    lda .data_pointer
    pha
    
    lsa
    lbi 0x00
    add
    
    jmz .done
    sta UART
    
    lda .data_pointer+1 ; increment data_pointer
    lbi 0x01
    add
    sta .data_pointer+1
    jnc .pass ; deal with carry for strings that crosses an 8bit address boundry
    lda .data_pointer
    add
    sta .data_pointer
    
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
    cal uart_print
    sti "\n", UART
    ret