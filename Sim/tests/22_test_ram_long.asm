#include "../CPU.asm"

pattern_1 = 0xFF
pattern_2 = 0x00
pattern_3 = 0x55
pattern_4 = 0xAA
pattern_5 = 0x00

#bank rom

; warning this uses assembler macros

store #pattern_1, test_pattern
call write_memory

store #pattern_2, test_pattern
call write_memory

store #pattern_3, test_pattern
call write_memory

store #pattern_4, test_pattern
call write_memory

store #pattern_5, test_pattern
call write_memory


halt

error:
    load a, 0xFF
    assert a, #0x00 ; throw error
    halt

write_memory:
    storew #ram_test_begining_address, addr_pointer
    .write:
        move test_pattern, (addr_pointer)

        call increment_pointer

        load a, addr_pointer
        sub a, #0xBF
        jnz .write ; didn't reached end of mem
verify_mem:
    storew #ram_test_begining_address, addr_pointer
    .verify:
        load a, (addr_pointer)
        load b, test_pattern
        sub a, b
        jnz error

        call increment_pointer

        load a, addr_pointer
        load b, 0xBF
        sub a, b
        jnz .verify ; didn't reached end of mem
        ret




increment_pointer:
    .increment_pointer_lsb:
        load a, addr_pointer+1
        add a, #0x01
        store a, addr_pointer+1
        jnc .done
    .increment_pointer_msb:
        load a, addr_pointer
        add a, #0x01
        store a, addr_pointer
    .done:
        ret

#bank ram
addr_pointer:
    #res 2
test_pattern:
    #res 1
ram_test_begining_address:
    #res 1