; ###
; ext_mem_utils.asm begin
; ###

#once

#bank ram
static_ext_move_block_len: #res 2 ; length
static_ext_move_block_src: #res 2 ; source pointer (in ext mem space)
static_ext_move_block_dst: #res 2 ; desination pointer (in mem space)
   
#bank rom
static_ext_move_block:
    ; source pointer (in ext mem space), desination pointer (in mem space), length
    ; this contaminates all parameters
    .loop:
    ; check if len has reached zero
    ; TODO: this could probably be done with hl, but the zero flag does not update
    load a, static_ext_move_block_len
    add a, #0x00
    jnz .process_byte
    load a, static_ext_move_block_len+1
    add a, #0x00
    jnz .process_byte
    jmp .done

    .process_byte:
    ; first save off new length value
    loadw hl, static_ext_move_block_len
    subw hl, #0x01
    storew hl, static_ext_move_block_len
    ; grab byte to a reg, incremte src ptr
    loadw hl, static_ext_move_block_src
    storew hl, EXT_ROM+1
    load a, EXT_ROM
    addw hl, #0x01
    storew hl, static_ext_move_block_src
    ; increment dst, and save byte
    loadw hl, static_ext_move_block_dst
    store a, (hl)
    addw hl, #0x01
    storew hl, static_ext_move_block_dst
    
    ; process next byte
    jmp .loop

    .done:
        ret


; ###
; ext_mem_utils.asm end
; ###