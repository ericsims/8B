#cpudef
{

    nop			              => 0x00
    hlt                       => 0x01
    lai, {value}              => 0x02 @ value`8
    lbi, {value}              => 0x03 @ value`8
    add                       => 0x04
    jmp, {address}            => 0x05 @ address`16
    sub                       => 0x06
    jmz, {address}            => 0x07 @ address`16
    jnz, {address}            => 0x08 @ address`16
    sta, {address}            => 0x09 @ address`16
    lba                       => 0x0A
    lda, {address}            => 0x0B @ address`16
    ldb, {address}            => 0x0C @ address`16
    jmc, {address}            => 0x0D @ address`16
    jnc, {address}            => 0x0E @ address`16
    sti, {value}, {address}   => 0x0F @ value`8 @ address`16
    cal, {address}            => 0x10 @ address`16
    ret                       => 0x11
    jmn, {address}            => 0x12 @ address`16
    rlc                       => 0x13
    rrc                       => 0x14
}

UART    = 0xD008