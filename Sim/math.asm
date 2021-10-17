mult_A = 0x8000
mult_B = 0x8001
mult_res = 0x8002

multiply:
    sti, 0x00, mult_res
    lda, mult_B
    jmz, mult_done
    lda, mult_res
    sta, mult_res
mult_run:
    lda, mult_B
    jmz, mult_done
    lda, mult_res
    ldb, mult_A
    add
    sta, mult_res
    lda, mult_B
    lbi, 0x01
    sub
    sta, mult_B
    jmp, mult_run
mult_done:
    ret


divide:
    sti, 0x00, mult_res
    lda, mult_B
    jmz, mult_done
    lda, mult_res
    sta, mult_res
div_run:
    lda, mult_A
    ldb, mult_B
    sub
    jmn, div_done
    sta, mult_A
    lda, mult_res
    lbi, 0x01
    add
    sta, mult_res
    jmp, div_run
div_done:
    ret
