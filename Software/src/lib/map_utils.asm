; ###
; map_utils.asm begin
; ###

#once

#bank ram
map_utils:
.num_nodes: ; number of nodes in map
    #res 1
.scratch1: ; scrach var used for math
    #res 2

#bank rom

.str_2: #d "Loading map: \0"
.str_5: #d "n: \0"
.str_3: #d " x: \0"
.str_4: #d ", y: \0"

get_num_nodes:
    move map, map_utils.num_nodes ; first byte of map is number of nodes
    ret


get_distance:
    ; gets the distance between two map nodes
    ; dist = sqrt(dx^2+dy^2)
    ; takes two params n0, n1. returns distance in b register
    ; calls get_node
    ;     _______________
    ; 6  |______.n0______|
    ; 5  |______.n1______|
    ; 4  |_______?_______| RESERVED
    ; 3  |_______?_______|    .
    ; 2  |_______?_______|    .
    ; 1  |_______?_______| RESERVED
    ; 0  |_____.x_0______|
    ;-1  |_____.y_0______|
    ;-2  |_____.p0_0_____|
    ;-3  |_____.p1_0_____|
    ;-4  |_____.p2_0_____|
    ;-5  |_____.p3_0_____|
    ;-6  |_____.n_0______|
    ;-7  |_____.x_1______|
    ;-8  |_____.y_1______|
    ;-9  |_____.p0_1_____|
    ;-10 |_____.p1_1_____|
    ;-11 |_____.p2_1_____|
    ;-12 |_____.p3_1_____|
    ;-13 |_____.n_1______|
    ;-14 |     .dx^2     |
    ;-15 |_______________|
    ;-16 |     .dy^2     |
    ;-17 |_______________|
    ;-18 |_____.dist_____|
    ;    |       ~       | additional ephemeral  stack usage for subcalls


    .n0 = 6
    .n1 = 5
    .x_0 = 0
    .y_0 = -1
    .x_1 = -7
    .y_1 = -8
    .dx2 = -14
    .dy2 = -16

    .init:
    __prologue
    pushw #0x0000 ; x_0 = 0, y_0 = 0
    pushw #0x0000 ; p0_0 = 0, p1_0 = 0
    pushw #0x0000 ; p2_0 = 0, p3_0 = 0
    __load_local a, .n0
    push a ; n_0 = n0

    call get_node
    
    pushw #0x0000 ; x_1 = 0, y_1 = 0
    pushw #0x0000 ; p0_1 = 0, p1_1 = 0
    pushw #0x0000 ; p2_1 = 0, p3_1 = 0
    __load_local a, .n1
    push a ; n_1 = n1

    call get_node

    ; ** compute dx^2 **
    __load_local a, .x_0
    __load_local b, .x_1
    ; compute dx=abs(x_0-x_1)
    sub a, b
    store a, static_x_32+3
    call static_abs8
    load a, static_x_32+3
    ; compute dx^2
    push a ; empherial x
    push a ; empherial y
    pushw #map_utils.scratch1 ; empherial desination reg
    call multiply8_fast
    popw hl ; discard scratch 1 pointer
    popw hl ; discard dx and dx
    pushw map_utils.scratch1 ; .dx^2

    ; ** compute dy^2 **
    __load_local a, .y_0
    __load_local b, .y_1
    ; compute dy=abs(y_0-y_1)
    sub a, b
    store a, static_x_32+3
    call static_abs8
    load a, static_x_32+3
    ; compute dy^2
    push a ; empherial x
    push a ; empherial y
    pushw #map_utils.scratch1 ; empherial desination reg
    call multiply8_fast
    popw hl ; discard scratch 1 pointer
    popw hl ; discard dx and dx
    pushw map_utils.scratch1 ; .dy^2

    ; ** compute sqrt(dx^2+dy^2) **
    ; store 0x0000_dx2 to static_x_32
    storew #0x00, static_x_32
    __load_local a, .dx2
    store a, static_x_32+2
    subw hl, #0x01
    load a, (hl)
    store a, static_x_32+3
    ; store 0x0000_dy2 to static_y_32
    storew #0x00, static_y_32
    __load_local a, .dy2
    store a, static_y_32+2
    subw hl, #0x01
    load a, (hl)
    store a, static_y_32+3
    ; compute dist2=dx^2+dy^2
    ; TODO:handle overflow?? or don't and just make sure node positions are low enough values that this doesn't overflow at 16 bit value
    call static_add32
    ; now do sqrt
    push #0x00 ; result placeholder
    pushw static_z_32+2
    call sqrt
    popw hl ; discard input

    .done:
    pop b   ; .distance
    popw hl ; .dy^2
    popw hl ; .dx^2
    pop a   ; .n_1
    popw hl ; .p3_1, .p2_1
    popw hl ; .p1_1, .p0_1
    popw hl ; .y_1, .x_1
    pop a   ; .n_0
    popw hl ; .p3_0, .p2_0
    popw hl ; .p1_0, .p0_0
    popw hl ; .y_0, .x_0
    __epilogue

get_node_ptr:
    ; gets the addresss of a node
    ; takes two params. .n node index, .node_ptr
    ; overwrites .node_ptr with node address
    ; calls ?

    ;    _______________
    ; 7 |   .node_ptr   |
    ; 6 |_______________|
    ; 5 |______.n_______|
    ; 4 |_______?_______| RESERVED
    ; 3 |_______?_______|    .
    ; 2 |_______?_______|    .
    ; 1 |_______?_______| RESERVED
    ;   |       ~       | additional ephemeral  stack usage for subcalls

    .node_ptr = 7
    .n = 5
 
    .init:
    __prologue

    ; multiplying node index by size of nodes
    loadw hl, sp ; save SP to hl
    subw hl, #0x01
    storew hl, map_utils.scratch1
    pushw #0x0000; placeholder result
    __load_local a, .n
    ; load a, map_utils.num_nodes
    push a
    push #0x06
    pushw map_utils.scratch1 
    call multiply8_fast
    pop a   ; discard param
    pop a   ; discard param
    popw hl ; discard param
    ; pop into map_utils.scratch1 to flip endianess
    pop a
    store a, map_utils.scratch1
    pop a
    store a, map_utils.scratch1+1
    loadw hl, map_utils.scratch1
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
    __store_local a, .node_ptr-1


    .done:
    __epilogue


