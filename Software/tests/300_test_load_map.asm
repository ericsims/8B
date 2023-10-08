#include "../src/CPU.asm"

#bank ram
num_nodes: ; number of nodes in map
    #res 1
scratch1:
    #res 2

#bank rom
top:
init_pointers:
loadw sp, #0xBFFF
storew #0x0000, BP
intro:
; print str_1
storew #str_1, static_uart_print.data_pointer
call static_uart_print

get_num_nodes:
load a, map
store a, num_nodes

call print_map_name

call print_nodes

end:
halt

print_nodes:
    ; prints the coordinates of the maps nodes
    ; takes no params. doesnt return anything
    ; calls ?

    ;    _______________
    ; 4 |_______?_______| RESERVED
    ; 3 |_______?_______|    .
    ; 2 |_______?_______|    .
    ; 1 |_______?_______| RESERVED
    ; 0 |______.n_______|
    ;-1 |   .node_ptr   |
    ;-2 |_______________|
    ;-3 |______.x_______|
    ;-4 |______.y_______|
    ;   |       ~       | additional empherial stack usage for subcalls

    .n = 0 ; node index
    .node_ptr = -1 ; node index
    .x = -3 ; x coord
    .y = -4 ; y coord
    __prologue
    .init:
    push #0x00 ; n = 0
    loadw hl, #map
    addw hl, #0x01
    ; pushw hl ; .node_ptr = map+1
    storew hl, scratch1
    pushw scratch1

    push #0x00 ; x = 0
    push #0x00 ; y = 0

    .top:
    ; TODO

    .get_coords:
    ; TODO: there is probably a way to do this on the stack...
    ; x
    __load_local a, .node_ptr
    store a,  scratch1
    __load_local a, (.node_ptr-1)
    store a,  scratch1+1
    loadw hl, scratch1
    load a, (hl)
    __store_local a, .x
    ; y
    __load_local a, .node_ptr
    store a,  scratch1
    __load_local a, (.node_ptr-1)
    store a,  scratch1+1
    loadw hl, scratch1
    addw hl, #0x01
    load a, (hl)
    __store_local a, .y

    ; print n: {n} x: {x}, y: {y}
    ; print "n: "
    storew #str_5, static_uart_print.data_pointer
    call static_uart_print
    __load_local a, .n
    push a
    call uart_print_itoa_hex
    pop a

    ; print "x: "
    storew #str_3, static_uart_print.data_pointer
    call static_uart_print
    __load_local a, .x
    push a
    call uart_print_itoa_hex
    pop a

    ; print "y: "
    storew #str_4, static_uart_print.data_pointer
    call static_uart_print
    __load_local a, .y
    push a
    call uart_print_itoa_hex
    pop a

    call static_uart_print_newline

    .check_done:
    ; check if we hit number of nodes
    load a, num_nodes
    __load_local b, .n
    sub a, #0x02
    sub a, b
    jmc .done
    ; if not increment .n
    add b, #0x01
    __store_local b, .n
    ; and increment .node_ptr
    __load_local a, .node_ptr
    store a,  scratch1
    __load_local a, (.node_ptr-1)
    store a,  scratch1+1
    loadw hl, scratch1
    addw hl, #0x06
    storew hl, scratch1
    load a,  scratch1
    __store_local a, .node_ptr
    load a,  scratch1+1
    __store_local a, (.node_ptr-1)
    jmp .top


    .done:
    pop a ; discard y
    pop a ; discard x
    popw hl ; discard .node_ptr
    pop a ; discard .n
    __epilogue



print_map_name:
    ; prints the name of the map to the console
    ; takes no params. doesnt return anything
    ; calls multiply8_fast, static_add32, static_uart_print

    ;    _______________
    ; 4 |_______?_______| RESERVED
    ; 3 |_______?_______|    .
    ; 2 |_______?_______|    .
    ; 1 |_______?_______| RESERVED
    ;   |       ~       | additional empherial stack usage for subcalls


    __prologue
    ; print str_2
    storew #str_2, static_uart_print.data_pointer
    call static_uart_print

    ; first find address of name string
    ; multiplying number of nodes by size of nodes
    loadw hl, sp ; save SP to hl
    subw hl, #0x01
    storew hl, scratch1
    pushw #0x0000; placeholder result
    load a, num_nodes
    push a
    push #0x06
    pushw scratch1 
    call multiply8_fast
    pop a   ; discard param
    pop a   ; discard param
    popw hl ; discard param
    ; pop into scratch1 to flip endianess
    pop a
    store a, scratch1
    pop a
    store a, scratch1+1
    loadw hl, scratch1
    ; add offset from start of map
    addw hl, #0x01
    storew #0x0000, static_x_32
    storew hl, static_x_32+2
    storew #0x0000, static_y_32
    storew #map, static_y_32+2
    call static_add32
    loadw hl, static_z_32+2
    ; print string
    storew hl, static_uart_print.data_pointer
    call static_uart_print
    call static_uart_print_newline
    __epilogue

str_1: #d "This program loads and parses a test map\n\0"
str_2: #d "Loading map: \0"
str_5: #d "n: \0"
str_3: #d " x: \0"
str_4: #d ", y: \0"

#include "../src/lib/static_math.asm"
#include "../src/lib/math.asm"
#include "../src/lib/char_utils.asm"

map: #d inchexstr("../lib_dev/Localize/Maps/map.dat")

halt ; dummy halt so i can see how big the program is