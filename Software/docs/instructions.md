
Instruction Set Manual
======================

# Control Signals

|Signal|Description|Active High/Low|
| :--- | :--- | :--- |
|OUT: 0<br>NONE|none| - |
|OUT: 1<br>HT|Halt| - |
|OUT: 2<br>PO|Program Counter Out| - |
|OUT: 3<br>AO|A Register Out| - |
|OUT: 4<br>BO|B Register Out| - |
|OUT: 5<br>MO|Memory Out| - |
|OUT: 6<br>NO|Stack Pointer Out| - |
|OUT: 7<br>SO|Stack Out| - |
|OUT: 8<br>HO|HL Register Out| - |
|OUT: 9<br>JO|J Scratch Register Out| - |
|OUT: 10<br>KO|K Scratch Register Out| - |
|OUT: 11<br>DO|D Scratch Register Out| - |
|IN: 0<br>NONE|none| - |
|IN: 1<br>PI|Program Counter In| - |
|IN: 2<br>II|Instruction Register In| - |
|IN: 3<br>XI|ALU X Register In| - |
|IN: 4<br>YI|ALU Y Register In| - |
|IN: 5<br>AI|A Register In| - |
|IN: 6<br>BI|B Register In| - |
|IN: 7<br>HI|HL Register In| - |
|IN: 8<br>MA|Memory Address Register In| - |
|IN: 9<br>MI|Memory In| - |
|IN: 10<br>NI|Stack Pointer In| - |
|IN: 11<br>SI|Stack In| - |
|IN: 12<br>JI|J Scratch Register In| - |
|IN: 13<br>KI|K Scratch Register In| - |
|IN: 14<br>DI|D Scratch Register In| - |
|ALU: 0<br>NONE|none| - |
|ALU: 1<br>ADD|Add| - |
|ALU: 2<br>SUB|Subtract| - |
|ALU: 3<br>AND|Logical AND| - |
|ALU: 4<br>OR|Logical OR| - |
|ALU: 5<br>XOR|Logical XOR| - |
|ALU: 6<br>SHL|Logical Shift Left| - |
|ALU: 7<br>SHR|Logical Shift Right| - |
|ALU: 8<br>ONES|Output 0xFF| - |
|ALU: 9<br>ZERO|Output 0x00| - |
|ALU: 10<br>ONE|Output 0x01| - |
|CE|Program Counter Enable|low|
|FI|ALU Flag Refresh|low|
|LM|Bus MSB Byte Select|low|
|RU|Reset Microcode Counter|low|
|MC|Memory Address Increment|low|
|IS|Increment Stack Pointer|low|
|DS|Decrement Stack Pointer|low|
|AT|Assert Condition|low|
|UC20|RFU20|low|
|UC21|RFU21|low|
|UC22|RFU22|low|
|UC23|RFU23|low|

# Instructions

