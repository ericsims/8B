
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
|00|nop|-|-|-|
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
|74|ret|-|-|-|
|78|assert_a|assert_b|assert_hl|assert_cf|
|7C|assert_zf|assert_nf|-|halt|
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

opcode: 0x00

Usage:

```asm
nop
```
## Load A Immediate


Load a register with immediate value

A <-- IMM


opcode: 0x04

Usage:

```asm
load a, #data[7:0]
```
## Load A Direct


load a register from direct address

A <-- MEM(IMM)


opcode: 0x05

Usage:

```asm
load a, addresss[15:0]
```
## Load A Indirect


load a register from indirect address

A <-- MEM(MEM(IMM))


opcode: 0x06

Usage:

```asm
load a, (address[15:0])
```
## Load HL with Stack Pointer


load hl with the address of the stack pointer register

HL <-- SP


opcode: 0x07

Usage:

```asm
loadw hl, sp
```
## Load B Immediate


load b register with immediate value

opcode: 0x08

Usage:

```asm
load b, #data[7:0]
```
## Load B Direct


load b register from direct address

B <-- MEM(IMM)


opcode: 0x09

Usage:

```asm
load b, addresss[15:0]
```
## Load B Indirect


load a register from indirect address

A <-- MEM(MEM(IMM))


opcode: 0x0A

Usage:

```asm
load b, (address[15:0])
```
## Load HL Indirect HL


load hl register with word from indirect address in hl register

HL <-- MEM(HL)


opcode: 0x0B

Usage:

```asm
loadw hl, (hl)
```
## Load HL Immediate


load hl register with immediate word

HL <-- IMM


opcode: 0x0C

Usage:

```asm
loadw hl, #data[15:0]
```
## Load HL Direct


load hl register from word from direct address

HL <-- MEM(IMM)


opcode: 0x0D

Usage:

```asm
loadw hl, address[15:0]
```
## Load A B


Load a register with value in b register

A <-- B


opcode: 0x13

Usage:

```asm
load a, b
```
## Add HL A


add a to hl word and save to hl word

HL <-- HL + A


opcode: 0x14

Usage:

```asm
addw hl, a
```

This instruction modifies the flags register
## Add HL B


add b to hl word and save to hl word

HL <-- HL + B


opcode: 0x15

Usage:

```asm
addw hl, b
```

This instruction modifies the flags register
## Add HL Immediate


add imm byte to hl word and save to hl word

HL <-- HL + IMM


opcode: 0x16

Usage:

```asm
addw hl, #data[7:0]
```

This instruction modifies the flags register
## Subtract HL A


subtract a byte from hl word and save to hl word

HL <-- HL - A


opcode: 0x1C

Usage:

```asm
subw hl, a
```

This instruction modifies the flags register
## Subtract HL B


subtract b byte from hl word and save to hl word

HL <-- HL - B


opcode: 0x1D

Usage:

```asm
subw hl, b
```

This instruction modifies the flags register
## Subtract HL Immediate


subtract imm byte to hl word and save to hl word

HL <-- HL - IMM


opcode: 0x1E

Usage:

```asm
subw hl, #data[7:0]
```

This instruction modifies the flags register
## Load B A


Load b register with value in a register

B <-- A


opcode: 0x17

Usage:

```asm
load b, a
```
## Load SP Immediate


load sp register with immediate word

SP <-- IMM


opcode: 0x1B

Usage:

```asm
loadw sp, #data[15:0]
```
## Add A B


add a register to b register and save to a

A <-- A + B


opcode: 0x10

Usage:

```asm
add a, b
```

This instruction modifies the flags register
## Add A Immediate


add a register to imm value and save to a

A <-- A + IMM


opcode: 0x11

Usage:

```asm
add a, #data[7:0]
```

This instruction modifies the flags register
## Add B Immediate


add b register to imm value and save to b

B <-- B + IMM


opcode: 0x12

Usage:

```asm
add b, #data[7:0]
```

This instruction modifies the flags register
## Subtract A B


Subtract b register from a register and save to a

A <-- A - B


opcode: 0x18

Usage:

```asm
sub a, b
```

This instruction modifies the flags register
## Subtract A Immediate


subtract imm value from a register and save to a

A <-- A - IMM


opcode: 0x19

Usage:

```asm
sub a, #data[7:0]
```

This instruction modifies the flags register
## Subtract B Immediate


subtract imm value from b register and save to b

B <-- B - IMM


opcode: 0x1A

Usage:

```asm
sub b, #data[7:0]
```

This instruction modifies the flags register
## Bitwise And A B


