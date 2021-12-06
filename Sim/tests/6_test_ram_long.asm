#include "../CPU.asm"

pattern_1 = 0xFF
pattern_2 = 0x00
pattern_3 = 0x55
pattern_4 = 0xAA
pattern_5 = 0x00

#bank rom

; warning this uses assembler macros

store pattern_1, test_pattern
cal write_memory

store pattern_2, test_pattern
cal write_memory

store pattern_3, test_pattern
cal write_memory

store pattern_4, test_pattern
cal write_memory

store pattern_5, test_pattern
cal write_memory


hlt

error:
    load a, 0xFF
    tta 0x00 ; throw error
    hlt

write_memory:
    store ram_test_begining_address, addr_pointer
    .write:
        move [addr_pointer], test_pattern

        cal increment_pointer

        load a, addr_pointer
        load b, 0xBF
        sub
        jnz .write ; didn't reached end of mem
verify_mem:
    store ram_test_begining_address, addr_pointer
    .verify:
        load a, [addr_pointer]
        load b, test_pattern
        sub
        jnz error

        cal increment_pointer

        load a, addr_pointer
        load b, 0xBF
        sub
        jnz .verify ; didn't reached end of mem
        ret




increment_pointer:
    .increment_pointer_lsb:
        load a, addr_pointer+1
        load b, 0x01
        add
        store a, addr_pointer+1
        jnc .done
    .increment_pointer_msb:
        load a, addr_pointer
        load b, 0x01
        add
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