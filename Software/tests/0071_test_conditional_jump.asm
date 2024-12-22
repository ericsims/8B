;;
; @file
; @author Eric Sims
;
; @section Description
; tests conditional jumps
;
; @section Test Coverage
; @coverage jmz jnz jmc jnc jmn jnn
;
;;

; program entry
#bank rom
top:
    ; ** jmz tests ***
    jmz_true:
        load b, #0x01
        load a, #0x00
        add a, #0x00 ; update flags with add op

        ; jump if zero. should evaluate to "true"
        jmz .a

        ; program should skip this
        load b, #0xFF

        ; program should jump here
        .a:
            assert b, #0x01
        .next:
    
    jmz_false:
        load b, #0x02
        load a, #0x01
        add a, #0x00 ; update flags with add op
        
        ; jump if zero. should evaluate to "false"
        jmz .a

        ; check program did not jump
        assert b, #0x02
        jmp .next

        ; program should NOT jump here
        .a:
            assert b, #0xFF
        .next:
    
    ; ** jnz tests ***
    jnz_true:
        load b, #0x03
        load a, #0x01
        add a, #0x00 ; update flags with add op

        ; jump if not zero. should evaluate to "true"
        jnz .a

        ; program should skip this
        load b, #0xFF

        ; program should jump here
        .a:
            assert b, #0x03
        .next:
    
    jnz_false:
        load b, #0x04
        load a, #0x00
        add a, #0x00 ; update flags with add op
        
        ; jump if not zero. should evaluate to "false"
        jnz .a

        ; check program did not jump
        assert b, #0x04
        jmp .next

        ; program should NOT jump here
        .a:
            assert b, #0xFF
        .next:

    ; ** jmc tests ***
    jmc_true:
        load b, #0x05
        load a, #0xFF
        add a, #0x01 ; update flags with add op

        ; jump if carry. should evaluate to "true"
        jmc .a

        ; program should skip this
        load b, #0xFF

        ; program should jump here
        .a:
            assert b, #0x05
        .next:
    
    jmc_false:
        load b, #0x06
        load a, #0xFF
        add a, #0x00 ; update flags with add op
        
        ; jump if zero. should evaluate to "false"
        jmc .a

        ; check program did not jump
        assert b, #0x06
        jmp .next

        ; program should NOT jump here
        .a:
            assert b, #0xFF
        .next:

    ; ** jnc tests ***
    jnc_true:
        load b, #0x07
        load a, #0xFF
        add a, #0x00 ; update flags with add op

        ; jump if no carry. should evaluate to "true"
        jnc .a

        ; program should skip this
        load b, #0xFF

        ; program should jump here
        .a:
            assert b, #0x07
        .next:

    jnc_false:
        load b, #0x08
        load a, #0xFF
        add a, #0x01 ; update flags with add op
        
        ; jump if no carry. should evaluate to "false"
        jnc .a

        ; check program did not jump
        assert b, #0x08
        jmp .next

        ; program should NOT jump here
        .a:
            assert b, #0xFF
        .next:

    ; ** jmn tests ***
    jmn_true:
        load b, #0x09
        load a, #0x80
        add a, #0x00 ; update flags with add op

        ; jump if negative. should evaluate to "true"
        jmn .a

        ; program should skip this
        load b, #0xFF

        ; program should jump here
        .a:
            assert b, #0x09
        .next:

    jmn_false:
        load b, #0x0A
        load a, #0x7F
        add a, #0x00 ; update flags with add op
        
        ; jump if negative. should evaluate to "false"
        jmn .a

        ; check program did not jump
        assert b, #0x0A
        jmp .next

        ; program should NOT jump here
        .a:
            assert b, #0xFF
        .next:

    ; ** jnn tests ***
    jnn_true:
        load b, #0x0B
        load a, #0x7F
        add a, #0x00 ; update flags with add op

        ; jump if not negative. should evaluate to "true"
        jnn .a

        ; program should skip this
        load b, #0xFF

        ; program should jump here
        .a:
            assert b, #0x0B
        .next:

    jnn_false:
        load b, #0x0C
        load a, #0x80
        add a, #0x00 ; update flags with add op
        
        ; jump if not negative. should evaluate to "false"
        jnn .a

        ; check program did not jump
        assert b, #0x0C
        jmp .next

        ; program should NOT jump here
        .a:
            assert b, #0xFF
        .next:

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
; -- none --