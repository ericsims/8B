#include "../src/CPU.asm"

#bank ram
path:
    #res (dijkstra.SIZE_OF_ARRAYS+1)

#bank rom
top:
main:
    init_pointers:
        loadw sp, #DEFAULT_STACK
        storew #0x0000, BP

    get_map:
        call print_map_name
 
    nav: ; 13 --> 5
        push #0x0D
        push #0x05
        call dijkstra
        pop a
        pop a
    
    verify_result: ; [13, 14, 4, 20, 21, 10, 9, 3, 7, 0, 6, 5]
        load a, {path+0}
        assert a, #0x0D
        load a, {path+1}
        assert a, #0x0E
        load a, {path+2}
        assert a, #0x04
        load a, {path+3}
        assert a, #0x14
        load a, {path+4}
        assert a, #0x15
        load a, {path+5}
        assert a, #0x0A
        load a, {path+6}
        assert a, #0x09
        load a, {path+7}
        assert a, #0x03
        load a, {path+8}
        assert a, #0x07
        load a, {path+9}
        assert a, #0x00
        load a, {path+10}
        assert a, #0x06
        load a, {path+11}
        assert a, #0x05
        load a, {path+12}
        assert a, #0xFF

    end:
        halt
; end main



#include "../src/lib/map_utils.asm"
#include "../src/lib/nav_utils.asm"

map: #d inchexstr("../lib_dev/Localize/Maps/map.dat")

