#include "CPU.asm"

#bank rom
top:
    sti string1[7:0], print_uart.data_pointer+1
    sti string1[15:8], print_uart.data_pointer
    cal print_uart
    sti string2[7:0], print_uart.data_pointer+1
    sti string2[15:8], print_uart.data_pointer
    cal print_uart
    sti string3[7:0], print_uart.data_pointer+1
    sti string3[15:8], print_uart.data_pointer
    cal print_uart
    hlt
    
    
# bank rom
string1:
    #d "hello world!\n", 0x00
string2:
    #d "This assembly thing seems to be working!!!\n", 0x00
string3:
    #d "yay.\n", 0x00


#include "math.asm"
#include "utils.asm"
