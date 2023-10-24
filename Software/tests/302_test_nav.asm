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
 
    nav:
        push #0x07
        push #0x13
        call dijkstra
        pop a
        pop a

    end:
        halt
; end main

dijkstra:
    ; find shortest path using dijkstra's algorithm
    ; takes two params n0 (start node), n1 (end node)
    ; calls get_node
    ;      _______________
    ; 6   |______.n0______|
    ; 5   |______.n1______|
    ; 4   |_______?_______| RESERVED
    ; 3   |_______?_______|    .
    ; 2   |_______?_______|    .
    ; 1   |_______?_______| RESERVED
    ; 0   |______.u_______|
    ;-1   |__.next_node___|
    ;-2   |__.path_index__|
    ;-3   |    dist_0     |
    ;            ...
    ;     |____dist_[SIZE_OF_ARRAYS-1]___|
    ;     |    prev_0     |
    ;            ...
    ;     |____prev_[SIZE_OF_ARRAYS-1]___|
    ;     |    visit_0    |
    ;            ...
    ;     |___visit_[SIZE_OF_ARRAYS-1]___|

    .SIZE_OF_ARRAYS   = 5 ; this needs to be >= to the NUM_NODES in the map, but less than 40ish, so stack manipulation works (i think)  i could probably do this dynamically from the NUM_NODES var
 

    .n0           =  6
    .n1           =  5
    .u            =  0
    .next_node    = -1
    .path_index   = -2
    .dist_start   = -3
    .prev_start   = (.dist_start-.SIZE_OF_ARRAYS)
    .visit_start  = (.dist_start-.SIZE_OF_ARRAYS*2)
    .next_node_x  = (.dist_start-.SIZE_OF_ARRAYS*3) ; unused?
    .next_node_y  = (.next_node_x-1) ; unused?
    .next_node_p0 = (.next_node_x-2)
    .next_node_p1 = (.next_node_x-3)
    .next_node_p2 = (.next_node_x-4)
    .next_node_p3 = (.next_node_x-5)

#bank ram
    .scratch1: #res 2 ; 2 bytes of scratch to use during init
#bank rom

     .init:
        __prologue
        push #0xFF ; u = FF
        push #0xFF ; next_node = FF
        push #0x00 ; path_index = 00
        ; init local arrays to FFs
        store #0x03, .scratch1 ; do this 3 times
        ..do_init:
            load a, .scratch1
            sub a, #0x01
            jmc ..done
            store a, .scratch1
            store #(.SIZE_OF_ARRAYS-1), .scratch1+1
            ...push_zeros:
                push #0xFF
                load a, .scratch1+1
                sub a, #0x01
                jmc ...done_init_zeros
                store a, .scratch1+1
                jmp ...push_zeros
            ...done_init_zeros:
            jmp ..do_init
        ..done:

    ; .test:
    ;     ; this writes a value to local array
    ;     loadw hl, BP
    ;     subw hl, #({.dist_start})*-1
    ;     push #0xAB ; value
    ;     push #0x05 ; index
    ;     storew hl, .scratch1 ; TODO: these two could be pushw hl
    ;     pushw .scratch1
    ;     call set_local_array
    ;     popw hl
    ;     popw hl
        
    .set_start:
        __load_local a, .n0
        __store_local a, .u ; init .u=.n0
        ; set dist[.n0] = 0
        loadw hl, BP
        subw hl, #({.dist_start})*-1
        storew hl, .scratch1 ; TODO: these two could be pushw hl
        push #0x00
        push a
        pushw .scratch1
        call set_local_array
        popw hl
        popw hl
    ; .check_if_we_visted_all_nodes? why is this ncessasay?

    .mark_node_visted:
        loadw hl, BP
        subw hl, #({.visit_start})*-1
        storew hl, .scratch1 ; TODO: these two could be pushw hl
        push #0x0E
        __load_local b, .u
        push b
        pushw .scratch1
        call set_local_array
        popw hl
        popw hl
    .check_done: ; if u == n1
        __load_local a, .n1
        __load_local b, .u
        sub a, b
        jmz .done
    .get_next_nodes:
        pushw #0x0000 ; .x, .y placeholders
        pushw #0x0000 ; .p0, .p1 placeholders
        pushw #0x0000 ; .p2, .p3 placeholders
        push b ; .u, still in b reg
        call get_node
        pop a ; discard node
        ; init path index to 0
        load a, #0x00 ; this could be store #0x00, (hl)
        __store_local a, .path_index
        ..check_valid_node:
            __load_local b, .path_index
            loadw hl, BP
            subw hl, #({.next_node_p0})*-1
            subw hl, b
            load b, (hl)
            load a, b
            store a, .scratch1
            sub b, #0xFF
            jmz ..next_node ; not a valid node
        ..get_dist:
            __load_local a, .u
            push a
            call uart_print_itoa_hex
            
            ;print u --> p
            storew #str_2, static_uart_print.data_pointer
            call static_uart_print

            push .scratch1
            call uart_print_itoa_hex

            call get_distance
            popw hl
            ; distance
            push b
            ; print dist
            storew #str_3, static_uart_print.data_pointer
            call static_uart_print
            call uart_print_itoa_hex
            call static_uart_print_newline
            pop a
            
        ..next_node:
            __load_local b, .path_index
            add b, #0x01
            store b, (hl)
            sub b, #0x04
            jmz ..done_checking_next_nodes
            jmp ..check_valid_node
        ..done_checking_next_nodes:
            popw hl
            popw hl
            popw hl

    .do_something_else:
        halt
    .done:
        ; discard local arrays
        store #0x03, .scratch1 ; do this 3 times
        ..do_init:
            load a, .scratch1
            sub a, #0x01
            jmc ..done
            store a, .scratch1
            store #(.SIZE_OF_ARRAYS-1), .scratch1+1
            ...push_zeros:
                pop a
                load a, .scratch1+1
                sub a, #0x01
                jmc ...done_init_zeros
                store a, .scratch1+1
                jmp ...push_zeros
            ...done_init_zeros:
            jmp ..do_init
        ..done:
        halt
        pop a ; .path_index
        pop a ; .next_node
        pop a ; u
        __epilogue
