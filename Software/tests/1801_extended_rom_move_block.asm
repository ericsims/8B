; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

test_ext_rom_move:
    storew #dest, static_ext_move_block_dst
    storew #0x0000, static_ext_move_block_src
    storew #test_length, static_ext_move_block_len

    call static_ext_move_block

done:
    halt 

; constants
test_length = 0x51 ; about the len of this progam

; includes
#include "../src/CPU.asm"
#include "../src/lib/ext_mem_utils.asm"

; global vars
#bank ram
dest: #res test_length ; random bytes 
STACK_BASE: #res 0