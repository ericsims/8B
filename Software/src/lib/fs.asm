; ###
; fs.asm begin
; ###

SDCARD_ADDR = SDCARD+0
SDCARD_DATA = SDCARD+4
SDCARD_CTRL = SDCARD+5

;;
; @function
; @brief ?
; @section description
;      _________________________
;  -4 |____________?____________| RESERVED
;  -3 |____________?____________|    .
;  -2 |____________?____________|    .
;  -1 |____________?____________| RESERVED
;
;;
fs_read_mbr:
    .init:
    __prologue


    load b, #15*4
    __store32 #0x000001BE, SDCARD_ADDR
    storew #part1, ptr

    .loop_read:
    move SDCARD_DATA, (ptr)
    loadw hl, ptr
    addw hl, #1
    storew hl, ptr
    loadw hl, SDCARD_ADDR+2
    addw hl, #1
    storew hl, SDCARD_ADDR+2
    sub b, #1
    jmc ..break
    jmp .loop_read
        ..break:

    
    .print:
    ; print parition 1
    storew #str_partition, static_uart_print.data_pointer
    call static_uart_print
    push #1
    call uart_print_itoa_hex
    pop a
    call static_uart_print_newline

    pushw #part1
    call fs_print_partition_entry
    dealloc 2
    call static_uart_print_newline

    ; hard coded lga start
    LGA_START_ADDR= 0x800
    P1_START_ADDR = LGA_START_ADDR*512
    __store32 #P1_START_ADDR, SDCARD_ADDR
    load b, #0xFF
    storew #boot_sector, ptr
    .loop_read_sectora:
    move SDCARD_DATA, (ptr)
    loadw hl, ptr
    addw hl, #1
    storew hl, ptr
    loadw hl, SDCARD_ADDR+2
    addw hl, #1
    storew hl, SDCARD_ADDR+2
    sub b, #1
    jmc ..break
    jmp .loop_read_sectora
        ..break:
    
    load b, #0xFF
    .loop_read_sectorb:
    move SDCARD_DATA, (ptr)
    loadw hl, ptr
    addw hl, #1
    storew hl, ptr
    loadw hl, SDCARD_ADDR+2
    addw hl, #1
    storew hl, SDCARD_ADDR+2
    sub b, #1
    jmc ..break
    jmp .loop_read_sectorb
    ..break:

    pushw #boot_sector
    call fs_print_bpb
    dealloc 2


    ; hard coded root dir start
    RESERVED_SECTORS = 0x04
    SECTORS_PER_FAT = 0x0020
    NUM_FATS = 0x02
    BYTES_PER_SECTOR = 0x0200
    ROOT_DIR_SECTOR_NUM = SECTORS_PER_FAT*NUM_FATS+RESERVED_SECTORS
    
    pushw #ROOT_DIR_SECTOR_NUM
    call fs_print_file_info
    dealloc 2


    .done:
    __epilogue
    ret
    
    str_partition: #d "partition \0"

#bank ram 
ptr: #res 2
part1: #res 16
part2: #res 16
part3: #res 16
part4: #res 16
#align 32*8
boot_sector: #res 512

#bank rom
;;
; @function
; @brief ?
; @section description
;      _________________________
;  -6 |    .param16_part_ptr    |
;  -5 |_________________________|
;  -4 |____________?____________| RESERVED
;  -3 |____________?____________|    .
;  -2 |____________?____________|    .
;  -1 |____________?____________| RESERVED
;
;;
fs_print_partition_entry:
    .param16_part_ptr = -6
    .init:
    __prologue

    .print_status:
    ; 1 byte status
    storew #.str_status, static_uart_print.data_pointer
    call static_uart_print
    loadw hl, (BP), .param16_part_ptr
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a
    call static_uart_print_newline

    .print_chs_start:
    ; 3 byte chs start
    storew #.str_chs_start, static_uart_print.data_pointer
    call static_uart_print
    loadw hl, (BP), .param16_part_ptr
    addw hl, #1+2
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a

    loadw hl, (BP), .param16_part_ptr
    addw hl, #1+1
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a

    loadw hl, (BP), .param16_part_ptr
    addw hl, #1+0
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a
    call static_uart_print_newline

    .print_part_type:
    ; 1 byte partition type
    storew #.str_part_type, static_uart_print.data_pointer
    call static_uart_print
    loadw hl, (BP), .param16_part_ptr
    addw hl, #4+0
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a
    call static_uart_print_newline

    .print_chs_end:
    ; 3 byte chs end
    storew #.str_chs_end, static_uart_print.data_pointer
    call static_uart_print
    loadw hl, (BP), .param16_part_ptr
    addw hl, #5+2
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a

    loadw hl, (BP), .param16_part_ptr
    addw hl, #5+1
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a

    loadw hl, (BP), .param16_part_ptr
    addw hl, #5+0
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a
    call static_uart_print_newline

    .print_lba_start:
    ; 4 byte lba start
    storew #.str_lba_start, static_uart_print.data_pointer
    call static_uart_print
    loadw hl, (BP), .param16_part_ptr
    addw hl, #8+3
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a

    loadw hl, (BP), .param16_part_ptr
    addw hl, #8+2
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a

    loadw hl, (BP), .param16_part_ptr
    addw hl, #8+1
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a

    loadw hl, (BP), .param16_part_ptr
    addw hl, #8+0
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a
    call static_uart_print_newline
    
    .print_num_sectors:
    ; 4 byte number of sectors
    storew #.str_num_sectors, static_uart_print.data_pointer
    call static_uart_print
    loadw hl, (BP), .param16_part_ptr
    addw hl, #12+3
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a

    loadw hl, (BP), .param16_part_ptr
    addw hl, #12+2
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a

    loadw hl, (BP), .param16_part_ptr
    addw hl, #12+1
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a

    loadw hl, (BP), .param16_part_ptr
    addw hl, #12+0
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a
    call static_uart_print_newline
    
    .done:
    __epilogue
    ret
    
    .str_status: #d "status: \0"
    .str_chs_start: #d "chs start: \0"
    .str_part_type: #d "partition type: \0"
    .str_chs_end: #d "chs end: \0"
    .str_lba_start: #d "lba start: \0"
    .str_num_sectors: #d "num sectors: \0"


