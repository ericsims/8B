    #include "CPU.asm"

; addr = 0xC000 + row/8+col*10; value is in bit 1 << row%8

#bank rom
top:
    cal clear_screen    
    
    ;write_screen_imm 40, 50, 1
    
    ;sti 0, row_num
    ;sti 0, col_num
    
    ;draw:
    ;lda row_num
    ;sta screen.row_num
    ;lda col_num
    ;sta screen.col_num
    ;cal set_screen_bit


    sti16 img_1, show_image.img_ptr
    
    cal show_image

done:
    hlt
    
#bank rom
img_1:
    ;#d8 10,10,  20,20,  30,30,  40,40,  50,50,  60,60,  70,70,  0xFF,0xFF
#d8 3,20, 3,21, 3,22, 3,23, 3,24, 3,25, 3,26, 3,27, 3,28, 3,29, 4,18, 4,19, 4,20, 4,21, 4,22, 4,23, 4,24, 4,25, 4,26, 4,27, 4,28, 4,29, 4,30, 4,31, 5,16, 5,17, 5,18, 5,19, 5,20, 5,29, 5,30, 5,31, 5,32, 5,33, 6,15, 6,16, 6,17, 6,32, 6,33, 6,34, 7,14, 7,15, 7,16, 7,33, 7,34, 7,35, 8,13, 8,14, 8,15, 8,34, 8,35, 8,36, 9,12, 9,13, 9,14, 9,35, 9,36, 9,37, 10,12, 10,13, 10,36, 10,37, 11,11, 11,12, 11,37, 11,38, 12,11, 12,12, 12,19, 12,20, 12,29, 12,30, 12,37, 12,38, 13,10, 13,11, 13,12, 13,18, 13,19, 13,20, 13,21, 13,28, 13,29, 13,30, 13,31, 13,37, 13,38, 13,39, 14,10, 14,11, 14,18, 14,19, 14,20, 14,21, 14,28, 14,29, 14,30, 14,31, 14,38, 14,39, 15,10, 15,11, 15,19, 15,20, 15,29, 15,30, 15,38, 15,39, 16,10, 16,11, 16,38, 16,39, 17,10, 17,11, 17,38, 17,39, 18,10, 18,11, 18,38, 18,39, 19,10, 19,11, 19,38, 19,39, 20,10, 20,11, 20,38, 20,39, 21,10, 21,11, 21,18, 21,19, 21,30, 21,31, 21,38, 21,39, 22,10, 22,11, 22,18, 22,19, 22,30, 22,31, 22,38, 22,39, 23,11, 23,12, 23,18, 23,19, 23,20, 23,29, 23,30, 23,31, 23,37, 23,38, 24,11, 24,12, 24,19, 24,20, 24,21, 24,22, 24,27, 24,28, 24,29, 24,30, 24,37, 24,38, 25,12, 25,13, 25,20, 25,21, 25,22, 25,23, 25,24, 25,25, 25,26, 25,27, 25,28, 25,29, 25,36, 25,37, 26,12, 26,13, 26,14, 26,22, 26,23, 26,24, 26,25, 26,26, 26,27, 26,35, 26,36, 26,37, 27,13, 27,14, 27,15, 27,34, 27,35, 27,36, 28,14, 28,15, 28,16, 28,33, 28,34, 28,35, 29,15, 29,16, 29,17, 29,32, 29,33, 29,34, 30,16, 30,17, 30,18, 30,19, 30,30, 30,31, 30,32, 30,33, 31,18, 31,19, 31,20, 31,21, 31,22, 31,23, 31,24, 31,25, 31,26, 31,27, 31,28, 31,29, 31,30, 31,31, 32,20, 32,21, 32,22, 32,23, 32,24, 32,25, 32,26, 32,27, 32,28, 32,29, 0xFF, 0xFF
    
#bank ram
row_num:
    #res 1
col_num:
    #res 1




#include "math.asm"


; fills entire dpram to 0's
#bank rom
clear_screen:
    sti16 0xC000, .row_ptr
