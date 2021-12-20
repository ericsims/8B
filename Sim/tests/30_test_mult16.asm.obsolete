#include "../CPU.asm"

#bank rom
top:
    ; 0x00 * 0x00 = 0x0000
    sti 0x00, mult_A
    sti 0x00, mult_B
    cal multiply16
    lda mult_res
    tta 0x00
    lda mult_res+1
    tta 0x00
    
    ; 0x01 * 0x00 = 0x0000
    sti 0x01, mult_A
    sti 0x00, mult_B
    cal multiply16
    lda mult_res
    tta 0x00
    lda mult_res+1
    tta 0x00
    
     ; 0x00 * 0x01 = 0x0000   
    sti 0x00, mult_A
    sti 0x01, mult_B
    cal multiply16
    lda mult_res
    tta 0x00
    lda mult_res+1
    tta 0x00
    
    ; 0xFF * 0x01 = 0x00FF   
    sti 0xFF, mult_A
    sti 0x01, mult_B
    cal multiply16
    lda mult_res
    tta 0x00
    lda mult_res+1
    tta 0xFF

    ; 0x12 * 0x34 = 0x03A8   
    sti 0x12, mult_A
    sti 0x34, mult_B
    cal multiply16
    lda mult_res
    tta 0x03
    lda mult_res+1
    tta 0xA8
    
    ; 0xFE * 0xDC = 0xDA48   
    sti 0xFE, mult_A
    sti 0xDC, mult_B
    cal multiply16
    lda mult_res
    tta 0xDA
    lda mult_res+1
    tta 0x48
    
    ; 0xAB * 0xCD = 0x88EF   
    sti 0xAB, mult_A
    sti 0xCD, mult_B
    cal multiply16
    lda mult_res
    tta 0x88
    lda mult_res+1
    tta 0xEF
    
    ; 0xFF * 0xFF = 0xFE01  
    sti 0xFF, mult_A
    sti 0xFF, mult_B
    cal multiply16
    lda mult_res
    tta 0xFE
    lda mult_res+1
    tta 0x01

hlt



#include "../math.asm"