; ###
; lib_dns.asm begin
; ###

#once


DNS_DEBUG = 0


DNS_PORT = 53


ERROR_DNS_NONE = 0
ERROR_DNS_TIMEOUT = -1
ERROR_DNS_ID_MISMATCH = -2
ERROR_DNS_NO_SUITABLE_RECORD = -3

; DNS resonse R Codes
ERROR_DNS_RCODE_FormErr = 1
ERROR_DNS_RCODE_ServFail = 2
ERROR_DNS_RCODE_NXDomain = 3
ERROR_DNS_RCODE_NotImp = 4
ERROR_DNS_RCODE_Refused = 5
ERROR_DNS_RCODE_YXDomain = 6
ERROR_DNS_RCODE_YXRRSet = 7
ERROR_DNS_RCODE_NXRRSet = 8
ERROR_DNS_RCODE_NotAuth = 9
ERROR_DNS_RCODE_NotZone = 10
ERROR_DNS_RCODE_DSOTYPENI = 11
ERROR_DNS_RCODE_BADVERS = 16
ERROR_DNS_RCODE_BADSIG = 16
ERROR_DNS_RCODE_BADKEY = 17
ERROR_DNS_RCODE_BADTIME = 18
ERROR_DNS_RCODE_BADMODE = 19
ERROR_DNS_RCODE_BADNAME = 20
ERROR_DNS_RCODE_BADALG = 21
ERROR_DNS_RCODE_BADTRUNC = 22
ERROR_DNS_RCODE_BADCOOKIE = 23

; packet format
; +---------------------+
; |        Header       |
; +---------------------+
; |       Question      | Question for the name server
; +---------------------+
; |        Answer       | Answers to the question
; +---------------------+

; Header format
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
; |                      ID                       |
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
; |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
; |                    QDCOUNT                    |
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
; |                    ANCOUNT                    |
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
; |                    NSCOUNT                    |
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
; |                    ARCOUNT                    |
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

; Question format
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
; |                                               |
; /                     QNAME                     /
; /                                               /
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
; |                     QTYPE                     |
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
; |                     QCLASS                    |
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+


; Answer Format
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
; |                                               |
; /                                               /
; /                     NAME                     /
; |                                               |
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
; |                     TYPE                      |
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
; |                     CLASS                     |
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
; |                      TTL                      |
; |                                               |
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
; |                    RDLENGTH                   |
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--|
; /                     RDATA                     /
; /                                               /
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

DNS_HEAD_ID_OFFSET = 0
DNS_HEAD_FLAGS_OFFSET = 2
    DNS_HEAD_RCODE_OFFSET = 3
    DNS_HEAD_RCODE_MASK = 0x0F
DNS_HEAD_QDCOUNT_OFFSET = 4
DNS_HEAD_ANCOUNT_OFFSET = 6
DNS_HEAD_NSCOUNT_OFFSET = 8
DNS_HEAD_ARCOUNT_OFFSET = 10
DNS_HEAD_Q_OFFSET = 12

DNS_Q_A_OFFSET = 4

DNS_A_TYPE_OFFSET = 0
    DNS_A_TYPE_A = 1
    DNS_A_TYPE_CNAME = 5
DNS_A_CLASS_OFFSET = 2
DNS_A_TTL_OFFSET = 4
DNS_A_RDLENGTH_OFFSET = 8
DNS_A_RDATA_OFFSET = 10



#bank ram
    DNS_IP_ADDRESS: #res 4 ; global IP address of DNS server to use
    DNS_MESSAGE_ID: #res 2 ; unique global DNS message id. increments on each request



;;
; @function dns_init
; @brief inits dns variables
;;
#bank rom
dns_init:
    ; init dns ip address with default
    movew .default_dns_ip, DNS_IP_ADDRESS
    movew .default_dns_ip+2, DNS_IP_ADDRESS+2

    ; init unique DNS message id
    storew #0x1234, DNS_MESSAGE_ID

    ret

.default_dns_ip: #d8 192,168,1,1



