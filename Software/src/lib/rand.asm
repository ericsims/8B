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
static_rand_lfsr8_x:
    #res 1
#bank rom
;;
; @function
; @brief sets global static_rand_lfsr8_x with a random number
; @section description
; sets global static_rand_lfsr8_x with a random number
; static_rand_lfsr8_x must be initialized to non-zero seed
;;
static_rand_lfsr8:
.load:
    load a, static_rand_lfsr8_x
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
    store a, static_rand_lfsr8_x
    ret

; rand.asm end