#bits 8

#ruledef
{


    load a, #{imm: i8} =>
    {
        assert(imm >= 0)
        assert(imm <= 0xff)
        0x04 @ imm`8
    }

    load a, {address: i16} =>
    {
        assert(imm >= 0)
        assert(imm <= 0xffff)
        0x05 @ imm`16
    }

    load a, ({address: i16}) =>
    {
        assert(imm >= 0)
        assert(imm <= 0xffff)
        0x06 @ imm`16
    }

    load b, #{imm: i8} =>
    {
        assert(imm >= 0)
        assert(imm <= 0xff)
        0x08 @ imm`8
    }

    load b, {address: i16} =>
    {
        assert(imm >= 0)
        assert(imm <= 0xffff)
        0x09 @ imm`16
    }

    load b, ({address: i16}) =>
    {
        assert(imm >= 0)
        assert(imm <= 0xffff)
        0x0A @ imm`16
    }


    store a, {address: i16} =>
    {
        asm
        {
            sta address
        }
    }

    move [{dest: i16}], {sour: i16}  =>
    {
        asm
        {
            lda dest+1 ; load lsb
            pha
            lda dest ; load msb
            pha
            lda sour ; load data
            ssa
        }
    }

    move b, a =>
    {
        asm
        {
            lba
        }
    }

    store {value: i8}, {address: i16} =>
    {
        asm
        {
            sti value, address
        }
    }

    store {value: i16}, {address: i16} =>
    {
        asm
        {
            sti value[15:8], address
            sti value[7:0], address+1
        }
    }
    
    lbi {value} =>
    {
        assert(value >= 0)
        assert(value <= 0xff)
        0x03 @ value`8
    }
    
    sti {value}, {address} =>
    {
        assert(value >= 0)
        assert(value <= 0xff)
        0x0F @ value`8 @ address`16
    }    
    
    sta {address}            => 0x09 @ address`16
    lba                      => 0x0A
    lda {address}            => 0x0B @ address`16
    ldb {address}            => 0x0C @ address`16
    
    ; ALU Operations
    add                      => 0x04
    sub                      => 0x06
    and                      => 0x19
    oor                      => 0x20
    xor                      => 0x21    
    rlc                      => 0x13
    rrc                      => 0x14
    
    
    
    ; Jump Operatoins
    jmp {address}            => 0x05 @ address`16
    jmz {address}            => 0x07 @ address`16
    jnz {address}            => 0x08 @ address`16
    jmc {address}            => 0x0D @ address`16
    jnc {address}            => 0x0E @ address`16
    cal {address}            => 0x10 @ address`16
    ret                      => 0x11
    jmn {address}            => 0x12 @ address`16
    

    ; Stack operations
    pha                      => 0x15
    ssa                      => 0x17
    lsa                      => 0x18
    
    ; test operations
    ttn {value}              => 0xFB @ value`8
    ttc {value}              => 0xFC @ value`8
    ttz {value}              => 0xFD @ value`8
    tta {value}              => 0xFE @ value`8
    
    nop                      => 0x00
    hlt                      => 0xFF
    
    
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