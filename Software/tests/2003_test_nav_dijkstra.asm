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
 
    nav: ; 7 --> 2
        push #0x07
        push #0x02
        call dijkstra
        pop a
        pop a
    
    verify_result: ; [7, 2]
        load a, {path+0}
        assert a, #0x07
        load a, {path+1}
        assert a, #0x02
        load a, {path+2}
        assert a, #0xFF

    end:
        halt
; end main



#include "../src/lib/map_utils.asm"
#include "../src/lib/nav_utils.asm"

map: #d inchexstr("../lib_dev/Localize/Maps/map.dat")