|opcode|||||
| :--- | :--- | :--- | :--- | :--- |
|00|nop|halt|-|-|
|04|load_a_imm|load_a_dir|load_a_indir|loadw_hl_sp|
|08|load_b_imm|load_b_dir|load_b_indir|loadw_hl_hl_indir|
|0C|loadw_hl_imm|loadw_hl_dir|-|-|
|10|add_a_b|add_a_imm|add_b_imm|load_a_b|
|14|addw_hl_a|addw_hl_b|addw_hl_imm|load_b_a|
|18|sub_a_b|sub_a_imm|sub_b_imm|loadw_sp_imm|
|1C|subw_hl_a|subw_hl_b|subw_hl_imm|-|
|20|and_a_b|and_a_imm|and_b_imm|-|
|24|or_a_b|or_a_imm|or_b_imm|-|
|28|xor_a_b|xor_a_imm|xor_b_imm|-|
|2C|lshift_a|lshift_b|rshift_a|rshift_b|
|30|store_a_dir|store_a_indir|store_b_dir|store_b_indir|
|34|storew_hl_dir|-|-|-|
|38|push_a|push_b|push_imm|push_dir|
|3C|push_indir|store_imm_dir|storew_imm_dir|store_imm_hl_indir|
|40|load_a_hl_indir|load_b_hl_indir|store_a_hl_indir|store_b_hl_indir|
|44|move_dir_dir|move_dir_indir|move_indir_dir|move_indir_indir|
|48|movew_dir_dir|-|-|-|
|4C|pushw_imm|pushw_dir|alloc|dealloc|
|50|pushw_hl|popw_hl|pop_a|pop_b|
|54|load_a_indir_poffset|load_a_indir_noffset|load_b_indir_poffset|load_b_indir_noffset|
|58|store_a_indir_poffset|store_a_indir_noffset|store_b_indir_poffset|store_b_indir_noffset|
|5C|loadw_hl_indir_poffset|loadw_hl_indir_noffset|storew_hl_indir_poffset|storew_hl_indir_noffset|
|60|store_imm_indir_poffset|store_imm_indir_noffset|jmp_hl|call_hl|
|64|jmp|jmz|jnz|jmc|
|68|jnc|jmn|jnn|call|
|6C|test_a|test_b|-|-|
|70|-|-|-|-|
|74|ret|-|-|assert_hl|
|78|assert_a|assert_b|assert_cf_s|assert_cf_c|
|7C|assert_zf_s|assert_zf_c|assert_nf_s|assert_nf_c|
|80|xfr_set_len_imm|xfr_set_len_a|-|-|
|84|xfr_set_dest_dir|-|-|-|
|88|xfr_set_src_dir|xfr_set_src_indir|-|-|
|8C|xfr8_loop|xfr8_loop_no_incr_dst|xfr8_loop_no_incr_src|-|
|90|-|-|-|-|
|94|-|-|-|-|
|98|-|-|-|-|
|9C|-|-|-|-|
|A0|-|-|-|-|
|A4|-|-|-|-|
|A8|-|-|-|-|
|AC|-|-|-|-|
|B0|-|-|-|-|
|B4|-|-|-|-|
|B8|-|-|-|-|
|BC|-|-|-|-|
|C0|-|-|-|-|
|C4|-|-|-|-|
|C8|-|-|-|-|
|CC|-|-|-|-|
|D0|-|-|-|-|
|D4|-|-|-|-|
|D8|-|-|-|-|
|DC|-|-|-|-|
|E0|-|-|-|-|
|E4|-|-|-|-|
|E8|-|-|-|-|
|EC|-|-|-|-|
|F0|-|-|-|-|
|F4|-|-|-|-|
|F8|-|-|-|-|
|FC|-|-|-|-|

## No Operation


No operation, or "no op" or "nop" command does not perfom any action.

short: `nop`

opcode: `0x00`

Usage: `nop`
## Load A Immediate


Load a register with immediate value

A <-- IMM


short: `load_a_imm`

opcode: `0x04`

Usage: `load a, #data[7:0]`
## Load A Direct


load a register from direct address

A <-- MEM(ADDR)


short: `load_a_dir`

opcode: `0x05`

Usage: `load a, addresss[15:0]`
## Load A Indirect


load a register from indirect address

A <-- MEM(MEM(ADDR))


short: `load_a_indir`

opcode: `0x06`

Usage: `load a, (address[15:0])`
## Load HL with Stack Pointer


load hl with the address of the stack pointer register. This performs a big endian 16-bit load, MSB first.

HL <-- SP


short: `loadw_hl_sp`

opcode: `0x07`

Usage: `loadw hl, sp`
## Load B Immediate


load b register with immediate value

short: `load_b_imm`

opcode: `0x08`

Usage: `load b, #data[7:0]`
## Load B Direct


load b register from direct address

B <-- MEM(ADDR)


short: `load_b_dir`

opcode: `0x09`

Usage: `load b, addresss[15:0]`
## Load B Indirect


load a register from indirect address

A <-- MEM(MEM(ADDR))


