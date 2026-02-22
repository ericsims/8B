; ###
; fs.asm begin
; ###
#once

; SDCARD_ADDR = SDCARD+0
; SDCARD_DATA = SDCARD+4
; SDCARD_CTRL = SDCARD+5

MBR_BLOCK_ADDR = 0x00000000
; MBR_START_ADDR = 0x00000000
; MBR_PART1_ADDR = MBR_START_ADDR + 0x1BE
; MBR_PART2_ADDR = MBR_PART1_ADDR + 0x020
; MBR_PART3_ADDR = MBR_PART2_ADDR + 0x020
; MBR_PART4_ADDR = MBR_PART3_ADDR + 0x020
; MBR_BOOT_SIGNATURE = MBR_START_ADDR + 0x1FE

FS_TYPE_EMPTY = 0x00
FS_TYPE_FAT16 = 0x06

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

fileinfo: ; 32 bytes
    .name: #res 8
    .ext: #res 3
    .attributes: #res 1
    .reserved_0C: #res 1
    .creation_milli: #res 1
    .creation_time: #res 2
    .creation_date: #res 2
    .last_access_date: #res 2
    .reserved_14: #res 2
    .last_write_time: #res 2
    .last_write_date: #res 2
    .starting_cluser: #res 2
    .file_size: #res 4
    .END:

file_handle:
    .name: #res 8
    .ext: #res 3
    .next_cluster: #res 2
    .file_ptr: #res 4
    .file_size: #res 4
    .file_length_remanding: #res 4
    .END:

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
#bank rom
fs_read_mbr:
    .init:
        __prologue
    
    .load_mbr:
        storew #.str_loading_mbr, static_uart_print.data_pointer
        call static_uart_print

        __push32 #MBR_BLOCK_ADDR
        call sd_read_block
        dealloc 4

        xfr_set_len #(mbr_parition_entry.END-mbr_parition_entry)
        xfr_set_dst mbr_parition_entry
        xfr_set_src sd_buf+0x1BE
        xfr8_loop


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
    .fat16_start_block:
        ; print partition address
        storew #.str_found_parition, static_uart_print.data_pointer
        call static_uart_print
        loadw hl, mbr_parition_entry.lba_start
        pushw hl
        loadw hl, mbr_parition_entry.lba_start+2
        pushw hl
        call uart_print_itoa_hex32
        dealloc 4
        call static_uart_print_newline

    .read_f16_boot_sector:
        storew #.str_loading_fs, static_uart_print.data_pointer
        call static_uart_print

        loadw hl, mbr_parition_entry.lba_start
        pushw hl
        loadw hl, mbr_parition_entry.lba_start+2
        pushw hl
        call sd_read_block
        dealloc 4

        xfr_set_len #(fat16_boot_sector.END-fat16_boot_sector)
        xfr_set_dst fat16_boot_sector
        xfr_set_src sd_buf
        xfr8_loop

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
        ; root_dir_sector = sectors_per_fat * num_fats + reserved_sectors
        storew #0x0000, root_dir_sector
        load a, fat16_boot_sector.num_fats
        ..compute_root_dir:
            ; sectors_per_fat * num_fats 
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
            ; root_dir_sector += reserved_sectors
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

        ..print:
            storew #.str_root_sector_num, static_uart_print.data_pointer
            call static_uart_print

            pushw root_dir_sector
            call uart_print_itoa_hex16
            popw hl

            call static_uart_print_newline

        call static_uart_print_newline
    
    .list_root_dir:
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
    .str_found_parition: #d "Found FAT16 partition. Start block: \0"
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

    .print_num_possible_root_entries:
    storew #.str_num_root_entries, static_uart_print.data_pointer
    call static_uart_print
    pushw fat16_boot_sector.num_possible_root_entries
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
    .str_num_root_entries: #d "\tnumber of root entries: \0"
    .str_ext_boot_sig: #d "\textended boot signature: \0"
    .str_volume_serial: #d "\tvolume serial number: \0"
    .str_volume_label: #d "\tvolume label: \0"
    .str_fs_type: #d "\tfile system type: \0"