Bitwise AND a register with b register and save to a

A <-- A & B


opcode: 0x20

Usage:

```asm
and a, b
```

This instruction modifies the flags register
## Bitwise And A Immediate


Bitwise AND a register with imm value and save to a

A <-- A & IMM


opcode: 0x21

Usage:

```asm
and a, #data[7:0]
```

This instruction modifies the flags register
## Bitwise And B Immediate


Bitwise AND B register with imm value and save to B

B <-- B & IMM


opcode: 0x22

Usage:

```asm
and b, #data[7:0]
```

This instruction modifies the flags register
## Bitwise Or A B


Bitwise OR a register with b register and save to a

A <-- A | B


opcode: 0x24

Usage:

```asm
or a, b
```

This instruction modifies the flags register
## Bitwise Or A Immediate


Bitwise OR a register with imm value and save to a

A <-- A | IMM


opcode: 0x25

Usage:

```asm
or a, #data[7:0]
```

This instruction modifies the flags register
## Bitwise Or B Immediate


Bitwise OR b register with imm value and save to b

B <-- B | IMM


opcode: 0x26

Usage:

```asm
or b, #data[7:0]
```

This instruction modifies the flags register
## Bitwise Xor A B


Bitwise XOR a register with b register and save to a

A <-- A ^ B


opcode: 0x28

Usage:

```asm
xor a, b
```

This instruction modifies the flags register
## Bitwise Xor A Immediate


Bitwise XOR a register with immediate value and save to a register.

A <-- A ^ IMM


opcode: 0x29

Usage:

```asm
xor a, #data[7:0]
```

This instruction modifies the flags register
## Bitwise Xor B Immediate


Bitwise XOR B register with immediate value and save to B register.

B <-- B ^ IMM


opcode: 0x2A

Usage:

```asm
xor b, #data[7:0]
```

This instruction modifies the flags register
## Bitwise Left Shift A


Bitwise shift left A register by one and save to A register. Zero is shifted into LSB.

A <-- A << 1

ZF: set if result is zero
NF: set if result bit 7 is set
CF: set if bit shifted off of the left was set


opcode: 0x2C

Usage:

```asm
lshift a
```

This instruction modifies the flags register
## Bitwise Left Shift B


Bitwise shift left B register by one and save to B. Zero is shifted into LSB.

B <-- B << 1

ZF: set if result is zero
NF: set if result bit 7 is set
CF: set if bit shifted off of the left was set


opcode: 0x2D

Usage:

```asm
lshift b
```

This instruction modifies the flags register
## Bitwise Right Shift A


Bitwise shift right A register by one and save to A register. Zero is shifted into MSB.

A <-- A >> 1

ZF: set if result is zero
NF: set if result bit 7 is set
CF: set if bit shifted off of the right was set


opcode: 0x2E

Usage:

```asm
rshift a
```

This instruction modifies the flags register
## Bitwise Right Shift B


Bitwise shift right B register by one and save to B register. Zero is shifted into MSB.

B <-- B >> 1

ZF: set if result is zero
NF: set if result bit 7 is set
CF: set if bit shifted off of the right was set


opcode: 0x2F

Usage:

```asm
rshift b
```

This instruction modifies the flags register
## Store A Direct


Store A register value to direct address.

MEM(IMM) <-- A


opcode: 0x30

Usage:

```asm
store a, address[15:0]
```
## Store A Indirect


Store A register value to indirect address.

MEM(MEM(IMM)) <-- A


opcode: 0x31

Usage:

```asm
store a, (address[15:0])
```
## Store B Direct


Store B register value to direct address.

MEM(IMM) <-- B


opcode: 0x32

Usage:

```asm
store b, address[15:0]
```
## Store B Indirect


Store B register value to indirect address.

MEM(MEM(IMM)) <-- B


opcode: 0x33

Usage:

```asm
store b, (address[15:0])
```
## storew_hl_dir


Store hl register value to direct address

opcode: 0x34

Usage:

```asm
store hl, address[15:0]
```
## store_imm_dir


Store imm value to direct address

opcode: 0x3D

Usage:

```asm
store #data[7:0], address[15:0]
```
## storew_imm_dir


Store imm word to direct address

opcode: 0x3E

Usage:

```asm
storew #data[16:0], address[15:0]
```
## push_a


push a register value to stack

opcode: 0x38

Usage:

```asm
push a
```
## push_b


push b register value to stack

opcode: 0x39

Usage:

```asm
push b
```
## store_imm_hl_indir


store imm value to indirect address in hl register

opcode: 0x3F

Usage:

