; ###
; math_ln.asm begin
; ###
#once
#include "math_rev_lut.asm"


#ruledef
{
    call ln => asm
    {
        pushw #lut_ln
        call _rev_lut
        popw hl
    }
}

lut_ln: #d inchexstr("../../lib_dev/Math/rev_lookup_ln.dat")

; ###
; math_ln.asm end
; ###