fs_read_directory_entry:
    .init:
    .fix_endianenss:
        load a, fileinfo.creation_time
        load b, fileinfo.creation_time+1
        store a, fileinfo.creation_time+1
        store b, fileinfo.creation_time

        load a, fileinfo.creation_date
        load b, fileinfo.creation_date+1
        store a, fileinfo.creation_date+1
        store b, fileinfo.creation_date

        load a, fileinfo.last_access_date
        load b, fileinfo.last_access_date+1
        store a, fileinfo.last_access_date+1
        store b, fileinfo.last_access_date

        load a, fileinfo.last_write_time
        load b, fileinfo.last_write_time+1
        store a, fileinfo.last_write_time+1
        store b, fileinfo.last_write_time

        load a, fileinfo.last_write_date
        load b, fileinfo.last_write_date+1
        store a, fileinfo.last_write_date+1
        store b, fileinfo.last_write_date

        load a, fileinfo.starting_cluser
        load b, fileinfo.starting_cluser+1
        store a, fileinfo.starting_cluser+1
        store b, fileinfo.starting_cluser

        load a, fileinfo.file_size
        load b, fileinfo.file_size+3
        store a, fileinfo.file_size+3
        store b, fileinfo.file_size
        load a, fileinfo.file_size+1
        load b, fileinfo.file_size+2
        store a, fileinfo.file_size+2
        store b, fileinfo.file_size+1
    .done:
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

        movew mbr_parition_entry.lba_start, static_x_32
        movew mbr_parition_entry.lba_start+2, static_x_32+2
        storew #0x0000, static_y_32
        loadw hl, (BP), .param16_sector_num 
        storew hl, static_y_32+2
        call static_add32

        pushw #0x0000
        pushw static_z_32+2
        call sd_read_block
        dealloc 4

        storew #sd_buf, xfr.src_ptr
    .load:
        xfr_set_len #0x20
        xfr_set_dst fileinfo
        xfr_set_src (xfr.src_ptr)
        xfr8_loop

        loadw hl, xfr.src_ptr
        addw hl, #0x20
        storew hl, xfr.src_ptr
        
        call fs_read_directory_entry
    
    
    ; debug
    ; pushw #fileinfo
    ; push #20
    ; call uart_dump_mem
    ; dealloc 3

    .print_file_line:
        load a, fileinfo
        test a
        jmz .done ; last file
        sub a, #0xE5
        jmz .load ; skip this file, it is empty

        storew #fileinfo.name, static_uart_print.data_pointer
        store #(8+3), static_uart_print_len.data_len ; 8 char file name + 3 char extension
        call static_uart_print_len

        store #" ", static_uart_putc.char
        call static_uart_putc
        call static_uart_putc

        pushw fileinfo.file_size
        pushw fileinfo.file_size+2
        call uart_print_itoa_hex32
        dealloc 4

        store #" ", static_uart_putc.char
        call static_uart_putc
        call static_uart_putc

        push fileinfo.attributes
        call uart_print_itoa_hex
        pop a

        store #" ", static_uart_putc.char
        call static_uart_putc
        call static_uart_putc

        pushw fileinfo.starting_cluser
        call uart_print_itoa_hex16
        popw hl

        call static_uart_print_newline

        jmp .load ; continue to next file in directory

    .done:
    call static_uart_print_newline
    __epilogue
    ret