get_node:
    ; gets the details of a node
    ; takes three params. .n0 node index, .x and .y, and .p0-.p3
    ; overwrites .x and .y with node position, and .p0-.p3 with nodes
    ; calls get_node_ptr
    ;    _______________
    ;11 |______.x_______|
    ;10 |______.y_______|
    ; 9 |______.p0______|
    ; 8 |______.p1______|
    ; 7 |______.p2______|
    ; 6 |______.p3______|
    ; 5 |______.n_______|
    ; 4 |_______?_______| RESERVED
    ; 3 |_______?_______|    .
    ; 2 |_______?_______|    .
    ; 1 |_______?_______| RESERVED
    ;   |       ~       | additional ephemeral  stack usage for subcalls

    .x  = 11
    .y  = 10
    .p0 = 9
    .p1 = 8
    .p2 = 7
    .p3 = 6
    .n  = 5

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
    storew hl, map_utils.scratch1

    ; x
    load a, (hl)
    addw hl, #0x01
    storew hl, map_utils.scratch1
    __store_local a, .x
    ; y
    loadw hl, map_utils.scratch1
    load a, (hl)
    addw hl, #0x01
    storew hl, map_utils.scratch1
    __store_local a, .y
    ; p0
    loadw hl, map_utils.scratch1
    load a, (hl)
    addw hl, #0x01
    storew hl, map_utils.scratch1
    __store_local a, .p0
    ; p1
    loadw hl, map_utils.scratch1
    load a, (hl)
    addw hl, #0x01
    storew hl, map_utils.scratch1
    __store_local a, .p1
    ; p2
    loadw hl, map_utils.scratch1
    load a, (hl)
    addw hl, #0x01
    storew hl, map_utils.scratch1
    __store_local a, .p2
    ; p3
    loadw hl, map_utils.scratch1
    load a, (hl)
    __store_local a, .p3

    .done:
    __epilogue


print_nodes:
    ; prints the coordinates of the maps nodes
    ; takes no params. doesnt return anything
    ; calls static_uart_print, uart_print_itoa_hex, static_uart_print_newline

    ;    _______________
    ; 4 |_______?_______| RESERVED
    ; 3 |_______?_______|    .
    ; 2 |_______?_______|    .
    ; 1 |_______?_______| RESERVED
    ; 0 |______.n_______|
    ;-1 |______.x_______|
    ;-2 |______.y_______|
    ;-3 |______.p0______|
    ;-4 |______.p1______|
    ;-5 |______.p2______|
    ;-6 |______.p3______|
    ;   |       ~       | additional ephemeral  stack usage for subcalls

    .n = 0 ; node index
    .x = -1 ; x coord
    .y = -2 ; y coord
    .p0 = -3 ; p0
    .p1 = -4 ; p1
    .p2 = -5 ; p2
    .p3 = -6 ; p3
    __prologue
    .init:
    push #0x00 ; n = 0
    pushw #0x0000 ; x = 0, y = 0
    pushw #0x0000 ; p0 = 0, p1 = 0
    pushw #0x0000 ; p2 = 0, p3 = 0

    .top:
    call get_num_nodes

    .get_coords:
    ; TODO: there is probably a way to do this all on the stack...
    __load_local a, .n
    push a
    call get_node
    pop a

    ; print n: {n} x: {x}, y: {y}
    ; print "n: "
    storew #map_utils.str_5, static_uart_print.data_pointer
    call static_uart_print
    __load_local a, .n
    push a
    call uart_print_itoa_hex
    pop a

    ; print "x: "
    storew #map_utils.str_3, static_uart_print.data_pointer
    call static_uart_print
    __load_local a, .x
    push a
    call uart_print_itoa_hex
    pop a

    ; print "y: "
    storew #map_utils.str_4, static_uart_print.data_pointer
    call static_uart_print
    __load_local a, .y
    push a
    call uart_print_itoa_hex
    pop a

    call static_uart_print_newline

    .check_done:
    ; check if we hit number of nodes
    load a, map_utils.num_nodes
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



print_map_name:
    ; prints the name of the map to the console
    ; takes no params. doesnt return anything
    ; calls multiply8_fast, static_add32, static_uart_print

    ;    _______________
    ; 4 |_______?_______| RESERVED
    ; 3 |_______?_______|    .
    ; 2 |_______?_______|    .
    ; 1 |_______?_______| RESERVED
    ;   |       ~       | additional ephemeral  stack usage for subcalls

    .init:
    __prologue
    .into:
    ; print str_2
    storew #map_utils.str_2, static_uart_print.data_pointer
    call static_uart_print

    .get_name:
    call get_num_nodes
    ; get node_ptr
    pushw #0x0000 ; node_ptr result
    load a, map_utils.num_nodes
    push a
    call get_node_ptr
    pop a
    popw hl
    storew hl, static_uart_print.data_pointer
    call static_uart_print
    call static_uart_print_newline
    __epilogue


#include "./static_math.asm"
#include "./math.asm"
#include "./math_sqrt.asm"
#include "./char_utils.asm"

; ###
; map_utils.asm end
; ###