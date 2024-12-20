#once
#include "instructions.asm"
#include "mems.asm"

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
    ;
    ; 1. push parameters to stack
    ; 2. call function using `call` instruciton. This will put the return address on the stack
    ; 3. prologue macro
    ;   3a. saves old BP to stack.
    ;   3b. save current base pointer to BP memory
    ;
    ; for return
    ; 1. set return value in b register
    ; 2. epilogue macro
    ;   2a. ;TODO: check SP=BP
    ;   2b. restore old BP
    ; 3. `ret` to return to function call 
    ;
    ; notes:
    ;  - stack grows up (address increases as values pushed to stack)
    ;  - b register for return value
    ;  - registers are not preserved during function calls
    ;  - all values are big endian
    ;  - don't overwrite parameters, use a pointer to set return value
    ;
    ; ex. fnc(param32, param16, param8)
    ;
    ;  BP             STACK
    ; OFFSET
    ;         _______________________
    ;  -11   |        .param32       | params stored big endian
    ;  -10   |                       |
    ;  -9    |                       |
    ;  -8    |_______________________|
    ;  -7    |        .param16       |
    ;  -6    |_______________________|
    ;  -5    |________.param8________|
    ;  -4    |      return_addr      | <-- address placed by `call instruction`
    ;  -3    |_______________________|
    ;  -2    |      previous_BP      | <-- BP saved during prologue
    ;  -1    |_______________________|
    ;   0    |           .           | <-- this address is saved to BP
    ;   1    |           .           |
    ;   2    |           .           | local vars stored big endian
    ;   3    |           .           |
    ;
    ;
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


; store
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
    __push32 #{imm: i32} =>
    {
        assert(imm <= 0xffff_ffff)
        asm
        {
            pushw #(({imm}>>16)`16)
            pushw #({imm}`16)
        }
    }

    
    ; store_imm
    ; store immediate values for more than one byte to memory
    __store32 #{imm: i32}, {addr: i16} =>
    {
        assert(imm <= 0xffff_ffff)
        asm
        {
            storew #(({imm}>>16)`16), {addr}
            storew #({imm}`16), {addr}+2
        }
    }


    ; push_pointer
    ; push immediate values for more than one byte to stack
    __push_pointer_sp {offset: i8} =>
    {
        assert(offset >= 0x00)
        assert(offset <= 0xFF)
        asm
        {
            loadw hl, sp
            addw hl, #({offset}`8)
            pushw hl
        }
    }
    __push_pointer_sp {offset: i8} =>
    {
        assert(offset < 0x00)
        assert(offset >= -0xFF)
        asm
        {
            loadw hl, sp
            subw hl, #({offset})*-1
            pushw hl
        }
    }


    __push_pointer (BP), {offset: i8} =>
    {
        assert(offset >= 0x00)
        assert(offset <= 0xFF)
        asm
        {
            loadw hl, BP
            addw hl, #({offset}`8)
            pushw hl
        }
    }
    __push_pointer (BP), {offset: i8} =>
    {
        assert(offset < 0x00)
        assert(offset >= -0xFF)
        asm
        {
            loadw hl, BP
            subw hl, #({offset})*-1
            pushw hl
        }
    }
    

}

#bankdef ram
{
    #bits 8
    #addr RAM
    #size RAM_SIZE
}

#bankdef rom
{
    #bits 8
    #addr ROM
    #size ROM_SIZE
    #outp 0x0000
}

#bank ram
BP: #res 2 ; base pointer for function calls