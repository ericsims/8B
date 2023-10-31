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

    get_nodes:
        call print_nodes

    test_distance_func:
        push #0x00
        push #0x03
        call get_distance
        pop a
        pop a
        assert b, #0x25

        push #0x03
        push #0x00
        call get_distance
        pop a
        pop a
        assert b, #0x25

    end:
        halt
; end main


#include "../src/lib/map_utils.asm"

map: #d inchexstr("../lib_dev/Localize/Maps/map.dat")

str_1: #d "This program loads and parses a test map\nThen, it computes some example distances between nodes\0"
