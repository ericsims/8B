#include "CPU.asm"

#bank rom
top:
    store #str_1, uart_print.data_pointer
    call uart_println
    
    store #0x00, counter
loop: ; loop 5 times
    load a, counter ; run itoa on counter and store in uitoa_b.buffer
    store a, uitoa_b.input_byte
    call uitoa_b
    
    store #loop_str, uart_print.data_pointer  ; print "loop #" 
    call uart_print
    
    store #uitoa_b.buffer, uart_print.data_pointer ; print "[x]\n"
    call uart_println
    
    load a, #0x04 ; check if we have finished 5th (index 4) loop, jump to done
    load b, counter
    sub a, b
    jmc done ; does jump carry work intead of jump negative here?
    
    load a, counter ; increment counter
    load b, #0x01
    add a, b
    store a, counter
    
    jmp loop ; run loop again
    
    
done:
    store #str_done, uart_print.data_pointer ; print "done!\n"
    call uart_println
    
    halt
    
    
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