```asm
store #data[7:0], (hl)
```
## load_a_hl_indir


load a register from indirect address in hl register

opcode: 0x40

Usage:

```asm
load a, (hl)
```
## load_b_hl_indir


load b register from indirect address in hl register

opcode: 0x41

Usage:

```asm
load b, (hl)
```
## store_a_hl_indir


store a register to indirect address in hl register

opcode: 0x42

Usage:

```asm
store a, (hl)
```
## store_b_hl_indir


store b register to indirect address in hl register

opcode: 0x43

Usage:

```asm
store b, (hl)
```
## push_imm


push immediate value to stack

opcode: 0x3A

Usage:

```asm
push #data[7:0]
```
## push_dir


push byte from source to stack

opcode: 0x3B

Usage:

```asm
push address[15:0]
```
## push_indir


push byte from indirect source to stack

opcode: 0x3C

Usage:

```asm
push (address[15:0])
```
## pushw_imm


push immediate word to stack

opcode: 0x4C

Usage:

```asm
pushw #data[15:0]
```
## pushw_dir


push word from source to stack

opcode: 0x4D

Usage:

```asm
pushw address[15:0]
```
## alloc


allocate n bytes on stack

opcode: 0x4E

Usage:

```asm
alloc data[7:0]
```

This instruction modifies the flags register
## dealloc


deallocate n bytes from stack

opcode: 0x4F

Usage:

```asm
dealloc data[7:0]
```

This instruction modifies the flags register
## pushw_hl


push hl register onto stack

opcode: 0x50

Usage:

```asm
push hl
```
## popw_hl


pop word off of stack into hl register

opcode: 0x51

Usage:

```asm
pop hl
```
## pop_a


pop value off of stack into a register

opcode: 0x52

Usage:

```asm
pop a
```
## pop_b


pop value off of stack into b register

opcode: 0x53

Usage:

```asm
pop b
```
## move_dir_dir


copy byte from source to destination

opcode: 0x44

Usage:

```asm
move src[15:0], dst[15:0]
```
## move_dir_indir


copy byte from source to indirect destination

opcode: 0x45

Usage:

```asm
move src[15:0], (dst[15:0])
```
## move_indir_dir


copy byte from indirect source to destination

opcode: 0x46

Usage:

```asm
move (src[15:0]), dst[15:0]
```
## move_indir_indir


copy byte from indirect source to indirect destination

opcode: 0x47

Usage:

```asm
move (src[15:0]), (dst[15:0])
```
## movew_dir_dir


copy 2 byte word from source to destination

opcode: 0x48

Usage:

```asm
movew src[15:0], dst[15:0]
```
## jmp


Unconditional Jump

opcode: 0x64

Usage:

```asm
jmp address[15:0]
```
## jmp_hl


Jump to address in hl register

opcode: 0x62

Usage:

```asm
jmp hl
```
## call_hl


Call Subroutine in hl register

opcode: 0x63

Usage:

```asm
call hl
```
## jmz


Jump if Zero

opcode: 0x65

Usage:

```asm
jmz address[15:0]
```
## jnz


Jump if not Zero

opcode: 0x66

Usage:

```asm
jnz address[15:0]
```
## jmc


Jump if Carry

opcode: 0x67

Usage:

```asm
jmc address[15:0]
```
## jnc


Jump if not Carry

opcode: 0x68

Usage:

```asm
jnc address[15:0]
```
## jmn


Jump if Negative

opcode: 0x69

Usage:

```asm
jnc address[15:0]
```
## jnn


Jump if not Negative

opcode: 0x6A

Usage:

```asm
jnc address[15:0]
```
## call


Call Subroutine

opcode: 0x6B

Usage:

```asm
call address[15:0]
```
## test_a


tests value in a register and updates flags

opcode: 0x6C

Usage:

```asm
test a
```

This instruction modifies the flags register
## test_b


tests value in ab register and updates flags

opcode: 0x6D

Usage:

```asm
test b
```

This instruction modifies the flags register
## ret


Return from Subroutine

opcode: 0x74

Usage:

```asm
ret
```
## assert_a


Assert value of A register == imm value

opcode: 0x78

Usage:

```asm
assert a, #data[7:0]
```
## assert_b


Assert value of b register == imm value

opcode: 0x79

Usage:

```asm
assert b, #data[7:0]
```
## assert_hl


Assert value of hl register == imm value

opcode: 0x7A

Usage:

```asm
assert hl, #data[15:0]
```
## assert_cf


Assert value of CF == imm value

opcode: 0x7B

Usage:

```asm
assert cf, #data[7:0]
```
## assert_zf


