#cpudef
{

    nop			             => 0x00
    lai {value}              => 0x02 @ value`8
    lbi {value}              => 0x03 @ value`8
    add                      => 0x04
    jmp {address}            => 0x05 @ address`16
    sub                      => 0x06
    jmz {address}            => 0x07 @ address`16
    jnz {address}            => 0x08 @ address`16
    sta {address}            => 0x09 @ address`16
    lba                      => 0x0A
    lda {address}            => 0x0B @ address`16
    ldb {address}            => 0x0C @ address`16
    jmc {address}            => 0x0D @ address`16
    jnc {address}            => 0x0E @ address`16
    sti {value}, {address}   => 0x0F @ value`8 @ address`16
    cal {address}            => 0x10 @ address`16
    ret                      => 0x11
    jmn {address}            => 0x12 @ address`16
    rlc                      => 0x13
    rrc                      => 0x14
    pha                      => 0x15
    ssa                      => 0x17
    lsa                      => 0x18
    ttn {value}              => 0xFB @ value`8
    ttc {value}              => 0xFC @ value`8
    ttz {value}              => 0xFD @ value`8
    tta {value}              => 0xFE @ value`8
    hlt                      => 0xFF
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

MOT_ENC  = 0xD002
MOT_CTRL = 0xD003
UART     = 0xD008