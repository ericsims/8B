; program entry
#bank rom
top:
init_pointers:
    loadw sp, #STACK_BASE
    storew #0x0000, BP

main:

    call w5300_init
    assert b, #0

    call print_net_info

    ; for now just hard code using socket 0
    store #Sn_CR_CLOSE, W5300_SOCK0+Sn_CR ; close existing socket if open
    store #Sn_MR1_TCP, W5300_SOCK0+Sn_MR1 ; set mode TCP
    store #Sn_CR_OPEN, W5300_SOCK0+Sn_CR ; open socket
    ; TODO: wait for SSR to go non zero?

    load a, W5300_SOCK0+Sn_SSR1
    assert a, #Sn_SSR1_SOCK_INIT ; SSR should be TCP mode

    ; Test example.org '104.18.2.24' 
    store #104, W5300_SOCK0+Sn_DIPR0 ; set IP
    store #18, W5300_SOCK0+Sn_DIPR1
    store #2, W5300_SOCK0+Sn_DIPR2
    store #24, W5300_SOCK0+Sn_DIPR3

    storew #80, W5300_SOCK0+Sn_DPORTR0; set port

    store #Sn_CR_CONNECT, W5300_SOCK0+Sn_CR ; connect

    load a, W5300_SOCK0+Sn_SSR1
    assert a, #Sn_SSR1_SOCK_ESTABLISHED ; conenction should be establisted

    ; TODO: fill buff

    store #Sn_CR_SEND, W5300_SOCK0+Sn_CR ; send
    
    halt

; includes
#include "../src/CPU.asm"
#include "../src/lib/lib_w5300.asm"

; global vars
#bank ram
STACK_BASE: #res 1024