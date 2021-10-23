#include "../CPU.asm"

lai 0x20
lbi 0x05
add
tta 0x25 ; check that 0x20 + 0x05 = 0x25
ttz 0
ttc 0
ttn 0

lai 0x00
lbi 0x00
add
tta 0x00 ; check that 0x00 + 0x00 = 0x00
ttz 1
ttc 0
ttn 0

lai 0x10
lbi 0x10
add
tta 0x20 ; check that 0x10 + 0x10 = 0x20
ttz 0
ttc 0
ttn 0

lai 0xFF
lbi 0x00
add
tta 0xFF ; check that 0xFF + 0x00 = 0xFF
ttz 0
ttc 0
ttn 1

lai 0xFF
lbi 0x01
add
tta 0x00 ; check that 0xFF + 0x01 = 0x00
ttz 1
ttc 1
ttn 0

hlt