;;
; @function
; @brief perform a DNS lookup to get ip address for a given hostname
; @section description
; references:
;   https://w3.cs.jmu.edu/kirkpams/OpenCSF/Books/csf/html/UDPSockets.html
;   https://mislove.org/teaching/cs4700/spring11/handouts/project1-primer.pdf
;
;      _________________________
; -10 |  .param32_ip_addr_res   |
;  -9 |                         |
;  -8 |                         |
;  -7 |_________________________|
;  -6 |   .param16_domain_ptr   |
;  -5 |_________________________|
;  -4 |____________?____________| RESERVED
;  -3 |____________?____________|    .
;  -2 |____________?____________|    .
;  -1 |____________?____________| RESERVED
;   0 |_______.local8_len_______|
;   1 |_____.local8_lsb_msb_____|
;   2 |_____.local8_ancount_____|
;   3 |       .local_buf        | 512 byte buffer
;   4 |            .            |
;   5 |            .            |
;   6 |            .            |
;
; @param param16_domain_ptr pointer to null terminated domain name string
; @param param32_ip_addr_res 4 byte resovled ip address
;;
#bank rom
dns_lookup:
    .param32_ip_addr_res = -10
    .param16_domain_ptr = -6
    .local8_len = 0
    .local8_lsb_msb = 1
    .local8_ancount = 2
    .local_buf = 3 ; 512 byte buffer for domain name query, and reponse
    .init:
        __prologue
        push #13 ; local8_len = 13 (12byte header plus start bytes of hostname)
        push #0 ; .local8_lsb_msb = 0 (msb)
        push #0 ; .local8_ancount = 0 

        ; 512 byte .local_buf
        alloc 255
        alloc 255
        alloc 2

        ; copy domain name to local ram
        loadw hl, BP
        addw hl, #.local_buf
        pushw hl ; dst pointer
        loadw hl, (BP), .param16_domain_ptr
        pushw hl ; src pointer
        call strcpy
        dealloc 4

    .start_udp_conn:
        ; for now just hard code using socket 0
        store #Sn_CR_CLOSE, W5300_SOCK0+Sn_CR ; close existing socket if open
        store #Sn_MR1_UDP, W5300_SOCK0+Sn_MR1 ; set mode TCP
        store #Sn_CR_OPEN, W5300_SOCK0+Sn_CR ; open socket
        ; TODO: wait for SSR to go non zero?

        load a, W5300_SOCK0+Sn_SSR1
        assert a, #Sn_SSR1_SOCK_UDP ; SSR should be UDP mode

        ; load DNS server ip address
        move DNS_IP_ADDRESS, W5300_SOCK0+Sn_DIPR0 ; set IP
        move DNS_IP_ADDRESS+1, W5300_SOCK0+Sn_DIPR1 ; set IP
        move DNS_IP_ADDRESS+2, W5300_SOCK0+Sn_DIPR2 ; set IP
        move DNS_IP_ADDRESS+3, W5300_SOCK0+Sn_DIPR3 ; set IP

        storew #DNS_PORT, W5300_SOCK0+Sn_DPORTR0 ; set port


    .build_header:
        ; send 12 byte header
        ; all transfers into FIFO must be 16 bit, MSB first!
        movew DNS_MESSAGE_ID, W5300_SOCK0+Sn_TX_FIFOR0 ; ID
        storew #0x0100, W5300_SOCK0+Sn_TX_FIFOR0 ; flags
        storew #0x0001, W5300_SOCK0+Sn_TX_FIFOR0 ; QDCOUNT (Number of Questions) = 1
        storew #0x0000, W5300_SOCK0+Sn_TX_FIFOR0 ; ANCOUNT (Number of answer RRs) = 0, since this is a query
        storew #0x0000, W5300_SOCK0+Sn_TX_FIFOR0 ; NSCOUNT (Number of authority RRs) = 0, since this is a query
        storew #0x0000, W5300_SOCK0+Sn_TX_FIFOR0 ; ARCOUNT (Number of additional RRs) = 0, since this is a query

    .tokenize_domain:
        ; strtok params
        push #"." ; delimiter
        loadw hl, BP
        addw hl, #.local_buf
        pushw hl ; domain name pointer
        pushw #0 ; match pointer

        ..next_domain_token:
            call strtok
            test b
            jmn ..done_tokenizing_domain
            call strlength
            call .__push_b_to_fifo

            popw hl ; match pointer 
            pushw hl 
        ..str_copy_token:
            load b, (hl)
            test b
            jmz ..next_domain_token

            call .__push_b_to_fifo
            addw hl, #1

            jmp ..str_copy_token

        ..done_tokenizing_domain:
            dealloc 5 ; cleanup strtok params

            ; null termination for string
            load b, #0x00
            call .__push_b_to_fifo

            ; type: TYPE_A
            load b, #0x00
            call .__push_b_to_fifo
            load b, #0x01
            call .__push_b_to_fifo

            ; class: CLASS_IN 
            load b, #0x00
            call .__push_b_to_fifo
            load b, #0x01
            call .__push_b_to_fifo

            load a, (BP), .local8_lsb_msb
            test a ; was this an odd number of writes?
            jmz ...skip_dummy_byte
            store #0, W5300_SOCK0+Sn_TX_FIFOR1 ; dummy byte in lsb to finish writing bytes
            ...skip_dummy_byte:

    .send_query:
        ; set tx length
        store #0, W5300_SOCK0+Sn_TX_WRSR1
        load a, (BP), .local8_len
        store a, W5300_SOCK0+Sn_TX_WRSR3

        store #Sn_CR_SEND, W5300_SOCK0+Sn_CR ; send

    .response:
        loadw hl, #0x0FFF ; timeout duration
        ..wait_for_data:
            subw hl, #1
            jmc .err_timeout
            ; check if there is data in RX buffer. Sn_RX_RSR is non-zero
            load a, W5300_SOCK0+Sn_RX_RSR1
            load b, W5300_SOCK0+Sn_RX_RSR2
            or a, b
            load b, W5300_SOCK0+Sn_RX_RSR3
            or a, b
            jmz ..wait_for_data


        loadw hl, BP
        addw hl, #.local_buf ; load hl with pointer to local buffer
        ..save_response:
            load a, W5300_SOCK0+Sn_RX_FIFOR0
            store a, (hl)
            addw hl, #1

            load a, W5300_SOCK0+Sn_RX_FIFOR1
            store a, (hl)
            addw hl, #1

            ; check for remaining bytes
            load a, W5300_SOCK0+Sn_RX_RSR1
            load b, W5300_SOCK0+Sn_RX_RSR2
            or a, b
            load b, W5300_SOCK0+Sn_RX_RSR3
            or a, b
            jnz ..save_response

        #if DNS_DEBUG == 1
        {
        ..dump_data:
            loadw hl, BP
            addw hl, #.local_buf ; load hl with pointer to local buffer
            pushw hl
            push #16
            call uart_dump_mem
            dealloc 3
        }
        
        ..parse_data:
            ...id:
                loadw hl, BP
                addw hl, #.local_buf ; load hl with pointer to local buffer
                addw hl, #DNS_HEAD_ID_OFFSET
                loadw hl, (hl)

                #if DNS_DEBUG == 1
                {
                    pushw hl
                    call uart_print_itoa_hex16
                    call static_uart_print_newline
                    popw hl
                }


                ; TODO: check ID matches
                
            ...r_code:
                loadw hl, BP
                addw hl, #.local_buf ; load hl with pointer to local buffer
                addw hl, #DNS_HEAD_RCODE_OFFSET
                load b, (hl)
                and b, #DNS_HEAD_RCODE_MASK

                #if DNS_DEBUG == 1
                {
                    push b
                    call uart_print_itoa_hex
                    call static_uart_print_newline
                    pop b
                }

                ; if rcode is nonzero, then an error occured. return the rcode as the error code
                test b
                jnz .done

            ...answer_count:
                loadw hl, BP
                addw hl, #.local_buf ; load hl with pointer to local buffer
                addw hl, #DNS_HEAD_ANCOUNT_OFFSET+1
                load a, (hl)
                test a
                jmz .err_no_suitable_record

                store a, (BP), .local8_ancount

                #if DNS_DEBUG == 1
                {
                    push a
                    call uart_print_itoa_hex
                    call static_uart_print_newline
                    pop a
                }
            
            ...skip_to_first_answer:
                loadw hl, BP
                addw hl, #.local_buf ; load hl with pointer to local buffer
                addw hl, #DNS_HEAD_Q_OFFSET
                
                call .__skip_name_field ; move pointer forward to end of domain name string in the question
                addw hl, #DNS_Q_A_OFFSET ; move pointer forward to start of answer
            
            ...skip_answer_name:
                call .__skip_name_field ; move pointer forward to end of domain name string in the answer
            
            ...get_type:
                addw hl, #DNS_A_TYPE_OFFSET+1 ; move pointer to LSB of record type

                load b, (hl) ; leave this dns record type result in b register to be used after rdlen
                pushw hl ; save pointer reg
                
                #if DNS_DEBUG == 1
                {
                    push b
                    call uart_print_itoa_hex
                    call static_uart_print_newline
                    pop b
                }

                popw hl
                subw hl, #DNS_A_TYPE_OFFSET+1 ; move pointer to LSB of record type
                
            ...get_rdlen:
                addw hl, #DNS_A_RDLENGTH_OFFSET+1 ; move pointer to LSB of record type
                load a, (hl)

                #if DNS_DEBUG == 1
                {
                    pushw hl ; save pointer reg
                    push b
                    push a
                    call uart_print_itoa_hex
                    call static_uart_print_newline
                    pop a
                    pop b
                    popw hl
                }
                
                addw hl, #1 ; move pointer to begining of rd

            ...check_record:
                ; a reg contains rdlen, b reg contains record type field
                push b
                sub b, #DNS_A_TYPE_A
                pop b
                jnz ...check_next_record ; if not an 'A' record 4 bytes, skip this record
                ; TODO: handle CNAME record

                push a
                sub a, #4 ; should expect 4 bytes for IPv4 address
                jnz ...check_next_record ; if not 4 bytes, skip this record
                pop a

            ...save_ip:
                load a, (hl)
                store a, (BP), .param32_ip_addr_res
                
                addw hl, #1
                load a, (hl)
                store a, (BP), .param32_ip_addr_res+1
                
                addw hl, #1
                load a, (hl)
                store a, (BP), .param32_ip_addr_res+2
                
                addw hl, #1
                load a, (hl)
                store a, (BP), .param32_ip_addr_res+3

                load b, #ERROR_DNS_NONE
                jmp .done
            
            ...check_next_record:
                addw hl, a ; skip rdata, using the rdlength value
                load a, (BP), .local8_ancount
                sub a, #1
                jmc .err_no_suitable_record ; got to the end of the records, without finding the ip address
                store a, (BP), .local8_ancount

                jmp ...skip_answer_name

    .done:
        ; increment global DNS query pointer
        loadw hl, DNS_MESSAGE_ID
        addw hl, #1
        storew hl, DNS_MESSAGE_ID

        ; close socket - not sure this matters for UDP, but we should clean up
        store #Sn_CR_CLOSE, W5300_SOCK0+Sn_CR ; close

        ; dealloc 512 byte buffer
        dealloc 255
        dealloc 255
        dealloc 2
        ; dealloc local vars
        dealloc 3
        __epilogue
        ret

    .err_timeout:
        storew #.str_query_timeout, static_uart_print.data_pointer
        call static_uart_print

        load b, #ERROR_DNS_TIMEOUT
        jmp .done
    
    .err_no_suitable_record:
        load b, #ERROR_DNS_NO_SUITABLE_RECORD
        jmp .done

    .__push_b_to_fifo:
        load a, (BP), .local8_lsb_msb
        test a
        jnz ..lsb
        ..msb:
            store b, W5300_SOCK0+Sn_TX_FIFOR0
            load a, #1
            store a, (BP), .local8_lsb_msb
            jmp ..incr
        ..lsb:
            store b, W5300_SOCK0+Sn_TX_FIFOR1
            load a, #0
            store a, (BP), .local8_lsb_msb
        ..incr:
            load a, (BP), .local8_len
            add a, #1
            store a, (BP), .local8_len
            ret

    .__skip_name_field:
        ..check_for_compression:
            load a, (hl)
            sub a, #0xC0 ; compression inidcator
            jnz ..skip_labels
            addw hl, #1
            load a, (hl)
            subw hl, #1
            sub a, #0x0C ; compression inidcator
            jnz ..skip_labels
            
            ; this is a compressed domain name, simply move the pointer forward by two bytes
            addw hl, #2
            ret
                    
        ..skip_labels:
            load a, (hl)
            addw hl, #1 ; discard length field
            addw hl, a ; skip forward by length of label indicated in the length feild
            test a
            jnz ..skip_labels
            ret
    
    .str_query_timeout: #d "query timed out!\n\0"



#include "char_utils.asm"
#include "lib_w5300.asm"