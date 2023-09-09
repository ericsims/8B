#include "../CPU.asm"

#bank rom

top:
init_pointers:
loadw sp, #0xBFFF
storew #0x0000, BP

test_ext_rom_move:
storew #dest, static_ext_move_block_dst
storew #0x0000, static_ext_move_block_src
storew #test_length, static_ext_move_block_len

call static_ext_move_block

done:
halt 

#include "../lib/ext_mem_utils.asm"

#bank ram
test_length = 0x51 ; about the len of this progam
dest:
    #res test_length ; random bytes 