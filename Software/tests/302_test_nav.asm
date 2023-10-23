#include "../src/CPU.asm"

#bank ram

#bank rom
top:
main:
    init_pointers:
        loadw sp, #0xBFFF
        storew #0x0000, BP

    intro: ; print str_1
        storew #str_1, static_uart_print.data_pointer
        call static_uart_print

    get_map:
        call print_map_name

    TODO:
        storew #str_2, static_uart_print.data_pointer
        call static_uart_print

    end:
        halt
; end main


#include "../src/lib/map_utils.asm"

map: #d inchexstr("../lib_dev/Localize/Maps/map.dat")

str_1: #d "This program loads and parses a test map then attempts to find the shortest path using dijkstra's algorithm.\n\0"
str_2: #d "NOT IMPLMENTED!\n\0"
