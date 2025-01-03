;;
; @file
; @author Eric Sims
;
; @section Description
; tests moving data
;
; @section Test Coverage
; @coverage move_dir_dir move_indir_dir move_dir_indir move_indir_indir movew_dir_dir
;
;;

; program entry
#bank rom
top:
    ; test move from direct address to direct address
    store #0x12, location1
    move location1, location2
    load a, location2
    assert a, #0x12


    ; test move from indirect address to direct address
    store #0x23, location1
    storew #location1, pointer1
    move (pointer1), location2
    load a, location2
    assert a, #0x23

    ; test move from direct address to indirect address
    store #0x34, location1
    storew #location2, pointer2
    move location1, (pointer2)
    load a, location2
    assert a, #0x34

    ; test move from indirect address to indirect address
    store #0x45, location1
    move (pointer1), (pointer2)
    load a, location2
    assert a, #0x45

    ; test move work from direct address to direct address
    storew #0xBEEF, location1
    movew location1, location2
    loadw hl, location2
    assert hl, #0xBEEF

    halt

; constants
; -- none --

; includes
#include "../src/CPU.asm"

; global vars
#bank ram
location1: #res 2
location2: #res 2
pointer1: #res 2
pointer2: #res 2
