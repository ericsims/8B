; ###
; fs.asm begin
; ###

SDCARD_ADDR = SDCARD+0
SDCARD_DATA = SDCARD+4
SDCARD_CTRL = SDCARD+5


#bank ram
mbr_parition_entry: ; 16 bytes, stored big-endian
.status: #res 1
.chs_start: #res 3
.partition_type: #res 1
.chs_end: #res 3
.lba_start: #res 4
.num_sectors: #res 4
.END:

partition_start_addr: #res 4

MBR_START_ADDR = 0x00000000
MBR_PART1_ADDR = MBR_START_ADDR + 0x1BE
MBR_PART2_ADDR = MBR_PART1_ADDR + 0x020
MBR_PART3_ADDR = MBR_PART2_ADDR + 0x020
MBR_PART4_ADDR = MBR_PART3_ADDR + 0x020
MBR_BOOT_SIGNATURE = MBR_START_ADDR + 0x1FE

FS_TYPE_EMPTY = 0x00
FS_TYPE_FAT16 = 0x06


fat16_boot_sector: ; 62 bytes, stored big-endian
.code: #res 3
.os_name: #res 8
.bytes_per_sector: #res 2
.sectors_per_cluser: #res 1
.reserved_sectors: #res 2
.num_fats: #res 1
.num_possible_root_entries: #res 2
.num_small_sectors: #res 2
.media_descriptor: #res 1
.sectors_per_fat: #res 2
.sectors_per_track: #res 2
.num_heads: #res 2
.hidden_sectors: #res 4
.num_large_sectors: #res 4
.drive_num: #res 1
.res_25: #res 1
.ext_boot_sig: #res 1
.volume_serial: #res 4
.volume_label: #res 11
.fs_type: #res 8
.END:

root_dir_sector: #res 2
root_dir_addr: #res 4

;;
; @function
; @brief copy from sd card to memory
; @section description
;      _________________________
; -12 |   .param32_start_addr   |
; -11 |                         |
; -10 |                         |
;  -9 |_________________________|
;  -8 |    .param16_dst_ptr     |
;  -7 |_________________________|
;  -6 |       .param16_len      |
;  -5 |_________________________|
;  -4 |____________?____________| RESERVED
;  -3 |____________?____________|    .
;  -2 |____________?____________|    .
;  -1 |____________?____________| RESERVED
;
;;
#bank rom
sd_mem_copy:
    .param32_start_addr = -12
    .param16_dst_ptr = -8
    .param16_len = -6
    .init:
        __prologue

        ; store 32bit start address in SDCARD ADDR
        loadw hl, (BP), .param32_start_addr
        storew hl, SDCARD_ADDR
        loadw hl, (BP), .param32_start_addr+2
        storew hl, SDCARD_ADDR+2

    .loop:
        ; check if len is zero
        loadw hl, (BP), .param16_len
        subw hl, #1
        jmc .done
        storew hl, (BP), .param16_len

        ; load dst_ptr
        loadw hl, (BP), .param16_dst_ptr
        ; copy byte
        load a, SDCARD_DATA
        store a, (hl)
        ; increment dst_ptr
        addw hl, #1
        storew hl, (BP), .param16_dst_ptr

        ; increment SDCARD ADDR
        loadw hl, SDCARD_ADDR+2
        addw hl, #1
        storew hl, SDCARD_ADDR+2
        jnc .loop
        ; handle carry
        loadw hl, SDCARD_ADDR
        addw hl, #1
        storew hl, SDCARD_ADDR

        jmp .loop

    .done:
        __epilogue
        ret

