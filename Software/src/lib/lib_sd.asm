; ###
; lib_sd.asm begin
; ###
#once

SDCARD_DATA = SDCARD+0
SDCARD_CTRL = SDCARD+1

; GO_IDLE Software reset
SD_CMD0       = 0
SD_CMD0_ARG   = 0x00000000
SD_CMD0_CRC   = 0x94
; CHECK_V For SDC v2 only. Check voltage range.
SD_CMD8       = 8
SD_CMD8_ARG   = 0x0000001AA
SD_CMD8_CRC   = 0x86 ; (1000011 << 1)
; READ_SINGLE_BLOCK 
SD_CMD17      = 17
SD_CMD17_CRC  = 0x00 ; crc does not mattter for CMD17
; ACMD_LEADING Leading command of ACMD<n> command
SD_CMD55      = 55
SD_CMD55_ARG  = 0x00000000
SD_CMD55_CRC  = 0x00 ; crc does not mattter for CMD55
; READ_OCR Read Operation Conditions Register
SD_CMD58      = 58
SD_CMD58_ARG  = 0x00000000
SD_CMD58_CRC  = 0x00 ; crc does not mattter for CMD58
; APP_INIT For SDC only. Initiate initialization process.
SD_ACMD41     = 41
SD_ACMD41_ARG = 0x00000000
SD_ACMD41_CRC = 0x00

#bank ram
sd_buf: #res 0x200

#bank rom
;;
; @function
; @brief init sd card
; @section description
;      _______________________
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;
; @return returns 0 for sucess, otherwise returns the r1 error code
;;
sd_init:
    .init:
        __prologue

    .sync: ; send 80 clocks, with CS deasserted
        store #0x00, SDCARD_CTRL ; deassert CS
        store #0xFF, SDCARD_DATA
        store #0xFF, SDCARD_DATA
        store #0xFF, SDCARD_DATA
        store #0xFF, SDCARD_DATA
        store #0xFF, SDCARD_DATA
        store #0xFF, SDCARD_DATA
        store #0xFF, SDCARD_DATA
        store #0xFF, SDCARD_DATA

        store #0xFF, SDCARD_DATA ; wait

    .go_idle:
        store #0xFF, SDCARD_DATA ; wait
        
        store #0x01, SDCARD_CTRL ; assert CS

        push #SD_CMD0
        __push32 #SD_CMD0_ARG
        push #SD_CMD0_CRC
        call sd_cmd ; send CMD0
        dealloc 6

        call sd_read_resp1
        
        store #0xFF, SDCARD_DATA ; wait
        store #0x00, SDCARD_CTRL ; deassert CS
        store #0xFF, SDCARD_DATA ; wait
    
        ; r1 response left in b register
        load a, b
        sub a, #0x01 ; expect b = 0x01
        jnz .done ; leave error in b reg

    .check_v2:
        store #0xFF, SDCARD_DATA ; wait
        
        store #0x01, SDCARD_CTRL ; assert CS

        push #SD_CMD8
        __push32 #SD_CMD8_ARG
        push #SD_CMD8_CRC
        call sd_cmd ; send CMD8
        dealloc 6

        alloc 4
        call sd_read_resp5
        dealloc 4 ; discard r7 response bytes
        
        store #0xFF, SDCARD_DATA ; wait
        store #0x00, SDCARD_CTRL ; deassert CS
        store #0xFF, SDCARD_DATA ; wait
    
        ; r1 response left in b register
        load a, b
        sub a, #0x04 ; if r1 is illegal command, go to v1
        jmz .v1
        load a, b
        sub a, #0x01 ; if r1 is valid, go to v2
        jmz .v2
        jnz .done ; else, this is an error, break and leave error in b reg

    .v1:
    .cmd_58:
        store #0xFF, SDCARD_DATA ; wait
        
        store #0x01, SDCARD_CTRL ; assert CS

        push #SD_CMD58
        __push32 #SD_CMD58_ARG
        push #SD_CMD58_CRC
        call sd_cmd ; send CMD58
        dealloc 6

        alloc 4
        call sd_read_resp5
        dealloc 4 ; discard r3 response bytes
        ; TODO: consider actually checking OCR data

        store #0xFF, SDCARD_DATA ; wait
        store #0x00, SDCARD_CTRL ; deassert CS
        store #0xFF, SDCARD_DATA ; wait
    
        ; r1 response left in b register
        load a, b
        sub a, #0x01 ; expect b = 0x01
        jnz .done ; leave error in b reg

    .cmd_55:
        store #0xFF, SDCARD_DATA ; wait
        
        store #0x01, SDCARD_CTRL ; assert CS

        push #SD_CMD55
        __push32 #SD_CMD55_ARG
        push #SD_CMD55_CRC
        call sd_cmd ; send CMD55
        dealloc 6

        call sd_read_resp1

        store #0xFF, SDCARD_DATA ; wait
        store #0x00, SDCARD_CTRL ; deassert CS
        store #0xFF, SDCARD_DATA ; wait
    
        ; r1 response left in b register
        load a, b
        sub a, #0x01 ; expect b = 0x01
        jnz .done ; leave error in b reg

    .acmd_41:
        store #0xFF, SDCARD_DATA ; wait
        
        store #0x01, SDCARD_CTRL ; assert CS

        push #SD_ACMD41
        __push32 #SD_ACMD41_ARG
        push #SD_ACMD41_CRC
        call sd_cmd ; send ACMD41
        dealloc 6

        call sd_read_resp1

        store #0xFF, SDCARD_DATA ; wait
        store #0x00, SDCARD_CTRL ; deassert CS
        store #0xFF, SDCARD_DATA ; wait
    
        ; r1 response left in b register
        test b
        jmz .app_init ; if b = 0x00, init done
        load a, b
        sub a, #0x01 
        jmz .cmd_55 ; b = 0x01, init is still busy
        ; TODO: add a timeout here perhaps?
        jnz .done ; leave error in b reg

    .app_init:
        load b, #0x00
        jmp .done

    .v2:
        ; TODO: sdcard v2 init
        load b, #0x02
        jmp .done
    
    .done:
        __epilogue
        ret