.loop:
    lda .row_ptr+1
    pha
    lda .row_ptr
    pha
    lai 0x00
    ssa
    
    lda .row_ptr+1
    lbi 0x01
    add
    sta .row_ptr+1
    
    jnc .loop
     
    lda .row_ptr
    lbi 0x01
    add
    sta .row_ptr
    
    lbi 0xC4
    sub
    jmn .loop
    
    ret

#bank ram
.row_ptr:
    #res 2

; displays image at pointer, in row,col cooridnates. expectes to be terminated with 0xFF
#bank rom
show_image:
    ; grab row number
    lda .img_ptr+1
    pha
    lda .img_ptr
    pha
    lsa
    sta screen.row_num ; store at row_num
    
    ; check if we have it the end of the image
    lbi 0xFF
    sub
    jmz .done
    
    cal .inc_img_ptr

    ; grab col number
    lda .img_ptr+1
    pha
    lda .img_ptr
    pha
    lsa
    sta screen.col_num ; store at col_num
    
    cal .inc_img_ptr
    
    ;set screen bit on    
    cal set_screen_bit
    
    jmp show_image
    
.done:
    ret
    
    
; sub routine for incrmenting the image pointer
.inc_img_ptr:
    ; inc img_ptr to now point at next item number
    lda .img_ptr+1
    lbi 0x01
    add
    sta .img_ptr+1
    jnc ..skip_img_pointer_carry
    
    lda .img_ptr ; inc img_ptr MSB
    lbi 0x01
    add
    sta .img_ptr
    
..skip_img_pointer_carry:
    ret

#bank ram
.img_ptr: ; address of start of image
    #res 2



#bank rom
set_screen_bit:
    ; calculate address
    cal calculate_pixel_addr
    ; load current value at that address
    lda screen.pixel_ptr+1
    pha
    lda screen.pixel_ptr
    pha
    lsa
    
    ; or with mask
    ldb screen.pixel_mask
    oor
    sta .temp_storeback
    
    ; store back
    lda screen.pixel_ptr+1
    pha
    lda screen.pixel_ptr
    pha
    
    lda .temp_storeback
    ssa
    ret
    
#bank ram
    .temp_storeback:
        #res 1


#bank rom
calculate_pixel_addr:
    ;value=(0x01)<<(row%8), addr= DPRAM + (row)/8+(col)*10
    sti16 DPRAM, screen.pixel_ptr ; save DPRAM starting address
    
    lda screen.row_num
    sta mult_A
    lai 8
    sta mult_B
    cal divide
    ; result is now in mult_res and remainder is now in mult_A 
    lda mult_A
    sta screen.row_remainder
    
    lda mult_res
    ldb screen.pixel_ptr+1
    add
    sta screen.pixel_ptr+1
    
    jnc .skip_MSB_incr_1
    lda 0x01
    ldb screen.pixel_ptr
    add
    sta screen.pixel_ptr
    
.skip_MSB_incr_1:
    
    lda screen.col_num
    sta mult_A
    lai 10
    sta mult_B
    cal multiply16
    ; result is now in mult_res and mult_res+1
    
    lda mult_res+1
    ldb screen.pixel_ptr+1
    add
    sta screen.pixel_ptr+1
    
    jnc .skip_MSB_incr_2
    lda 0x01
    ldb screen.pixel_ptr
    add
    sta screen.pixel_ptr
    
.skip_MSB_incr_2:
    
    lda screen.pixel_ptr
    ldb mult_res
    add
    sta screen.pixel_ptr
       
    ; calculate mask
    sti 0x01, screen.pixel_mask
    
.left_shift:
    lda screen.row_remainder
    lbi 0x01
    sub
    sta screen.row_remainder
    jmn .done_shifting
    
    lda screen.pixel_mask
    rlc
    sta screen.pixel_mask
    jmp .left_shift
    
.done_shifting:
    ret
    

    
screen:
#bank ram
    .row_num:
        #res 1
    .col_num:
        #res 1
    .pixel_ptr:
        #res 2
    .row_remainder:
        #res 1
    .pixel_mask:
        #res 1