Assert value of ZF == imm value

opcode: 0x7C

Usage:

```asm
assert zf, #data[7:0]
```
## assert_nf


Assert value of NF == imm value

opcode: 0x7D

Usage:

```asm
assert nf, #data[7:0]
```
## halt


Halts execution

opcode: 0x7F

Usage:

```asm
halt
```
## load_a_indir_poffset


load a register with value in (address) + offset

opcode: 0x54

Usage:

```asm
load a, address[15:0], offset[7:0]
```

This instruction modifies the flags register
## load_a_indir_noffset


load a register with value in (address) - offset

opcode: 0x55

Usage:

```asm
load a, address[15:0], offset[7:0]
```

This instruction modifies the flags register
## load_b_indir_poffset


load b register with value in (address) + offset

opcode: 0x56

Usage:

```asm
load b, address[15:0], offset[7:0]
```

This instruction modifies the flags register
## load_b_indir_noffset


load b register with value in (address) - offset

opcode: 0x57

Usage:

```asm
load b, address[15:0], offset[7:0]
```

This instruction modifies the flags register
## store_a_indir_poffset


store a register to indirect (address) + offset

opcode: 0x58

Usage:

```asm
store a, address[15:0], offset[7:0]
```

This instruction modifies the flags register
## store_a_indir_noffset


store a register to indirect (address) - offset

opcode: 0x59

Usage:

```asm
store a, address[15:0], offset[7:0]
```

This instruction modifies the flags register
## store_b_indir_poffset


store b register to indirect (address) + offset

opcode: 0x5A

Usage:

```asm
store b, address[15:0], offset[7:0]
```

This instruction modifies the flags register
## store_b_indir_noffset


store b register to indirect (address) - offset

opcode: 0x5B

Usage:

```asm
store b, address[15:0], offset[7:0]
```

This instruction modifies the flags register
## loadw_hl_indir_poffset


load hl register with value in (address) + offset

opcode: 0x5C

Usage:

```asm
loadw hl, address[15:0], offset[7:0]
```

This instruction modifies the flags register
## loadw_hl_indir_noffset


load hl register with value in (address) - offset

opcode: 0x5D

Usage:

```asm
loadw hl, addr[15:0], offset[7:0]
```

This instruction modifies the flags register
## storew_hl_indir_poffset


store hl register value in (address) + offset

opcode: 0x5E

Usage:

```asm
store hl, addr[15:0], offset[7:0]
```

This instruction modifies the flags register
## storew_hl_indir_noffset


store hl register value in (address) - offset

opcode: 0x5F

Usage:

```asm
storew hl, (address[15:0]), offset[7:0]
```

This instruction modifies the flags register
## store_imm_indir_poffset


store imm value to indirect (address) + offset

opcode: 0x60

Usage:

```asm
store #data[7:0], address[15:0], offset[7:0]
```

This instruction modifies the flags register
## store_imm_indir_noffset


store imm value to indirect (address) - offset

opcode: 0x61

Usage:

```asm
store #data[7:0], address[15:0], offset[7:0]
```

This instruction modifies the flags register
## xfr_set_len_imm


init transfer. set length to immediate value. limit 255 bytes/words

opcode: 0x80

Usage:

```asm
xfr_set_len #len[7:0]
```
## xfr_set_len_a


init transfer. set length. limit 255 bytes/words

opcode: 0x81

Usage:

```asm
xfr_set_len a
```
## xfr_set_dest_dir


transfer setup - set destination address to direct addr

opcode: 0x84

Usage:

```asm
xfr_set_dst dst[15:0]
```
## xfr_set_src_dir


transfer setup - set source address to direct addr

opcode: 0x88

Usage:

```asm
xfr src[15:0]
```
## xfr_set_src_indir


transfer setup - set source address to indirect addr

opcode: 0x89

Usage:

```asm
xfr (src[15:0])
```
## xfr8_loop


Microcode for byte transfer loop. xfr setup instruction must be called immediately before

opcode: 0x8C

Usage:

```asm
xfr8_loop
```

This instruction modifies the flags register
## xfr8_loop_no_incr_dst


Microcode for byte transfer loop. Will not increment dst pointer. xfr setup instruction must be called immediately before

opcode: 0x8D

Usage:

```asm
xfr8_loop_no_incr_dst
```

This instruction modifies the flags register
## xfr8_loop_no_incr_src


Microcode for byte transfer loop. Will not increment src pointer. xfr setup instruction must be called immediately before

opcode: 0x8E

Usage:

```asm
xfr8_loop_no_incr_src
```

This instruction modifies the flags register