short: `load_b_indir`

opcode: `0x0A`

Usage: `load b, (address[15:0])`
## Load HL Indirect HL


load hl register with word from indirect address in hl register.

HL <-- MEM(HL)


short: `loadw_hl_hl_indir`

opcode: `0x0B`

Usage: `loadw hl, (hl)`
## Load HL Immediate


load hl register with immediate word

HL <-- IMM


short: `loadw_hl_imm`

opcode: `0x0C`

Usage: `loadw hl, #data[15:0]`
## Load HL Direct


load hl register from word from direct address

HL <-- MEM(ADDR)


short: `loadw_hl_dir`

opcode: `0x0D`

Usage: `loadw hl, address[15:0]`
## Load A B


Load a register with value in b register

A <-- B


short: `load_a_b`

opcode: `0x13`

Usage: `load a, b`
## Add HL A


add a to hl word and save to hl word

HL <-- HL + A

ZF: set if upper byte of result is zero (this does not reflect that the entire word is zero)

NF: set if result bit 15 is set (result is negative)

CF: set if adder carried out on the upper byte


This instruction modifies the flags register

short: `addw_hl_a`

opcode: `0x14`

Usage: `addw hl, a`
## Add HL B


add b to hl word and save to hl word

HL <-- HL + B

ZF: set if upper byte of result is zero (this does not reflect that the entire word is zero)

NF: set if result bit 15 is set (result is negative)

CF: set if adder carried out on the upper byte


This instruction modifies the flags register

short: `addw_hl_b`

opcode: `0x15`

Usage: `addw hl, b`
## Add HL Immediate


add imm byte to hl word and save to hl word

HL <-- HL + IMM

ZF: set if upper byte of result is zero (this does not reflect that the entire word is zero)

NF: set if result bit 15 is set (result is negative)

CF: set if adder carried out on the upper byte


This instruction modifies the flags register

short: `addw_hl_imm`

opcode: `0x16`

Usage: `addw hl, #data[7:0]`
## Subtract HL A


subtract a byte from hl word and save to hl word

HL <-- HL - A

ZF: set if upper byte of result is zero (this does not reflect that the entire word is zero)

NF: set if result bit 15 is set (result is negative)

CF: set if adder carried out on the upper byte


This instruction modifies the flags register

short: `subw_hl_a`

opcode: `0x1C`

Usage: `subw hl, a`
## Subtract HL B


subtract b byte from hl word and save to hl word

HL <-- HL - B

ZF: set if upper byte of result is zero (this does not reflect that the entire word is zero)

NF: set if result bit 15 is set (result is negative)

CF: set if adder carried out on the upper byte


This instruction modifies the flags register

short: `subw_hl_b`

opcode: `0x1D`

Usage: `subw hl, b`
## Subtract HL Immediate


subtract imm byte to hl word and save to hl word

HL <-- HL - IMM

ZF: set if upper byte of result is zero (this does not reflect that the entire word is zero)

NF: set if result bit 15 is set (result is negative)

CF: set if adder carried out on the upper byte


This instruction modifies the flags register

short: `subw_hl_imm`

opcode: `0x1E`

Usage: `subw hl, #data[7:0]`
## Load B A


Load b register with value in a register

B <-- A


short: `load_b_a`

opcode: `0x17`

Usage: `load b, a`
## Load SP Immediate


load sp register with immediate word

SP <-- IMM


short: `loadw_sp_imm`

opcode: `0x1B`

Usage: `loadw sp, #data[15:0]`
## Add A B


add a register to b register and save to a

A <-- A + B

ZF: set if result is zero

NF: set if result bit 7 is set

CF: set if adder carried out


This instruction modifies the flags register

short: `add_a_b`

opcode: `0x10`

Usage: `add a, b`
## Add A Immediate


add a register to imm value and save to a

A <-- A + IMM

ZF: set if result is zero

NF: set if result bit 7 is set

CF: set if adder carried out


