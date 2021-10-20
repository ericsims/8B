; ###
; math.asm begin
; ###

#bank ram
mult_A:     ; input A, numerator for division. stores remainder after division
    #res 1
mult_B:     ; input B, denominator for division
    #res 1
mult_res:   ; result of multiplcation or division.
    #res 1
    
    
#bank rom
multiply:
    sti 0x00, mult_res
    lda mult_B
    jmz mult_done
    lda mult_res
    sta mult_res
mult_run:
    lda mult_B
    jmz mult_done
    lda mult_res
    ldb mult_A
    add
    sta mult_res
    lda mult_B
    lbi 0x01
    sub
    sta mult_B
    jmp mult_run
mult_done:
    ret


divide:
    sti 0x00, mult_res
    lda mult_B
    jmz mult_done
    lda mult_res
    sta mult_res
div_run:
    lda mult_A
    ldb mult_B
    sub
    jmc div_done ;; jmn
    sta mult_A
    lda mult_res
    lbi 0x01
    add
    sta mult_res
    jmp div_run
div_done:
    ret


; ###
; math.asm end
; ###