;;
; @function
; @brief sends 6 byte sd command
; @section description
;      _______________________
; -10 |______.param8_cmd______|
;  -9 |______.param8_arg0_____|
;  -8 |______.param8_arg1_____|
;  -7 |______.param8_arg2_____|
;  -6 |______.param8_arg3_____|
;  -5 |______.param8_crc7_____|
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;
; @param .param8_cmd commnad byte
; @param .param8_arg0 - .param8_arg3 4 byte arg
; @param .param8_crc7 left adjusted
;;
sd_cmd:
    .param8_cmd = -10
    .param8_arg0 = -9
    .param8_arg1 = -8
    .param8_arg2 = -7
    .param8_arg3 = -6
    .param8_crc7 = -5
    .init:
        __prologue

    .send:
        ; TODO: this can be sped up
        load a, (BP), .param8_cmd
        or a, #0x40 ; set transmission bit
        store a, SDCARD_DATA ; send cmd
        load a, (BP), .param8_arg0
        store a, SDCARD_DATA ; send args
        load a, (BP), .param8_arg1
        store a, SDCARD_DATA ; send args
        load a, (BP), .param8_arg2
        store a, SDCARD_DATA ; send args
        load a, (BP), .param8_arg3
        store a, SDCARD_DATA ; send args
        load a, (BP), .param8_crc7
        or a, #0x01 ; set end bit
        store a, SDCARD_DATA ; send crc
    
    .done:
        __epilogue
        ret


;;
; @function
; @brief reads block at addr
; @section description
;      _______________________
;  -8 |    .param32_block     |
;  -7 |                       |
;  -6 |                       |
;  -5 |_______________________|
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;
; @param .param8_cmd commnad byte
;;
sd_read_block:
    .param32_block = -8
    .init:
        __prologue

    .cmd17:
        store #0xFF, SDCARD_DATA ; wait
        store #0x01, SDCARD_CTRL ; assert CS
        push #SD_CMD17
        loadw hl, (BP), .param32_block
        pushw hl
        loadw hl, (BP), .param32_block+2
        pushw hl
        push #SD_CMD17_CRC
        call sd_cmd ; send CMD17
        dealloc 6
        
        call sd_read_resp1
    
        load a, b
        sub a, #0x01 ; expect b = 0x01
        jnz .done ; leave error in b reg

    .wait_for_start_token:
        store #0xFF, SDCARD_DATA
        load a, SDCARD_DATA
        sub a, #0xFE
        jnz .wait_for_start_token
        ; TODO: include a timeout here

        loadw hl, #sd_buf ; output buffer poiner
        load b, #0x00
    .copy_256:
        store #0xFF, SDCARD_DATA
        load a, SDCARD_DATA
        store a, (hl)
        addw hl, #1
        add b, #1
        jnc .copy_256
    .copy_512:
        store #0xFF, SDCARD_DATA
        load a, SDCARD_DATA
        store a, (hl)
        addw hl, #1
        add b, #1
        jnc .copy_512

        store #0x00, SDCARD_CTRL ; deassert CS
        store #0xFF, SDCARD_DATA ; wait
    
        load b, #0x00
        
    .done:
        __epilogue
        ret

;;
; @function
; @brief reads response 1, returns in b reg
; @section description
;      _______________________
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;
;;
sd_read_resp1:
    store #0xFF, SDCARD_DATA
    load b, SDCARD_DATA
    ; TODO: check if b is 0xFF 8 times, then timeout
    ; load a, b
    ; sub a, #0xFF

    ret


;;
; @function
; @brief reads 5 bytes response, returns r1 in b reg
; @section description
;      _______________________
;  -8 |      .param32_r       |
;  -7 |                       |
;  -6 |                       |
;  -5 |_______________________|
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;
;;
sd_read_resp5:
    .param32_r = -8
    .init:
        __prologue
    .read:
        store #0xFF, SDCARD_DATA
        load b, SDCARD_DATA
        ; TODO: check if b is 0xFF 8 times, then timeout
        ; load a, b
        ; sub a, #0xFF
        store #0xFF, SDCARD_DATA
        load a, SDCARD_DATA
        store a, (BP), .param32_r
        store #0xFF, SDCARD_DATA
        load a, SDCARD_DATA
        store a, (BP), .param32_r+1
        store #0xFF, SDCARD_DATA
        load a, SDCARD_DATA
        store a, (BP), .param32_r+2
        store #0xFF, SDCARD_DATA
        load a, SDCARD_DATA
        store a, (BP), .param32_r+3
    .done:
        __epilogue
        ret