This instruction modifies the flags register

short: `add_a_imm`

opcode: `0x11`

Usage: `add a, #data[7:0]`
## Add B Immediate


add b register to imm value and save to b

B <-- B + IMM

ZF: set if result is zero

NF: set if result bit 7 is set

CF: set if adder carried out


This instruction modifies the flags register

short: `add_b_imm`

opcode: `0x12`

Usage: `add b, #data[7:0]`
## Subtract A B


Subtract b register from a register and save to a

A <-- A - B

ZF: set if result is zero

NF: set if result bit 7 is set

CF: set if adder carried out


This instruction modifies the flags register

short: `sub_a_b`

opcode: `0x18`

Usage: `sub a, b`
## Subtract A Immediate


subtract imm value from a register and save to a

A <-- A - IMM

ZF: set if result is zero

NF: set if result bit 7 is set

CF: set if adder carried out


This instruction modifies the flags register

short: `sub_a_imm`

opcode: `0x19`

Usage: `sub a, #data[7:0]`
## Subtract B Immediate


subtract imm value from b register and save to b

B <-- B - IMM

ZF: set if result is zero

NF: set if result bit 7 is set

CF: set if adder carried out


This instruction modifies the flags register

short: `sub_b_imm`

opcode: `0x1A`

Usage: `sub b, #data[7:0]`
## Bitwise And A B


Bitwise AND a register with b register and save to a

A <-- A & B

ZF: set if result is zero

NF: set if result bit 7 is set

CF: undefined


This instruction modifies the flags register

short: `and_a_b`

opcode: `0x20`

Usage: `and a, b`
## Bitwise And A Immediate


Bitwise AND a register with imm value and save to a

A <-- A & IMM

ZF: set if result is zero

NF: set if result bit 7 is set

CF: undefined


This instruction modifies the flags register

short: `and_a_imm`

opcode: `0x21`

Usage: `and a, #data[7:0]`
## Bitwise And B Immediate


Bitwise AND B register with imm value and save to B

B <-- B & IMM

ZF: set if result is zero

NF: set if result bit 7 is set

CF: undefined


This instruction modifies the flags register

short: `and_b_imm`

opcode: `0x22`

Usage: `and b, #data[7:0]`
## Bitwise Or A B


Bitwise OR a register with b register and save to a

A <-- A | B

ZF: set if result is zero

NF: set if result bit 7 is set

CF: undefined


This instruction modifies the flags register

short: `or_a_b`

opcode: `0x24`

Usage: `or a, b`
## Bitwise Or A Immediate


Bitwise OR a register with imm value and save to a

A <-- A | IMM

ZF: set if result is zero

NF: set if result bit 7 is set

CF: undefined


This instruction modifies the flags register

short: `or_a_imm`

opcode: `0x25`

Usage: `or a, #data[7:0]`
## Bitwise Or B Immediate


Bitwise OR b register with imm value and save to b

B <-- B | IMM

ZF: set if result is zero

NF: set if result bit 7 is set

CF: undefined


This instruction modifies the flags register

short: `or_b_imm`

opcode: `0x26`

Usage: `or b, #data[7:0]`
## Bitwise Xor A B


Bitwise XOR a register with b register and save to a

A <-- A ^ B

ZF: set if result is zero

NF: set if result bit 7 is set

CF: undefined


This instruction modifies the flags register

short: `xor_a_b`

opcode: `0x28`

Usage: `xor a, b`
## Bitwise Xor A Immediate


Bitwise XOR a register with immediate value and save to a register.

A <-- A ^ IMM

ZF: set if result is zero

NF: set if result bit 7 is set

CF: undefined


This instruction modifies the flags register

short: `xor_a_imm`

opcode: `0x29`

Usage: `xor a, #data[7:0]`
## Bitwise Xor B Immediate


Bitwise XOR B register with immediate value and save to B register.

B <-- B ^ IMM

ZF: set if result is zero

NF: set if result bit 7 is set

