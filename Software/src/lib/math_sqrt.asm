; ###
; math_sqrt.asm begin
; ###
#once
#include "math_rev_lut.asm"


#ruledef
{
    call sqrt => asm
    {
        pushw #lut_sqrt
        call _rev_lut
        popw hl
    }
}

lut_sqrt: #d inchexstr("../../lib_dev/Math/rev_lookup_sqrt.dat")

; ###
; math_sqrt.asm end
; ###