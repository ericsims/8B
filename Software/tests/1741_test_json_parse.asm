; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:

    ; Test 1
    ; check with a bogus key, make sure there is no match
    pushw #data_test
    pushw #search_str1
    pushw #json_key_buf
    pushw #json_value_buf
    call json_parse
    dealloc 8
    assert b, #0 ; expecting no match


    ; Test 2
    ; Search for a string
    pushw #data_test
    pushw #search_str2
    pushw #json_key_buf
    pushw #json_value_buf
    call json_parse
    dealloc 8
    assert b, #1 ; expecting a string

    pushw #search_str2
    pushw #json_key_buf
    call strcmp
    dealloc 4
    assert b, #0 ; search_str2 = json_key_buf
    
    pushw #exp_res2
    pushw #json_value_buf
    call strcmp
    dealloc 4
    assert b, #0 ; exp_res2 = json_value_buf

    call print_key_val

    ; Test 3
    ; Search for a number
    pushw #data_test
    pushw #search_str3
    pushw #json_key_buf
    pushw #json_value_buf
    call json_parse
    dealloc 8
    assert b, #2 ; expecting a number

    pushw #search_str3
    pushw #json_key_buf
    call strcmp
    dealloc 4
    assert b, #0 ; search_str3 = json_key_buf
    
    pushw #exp_res3
    pushw #json_value_buf
    call strcmp
    dealloc 4
    assert b, #0 ; exp_res3 = json_value_buf
        
    call print_key_val

    halt

print_key_val:
    storew #json_key_buf, static_uart_print.data_pointer
    call static_uart_print
    call static_uart_print_newline

    storew #json_value_buf, static_uart_print.data_pointer
    call static_uart_print
    call static_uart_print_newline
    ret

; includes
#include "../src/CPU.asm"
#include "../src/lib/char_utils.asm"
#include "../src/lib/json_parse.asm"

data_test: #d incbin("./json_test_data4.json"), 0x00
search_str1: #d ".this.is.a.fake.key\0"

search_str2: #d ".properties.forecastOffice\0"
exp_res2: #d "https://api.weather.gov/offices/BOX\0"

search_str3: #d ".properties.relativeLocation.geometry.coordinates[01]\0"
exp_res3: #d "42.33196\0"

; global vars
#bank ram
json_key_buf: #res 128
json_value_buf: #res 128
STACK_BASE: #res 1024