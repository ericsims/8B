; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

test:
    storew #0x0005, EXT_ROM+1
    load a, EXT_ROM

    halt

    __load_ext_rom a, done

done:
    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"
#ruledef
{
    __load_ext_rom a, {addr: i16} =>
    {
        asm
        {
            storew #{addr}, EXT_ROM+1
            load a, EXT_ROM
        }
    }
}

; global vars
#bank ram
STACK_BASE: #res 0