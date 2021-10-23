#include "CPU.asm"

#bank rom

top:
    sti string[7:0], println.data_pointer+1
    sti string[15:8], println.data_pointer
    cal println
    hlt
    
    

string:
    #d "hello world!\n", 0x00

#include "math.asm"
#include "utils.asm"
