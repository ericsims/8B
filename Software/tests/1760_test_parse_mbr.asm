; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    call fs_read_mbr
    halt


; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"
#include "../src/lib/fs.asm"

; global vars
#bank ram
STACK_BASE: #res 1024