CF: undefined


This instruction modifies the flags register

short: `xor_b_imm`

opcode: `0x2A`

Usage: `xor b, #data[7:0]`
## Bitwise Left Shift A


Bitwise shift left A register by one and save to A register. Zero is shifted into LSB.

A <-- A << 1

ZF: set if result is zero

NF: set if result bit 7 is set

CF: set if bit shifted off of the left was set


This instruction modifies the flags register

short: `lshift_a`

opcode: `0x2C`

Usage: `lshift a`
## Bitwise Left Shift B


Bitwise shift left B register by one and save to B. Zero is shifted into LSB.

B <-- B << 1

ZF: set if result is zero

NF: set if result bit 7 is set

CF: set if bit shifted off of the left was set


This instruction modifies the flags register

short: `lshift_b`

opcode: `0x2D`

Usage: `lshift b`
## Bitwise Right Shift A


Bitwise shift right A register by one and save to A register. Zero is shifted into MSB.

A <-- A >> 1

ZF: set if result is zero

NF: set if result bit 7 is set

CF: set if bit shifted off of the right was set


This instruction modifies the flags register

short: `rshift_a`

opcode: `0x2E`

Usage: `rshift a`
## Bitwise Right Shift B


Bitwise shift right B register by one and save to B register. Zero is shifted into MSB.

B <-- B >> 1

ZF: set if result is zero

NF: set if result bit 7 is set

CF: set if bit shifted off of the right was set


This instruction modifies the flags register

short: `rshift_b`

opcode: `0x2F`

Usage: `rshift b`
## Store A Direct


Store A register value to direct address.

MEM(ADDR) <-- A


short: `store_a_dir`

opcode: `0x30`

Usage: `store a, address[15:0]`
## Store A Indirect


Store A register value to indirect address.

MEM(MEM(ADDR)) <-- A


short: `store_a_indir`

opcode: `0x31`

Usage: `store a, (address[15:0])`
## Store B Direct


Store B register value to direct address.

MEM(ADDR) <-- B


short: `store_b_dir`

opcode: `0x32`

Usage: `store b, address[15:0]`
## Store B Indirect


Store B register value to indirect address.

MEM(MEM(ADDR)) <-- B


short: `store_b_indir`

opcode: `0x33`

Usage: `store b, (address[15:0])`
## Store HL Direct


Store HL register word to direct address. This performs a big endian 16-bit store, MSB first.

MEM(ADDR) <-- HL


short: `storew_hl_dir`

opcode: `0x34`

Usage: `store hl, address[15:0]`
## Store Immediate Direct


Store imm value to direct address.

MEM(ADDR) <-- IMM


short: `store_imm_dir`

opcode: `0x3D`

Usage: `store #data[7:0], address[15:0]`
## Store Immediate Word Direct


Store imm word to direct address. This performs a big endian 16-bit store, MSB first.

MEM(ADDR) <-- IMM


short: `storew_imm_dir`

opcode: `0x3E`

Usage: `storew #data[16:0], address[15:0]`
## Stack Push A


Push A register value to stack. Increments stack pointer.

MEM(SP) <-- A

SP <-- SP + 1


short: `push_a`

opcode: `0x38`

Usage: `push a`
## Stack Push B


Push B register value to stack. Increments stack pointer.

MEM(SP) <-- B

SP <-- SP + 1


short: `push_b`

opcode: `0x39`

Usage: `push b`
## Store Immediate HL Indirect


store imm value to indirect address in hl register

MEM(HL) <-- IMM


short: `store_imm_hl_indir`

opcode: `0x3F`

Usage: `store #data[7:0], (hl)`
## Load A HL Indirect


Load A register from indirect address in hl register.

A <-- MEM(HL)


short: `load_a_hl_indir`

opcode: `0x40`

Usage: `load a, (hl)`
## Load B HL Indirect


Load B register from indirect address in hl register.

B <-- MEM(HL)


short: `load_b_hl_indir`