;;
; @function
; @brief reads MBR from SD card
; @section description
; Reads MBR (Master Boot Record) partition table from SD card
; stores in static mbr_parition_entry variable
;      _________________________
;  -4 |____________?____________| RESERVED
;  -3 |____________?____________|    .
;  -2 |____________?____________|    .
;  -1 |____________?____________| RESERVED
;
; @return status
;   -1 = general error
;   -2 = filesystem type not supported
;;
fs_read_mbr:
    .init:
        __prologue
    
    .load_mbr:
        storew #.str_loading_mbr, static_uart_print.data_pointer
        call static_uart_print

        __push32 #MBR_PART1_ADDR
        pushw #mbr_parition_entry
        pushw #(mbr_parition_entry.END-mbr_parition_entry)
        call sd_mem_copy
        dealloc 8

        ; debug
        ; pushw #mbr_parition_entry
        ; push #1
        ; call uart_dump_mem
        ; dealloc 3

        ..fix_endianenss:
            load a, mbr_parition_entry.chs_start
            load b, mbr_parition_entry.chs_start+2
            store a, mbr_parition_entry.chs_start+2
            store b, mbr_parition_entry.chs_start

            load a, mbr_parition_entry.chs_end
            load b, mbr_parition_entry.chs_end+2
            store a, mbr_parition_entry.chs_end+2
            store b, mbr_parition_entry.chs_end

            load a, mbr_parition_entry.lba_start
            load b, mbr_parition_entry.lba_start+3
            store a, mbr_parition_entry.lba_start+3
            store b, mbr_parition_entry.lba_start
            load a, mbr_parition_entry.lba_start+1
            load b, mbr_parition_entry.lba_start+2
            store a, mbr_parition_entry.lba_start+2
            store b, mbr_parition_entry.lba_start+1

            load a, mbr_parition_entry.num_sectors
            load b, mbr_parition_entry.num_sectors+3
            store a, mbr_parition_entry.num_sectors+3
            store b, mbr_parition_entry.num_sectors
            load a, mbr_parition_entry.num_sectors+1
            load b, mbr_parition_entry.num_sectors+2
            store a, mbr_parition_entry.num_sectors+2
            store b, mbr_parition_entry.num_sectors+1
            load a, mbr_parition_entry.num_sectors
            load b, mbr_parition_entry.num_sectors+3
            store a, mbr_parition_entry.num_sectors+3
    
        ..print:
            ; print parition 1
            storew #.str_partition, static_uart_print.data_pointer
            call static_uart_print

            push #1
            call uart_print_itoa_hex
            pop a
            call static_uart_print_newline

            call fs_print_partition_entry
            call static_uart_print_newline

    .check_partition:
        ; file system only support FAT16
        ; partition_type == 6
        load b, mbr_parition_entry.partition_type
        sub b, #FS_TYPE_FAT16
        jmz ..else
        ; print error
        storew #.str_error_filesystem_not_supported1, static_uart_print.data_pointer
        call static_uart_print
        load a, mbr_parition_entry.partition_type
        push a
        call uart_print_itoa_hex
        pop a
        storew #.str_error_filesystem_not_supported2, static_uart_print.data_pointer
        call static_uart_print
        ; return error code
        load b, #-2
        jmp .done
        ..else:

    .compute_partition_address:
        ; print partition address
        storew #.str_found_parition, static_uart_print.data_pointer
        call static_uart_print

        ; compute address
        ; assume 512 byte sector, i.e. partition start address = lba_start << 9
        ..byte0:
            load a, mbr_parition_entry.lba_start+1
            lshift a
            store a, partition_start_addr

        ..byte1:
            load a, mbr_parition_entry.lba_start+2
            lshift a
            store a, partition_start_addr+1
            jnc ..byte2
            ; handle carry
            load a, partition_start_addr
            add a, #1
            store a, partition_start_addr

        ..byte2:
            load a, mbr_parition_entry.lba_start+3
            lshift a
            store a, partition_start_addr+2
            jnc ..byte3
            ; handle carry
            load a, partition_start_addr+1
            add a, #1
            store a, partition_start_addr+1

        ..byte3:
            store #0x00, partition_start_addr+3

        ..print:
            loadw hl, partition_start_addr
            pushw hl
            loadw hl, partition_start_addr+2
            pushw hl
            call uart_print_itoa_hex32
            dealloc 4
            call static_uart_print_newline

    .read_f16_boot_sector:
        storew #.str_loading_fs, static_uart_print.data_pointer
        call static_uart_print

        loadw hl, partition_start_addr
        pushw hl
        loadw hl, partition_start_addr+2
        pushw hl
        pushw #fat16_boot_sector
        pushw #(fat16_boot_sector.END-fat16_boot_sector)
        call sd_mem_copy
        dealloc 8
    
        ; debug
        ; pushw #fat16_boot_sector
        ; push #4
        ; call uart_dump_mem
        ; dealloc 3

        ..fix_endianenss:
        load a, fat16_boot_sector.bytes_per_sector
        load b, fat16_boot_sector.bytes_per_sector+1
        store a, fat16_boot_sector.bytes_per_sector+1
        store b, fat16_boot_sector.bytes_per_sector
        
        load a, fat16_boot_sector.reserved_sectors
        load b, fat16_boot_sector.reserved_sectors+1
        store a, fat16_boot_sector.reserved_sectors+1
        store b, fat16_boot_sector.reserved_sectors

        load a, fat16_boot_sector.num_possible_root_entries
        load b, fat16_boot_sector.num_possible_root_entries+1
        store a, fat16_boot_sector.num_possible_root_entries+1
        store b, fat16_boot_sector.num_possible_root_entries

        load a, fat16_boot_sector.num_small_sectors
        load b, fat16_boot_sector.num_small_sectors+1
        store a, fat16_boot_sector.num_small_sectors+1
        store b, fat16_boot_sector.num_small_sectors

        load a, fat16_boot_sector.sectors_per_fat
        load b, fat16_boot_sector.sectors_per_fat+1
        store a, fat16_boot_sector.sectors_per_fat+1
        store b, fat16_boot_sector.sectors_per_fat

        load a, fat16_boot_sector.sectors_per_track
        load b, fat16_boot_sector.sectors_per_track+1
        store a, fat16_boot_sector.sectors_per_track+1
        store b, fat16_boot_sector.sectors_per_track

        load a, fat16_boot_sector.num_heads
        load b, fat16_boot_sector.num_heads+1
        store a, fat16_boot_sector.num_heads+1
        store b, fat16_boot_sector.num_heads

        load a, fat16_boot_sector.hidden_sectors
        load b, fat16_boot_sector.hidden_sectors+3
        store a, fat16_boot_sector.hidden_sectors+3
        store b, fat16_boot_sector.hidden_sectors
        load a, fat16_boot_sector.hidden_sectors+1
        load b, fat16_boot_sector.hidden_sectors+2
        store a, fat16_boot_sector.hidden_sectors+2
        store b, fat16_boot_sector.hidden_sectors+1

        load a, fat16_boot_sector.num_large_sectors
        load b, fat16_boot_sector.num_large_sectors+3
        store a, fat16_boot_sector.num_large_sectors+3
        store b, fat16_boot_sector.num_large_sectors
        load a, fat16_boot_sector.num_large_sectors+1
        load b, fat16_boot_sector.num_large_sectors+2
        store a, fat16_boot_sector.num_large_sectors+2
        store b, fat16_boot_sector.num_large_sectors+1

        load a, fat16_boot_sector.volume_serial
        load b, fat16_boot_sector.volume_serial+3
        store a, fat16_boot_sector.volume_serial+3
        store b, fat16_boot_sector.volume_serial
        load a, fat16_boot_sector.volume_serial+1
        load b, fat16_boot_sector.volume_serial+2
        store a, fat16_boot_sector.volume_serial+2
        store b, fat16_boot_sector.volume_serial+1

        ..print:
            call fs_print_boot_sector
    
    .check_sector_size:
        ; sector must be 512 bytes
        load a, fat16_boot_sector.bytes_per_sector+1
        test a
        jnz ..sector_size_error
        load a, fat16_boot_sector.bytes_per_sector
        sub a, #0x02
        jnz ..sector_size_error
        jmp ..continue
        ..sector_size_error:
            storew #.str_error_sector_size, static_uart_print.data_pointer
            call static_uart_print
            load b, #-1
            jmp .done
    ..continue:



    .find_root_dir:
        ; ROOT_DIR_SECTOR_NUM = SECTORS_PER_FAT * NUM_FATS + RESERVED_SECTORS
        storew #0x0000, root_dir_sector
        load a, fat16_boot_sector.num_fats
        ..compute_root_dir:
            ; SECTORS_PER_FAT * NUM_FATS 
            sub a, #1
            jmc ...break
            push a
            ...lsb:
                load b, root_dir_sector+1
                load a, fat16_boot_sector.sectors_per_fat+1
                add a, b
                store a, root_dir_sector+1
                jnc ....nocarry
                ....carry:
                    load b, root_dir_sector
                    add b, #1
                    store b, root_dir_sector
                ....nocarry:

            ...msb:
                load b, root_dir_sector
                load a, fat16_boot_sector.sectors_per_fat
                add a, b
                store a, root_dir_sector
                pop a
            
            jmp ..compute_root_dir
            ...break:

            ...offset:
            ; root_dir_sector += RESERVED_SECTORS
                load b, root_dir_sector+1
                load a, fat16_boot_sector.reserved_sectors+1
                add a, b
                store a, root_dir_sector+1
                jnc ....nocarry
                ....carry:
                    load b, root_dir_sector
                    add b, #1
                    store b, root_dir_sector
                ....nocarry:
                load b, root_dir_sector
                load a, fat16_boot_sector.reserved_sectors
                add a, b
                store a, root_dir_sector

            pushw root_dir_sector
            call seek_to_sector
            popw hl
            movew SDCARD_ADDR, root_dir_addr
            movew SDCARD_ADDR+2, root_dir_addr+2

        ..print:
            storew #.str_root_sector_num, static_uart_print.data_pointer
            call static_uart_print

            pushw root_dir_sector
            call uart_print_itoa_hex16
            popw hl

            call static_uart_print_newline
            
            storew #.str_root_addr, static_uart_print.data_pointer
            call static_uart_print

            pushw root_dir_addr
            pushw root_dir_addr+2
            call uart_print_itoa_hex32
            dealloc 4

            call static_uart_print_newline

    pushw root_dir_sector
    call fs_print_dir_info
    dealloc 2



    load b, #0

    .done:
        __epilogue
        ret
    
    .str_loading_mbr: #d "Loading Master Boot Record...\n\0"
    .str_partition: #d "MBR Partition \0"
    .str_error_filesystem_not_supported1: #d "ERROR. FILESYSTEM TYPE \0"
    .str_error_filesystem_not_supported2: #d " IS NOT SUPPORTED!\n\0"
    .str_error_sector_size: #d "ERROR. SECTOR SIZE IS NOT 0x0200!\n\0"
    .str_found_parition: #d "Found FAT16 partition. Start addr: \0"
    .str_loading_fs: #d "Loading File System Boot Sector...\n\0"
    .str_root_sector_num: #d "root sector: \0"
    .str_root_addr: #d "root dir start addr: \0"