#bank rom
;;
; @function
; @brief ?
; @section description
;      _________________________
;  -6 |    .param16_bpb_ptr     |
;  -5 |_________________________|
;  -4 |____________?____________| RESERVED
;  -3 |____________?____________|    .
;  -2 |____________?____________|    .
;  -1 |____________?____________| RESERVED
;
;;
fs_print_bpb:
    .param16_bpb_ptr = -6
    .init:
    __prologue
    storew #.str_header, static_uart_print.data_pointer
    call static_uart_print

    .print_bytes_per_sector:
    storew #.str_bytes_per_sector, static_uart_print.data_pointer
    call static_uart_print
    loadw hl, #boot_sector
    addw hl, #12
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a
    loadw hl, #boot_sector
    addw hl, #11
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a
    call static_uart_print_newline

    .print_sectors_per_cluster:
    storew #.str_sectors_per_cluster, static_uart_print.data_pointer
    call static_uart_print
    loadw hl, #boot_sector
    addw hl, #13
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a
    call static_uart_print_newline
    
    .print_reserved_sectors:
    storew #.str_reserved_sectors, static_uart_print.data_pointer
    call static_uart_print
    loadw hl, #boot_sector
    addw hl, #15
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a
    loadw hl, #boot_sector
    addw hl, #14
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a
    call static_uart_print_newline
    
    .print_num_fats:
    storew #.str_num_fats, static_uart_print.data_pointer
    call static_uart_print
    loadw hl, #boot_sector
    addw hl, #16
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a
    call static_uart_print_newline
    
    .print_sectors_per_fat:
    storew #.str_sectors_per_fat, static_uart_print.data_pointer
    call static_uart_print
    loadw hl, #boot_sector
    addw hl, #23
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a
    loadw hl, #boot_sector
    addw hl, #22
    load a, (hl)
    push a
    call uart_print_itoa_hex
    pop a
    call static_uart_print_newline

    .done:
    __epilogue
    ret

    .str_header: #d "\nPrinting FAT16 BIOS Parameter Block\n\0"
    .str_bytes_per_sector: #d "Bytes per sector: \0"
    .str_sectors_per_cluster: #d "sectors per cluster: \0"
    .str_reserved_sectors: #d "reserved sectors: \0"
    .str_num_fats: #d "number of FAT: \0"
    .str_sectors_per_fat: #d "sectors per FAT: \0"


#bank rom
;;
; @function
; @brief ?
; @section description
;      _________________________
;  -6 |   .param16_sector_num   |
;  -5 |_________________________|
;  -4 |____________?____________| RESERVED
;  -3 |____________?____________|    .
;  -2 |____________?____________|    .
;  -1 |____________?____________| RESERVED
;
;;
fs_print_file_info:
    .param16_sector_num = -6
    ; hard coded for now
    DIR_START_ADDR = P1_START_ADDR + (ROOT_DIR_SECTOR_NUM)*BYTES_PER_SECTOR
    .init:
    __prologue

    __store32 #DIR_START_ADDR, SDCARD_ADDR
    storew #.fileinfo, .ptr

    load b, #31
    .loop_read:
    move SDCARD_DATA, (.ptr)
    loadw hl, .ptr
    addw hl, #1
    storew hl, .ptr
    loadw hl, SDCARD_ADDR+2
    addw hl, #1
    storew hl, SDCARD_ADDR+2
    sub b, #1
    jmc ..break
    jmp .loop_read
        ..break:
    
    .print_file_name:
    storew #.fileinfo, static_uart_print.data_pointer
    call static_uart_print
    call static_uart_print_newline

    .done:
    __epilogue
    ret

#bank ram
    .fileinfo: #res 32
    .ptr: #res 2


#include "./char_utils.asm"