opcode: `0x41`

Usage: `load b, (hl)`
## store_a_hl_indir


store a register to indirect address in hl register

short: `store_a_hl_indir`

opcode: `0x42`

Usage: `store a, (hl)`
## store_b_hl_indir


store b register to indirect address in hl register

short: `store_b_hl_indir`

opcode: `0x43`

Usage: `store b, (hl)`
## Stack Push Immediate


Push immediate value to stack.

MEM(SP) <-- IMM

SP <-- SP + 1


short: `push_imm`

opcode: `0x3A`

Usage: `push #data[7:0]`
## Stack Push Direct


Push byte from direct address value to stack.

MEM(SP) <-- MEM(ADDR)

SP <-- SP + 1


short: `push_dir`

opcode: `0x3B`

Usage: `push address[15:0]`
## Stack Push Indirect


Push byte from indirect address value to stack.

MEM(SP) <-- MEM(MEM(ADDR))

SP <-- SP + 1


short: `push_indir`

opcode: `0x3C`

Usage: `push (address[15:0])`
## Stack Push Word Immediate


Push immediate word to stack. This performs a big endian 16-bit store, MSB first.

MEM(SP) <-- IMM

SP <-- SP + 2


short: `pushw_imm`

opcode: `0x4C`

Usage: `pushw #data[15:0]`
## pushw_dir


push word from source to stack

short: `pushw_dir`

opcode: `0x4D`

Usage: `pushw address[15:0]`
## Stack Allocate


Allocate n bytes on stack. Limit of 255 bytes. Flags are updated as part of the allocation microcode, but not designed to be used by the user.

SP <-- SP + IMM


This instruction modifies the flags register

short: `alloc`

opcode: `0x4E`

Usage: `alloc data[7:0]`
## Stack Allocate


deallocate n bytes on stack. Limit of 255 bytes. Flags are updated as part of the deallocation microcode, but not designed to be used by the user.

SP <-- SP - IMM


This instruction modifies the flags register

short: `dealloc`

opcode: `0x4F`

Usage: `dealloc data[7:0]`
## pushw_hl


push hl register onto stack

short: `pushw_hl`

opcode: `0x50`

Usage: `push hl`
## popw_hl


pop word off of stack into hl register

short: `popw_hl`

opcode: `0x51`

Usage: `pop hl`
## Stack Pop A


Pop value off of stack into A register. Decrements stack pointer.

MEM(SP) <-- A

SP <-- SP - 1


short: `pop_a`

opcode: `0x52`

Usage: `pop a`
## Stack Pop B


Pop value off of stack into B register. Decrements stack pointer.

MEM(SP) <-- B

SP <-- SP - 1


short: `pop_b`

opcode: `0x53`

Usage: `pop b`
## move_dir_dir


copy byte from source to destination

short: `move_dir_dir`

opcode: `0x44`

Usage: `move src[15:0], dst[15:0]`
## move_dir_indir


copy byte from source to indirect destination

short: `move_dir_indir`

opcode: `0x45`

Usage: `move src[15:0], (dst[15:0])`
## move_indir_dir


copy byte from indirect source to destination

short: `move_indir_dir`

opcode: `0x46`

Usage: `move (src[15:0]), dst[15:0]`
## move_indir_indir


copy byte from indirect source to indirect destination

short: `move_indir_indir`

opcode: `0x47`

Usage: `move (src[15:0]), (dst[15:0])`
## movew_dir_dir


copy 2 byte word from source to destination

short: `movew_dir_dir`

opcode: `0x48`

Usage: `movew src[15:0], dst[15:0]`
## Jump


Unconditional Jump

PC <-- ADDR


short: `jmp`

opcode: `0x64`

Usage: `jmp address[15:0]`
## Jump HL


Jump to address in HL register.

PC <-- HL


short: `jmp_hl`

opcode: `0x62`

Usage: `jmp hl`
## call_hl


Call Subroutine in hl register

short: `call_hl`

