; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
    pushw #str_1a
    pushw #str_1b
    call strcmp
    dealloc 4
    assert b, #0

    pushw #str_2a
    pushw #str_2b
    call strcmp
    dealloc 4
    assert b, #1
    
    pushw #str_3a
    pushw #str_3b
    call strcmp
    dealloc 4
    assert b, #1

    pushw #str_4a
    pushw #str_4b
    call strcmp
    dealloc 4
    assert b, #0

    pushw #str_5a
    pushw #str_5b
    call strcmp
    dealloc 4
    assert b, #1

    pushw #str_6a
    pushw #str_6b
    call strcmp
    dealloc 4
    assert b, #1

    pushw #str_7a
    pushw #str_7b
    call strcmp
    dealloc 4
    assert b, #0

    pushw #str_8a
    pushw #str_8b
    call strcmp
    dealloc 4
    assert b, #1
    
    halt

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"

str_1a: #d "\0"
str_1b: #d "\0"

str_2a: #d "a\0"
str_2b: #d "\0"

str_3a: #d "\0"
str_3b: #d "a\0"

str_4a: #d "abc\0"
str_4b: #d "abc\0"

str_5a: #d "abcdef\0"
str_5b: #d "abc\0"

str_6a: #d "abc\0"
str_6b: #d "abcdef\0"

str_7a: #d "wppjrxxcotmxdjwycjuwtyzxzoxdvyxmugbveqpygtrovmmgdroklmoktlbiapnekeefsqodwqicrnpedxkgsrmwjrcezphoolizhhkyuxcfcqhjfcephuzgplexscwg\0"
str_7b: #d "wppjrxxcotmxdjwycjuwtyzxzoxdvyxmugbveqpygtrovmmgdroklmoktlbiapnekeefsqodwqicrnpedxkgsrmwjrcezphoolizhhkyuxcfcqhjfcephuzgplexscwg\0"

str_8a: #d "wppjrxxcotmxdjwycjuwtyzxzoxdvyxmugbveqpygtrovmmgdroklmoktlbiapnekeefsqodwqicrnpedxkgsrmwjrcezphoolizhhkyuxcfcqhjfcephuzgplexscwG\0"
str_8b: #d "wppjrxxcotmxdjwycjuwtyzxzoxdvyxmugbveqpygtrovmmgdroklmoktlbiapnekeefsqodwqicrnpedxkgsrmwjrcezphoolizhhkyuxcfcqhjfcephuzgplexscwg\0"



; global vars
#bank ram
STACK_BASE: #res 0