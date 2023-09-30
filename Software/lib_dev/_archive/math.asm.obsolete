; ###
; math.asm begin
; ###

#bank ram
mult_A:     ; input A, numerator for division. stores remainder after division
    #res 1
mult_B:     ; input B, denominator for division
    #res 1
mult_res:   ; result of multiplcation or division.
    #res 2
    
    
#bank rom
multiply:
    sti 0x00, mult_res
.run:
    lda mult_B
    lbi 0x00
    add
    jmz .done
    lda mult_res
    ldb mult_A
    add
    sta mult_res
    
    lda mult_B
    lbi 0x01
    sub
    sta mult_B
    jmp .run
.done:
    ret
    
    
multiply16:
    sti 0x00, mult_res
    sti 0x00, mult_res+1
.run:
    lda mult_B
    lbi 0x00
    add
    jmz .done
    lda mult_res+1
    ldb mult_A
    add
    sta mult_res+1
    
    jnc .skip_carry
    lda mult_res
    lbi 0x01
    add
    sta mult_res
    
.skip_carry:
    lda mult_B
    lbi 0x01
    sub
    sta mult_B
    jmp .run
.done:
    ret


divide:
    sti 0x00, mult_res
    lda mult_B
    lbi 0x00
    add
    jmz .done
.run:
    lda mult_A
    ldb mult_B
    sub
    jmc .done
    sta mult_A
    lda mult_res
    lbi 0x01
    add
    sta mult_res
    jmp .run
.done:
    ret


; ###
; math.asm end
; ###