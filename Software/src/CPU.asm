#once
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
    

    ; calling convetion
    __prologue => asm
    {
        ; prologue 
        pushw BP ; save old base pointer to stack
        loadw hl, sp ; save SP to base pointer
        storew hl, BP
    }

    __epilogue => asm
    {
        ; epilogue
        popw hl ; restore old base pointer
        storew hl, BP
        ret
    }
; loads
    __load_local a, {index: i8} =>
    {
        assert(index == 0)
        asm
        {
            load a, (BP)
        }
    }
    __load_local a, {index: i8} =>
    {
        assert(index < 0)
        asm
        {
            loadw hl, BP
            subw hl, #({index})*-1
            load a, (hl)
        }
    }
    __load_local a, {index: i8} =>
    {
        assert(index > 0)
        asm
        {
            loadw hl, BP
            addw hl, #{index}
            load a, (hl)
        }
    }
    __load_local b, {index: i8} =>
    {
        assert(index == 0)
        asm
        {
            loadw hl, BP
            load b, (hl)
        }
    }
    __load_local b, {index: i8} =>
    {
        assert(index < 0)
        asm
        {
            loadw hl, BP
            subw hl, #({index})*-1
            load b, (hl)
        }
    }
    __load_local b, {index: i8} =>
    {
        assert(index > 0)
        asm
        {
            loadw hl, BP
            addw hl, #{index}
            load b, (hl)
        }
    }


;store
    __store_local a, {index: i8} =>
    {
        assert(index == 0)
        asm
        {
            store a, (BP)
        }
    }
    __store_local a, {index: i8} =>
    {
        assert(index < 0)
        asm
        {
            loadw hl, BP
            subw hl, #({index})*-1
            store a, (hl)
        }
    }
    __store_local a, {index: i8} =>
    {
        assert(index > 0)
        asm
        {
            loadw hl, BP
            addw hl, #{index}
            store a, (hl)
        }
    }
    __store_local b, {index: i8} =>
    {
        assert(index == 0)
        asm
        {
            loadw hl, BP
            store b, (hl)
        }
    }
    __store_local b, {index: i8} =>
    {
        assert(index < 0)
        asm
        {
            loadw hl, BP
            subw hl, #({index})*-1
            store b, (hl)
        }
    }
    __store_local b, {index: i8} =>
    {
        assert(index > 0)
        asm
        {
            loadw hl, BP
            addw hl, #{index}
            store b, (hl)
        }
    }

    ; push_imm
    ; push immediate values for more than one byte to stack
    __push16 #{imm: i16} =>
    {
    assert(imm <= 0xffff)
        asm
        {
            push #(({imm}>>8)`8)
            push #({imm}`8)
        }
    }

    ; push_imm
    ; push immediate values for more than one byte to stack
    __push32 #{imm: i32} =>
    {
    assert(imm <= 0xffff_ffff)
        asm
        {
            push #(({imm}>>24)`8)
            push #(({imm}>>16)`8)
            push #(({imm}>>8)`8)
            push #({imm}`8)
        }
    }
    
}


#bankdef ram
{
    #bits 8
    #addr 0x8000
    #size 0x4000
}

#bankdef rom
{
    #bits 8
    #addr 0x0000
    #size 0x8000
    #outp 0x0000
}

#bank ram
BP: ; base pointer for function calls
    #res 2

#bank rom

; con
DEFAULT_STACK   = 0xBFFF
DPRAM           = 0xC000
MOT_ENC         = 0xD002
MOT_CTRL        = 0xD003
UART            = 0xD008
EXT_ROM         = 0xD00C