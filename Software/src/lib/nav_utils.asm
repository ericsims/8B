; ###
; nav_utils.asm begin
; ###

#once

#bank rom

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

    .SIZE_OF_ARRAYS   = 40 ; this needs to be >= to the NUM_NODES in the map, but less than 40ish, so stack manipulation works (i think)  i could probably do this dynamically from the NUM_NODES var
 

    .n0            =  6
    .n1            =  5
    .u             =  0
    .next_node     = -1
    .path_index    = -2
    .dist_start    = -3
    .prev_start    = (.dist_start-.SIZE_OF_ARRAYS)
    .visit_start   = (.dist_start-.SIZE_OF_ARRAYS*2)
    .next_node_x   = (.dist_start-.SIZE_OF_ARRAYS*3)  ; unused
    .next_node_y   = (.next_node_x-1)                 ; unused
    .next_node_p0  = (.next_node_x-2)
    .next_node_p1  = (.next_node_x-3)
    .next_node_p2  = (.next_node_x-4)
    .next_node_p3  = (.next_node_x-5)

    .smallest_dist = (.dist_start-.SIZE_OF_ARRAYS*3)

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
        
    .set_start:
        __load_local b, .n0
        __store_local b, .u ; init .u=.n0
        ; set dist[.n0] = 0
        loadw hl, BP
        subw hl, #({.dist_start})*-1
        subw hl, b
        load a, #0x00
        store a, (hl)
    ; .check_if_we_visted_all_nodes? why is this ncessasay?

    .mark_node_visted:
        ; set visit[.u] = 0x0E
        __load_local b, .u
        loadw hl, BP
        subw hl, #({.visit_start})*-1
        subw hl, b
        load a, #0x0E
        store a, (hl)
    .check_done: ; if u == n1
        __load_local a, .n1
        __load_local b, .u
        sub a, b
        jmz .reconstruct
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
            __store_local b, .next_node
            sub b, #0xFF
            jmz ..next_node ; not a valid node
        ..get_dist:
            __load_local a, .u
            push a
            ; call uart_print_itoa_hex
            
            ; print u --> p
            ; storew #str_2, static_uart_print.data_pointer
            ; call static_uart_print

            __load_local a, .next_node
            push a
            ; call uart_print_itoa_hex

            call get_distance ; dist_to_next_node = sqrt((.u.x-.p.x)^2+(.u.y-.p.y)^2)
            popw hl
            ; distance
            push b
            ; print dist
            ; storew #str_3, static_uart_print.data_pointer
            ; call static_uart_print
            ; call uart_print_itoa_hex
            ; call static_uart_print_newline

            ...next_dist:
                ; next_dist = dist[.u] + dist_to_next_node
                __load_local b, .u
                loadw hl, BP
                subw hl, #({.dist_start})*-1
                subw hl, b
                load a, (hl)
                pop b
                add a, b
                jmc .error ;
                store a, .scratch1 ; next_dist in .scratch1

                ; if dist[next_node] == 0xFF || next_dist < dist[next_node] ...\
                ; start by saving dist[next_node], since its needed twice
                __load_local b, .next_node
                loadw hl, BP
                subw hl, #({.dist_start})*-1
                subw hl, b
                load a, (hl)
                store a, .scratch1+1 ; dist[next_node] in .scratch1+1

                ; if dist[next_node] == 0xFF
                ; do i actaully need this? isnt next_dist always < FF?
                ; sub a, #0xFF
                ; jmz ...do_update

                ; or if next_dist < dist[next_node]
                load a, .scratch1
                load b, .scratch1+1
                sub a, b
                jmc ...do_update
                jmp ...done_with_dist

            ...do_update:
                ; dist[next_node] = next_dist
                load a, .scratch1
                __load_local b, .next_node
                loadw hl, BP
                subw hl, #({.dist_start})*-1
                subw hl, b
                store a, (hl)
                ; prev[next_node] = .u
                __load_local a, .u
                __load_local b, .next_node
                loadw hl, BP
                subw hl, #({.prev_start})*-1
                subw hl, b
                store a, (hl)
            ...done_with_dist:
            
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

    .check_closest_node:
        ; print "fiding next node"
        ; storew #str_4, static_uart_print.data_pointer
        ; call static_uart_print
        ..init:
            ; i = 0
            ; smallest_distance = FF
            push #0xFF; smallest_distance = FF
            store #0x00, .scratch1 ; i = 0
            ; using.smallest_dist as well
        ; for i in NUM_NODES, (or just skip unused notes in destance)
        ..check_valid:
            ; print current node
            ; load b, .scratch1
            ; push b
            ; call uart_print_itoa_hex
            ; pop b
            ; store #" ", static_uart_putc.char
            ; call static_uart_putc

            ; if visit[i] == 0x0E continue, this node is already visted
            load a, #0x0E
            load b, .scratch1
            loadw hl, BP
            subw hl, #({.visit_start})*-1
            subw hl, b
            load b, (hl)
            sub a, b
            jmz ..continue
            ; if dist[i] == 0xFF continue this distnace hasn't be checked
            load a, #0xFF
            addw hl, #(.SIZE_OF_ARRAYS*2) ; load dist[i], which is a fixed offset from visit[i]
            load b, (hl)
            store b, .scratch1+1 ; save dist[i] for later use in .scratch1+1
            sub a, b
            jmz ..continue

            ; push b
            ; call uart_print_itoa_hex
            ; pop b

            ; if smallest_distance == 0xFF, or dist[i] < smallest_distance
            ; actually since smallest_dist is init to 0xFF, the '<' comparison is enough
            load a, .scratch1+1;perhaps this is already in b reg?
            __load_local b, .smallest_dist
            sub a, b
            jmc ..do_update
            jmp ..continue
            ..do_update:
            ; smallest_distance = dist[i] (set smallest dist)
            load b, .scratch1+1
            __store_local b, .smallest_dist
            ; u = i (jump to next node)
            load a, .scratch1
            __store_local a, .u
        ..continue:
            ; __load_local a, .smallest_dist
            ; push a
            ; call uart_print_itoa_hex
            ; pop a
            ; call static_uart_print_newline

            load a, .scratch1
            add a, #0x01
            store a, .scratch1
            load b, map_utils.num_nodes
            sub a, b
            jmz ..done
            jmp ..check_valid
        ..done:
            __load_local b, .u ; b = .u (next node)
            pop a ; a = shortest_dist
            jmp .mark_node_visted
    .reconstruct:
        ; reconstruct path backwards from destination to start
        ..clear:
            ; clear visited array to reuse for reversing the path.
            load b, #(.SIZE_OF_ARRAYS-1)
            loadw hl, BP
            subw hl, #({.visit_start})*-1
            subw hl, b
            store b, .scratch1+1
            ...update_data:
                load a, #0xFF
                store a, (hl)
                addw hl, #0x01
                sub b, #0x01
                jnz ...update_data
        ..reverse:
        ..next_node:
            ; a = .u
            __load_local a, .u
            ; save a to array in reverse order
            loadw hl, BP
            subw hl, #({.visit_start})*-1
            load b, .scratch1+1
            subw hl, b
            store a, (hl)
            ; decrement counter and save for next loop
            sub b, #0x01
            store b, .scratch1+1
            ; print path
            ; push a
            ; call uart_print_itoa_hex
            ; pop b
            load b, a ; comment this out if printing path!!
            loadw hl, BP
            subw hl, #({.prev_start})*-1
            subw hl, b
            load a, (hl) ; a = prev[.u]
            load b, a
            sub a, #0xFF
            jmz ..done_pushing_path
            __store_local b, .u
            
            ; print path in reverse order
            ; storew #str_5, static_uart_print.data_pointer
            ; call static_uart_print

            jmp ..next_node
        ..done_pushing_path:
            ; call static_uart_print_newline

        ..save_reverse_order:
            ; destination offset
            store #0x00, .scratch1
            ; source array offset still in .scratch+1
            load b, .scratch1+1
            add b, #0x01
            store b, .scratch1+1
            
            ...save_byte:
            ; check if done
            load b, .scratch1+1 
            sub b, #(.SIZE_OF_ARRAYS)
            jmz ..done_reversing

            ; get source byte
            loadw hl, BP
            subw hl, #({.visit_start})*-1
            load b, .scratch1+1
            subw hl, b
            load a, (hl)
            ; increment counter and save for next loop
            add b, #0x01
            store b, .scratch1+1

            ; save byte to destination
            loadw hl, #path
            load b, .scratch1
            addw hl, b
            store a, (hl)
            ; increment counter and save for next loop
            add b, #0x01
            store b, .scratch1

            jmp ...save_byte

        ..done_reversing:
            ; save terminating 0xFF byte to destination
            loadw hl, #path
            load b, .scratch1
            addw hl, b
            load a, #0xFF
            store a, (hl)
           
    .done:
        ; discard local arrays
        store #0x03, .scratch1 ; do this 3 times
        ..do_free:
            load a, .scratch1
            sub a, #0x01
            jmc ..done
            store a, .scratch1
            store #(.SIZE_OF_ARRAYS-1), .scratch1+1
            ...pop_data:
                pop a
                load a, .scratch1+1
                sub a, #0x01
                jmc ...done_free
                store a, .scratch1+1
                jmp ...pop_data
            ...done_free:
                jmp ..do_free
        ..done:
        pop a ; .path_index
        pop a ; .next_node
        pop a ; u
        __epilogue
        ret
    
    .error: ; error. call this if there is an error to halt
        load a, #0x00
        assert a, #0xFF
        halt
; end dijkstra
; dijkstra strings
; str_1: #d "This program loads and parses a test map then attempts to find the shortest path using dijkstra's algorithm.\n\0"
; str_2: #d " --> \0"
; str_3: #d " dist: \0"
; str_4: #d "finding next node...\n\0"
; str_5: #d " <-- \0"

; #include "./char_utils.asm"

; ###
; nav_utils.asm end
; ###