; autogenerated instruction definitions

#ruledef
{

; nop
; no operation
; usage: nop
nop =>
{
  0x00
}   

; load_a_imm
; Load a register with immediate value
; usage: load a, #data[7:0]
load a, #{imm: i8} =>
{
  assert(imm >= 0)
  assert(imm <= 0xff)
  0x04 @ imm`8
}

; load_a_dir
; load a register from direct address
; usage: load a, addresss[15:0]
load a, {addr: i16} =>
{
  assert(addr >= 0)
  assert(addr <= 0xffff)
  0x05 @ addr`16
}

; load_a_indir
; load a register from indirect address
; usage: load a, (address[15:0])
load a, ({addr: i16}) =>
{
  assert(addr >= 0)
  assert(addr <= 0xffff)
  0x06 @ addr`16
}

; load_b_imm
; load b register with immediate value
; usage: load b, #data[7:0]
load b, #{imm: i8} =>
{
  assert(imm >= 0)
  assert(imm <= 0xff)
  0x08 @ imm`8
}

; load_b_dir
; load b register from direct address
; usage: load b, addresss[15:0]
load b, {addr: i16} =>
{
  assert(addr >= 0)
  assert(addr <= 0xffff)
  0x09 @ addr`16
}

; load_b_indir
; load a register from indirect address
; usage: load b, (address[15:0])
load b, ({addr: i16}) =>
{
  assert(addr >= 0)
  assert(addr <= 0xffff)
  0x0A @ addr`16
}

; load_a_b
; Load a register with value in b register
; usage: load a, b
load a, b =>
{
  0x13
}

; load_b_a
; Load b register with value in a register
; usage: load b, a
load b, a =>
{
  0x17
}

; add_a_b
; add a register to b register and save to a
; usage: add a, b
add a, b =>
{
  0x10
}

; add_a_imm
; add a register to imm value and save to a
; usage: add a, #data[7:0]
add a, #{imm: i8} =>
{
  assert(imm >= 0)
  assert(imm <= 0xff)
  0x11 @ imm`8
}

; add_b_imm
; add b register to imm value and save to b
; usage: add b, #data[7:0]
add b, #{imm: i8} =>
{
  assert(imm >= 0)
  assert(imm <= 0xff)
  0x12 @ imm`8
}

; sub_a_b
; Subtract b register from a register and save to a
; usage: sub a, b
sub a, b =>
{
  0x18
}

; sub_a_imm
; subtract imm value from a register and save to a
; usage: sub a, #data[7:0]
sub a, #{imm: i8} =>
{
  assert(imm >= 0)
  assert(imm <= 0xff)
  0x19 @ imm`8
}

; sub_b_imm
; subtract imm value from b register and save to b
; usage: sub b, #data[7:0]
sub b, #{imm: i8} =>
{
  assert(imm >= 0)
  assert(imm <= 0xff)
  0x1A @ imm`8
}

; and_a_b
; Logical AND a register with b register and save to a
; usage: and a, b
and a, b =>
{
  0x20
}

; and_a_imm
; Logical AND a register with imm value and save to a
; usage: and a, #data[7:0]
and a, #{imm: i8} =>
{
  assert(imm >= 0)
  assert(imm <= 0xff)
  0x21 @ imm`8
}

; and_b_imm
; Logical AND b register with imm value and save to b
; usage: and b, #data[7:0]
and b, #{imm: i8} =>
{
  assert(imm >= 0)
  assert(imm <= 0xff)
  0x22 @ imm`8
}

; or_a_b
; Logical OR baregister with b register and save to a
; usage: or a, b
or a, b =>
{
  0x24
}  

; or_a_imm
; Logical OR a register with imm value and save to a
; usage: or a, #data[7:0]
or a, #{imm: i8} =>
{
  assert(imm >= 0)
  assert(imm <= 0xff)
  0x25 @ imm`8
}

; or_b_imm
; Logical OR b register with imm value and save to b
; usage: or b, #data[7:0]
or b, #{imm: i8} =>
{
  assert(imm >= 0)
  assert(imm <= 0xff)
  0x26 @ imm`8
}

; xor_a_b
; Logical XOR a register with b register and save to a
; usage: xor a, b
xor a, b =>
{
  0x28
}      

; xor_a_imm
; Logical XOR a register with imm value and save to a
; usage: xor a, #data[7:0]
xor a, #{imm: i8} =>
{
  assert(imm >= 0)
  assert(imm <= 0xff)
  0x29 @ imm`8
}

; xor_b_imm
; Logical XOR b register with imm value and save to b
; usage: xor b, #data[7:0]
xor b, #{imm: i8} =>
{
  assert(imm >= 0)
  assert(imm <= 0xff)
  0x2A @ imm`8
}

; lshift_a
; Logical shift left a register by one and save to a
; usage: lshift a
lshift a =>
{
  0x2C
}

; lshift_b
; Logical shift left b register by one and save to b
; usage: lshift b
lshift b =>
{
  0x2D
}

; rshift_a
; Logical shift right a register by one and save to a
; usage: rshift a
rshift a =>
{
  0x2E
}

; rshift_b
; Logical shift right b register by one and save to b
; usage: rshift b
rshift b =>
{
  0x2F
}

; store_a_dir
; Store a register value to direct address
; usage: store a, address[15:0]
store a, {addr: i16} =>
{
  assert(addr >= 0)
  assert(addr <= 0xffff)
  0x30 @ addr`16
}

; store_imm_dir
; Store imm value to direct address
; usage: store #data[7:0], address[15:0]
store #{imm: i8}, {addr: i16} =>
{
  assert(imm >= 0)
  assert(imm <= 0xff)
  assert(addr >= 0)
  assert(addr <= 0xffff)
  0x3D @imm`8 @ addr`16
}

; storew_imm_dir
; Store imm word to direct address
; usage: storew #data[16:0], address[15:0]
storew #{imm: i16}, {addr: i16} =>
{
  assert(imm >= 0)
  assert(imm <= 0xffff)
  assert(addr >= 0)
  assert(addr <= 0xffff)
  0x3E @imm`8 @ addr`16
}

; push_a
; push a register value to stack
; usage: push a
push a =>
{
  0x38
}

; push_b
; push b register value to stack
; usage: push b
push b =>
{
  0x39
}

; push_imm
; push immediate value to stack
; usage: push #data[7:0]
push #{imm: i8} =>
{
  assert(imm >= 0)
  assert(imm <= 0xff)
  0x3A @ imm`8
}

; push_dir
; push byte from source to stack
; usage: push address[15:0]
push {addr: i16} =>
{
  assert(addr >= 0)
  assert(addr <= 0xffff)
  0x3B @ addr`16
}

; push_indir
; push byte from indirect source to stack
; usage: push (address[15:0])
push ({addr: i16}) =>
{
  assert(addr >= 0)
  assert(addr <= 0xffff)
  0x3C @ addr`16
} 

; move_dir_dir
; copy byte from source to destination
; usage: move src[15:0], dst[15:0]
move {src: i16}, {dst: i16} =>
{
  assert(src >= 0)
  assert(src <= 0xffff)
  assert(dst >= 0)
  assert(dst <= 0xffff)
  0x44 @ src`16 @ dst`16
}

; move_dir_indir
; copy byte from source to indirect destination
; usage: move src[15:0], (dst[15:0])
move {src: i16}, ({dst: i16}) =>
{
  assert(src >= 0)
  assert(src <= 0xffff)
  assert(dst >= 0)
  assert(dst <= 0xffff)
  0x45 @ src`16 @ dst`16
}

; move_indir_dir
; copy byte from indirect source to destination
; usage: move (src[15:0]), dst[15:0]
move ({src: i16}), {dst: i16} =>
{
  assert(src >= 0)
  assert(src <= 0xffff)
  assert(dst >= 0)
  assert(dst <= 0xffff)
  0x46 @ src`16 @ dst`16
}

; move_indir_indir
; copy byte from indirect source to indirect destination
; usage: move (src[15:0]), (dst[15:0])
move ({src: i16}), ({dst: i16}) =>
{
  assert(src >= 0)
  assert(src <= 0xffff)
  assert(dst >= 0)
  assert(dst <= 0xffff)
  0x47 @ src`16 @ dst`16
}

; movew_dir_dir
; copy 2 byte word from source to destination
; usage: movew src[15:0], dst[15:0]
movew {src: i16}, {dst: i16} =>
{
  assert(src >= 0)
  assert(src <= 0xffff)
  assert(dst >= 0)
  assert(dst <= 0xffff)
  0x48 @ src`16 @ dst`16
}

; jmp
; Unconditional Jump
; usage: jmp address[15:0]
jmp {addr: i16} =>
{
  assert(addr >= 0)
  assert(addr <= 0xffff)
  0x6C @ addr`16
}

; jmz
; Jump if Zero
; usage: jmz address[15:0]
jmz {addr: i16} =>
{
  assert(addr >= 0)
  assert(addr <= 0xffff)
  0x6D @ addr`16
}

; jnz
; Jump if not Zero
; usage: jnz address[15:0]
jnz {addr: i16} =>
{
  assert(addr >= 0)
  assert(addr <= 0xffff)
  0x6E @ addr`16
}

; jmc
; Jump if Carry
; usage: jmc address[15:0]
jmc {addr: i16} =>
{
  assert(addr >= 0)
  assert(addr <= 0xffff)
  0x6F @ addr`16
}

; jnc
; Jump if not Carry
; usage: jnc address[15:0]
jnc {addr: i16} =>
{
  assert(addr >= 0)
  assert(addr <= 0xffff)
  0x70 @ addr`16
}

; call
; Call Subroutine
; usage: call address[15:0]
call {addr: i16} =>
{
  assert(addr >= 0)
  assert(addr <= 0xffff)
  0x73 @ addr`16
}

; ret
; Return from Subroutine
; usage: ret
ret  =>
{
  0x74
}

; assert_a
; Assert value of A register == imm value
; usage: assert a, #data[7:0]
assert a, #{imm: i8} =>
{
  assert(imm >= 0)
  assert(imm <= 0xff)
  0x78 @ imm`8
}

; assert_b
; Assert value of b register == imm value
; usage: assert b, #data[7:0]
assert b, #{imm: i8} =>
{
  assert(imm >= 0)
  assert(imm <= 0xff)
  0x79 @ imm`8
}

; assert_zf
; Assert value of ZF == imm value
; usage: assert zf, #data[7:0]
assert zf, #{imm: i8} =>
{
  assert(imm >= 0)
  assert(imm <= 0xff)
  0x7C @ imm`8
}

; halt
; Halts execution
; usage: halt
halt =>
{
  0x7F
}

}