opcode: `0x63`

Usage: `call hl`
## jmz


Jump if Zero

short: `jmz`

opcode: `0x65`

Usage: `jmz address[15:0]`
## jnz


Jump if not Zero

short: `jnz`

opcode: `0x66`

Usage: `jnz address[15:0]`
## jmc


Jump if Carry

short: `jmc`

opcode: `0x67`

Usage: `jmc address[15:0]`
## jnc


Jump if not Carry

short: `jnc`

opcode: `0x68`

Usage: `jnc address[15:0]`
## jmn


Jump if Negative

short: `jmn`

opcode: `0x69`

Usage: `jnc address[15:0]`
## jnn


Jump if not Negative

short: `jnn`

opcode: `0x6A`

Usage: `jnc address[15:0]`
## call


Call Subroutine. This places the return address on the stack (big-endian) then jumps to the subroutine address. Program can return from Subroutine.

MEM(SP) <-- PC

SP <-- SP + 2

PC <-- IMM


short: `call`

opcode: `0x6B`

Usage: `call address[15:0]`
## test_a


tests value in a register and updates flags

This instruction modifies the flags register

short: `test_a`

opcode: `0x6C`

Usage: `test a`
## test_b


tests value in ab register and updates flags

This instruction modifies the flags register

short: `test_b`

opcode: `0x6D`

Usage: `test b`
## Return


Return from Subroutine call to the return address saved on the stack.

PC <-- MEM(SP)

SP <-- SP - 2


short: `ret`

opcode: `0x74`

Usage: `ret`
## assert_a


Assert value of A register == imm value

This instruction modifies the flags register

short: `assert_a`

opcode: `0x78`

Usage: `assert a, #data[7:0]`
## assert_b


Assert value of b register == imm value

This instruction modifies the flags register

short: `assert_b`

opcode: `0x79`

Usage: `assert b, #data[7:0]`
## assert_hl


Assert value of hl register == imm value

This instruction modifies the flags register

short: `assert_hl`

opcode: `0x77`

Usage: `assert hl, #data[15:0]`
## assert_cf_s


Assert CF is set

short: `assert_cf_s`

opcode: `0x7A`

Usage: `assert cf, #1`
## assert_cf_c


Assert CF is cleared

short: `assert_cf_c`

opcode: `0x7B`

Usage: `assert cf, #0`
## assert_zf_s


Assert ZF is set

short: `assert_zf_s`

opcode: `0x7C`

Usage: `assert zf, #1`
## assert_zf_c


Assert ZF is cleared

short: `assert_zf_c`

opcode: `0x7D`

Usage: `assert zf, #0`
## assert_nf_s


Assert NF is set

short: `assert_nf_s`

opcode: `0x7E`

Usage: `assert nf, #1`
## assert_nf_c


Assert NF is  cleared

short: `assert_nf_c`

opcode: `0x7F`

Usage: `assert nf, #0`
## Halt


Halts execution.

short: `halt`

opcode: `0x01`

Usage: `halt`
## load_a_indir_poffset


load a register with value in (address) + offset

This instruction modifies the flags register

short: `load_a_indir_poffset`

opcode: `0x54`

Usage: `load a, address[15:0], offset[7:0]`
## load_a_indir_noffset


load a register with value in (address) - offset

This instruction modifies the flags register

short: `load_a_indir_noffset`

opcode: `0x55`

Usage: `load a, address[15:0], offset[7:0]`
## load_b_indir_poffset


load b register with value in (address) + offset

This instruction modifies the flags register

short: `load_b_indir_poffset`

opcode: `0x56`

Usage: `load b, address[15:0], offset[7:0]`
## load_b_indir_noffset


load b register with value in (address) - offset

This instruction modifies the flags register

short: `load_b_indir_noffset`

opcode: `0x57`

Usage: `load b, address[15:0], offset[7:0]`
## store_a_indir_poffset


store a register to indirect (address) + offset

This instruction modifies the flags register