#bank rom
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
fs_print_partition_entry:
    .init:
    __prologue

    .print_status:
        ; 1 byte status
        storew #.str_status, static_uart_print.data_pointer
        call static_uart_print

        push mbr_parition_entry.status
        call uart_print_itoa_hex
        pop a

        call static_uart_print_newline
    
    .print_part_type:
        ; 1 byte partition type
        storew #.str_part_type, static_uart_print.data_pointer
        call static_uart_print

        push mbr_parition_entry.partition_type
        call uart_print_itoa_hex
        pop a

        call static_uart_print_newline

    .print_chs_start:
        ; 3 byte chs start
        storew #.str_chs_start, static_uart_print.data_pointer
        call static_uart_print

        pushw mbr_parition_entry.chs_start
        push mbr_parition_entry.chs_start+2
        call uart_print_itoa_hex24
        dealloc 3

        call static_uart_print_newline

    .print_chs_end:
        ; 3 byte chs end
        storew #.str_chs_end, static_uart_print.data_pointer
        call static_uart_print

        pushw mbr_parition_entry.chs_end
        push mbr_parition_entry.chs_end+2
        call uart_print_itoa_hex24
        dealloc 3

        call static_uart_print_newline

    .print_lba_start:
        ; 4 byte lba start
        storew #.str_lba_start, static_uart_print.data_pointer
        call static_uart_print

        pushw mbr_parition_entry.lba_start
        pushw mbr_parition_entry.lba_start+2
        call uart_print_itoa_hex32
        dealloc 4

        call static_uart_print_newline
    
    .print_num_sectors:
        ; 4 byte number of sectors
        storew #.str_num_sectors, static_uart_print.data_pointer
        call static_uart_print

        pushw mbr_parition_entry.num_sectors
        pushw mbr_parition_entry.num_sectors+2
        call uart_print_itoa_hex32
        dealloc 4

        call static_uart_print_newline
    
    .done:
        __epilogue
        ret
    
    .str_status: #d "\tstatus: \0"
    .str_chs_start: #d "\tchs start: \0"
    .str_part_type: #d "\tpartition type: \0"
    .str_chs_end: #d "\tchs end: \0"
    .str_lba_start: #d "\tlba start: \0"
    .str_num_sectors: #d "\tnum sectors: \0"


