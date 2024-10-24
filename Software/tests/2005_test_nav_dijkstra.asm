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

    nav: ; 12 --> 18
        push #0x0C
        push #0x12
        call dijkstra
        pop a
        pop a
    
    verify_result: ; [12, 1, 11, 10, 9, 15, 18]
        load a, {path+0}
        assert a, #0x0C
        load a, {path+1}
        assert a, #0x01
        load a, {path+2}
        assert a, #0x0B
        load a, {path+3}
        assert a, #0x0A
        load a, {path+4}
        assert a, #0x09
        load a, {path+5}
        assert a, #0x0F
        load a, {path+6}
        assert a, #0x12
        load a, {path+7}
        assert a, #0xFF

    end:
        halt
; end main



#include "../src/lib/map_utils.asm"
#include "../src/lib/nav_utils.asm"

map: #d inchexstr("../lib_dev/Localize/Maps/map.dat")

