#include "../src/CPU.asm"

#bank ram
num_nodes: ; number of nodes in map
    #res 1
scratch1:
    #res 2

#bank rom
top:
init_pointers:
loadw sp, #DEFAULT_STACK
storew #0x0000, BP
intro: ; print str_1
storew #str_1, static_uart_print.data_pointer
call static_uart_print

get_num_nodes:
load a, map
store a, num_nodes

call print_map_name

call print_nodes

end:
halt


get_node_ptr:
    ; gets the addresss of a node
    ; takes two params. .n node index, .node_ptr
    ; overwrites .node_ptr with node address
    ; calls ?

    ;     _______________
    ; -7 |   .node_ptr   |
    ; -6 |_______________|
    ; -5 |______.n_______|
    ; -4 |_______?_______| RESERVED
    ; -3 |_______?_______|    .
    ; -2 |_______?_______|    .
    ; -1 |_______?_______| RESERVED
    ;  0 |       ~       | additional ephemeral  stack usage for subcalls

    .node_ptr = -7
    .n = -5
 
    .init:
    __prologue

    ; multiplying node index by size of nodes
    loadw hl, sp ; save SP to hl
    subw hl, #0x01
    storew hl, scratch1
    pushw #0x0000; placeholder result
    __load_local a, .n
    ; load a, num_nodes
    push a
    push #0x06
    pushw scratch1 
    call mult8
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
    ; loadw hl, static_z_32+2
    load a, static_z_32+2
    __store_local a, .node_ptr
    load a, static_z_32+3
    __store_local a, .node_ptr+1


    .done:
    __epilogue
    ret


get_node:
    ; gets the details of a node
    ; takes three params. .n0 node index, .x and .y, and .p0-.p3
    ; overwrites .x and .y with node position, and .p0-.p3 with nodes
    ; calls ?
    ;    _______________
    ;-11 |______.x_______|
    ;-10 |______.y_______|
    ; -9 |______.p0______|
    ; -8 |______.p1______|
    ; -7 |______.p2______|
    ; -6 |______.p3______|
    ; -5 |______.n_______|
    ; -4 |_______?_______| RESERVED
    ; -3 |_______?_______|    .
    ; -2 |_______?_______|    .
    ; -1 |_______?_______| RESERVED
    ;  0  |       ~       | additional ephemeral  stack usage for subcalls

    .x  = -11
    .y  = -10
    .p0 = -9
    .p1 = -8
    .p2 = -7
    .p3 = -6
    .n  = -5

    .init:
    __prologue
    
    .get_ptr:
    ; get node_ptr
    pushw #0x0000 ; node_ptr result
    __load_local a, .n
    push a
    call get_node_ptr
    pop a
    popw hl
    storew hl, scratch1

    ; x
    load a, (hl)
    addw hl, #0x01
    storew hl, scratch1
    __store_local a, .x
    ; y
    loadw hl, scratch1
    load a, (hl)
    addw hl, #0x01
    storew hl, scratch1
    __store_local a, .y
    ; p0
    loadw hl, scratch1
    load a, (hl)
    addw hl, #0x01
    storew hl, scratch1
    __store_local a, .p0
    ; p1
    loadw hl, scratch1
    load a, (hl)
    addw hl, #0x01
    storew hl, scratch1
    __store_local a, .p1
    ; p2
    loadw hl, scratch1
    load a, (hl)
    addw hl, #0x01
    storew hl, scratch1
    __store_local a, .p2
    ; p3
    loadw hl, scratch1
    load a, (hl)
    __store_local a, .p3

    .done:
    __epilogue
    ret


print_nodes:
    ; prints the coordinates of the maps nodes
    ; takes no params. doesnt return anything
    ; calls static_uart_print, uart_print_itoa_hex, static_uart_print_newline

    ;     _______________
    ; -4 |_______?_______| RESERVED
    ; -3 |_______?_______|    .
    ; -2 |_______?_______|    .
    ; -1 |_______?_______| RESERVED
    ;  0 |______.n_______|
    ;  1 |______.x_______|
    ;  2 |______.y_______|
    ;  3 |______.p0______|
    ;  4 |______.p1______|
    ;  5 |______.p2______|
    ;  6 |______.p3______|
    ;    |       ~       | additional ephemeral  stack usage for subcalls

    .n = 0 ; node index
    .x = 1 ; x coord
    .y = 2 ; y coord
    .p0 = 3 ; p0
    .p1 = 4 ; p1
    .p2 = 5 ; p2
    .p3 = 6 ; p3
    __prologue
    .init:
    push #0x00 ; n = 0
    pushw #0x0000 ; x = 0, y = 0
    pushw #0x0000 ; p0 = 0, p1 = 0
    pushw #0x0000 ; p2 = 0, p3 = 0

    .top:

    .get_coords:
    ; TODO: there is probably a way to do this all on the stack...
    __load_local a, .n
    push a
    call get_node
    pop a

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
    jmp .top


    .done:
    popw hl
    popw hl
    popw hl
    pop a
    __epilogue
    ret



print_map_name:
    ; prints the name of the map to the console
    ; takes no params. doesnt return anything
    ; calls mult8, static_uart_print

    ;    _______________
    ; 4 |_______?_______| RESERVED
    ; 3 |_______?_______|    .
    ; 2 |_______?_______|    .
    ; 1 |_______?_______| RESERVED
    ;   |       ~       | additional ephemeral  stack usage for subcalls


    __prologue
    ; print str_2
    storew #str_2, static_uart_print.data_pointer
    call static_uart_print

    ; get node_ptr
    pushw #0x0000 ; node_ptr result
    load a, num_nodes
    push a
    call get_node_ptr
    pop a
    popw hl
    storew hl, static_uart_print.data_pointer
    call static_uart_print
    call static_uart_print_newline
    __epilogue
    ret

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