#bank rom
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
fs_print_boot_sector:
    .init:
    __prologue
    storew #.str_header, static_uart_print.data_pointer
    call static_uart_print

    .print_bytes_per_sector:
    storew #.str_bytes_per_sector, static_uart_print.data_pointer
    call static_uart_print
    pushw fat16_boot_sector.bytes_per_sector
    call uart_print_itoa_hex16
    dealloc 2
    call static_uart_print_newline

    .print_sectors_per_cluster:
    storew #.str_sectors_per_cluster, static_uart_print.data_pointer
    call static_uart_print
    push fat16_boot_sector.sectors_per_cluser
    call uart_print_itoa_hex
    pop a
    call static_uart_print_newline
    
    .print_reserved_sectors:
    storew #.str_reserved_sectors, static_uart_print.data_pointer
    call static_uart_print
    pushw fat16_boot_sector.reserved_sectors
    call uart_print_itoa_hex16
    dealloc 2
    call static_uart_print_newline
    
    .print_num_fats:
    storew #.str_num_fats, static_uart_print.data_pointer
    call static_uart_print
    push fat16_boot_sector.num_fats
    call uart_print_itoa_hex
    pop a
    call static_uart_print_newline
    
    .print_sectors_per_fat:
    storew #.str_sectors_per_fat, static_uart_print.data_pointer
    call static_uart_print
    pushw fat16_boot_sector.sectors_per_fat
    call uart_print_itoa_hex16
    dealloc 2
    call static_uart_print_newline
    
    .print_ext_boot_sig:
    storew #.str_ext_boot_sig, static_uart_print.data_pointer
    call static_uart_print
    push fat16_boot_sector.ext_boot_sig
    call uart_print_itoa_hex
    pop a
    call static_uart_print_newline

    ; check for extended boot signature
    load a, fat16_boot_sector.ext_boot_sig
    sub a, #0x29
    jnz .done

    .print_volume_serial:
    storew #.str_volume_serial, static_uart_print.data_pointer
    call static_uart_print
    pushw fat16_boot_sector.volume_serial
    pushw fat16_boot_sector.volume_serial+2
    call uart_print_itoa_hex32
    dealloc 4
    call static_uart_print_newline

    .print_volume_label:
    storew #.str_volume_label, static_uart_print.data_pointer
    call static_uart_print
    storew #fat16_boot_sector.volume_label, static_uart_print.data_pointer
    store #11, static_uart_print_len.data_len
    call static_uart_print_len
    call static_uart_print_newline

    .print_fs_type:
    storew #.str_fs_type, static_uart_print.data_pointer
    call static_uart_print
    storew #fat16_boot_sector.fs_type, static_uart_print.data_pointer
    store #8, static_uart_print_len.data_len
    call static_uart_print_len
    call static_uart_print_newline

    .done:
    call static_uart_print_newline
    __epilogue
    ret

    .str_header: #d "FAT16 BIOS Parameter Block\n\0"
    .str_bytes_per_sector: #d "\tbytes per sector: \0"
    .str_sectors_per_cluster: #d "\tsectors per cluster: \0"
    .str_reserved_sectors: #d "\treserved sectors: \0"
    .str_num_fats: #d "\tnumber of FATs: \0"
    .str_sectors_per_fat: #d "\tsectors per FAT: \0"
    .str_ext_boot_sig: #d "\textended boot signature: \0"
    .str_volume_serial: #d "\tvolume serial number: \0"
    .str_volume_label: #d "\tvolume label: \0"
    .str_fs_type: #d "\tfile system type: \0"

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
seek_to_sector:
    .param16_sector_num = -6
    .init:
        __prologue

    .seek:
        ; addr = partition_start_addr + (ROOT_DIR_SECTOR_NUM)*BYTES_PER_SECTOR
        store #0x00, static_x_32
        load a, (BP), .param16_sector_num
        lshift a
        store a, static_x_32+1
        load a, (BP), .param16_sector_num+1
        lshift a
        store a, static_x_32+2
        jnc ..nocarry
        load a, static_x_32+1
        add a, #1
        store a, static_x_32+1
        ..nocarry:
        store #0x00, static_x_32+3

        movew partition_start_addr, static_y_32
        movew partition_start_addr+2, static_y_32+2
        call static_add32
        movew static_z_32, SDCARD_ADDR
        movew static_z_32+2, SDCARD_ADDR+2
    .done:
        __epilogue
        ret


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
fs_print_dir_info:
    .param16_sector_num = -6
    .init:
    __prologue

    loadw hl, (BP), .param16_sector_num 
    pushw hl
    call seek_to_sector
    popw hl

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
#include "./static_math.asm"