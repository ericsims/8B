#include "CPU.asm"

#bank rom
top:
    sti16 str_1, uart_print.data_pointer
    cal uart_println
    
    sti 0x00, counter
loop: ; loop 5 times
    lda counter ; run itoa on counter and store in uitoa_b.buffer
    sta uitoa_b.input_byte
    cal uitoa_b
    
    sti16 loop_str, uart_print.data_pointer  ; print "loop #" 
    cal uart_print
    
    sti16 uitoa_b.buffer, uart_print.data_pointer ; print "[x]\n"
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
    sti16 str_done, uart_print.data_pointer ; print "done!\n"
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
