# Memory Copy

I have been using a simple memcpy routine that is similar to the [linux memcpy(3)](https://man7.org/linux/man-pages/man3/memcpy.3.html) function.

```asm
;;
; @function
; @brief static memcpy function
; @section description
; static memcpy copies from source to destination
; usage:
;   1. set static_memcpy.src_ptr to start of source memory
;   2. set static_memcpy.src_ptr to start of destination memory
;   3. set static_memcpy.len (16-bit) to number of bytes to copy
;   4. call static_memcpy
;;
#bank rom
static_memcpy:
    .copy:
        loadw hl, .len                  ; load remaining length value into 16-bit hl register
        subw hl, #1                     ; subtract 1
        jmc .done                       ; if this overflowed (carry out), len was 0, jump to done
        storew hl, .len                 ; save decremented length value

        move (.src_ptr), (.dst_ptr)     ; indirect copy value located in .src_ptr to .dst_ptr
        
        loadw hl, .src_ptr              ; load source pointer address into 16-bit hl register
        addw hl, #1                     ; increment
        storew hl, .src_ptr             ; save incremented value
        loadw hl, .dst_ptr              ; load desination pointer address into 16-bit hl register
        addw hl, #1                     ; increment
        storew hl, .dst_ptr             ; save incremented value
        
        jmp .copy                       ; jump back to .copy to loop
    .done:
        ret

#bank ram
    .src_ptr: #res 2                    ; static source pointer. points to next byte to copy
    .dst_ptr: #res 2                    ; static source pointer. points to next location to save byte
    .len: #res 2                        ; 16-bit length remaining
```


This function works just fine, but its main issue is how slow it is. The actual `move_indir_indir` instruction is 27 clock cycles long, which is not great, but the bigger deal is all pointer incrementing and len decrementing that takes place. In total, the copy label takes 138 clock cycles per loop!

There are lots of things that could speed this up, but here are some that I considered.

## option one - new instruction to speed up pointer increment

it takes 33 clock cycles to increment a 16-bit pointer (direct addressing)

```asm
loadw hl, .src_ptr          ; 12 clock cycles
addw hl, #1                 ; 9 clock cycles
storew hl, .src_ptr         ; 12 clock cycles
```

If I added a dedicated increment instruciton (maybe `incrw .src_ptr`, for increment word - direct address) this could speed up the loading into hl reg, add, then store operations.

- fetch: 3 clock cycles
- load word direct: 9 clock cycles
- increment word: 6 clock cycles
- store ord direct: 9 clock cycles
total: 27 clock cycles

```asm
incrw .src_ptr              ; 27 clock cycles (proposed instruction)
```

This also reduces the number of bytes of code required from 8 to 3, which is nice!

The speed up from 33 to 27 cycles for each increment is good, since this is done twice per loop, it that is 12 cycles off each loop, or about a 9% speed up. This is ok, but not really the improvement I was hoping for! I might consider adding an incr instruction anyways, since it makes for cleaner code.

## option two - DMA instruction??

Another option here could be to replace the enture memcpy routine with a microcoded dma or transfer function. It is  costly to move 16 bit values around on this system, and even more costly to increment a 16-bit value in the 8-bit ALU. What if, instead of using the ALU, the memory address register was used? This regiser supports incrementing with the `MC` control signal, so the 16 bit values do not need to costly 9 cycle increment.

But what aobut the desination pointer? Well, there is also the stack pointer address register that supports incrementing. Using this address register would be convienient, but would cause the stack pointer location to be lost when a memcpy occured. Perhaps I can just back up the stack pointer to a scratch reg...

This would be cool, but i would lose the memory address regiser on the next instruction fetch, so for this idea to work, the memory copy would have to complete in a single instruction. I could do this with a single unrolled, loop, but the micro code is limited to 32 clock cycles. What if instead, I looped ***in*** the microcode? This is not something that I have done before, but it seems possible. As long as the instruction register isn't updated, the microcode counter wil wrap over allowing for as many transfers as needed.

This would still require something to break out of this instruction, but this could be reasonably simple. Load an 8-bit value into the ALU, then keep decerementing, on carry out, update the instrucion register!

For this to work, this will need to be two instructions, one setup instruction, then the actual transfer itself.
setup instruction
1. instruction fetch, and increment program counter to next instruciotn
2. load 16-bit stack register into J scrach register (this it to back up stack register, to restore at the end)
3. load the immediate "value" into the D scartch register. This is the next instruction opcode to execute!
4. load length value into ALU X register
5. load 1 into ALU Y register
6. load 16-bit destination pointer address into K scrach register
7. Load K scrach register contents into  stack address register
5. load 16-bit source pointer address into memory address register
7. load D scratch register value into the instruciton register. This magic here allows the processor to execute transfer without discarding the memory address register!

transfer instruction
1. ALU subtract, store result in ALU X, if carry out, then restore stack pointer, fetch next instruction, and reset microcode counter. This magic will cause the instruction to end, breaking the loop
2. otherwise, load memory out into D scratch register
3. increment memory address register
4. load D scratch register into stack pointer
5. increment stack pointer
6. microcode counter reset. loop without a fetch cycle!

This should be wayyy faster, since it should only take a few 3 clock cycles per byte!

```yaml
  xfr8_dir_dir_imm:
    description: 'Transfers bytes from direct source to direct destination. limit 255 bytes'
    duration: 23  # clock cycles
    operands: 6  # direct source address, direct destination address, length, next opcode
    usage: 'xfr8 src[15:0], dst[15:0], #len[7:0]'
    opcode: 0x70
    asm_def: |
      xfr8 {src: i16}, {dst: i16}, #{len: i8} =>
      {
        {OPCODE} @ 0x71 @ len`8 @ dst`16 @ src`16 ; 0x71 is hardcoded xfr8_loop opcode
      }
    ucode:
      - [PO, MA, LM]         # Fetch cycle, load MAR with MSB in PC
      - [PO, MA]             # Fetch cycle, load MAR with LSB in PC
      - [CE, MO, II]         # Fetch cycle, increment PC, and load instruction into IR
      # save stack pointer
      - ['NO', JI, LM]       # Save stack pointer MSB in J scrach register
      - ['NO', JI]           # Save stack pointer LSB in J scrach register
      # load next intruction into d register
      - [MC, CE]             # Increment MAR to point to immediate instruction, keep up with program counter
      - [DI, MO]             # load D scratch register with immediate data
      # load length into ALU X register
      - [MC, CE]             # Increment MAR to point to immediate length, keep up with program counter
      - [XI, MO]             # load ALU X register with immediate data
      - [YI, ONE]            # load ALU Y register with 1
      # load destination pointer
      - [MC, CE]             # Increment MAR to point to immediate MSB, keep up with program counter
      - [KI, MO, LM]         # load K scratch register with dst pointer MSB
      - [MC, CE]             # Increment MAR to point to immediate LSB, keep up with program counter
      - [KI, MO]             # load K scratch register with dst pointer LSB
      - [KO, NI, LM]         # load stack pointer with K scratch register MSB
      - [KO, NI]             # load stack pointer with K scratch register LSB
      # load source pointer
      - [MC, CE]             # Increment MAR to point to immediate MSB, keep up with program counter
      - [KI, MO, LM]         # load K scratch register with sr pointer MSB
      - [MC, CE]             # Increment MAR to point to immediate LSB, keep up with program counter
      - [KI, MO]             # load K scratch register with src pointer LSB
      - [KO, MA, LM]         # load MAR with K scratch register MSB
      - [KO, MA]             # load MAR with K scratch register LSB
      # call xfr8_loop microcode
      - [DS, DO, II, RU]     # pre-decrement dst addr. load instruction register with opcode in D scratch register. Microcode reset

  xfr8_loop:
    description: 'Microcode for byte transfer loop. Do not call directly'
    duration: 4  # clock cycles
    operands: 0
    usage: ""
    opcode: 0x71
    asm_def: ""  # do not emmit an asm def, don't call this directly
    ucode:
      conditions: [CF]
      false:
        # no fetch!
        # decrement length
        - [SUB, XI, FI]      # subtract 1 from length in XI reg. Store back to X1, flags update
        - [MO, DI, IS]       # load byte from memory and store in D screatch reg. incrment dst addr
        - [DO, SI, MC, RU]   # store D scratch value to stack. increment MAR, and loop
      true:
        - [SUB, XI, FI]      # subtract 1 from legnth in XI reg. Store back to X1, flags update
        # if carry flag, stop transfer
        - [JO, NI, LM]       # restore stack pointer MSB
        - [JO, NI]           # restore stack pointer LSB
        # load next instruction
        - [PO, MA, LM]       # Fetch cycle, load MAR with MSB in PC
        - [PO, MA]           # Fetch cycle, load MAR with LSB in PC
        - [MO, II, RU]       # Fetch cycle, increment PC, and load instruction into IR
```



## results

using memcpy copying 149 bytes takes 2744 clock cycles.
```asm
    storew #test_src, static_memcpy.src_ptr
    storew #test_dst, static_memcpy.dst_ptr
    storew #(test_src.end - test_src), static_memcpy.len
    call static_memcpy
```

using xfr8_dir_dir_imm, this same copy takes 503 clock cyles! this is about 80% faster!

```asm
xfr8 test_src, test_dst, #(test_src.end - test_src)
```

