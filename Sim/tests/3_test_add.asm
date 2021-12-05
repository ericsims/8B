#include "../CPU.asm"

lai 0x20
lbi 0x05
add
tta 0x25 ; check that 0x20 + 0x05 = 0x25
ttz 0 ; zero flag should be false
ttc 0 ; carry flag should be false
ttn 0 ; negative flag should be false

lai 0x00
lbi 0x00
add
tta 0x00 ; check that 0x00 + 0x00 = 0x00
ttz 1 ; zero flag should be true
ttc 0 ; carry flag should be false
ttn 0 ; negative flag should be false

lai 0x10
lbi 0x10
add
tta 0x20 ; check that 0x10 + 0x10 = 0x20
ttz 0 ; zero flag should be false
ttc 0 ; carry flag should be false
ttn 0 ; negative flag should be false

lai 0xFF
lbi 0x00
add
tta 0xFF ; check that 0xFF + 0x00 = 0xFF
ttz 0 ; zero flag should be false
ttc 0 ; carry flag should be false
ttn 1 ; negative flag should be true

lai 0xFF
lbi 0x01
add
tta 0x00 ; check that 0xFF + 0x01 = 0x00
ttz 1 ; zero flag should be true
ttc 1 ; carry flag should be true
ttn 0 ; negative flag should be false

hlt