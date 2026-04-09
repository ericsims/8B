#once

;;
; @function
; @brief draw a set of points on screen
; @section description
;      _______________________
; -10 |    .param16_color     |
;  -9 |_______________________|
;  -8 |  .param16_list_ptr    |
;  -7 |_______________________|
;  -6 |___.param8_list_len____|
;  -5 |_____.param8_angle_____|
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;   0 |   .local32_line_arr   |
;   1 |                       |
;   2 |                       |
;   4 |_______________________|
;;
#bank rom
draw_2d_points:
    .param16_color = -10
    .param16_list_ptr = -8
    .param8_list_len = -6
    .param8_angle = -5
    .local32_line_arr = 0 
    .init:
        __prologue
        
        loadw hl, (BP), .param16_list_ptr
        storew hl, point_list_ptr

        load a, (BP), .param8_list_len
        store a, point_list_len
    
    .compute_angle:
        load a, (BP), .param8_angle

        pushw #0 ; result
        push a ; angle
        call cos
        pop a ; preserve angle
        popw hl
        storew hl, cosx

        pushw #0 ; result
        push a ; angle
        call sin
        pop a
        popw hl
        storew hl, sinx
    
    .process_points:
        load a, point_list_len
        sub a, #1
        jmc .display_points
        store a, point_list_len

        call ._load_point_temp ; corner 1
        call ._rotate_x_point
        call ._rotate_y_point

        ; center on screen, push point to stack
        loadw hl, point_temp_rotated.x
        addw hl, #TFT_SCREEN_WIDTH/4 - 1
        addw hl, #TFT_SCREEN_WIDTH/4 - 1
        addw hl, #2
        pushw hl

        loadw hl, point_temp_rotated.y
        addw hl, #TFT_SCREEN_HEIGHT/4
        addw hl, #TFT_SCREEN_HEIGHT/4
        pushw hl

        call ._load_point_temp ; corner 2
        call ._rotate_x_point
        call ._rotate_y_point

        ; center on screen, push point to stack
        loadw hl, point_temp_rotated.x
        addw hl, #TFT_SCREEN_WIDTH/4 - 1
        addw hl, #TFT_SCREEN_WIDTH/4 - 1
        addw hl, #2
        pushw hl

        loadw hl, point_temp_rotated.y
        addw hl, #TFT_SCREEN_HEIGHT/4
        addw hl, #TFT_SCREEN_HEIGHT/4
        pushw hl

        call ._load_point_temp ; corner 3
        call ._rotate_x_point
        call ._rotate_y_point

        ; center on screen, push point to stack
        loadw hl, point_temp_rotated.x
        addw hl, #TFT_SCREEN_WIDTH/4 - 1
        addw hl, #TFT_SCREEN_WIDTH/4 - 1
        addw hl, #2
        pushw hl

        loadw hl, point_temp_rotated.y
        addw hl, #TFT_SCREEN_HEIGHT/4
        addw hl, #TFT_SCREEN_HEIGHT/4
        pushw hl

        jmp .process_points

    .display_points:
        ; clear screen
        pushw #0x0000 ; x0
        pushw #0x0000 ; y0
        pushw #TFT_SCREEN_WIDTH ; x1
        pushw #TFT_SCREEN_HEIGHT ; y1
        pushw #COLOR65K_BLACK
        call ra8876_draw_sqaure_fill
        dealloc 10

        load a, (BP), .param8_list_len
        store a, point_list_len

    .draw_point:
        load a, point_list_len
        sub a, #1
        jmc .done
        store a, point_list_len

        ; all three corners still on stack

        loadw hl, (BP), .param16_color
        pushw hl
        call ra8876_draw_triangle
        dealloc 14

        jmp .draw_point

    .done:
        __epilogue
        ret

    ._load_point_temp: ; helper function to load next point from input array to static structure
        loadw hl, point_list_ptr

        ; copy point from list to ram buffer
        load a, (hl)
        store a, point_temp.x
        addw hl, #1
        load a, (hl)
        store a, point_temp.x+1
        addw hl, #1
        load a, (hl)
        store a, point_temp.y
        addw hl, #1
        load a, (hl)
        store a, point_temp.y+1

        addw hl, #1
        storew hl, point_list_ptr
        
        ; invert y
        load a, point_temp.y
        xor a, #0xFF
        store a, point_temp.y
        load a, point_temp.y+1
        xor a, #0xFF
        store a, point_temp.y+1
        loadw hl, point_temp.y
        addw hl, #1
        storew hl, point_temp.y

        ret

    ._rotate_x_point:
        ; x' = point_temp.x * cos(theta) - point_temp.y * sin(theta)
        
        ; point_temp.x * cos(theta)
        alloc 4
        pushw point_temp.x
        pushw cosx
        call mult16
        dealloc 5
        popw hl
        storew hl, temp1
        dealloc 1
        
        ; point_temp.y * sin(theta)
        alloc 4
        pushw point_temp.y
        pushw sinx
        call mult16
        dealloc 5
        popw hl
        storew hl, temp2
        dealloc 1

        ; invert point_temp.y * sin(theta)
        load a, temp2
        xor a, #0xFF
        store a, temp2
        load a, temp2+1
        xor a, #0xFF
        store a, temp2+1
        loadw hl, temp2
        addw hl, #1
        storew hl, temp2

        ; sum
        load a, temp1
        load b, temp2
        add a, b ; msb
        store a, temp1
        
        loadw hl, temp1
        load a, temp2 + 1 ; lsb
        addw hl, a ; add lsb
        storew hl, point_temp_rotated.x

        ret

    ._rotate_y_point:
        ; x' = point_temp.x * sin(theta) + point_temp.y * cos(theta)
        
        ; point_temp.x * sin(theta)
        alloc 4
        pushw point_temp.x
        pushw sinx
        call mult16
        dealloc 5
        popw hl
        storew hl, temp1
        dealloc 1
        
        ; point_temp.y * cos(theta)
        alloc 4
        pushw point_temp.y
        pushw cosx
        call mult16
        dealloc 5
        popw hl
        storew hl, temp2
        dealloc 1

        ; sum
        load a, temp1
        load b, temp2
        add a, b ; msb
        store a, temp1
        
        loadw hl, temp1
        load a, temp2 + 1 ; lsb
        addw hl, a ; add lsb
        storew hl, point_temp_rotated.y

        ret


#bank ram
point_list_ptr: #res 2
point_list_len: #res 1
sinx: #res 2
cosx: #res 2
point_temp:
    .x: #res 2
    .y: #res 2
    .z: #res 2
point_temp_rotated:
    .x: #res 2
    .y: #res 2
    .z: #res 2
temp1: #res 2
temp2: #res 2

#include "lib_math.asm"
#include "lib_math_trig.asm"