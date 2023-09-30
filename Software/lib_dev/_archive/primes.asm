#include "CPU.asm"

#bank ram
testnum_ptr:
    #res 1
divisor_ptr:
    #res 1

#bank rom

top:
    sti 0x05, testnum_ptr ; load first test number
    
testn:
    lda testnum_ptr
    rrc
    sta divisor_ptr ; set first divisor to half test_num
    
testt:
    lda testnum_ptr
    sta mult_A
    lda divisor_ptr
    sta mult_B
    cal divide ; divide testnum_ptr by divisor_ptr
    lda mult_A ; remainder
    lbi 0x00
    add
    jmz nextn ; if divisor_ptr was a factor jump to next test number
    ;jmp nextt_nd ; otherwise, try the next divisor

nextt_nd:
    lda divisor_ptr
    lbi 0x01
    sub ; subtract 1 from the divisor and store back to divisor_ptr
    sta divisor_ptr
    sub
    jnz testt ; if the divisor is >1 test it
    lda testnum_ptr ; otherwise, we have checked all divisors and the number is prime!
    sta UART ; print it to console
    ;jmp nextn ; then check the next test number

nextn:
    lda testnum_ptr ; incrmente test number by 2 (only odds >2 can be prime)
    lbi 0x02
    add
    jmc hlt ; if we have passed 255, halt the program
    sta testnum_ptr ; store test number
    jmp testn ; test it



hlt:
    hlt
    
    
#include "math.asm"
    
    