;;
; @function
; @brief finds a file by filename
; @section description
;      _________________________
;  -6 |    .param16_name_ptr    |
;  -5 |_________________________|
;  -4 |____________?____________| RESERVED
;  -3 |____________?____________|    .
;  -2 |____________?____________|    .
;  -1 |____________?____________| RESERVED
;
;;
#bank rom
fs_find_file:
    .param16_name_ptr = -6
    .init:
        __prologue

        movew mbr_parition_entry.lba_start, static_x_32
        movew mbr_parition_entry.lba_start+2, static_x_32+2
        storew #0x0000, static_y_32
        movew root_dir_sector, static_y_32+2
        call static_add32

        pushw #0x0000
        pushw static_z_32+2
        call sd_read_block
        dealloc 4

        storew #sd_buf, xfr.src_ptr
    .load:
        xfr_set_len #0x20
        xfr_set_dst fileinfo
        xfr_set_src (xfr.src_ptr)
        xfr8_loop

        loadw hl, xfr.src_ptr
        addw hl, #0x20
        storew hl, xfr.src_ptr

        call fs_read_directory_entry

    .print_file_line:
        load a, fileinfo
        test a
        jmz .no_match ; last file
        sub a, #0xE5
        jmz .load ; skip this file, it is empty

        loadw hl, (BP), .param16_name_ptr
        pushw hl
        pushw #fileinfo.name
        call strcmp
        dealloc 4
        test b
        jmz .match

        jmp .load ; continue to next file in directory
    
    .match:
        movew fileinfo.file_size, file_handle.file_size
        movew fileinfo.file_size+2, file_handle.file_size+2
        movew fileinfo.starting_cluser, file_handle.next_cluster
        
        xfr_set_len #11
        xfr_set_dst file_handle.name
        xfr_set_src fileinfo.name
        xfr8_loop

        load b, #0
        __epilogue
        ret
        
    .no_match:
        load b, #1
        __epilogue
        ret


;;
; @function
; @brief ?
; @section description
;      _________________________
;  -6 |    .param16_dst_ptr     |
;  -5 |_________________________|
;  -4 |____________?____________| RESERVED
;  -3 |____________?____________|    .
;  -2 |____________?____________|    .
;  -1 |____________?____________| RESERVED
;
;;
#bank rom
load_file:
    .param16_dst_ptr = -6
    .init:
    __prologue

    storew #.str_loading_file, static_uart_print.data_pointer
    call static_uart_print

    ; root_dir_sector + lba_start
    storew #0x0000, static_x_32
    movew root_dir_sector, static_x_32+2
    movew mbr_parition_entry.lba_start, static_y_32
    movew mbr_parition_entry.lba_start+2, static_y_32+2
    call static_add32

    ; data_start_sector = root_dir_sector + 32 (dir size)
    movew static_z_32, static_x_32
    movew static_z_32+2, static_x_32+2
    storew #0x0000, static_y_32
    storew #0x0020, static_y_32+2
    call static_add32
    
    ; debug
    ; pushw static_z_32
    ; pushw static_z_32+2
    ; call uart_print_itoa_hex32
    ; call static_uart_print_newline
    ; dealloc 4

    ; data_sector = data_start_sector + (cluster-2)*4
    storew #0x0000, static_y_32
    loadw hl, file_handle.next_cluster
    subw hl, #2 ; first two clusters are not used
    storew hl, static_y_32+2

    movew static_z_32, static_x_32
    movew static_z_32+2, static_x_32+2
    call static_add32
    movew static_z_32, static_x_32
    movew static_z_32+2, static_x_32+2
    call static_add32
    movew static_z_32, static_x_32
    movew static_z_32+2, static_x_32+2
    call static_add32
    movew static_z_32, static_x_32
    movew static_z_32+2, static_x_32+2
    call static_add32

    ; debug
    ; pushw static_z_32
    ; pushw static_z_32+2
    ; call uart_print_itoa_hex32
    ; call static_uart_print_newline
    ; dealloc 4


    loadw hl, (BP), .param16_dst_ptr
    storew hl, static_memcpy.dst_ptr
    .load:
        pushw #0x0000
        pushw static_z_32+2
        call sd_read_block
        dealloc 4
        
        storew #sd_buf, static_memcpy.src_ptr
        storew #0x200, static_memcpy.len
        call static_memcpy

    ; TODO: handle reads that span more than one sector

    .print:
        ; debug
        loadw hl, (BP), .param16_dst_ptr
        pushw hl
        push #10
        call uart_dump_mem
        dealloc 3

    .done:
    load b, #0
    __epilogue
    ret

    .str_loading_file: #d "loading file...\n\0"



#include "./char_utils.asm"
#include "./static_math.asm"
#include "./lib_sd.asm"