; end dijkstra


get_array_addr:
    ; helper function that is used by set_local_array and get_local_array
    ; accesses the stack of the calling function!
    .n     = 7
    .start = 6
    #bank ram
    .addr: #res 2 ; 2 bytes of address scratc to make this faster
    #bank rom
    ; store .start addr in .addr
    loadw hl, BP
    addw hl, #.start
    load a, (hl)
    store a, .addr
    subw hl, #0x01
    load a, (hl)
    store a, .addr+1
    
    ; compute offset address
    __load_local b, .n
    loadw hl, .addr
    subw hl, b
    storew hl, .addr
    ret

set_local_array:
    ; sets value in local array
    ; takes .start address, n index, and v value
    ;      _______________
    ; 8   |______.v_______|
    ; 7   |______.n_______|
    ; 6   |    .start     |
    ; 5   |_______________|
    ; 4   |_______?_______| RESERVED
    ; 3   |_______?_______|    .
    ; 2   |_______?_______|    .
    ; 1   |_______?_______| RESERVED

    .v     = 8
    .n     = 7
    .start = 6

    .init:
        __prologue
    .get_array_addr:
        call get_array_addr
    .set_val:
        ; save val
        __load_local a, .v
        loadw hl, get_array_addr.addr
        store a, (hl)

    .done:
        __epilogue
; set_local_array

get_local_array:
    ; gets value in local array
    ; takes .start address, n index, and v value. store value to in
    ;      _______________
    ; 8   |______.v_______|
    ; 7   |______.n_______|
    ; 6   |    .start     |
    ; 5   |_______________|
    ; 4   |_______?_______| RESERVED
    ; 3   |_______?_______|    .
    ; 2   |_______?_______|    .
    ; 1   |_______?_______| RESERVED

    .v     = 8
    .n     = 7
    .start = 6

    .init:
        __prologue
    .get_array_addr:
        call get_array_addr
    .set_val:
        ; save val
        loadw hl, get_array_addr.addr
        load a, (hl)
        __store_local a, .v

    .done:
        __epilogue
; set_local_array

#include "../src/lib/map_utils.asm"

map: #d inchexstr("../lib_dev/Localize/Maps/map.dat")

str_1: #d "This program loads and parses a test map then attempts to find the shortest path using dijkstra's algorithm.\n\0"
str_2: #d " --> \0"
str_3: #d " dist: \0"

