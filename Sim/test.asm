#include "CPU.asm"

#bank rom
top:
    sti str_1[7:0], uart_print.data_pointer+1
    sti str_1[15:8], uart_print.data_pointer
    cal uart_println
    
    sti 0x00, counter
loop: ; loop 5 times
    lda counter ; run itoa on counter and store in uitoa_b.buffer
    sta uitoa_b.input_byte
    cal uitoa_b
    
    sti loop_str[7:0], uart_print.data_pointer+1  ; print "loop #"
    sti loop_str[15:8], uart_print.data_pointer    
    cal uart_print
    
    sti uitoa_b.buffer[7:0], uart_print.data_pointer+1 ; print "[x]\n"
    sti uitoa_b.buffer[15:8], uart_print.data_pointer
    cal uart_println
    
    lai 0x04 ; check if counter has reached 4, jump to done
    ldb counter
    sub
    jmn done
    
    lda counter ; increment counter
    lbi 0x01
    add
    sta counter
    
    jmp loop ; run loop again
    
    
done:
    sti str_done[7:0], uart_print.data_pointer+1 ; print "done!\n"
    sti str_done[15:8], uart_print.data_pointer
    cal uart_println
    
    hlt
    
    
#bank rom
str_1:
    #d "hello world!\nThis assembly thing seems to be working!!!\nyay.", 0x00
str_done:
    #d "done!", 0x00
loop_str:
    #d "loop #", 0x00
    
    
#bank ram
counter:
    #res 1


#include "math.asm"
#include "utils.asm"
