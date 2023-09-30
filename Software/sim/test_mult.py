a=0xFA
b=0x07
n=8
z=0

multiplier = b
while(n>0):
    print(F"n: {n} mult: 0x{multiplier:02x} z: 0x{z:04x}")
    n -= 1
    if (multiplier & 0x1):
        z = z + (a<<8)
    z = z >> 1
    multiplier = multiplier >> 1

print(F"n: {n} mult: 0x{multiplier:02x} z: 0x{z:04x}")