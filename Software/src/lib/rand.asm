;;
; @file
; @author Eric Sims
;
; @section description
; pseduo random number generator
;
;;

#once

#bank ram
static_rand_lfsr8_x: #res 1

#bank rom
;;
; @function
; @brief sets lfsr x value with a random number
; @section description
; updates lfsr x value in pointer with psudeorandom number
; psudeorandom number must be initialized to non-zero seed
; also returns value in b register
; @param .param16_inp pointer to lfsr x value
; @return lfsr x
;
;      _______________________
;  -6 |     .param16_inp      |
;  -5 |_______________________|
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;;
rand_lfsr8:
    .param16_inp = -6
    .init:
        __prologue
    .load:
        loadw hl, (BP), .param16_inp
        load a, (hl)
    .xor7: ; rng ^= (rng << 7)
        load b, a
        lshift b
        lshift b
        lshift b
        lshift b
        lshift b
        lshift b
        lshift b
        xor a, b
    .xor5: ; rng ^= (rng >> 5)
        load b, a
        rshift b
        rshift b
        rshift b
        rshift b
        rshift b
        xor a, b
    .xor3: ; rng ^= (rng << 3)
        load b, a
        lshift b
        lshift b
        lshift b
        xor a, b
    .done:
        store a, (hl)
        load b, a
        __epilogue
        ret

; rand.asm end