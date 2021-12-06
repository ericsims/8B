#include "../CPU.asm"

#bank rom

; check frist address of ram
lai 0x00
sta 0x8000
lda 0x8000
tta 0x00 ; check that the write/read was sucessful

lai 0xAA
sta 0x8000
lda 0x8000
tta 0xAA ; check that the write/read was sucessful

lai 0x55
sta 0x8000
lda 0x8000
tta 0x55 ; check that the write/read was sucessful

lai 0xFF
sta 0x8000
lda 0x8000
tta 0xFF ; check that the write/read was sucessful

lai 0x00
sta 0x8000
lda 0x8000
tta 0x00 ; check that the write/read was sucessful

; check near end of ram
lai 0x00
sta 0xBFF0
lda 0xBFF0
tta 0x00 ; check that the write/read was sucessful

lai 0xAA
sta 0xBFF1
lda 0xBFF1
tta 0xAA ; check that the write/read was sucessful

lai 0x55
sta 0xBFF1
lda 0xBFF1
tta 0x55 ; check that the write/read was sucessful

lai 0xFF
sta 0xBFF1
lda 0xBFF1
tta 0xFF ; check that the write/read was sucessful

lai 0x00
sta 0xBFF1
lda 0xBFF1
tta 0x00 ; check that the write/read was sucessful

hlt