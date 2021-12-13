#bits 8

#include "instructions.asm"

#ruledef
{
   
    
    write_screen_imm {row}, {col}, {value} =>
    {
        assert(value >= 0)
        assert(value <= 1)
        assert(row >= 0)
        assert(row <= 80)
        assert(col >= 0)
        assert(col <= 101)
        asm
        {
            sti (value&0x01)<<(row%8), DPRAM + (row)/8+(col)*10
        }
    }
    
    
}

#bankdef ram
{
    #addr 0x8000
    #size 0x4000
}

#bankdef rom
{
    #addr 0x0000
    #size 0x8000
    #outp 0x0000
}

#bank rom

DEFAULT_STACK   = 0xBFFF
DPRAM           = 0xC000
MOT_ENC         = 0xD002
MOT_CTRL        = 0xD003
UART            = 0xD008