; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:
test1:
    pushw #test_str1
    call cli_parse_cmd
    dealloc 2
    assert b, #1
    
test2:
    pushw #test_str2
    call cli_parse_cmd
    dealloc 2
    assert b, #2

test3:
    pushw #test_str3
    call cli_parse_cmd
    dealloc 2
    assert b, #-2

test4:
    pushw #test_str4
    call cli_parse_cmd
    dealloc 2
    assert b, #0

test5:
    pushw #test_str5
    call cli_parse_cmd
    dealloc 2
    assert b, #0

test6:
    pushw #str
    pushw #test_str6
    call strcpy
    dealloc 4
    
    pushw #str
    call cli_parse_cmd
    dealloc 2
    assert b, #-1

test7:
    pushw #str
    pushw #test_str7
    call strcpy
    dealloc 4
    
    pushw #str
    call cli_parse_cmd
    dealloc 2
    assert b, #0

test8:
    pushw #str
    pushw #test_str8
    call strcpy
    dealloc 4
    
    pushw #str
    call cli_parse_cmd
    dealloc 2
    assert b, #-1
    
test9:
    pushw #str
    pushw #test_str9
    call strcpy
    dealloc 4
    
    pushw #str
    call cli_parse_cmd
    dealloc 2
    assert b, #0
    
test10:
    pushw #str
    pushw #test_str10
    call strcpy
    dealloc 4
    
    pushw #str
    call cli_parse_cmd
    dealloc 2
    assert b, #0

test11:
    pushw #str
    pushw #test_str11
    call strcpy
    dealloc 4
    
    pushw #str
    call cli_parse_cmd
    dealloc 2
    assert b, #0

test12:
    pushw #str
    pushw #test_str12
    call strcpy
    dealloc 4
    
    pushw #str
    call cli_parse_cmd
    dealloc 2
    assert b, #0

test13:
    pushw #str
    pushw #test_str13
    call strcpy
    dealloc 4
    
    pushw #str
    call cli_parse_cmd
    dealloc 2
    assert b, #0

    load a, 0x5000
    assert a, #0xAB

test14:
    pushw #str
    pushw #test_str14
    call strcpy
    dealloc 4
    
    pushw #str
    call cli_parse_cmd
    dealloc 2
    assert b, #0

    loadw hl, 0x5000
    assert hl, #0xABCD

test15:
    pushw #str
    pushw #test_str15
    call strcpy
    dealloc 4
    
    pushw #str
    call cli_parse_cmd
    dealloc 2
    assert b, #0

    loadw hl, 0x5000
    assert hl, #0xDEAD
    loadw hl, 0x5002
    assert hl, #0xBEEF

halt:
    halt

#addr 0x1000
test_str1: #d "TEST1\0" ; this returns a 1. b = 1
test_str2: #d "TEST2\0" ; this returns a 2. b = 2
test_str3: #d "FAKE\0" ; command not found. b = -2
test_str4: #d "$?\0" ; b = 0
test_str5: #d "HELP\0" ; b = 0
test_str6: #d "READ8\0" ; this should error out, since not enough parameters. b = -1
test_str7: #d "READ8 1000\0" ; this should print a 54 for 'T'. b = 0
test_str8: #d "READ8 1000 \0" ; this should error out, since it has an extra parameters. b = -1
test_str9: #d "READ16 1000\0" ; this should print a 5445 for 'TE'. b = 0
test_str10: #d "READ32 1000\0" ; this should print a 54455354 for 'TEST'. b = 0
test_str11: #d "PRINT 1000\0" ; this should print a "TEST1". b = 0
test_str12: #d "DUMP 1000 04\0" ; this should dump 0x04 lines of memory at address 0x1000. b = 0
test_str13: #d "WRITE8 5000 AB\0" ; write 0xAB to 0x5000. b = 0
test_str14: #d "WRITE16 5000 ABCD\0" ; write 0xABCD to 0x5000. b = 0
test_str15: #d "WRITE32 5000 DEADBEEF\0" ; write 0xDEADBEEF to 0x5000. b = 0


; includes
#bank rom
#include "../src/CPU.asm"
#include "../src/lib/cli.asm"

; global vars
#bank ram
str: #res 256
STACK_BASE: #res 1024
#addr 0x5000
test_addr: #res 4