short: `store_a_indir_poffset`

opcode: `0x58`

Usage: `store a, address[15:0], offset[7:0]`
## store_a_indir_noffset


store a register to indirect (address) - offset

This instruction modifies the flags register

short: `store_a_indir_noffset`

opcode: `0x59`

Usage: `store a, address[15:0], offset[7:0]`
## store_b_indir_poffset


store b register to indirect (address) + offset

This instruction modifies the flags register

short: `store_b_indir_poffset`

opcode: `0x5A`

Usage: `store b, address[15:0], offset[7:0]`
## store_b_indir_noffset


store b register to indirect (address) - offset

This instruction modifies the flags register

short: `store_b_indir_noffset`

opcode: `0x5B`

Usage: `store b, address[15:0], offset[7:0]`
## loadw_hl_indir_poffset


load hl register with value in (address) + offset

This instruction modifies the flags register

short: `loadw_hl_indir_poffset`

opcode: `0x5C`

Usage: `loadw hl, address[15:0], offset[7:0]`
## loadw_hl_indir_noffset


load hl register with value in (address) - offset

This instruction modifies the flags register

short: `loadw_hl_indir_noffset`

opcode: `0x5D`

Usage: `loadw hl, addr[15:0], offset[7:0]`
## storew_hl_indir_poffset


store hl register value in (address) + offset

This instruction modifies the flags register

short: `storew_hl_indir_poffset`

opcode: `0x5E`

Usage: `store hl, addr[15:0], offset[7:0]`
## storew_hl_indir_noffset


store hl register value in (address) - offset

This instruction modifies the flags register

short: `storew_hl_indir_noffset`

opcode: `0x5F`

Usage: `storew hl, (address[15:0]), offset[7:0]`
## store_imm_indir_poffset


store imm value to indirect (address) + offset

This instruction modifies the flags register

short: `store_imm_indir_poffset`

opcode: `0x60`

Usage: `store #data[7:0], address[15:0], offset[7:0]`
## store_imm_indir_noffset


store imm value to indirect (address) - offset

This instruction modifies the flags register

short: `store_imm_indir_noffset`

opcode: `0x61`

Usage: `store #data[7:0], address[15:0], offset[7:0]`
## xfr_set_len_imm


init transfer. set length to immediate value. limit 255 bytes/words

short: `xfr_set_len_imm`

opcode: `0x80`

Usage: `xfr_set_len #len[7:0]`
## xfr_set_len_a


init transfer. set length. limit 255 bytes/words

short: `xfr_set_len_a`

opcode: `0x81`

Usage: `xfr_set_len a`
## xfr_set_dest_dir


transfer setup - set destination address to direct addr

short: `xfr_set_dest_dir`

opcode: `0x84`

Usage: `xfr_set_dst dst[15:0]`
## xfr_set_src_dir


transfer setup - set source address to direct addr

short: `xfr_set_src_dir`

opcode: `0x88`

Usage: `xfr src[15:0]`
## xfr_set_src_indir


transfer setup - set source address to indirect addr

short: `xfr_set_src_indir`

opcode: `0x89`

Usage: `xfr (src[15:0])`
## xfr8_loop


Microcode for byte transfer loop. xfr setup instruction must be called immediately before

This instruction modifies the flags register

short: `xfr8_loop`

opcode: `0x8C`

Usage: `xfr8_loop`
## xfr8_loop_no_incr_dst


Microcode for byte transfer loop. Will not increment dst pointer. xfr setup instruction must be called immediately before

This instruction modifies the flags register

short: `xfr8_loop_no_incr_dst`

opcode: `0x8D`

Usage: `xfr8_loop_no_incr_dst`
## xfr8_loop_no_incr_src


Microcode for byte transfer loop. Will not increment src pointer. xfr setup instruction must be called immediately before

This instruction modifies the flags register

short: `xfr8_loop_no_incr_src`

opcode: `0x8E`

Usage: `xfr8_loop_no_incr_src`