#!/usr/bin/env python3

def karastuba(x, y, bits):
    print(F"{x:0{bits>>2}X} * {y:0{bits>>2}X} = {x*y:0{bits>>1}X}")

    x1 = (x >> (bits >> 1)) & (2**(bits>>1)-1)
    x0 = x & (2**(bits>>1)-1)

    y1 = (y >> (bits >> 1)) & (2**(bits>>1)-1)
    y0 = y & (2**(bits>>1)-1)

    z2 = x1*y1
    z1 = x1*y0 + x0*y1
    z0 = x0*y0
    z4 = (x1 - x0)*(y1 - y0)


    print(F"x1-x0:{(x1-x0)&(2**(bits>>1)-1):0{bits>>3}X} y1-y0:{(y1-y0)&(2**(bits>>1)-1):0{bits>>3}X} ")
    print(F"x1-x0:{x1-x0} y1-y0:{y1-y0}")

    print(F"z0:{z0:0{bits>>2}X} z1:{z1:0{bits>>2}X} z2:{z2:0{bits>>2}X} z4:{z4&(2**(bits)-1):0{bits>>2}X}")

    xy = (z2 << bits) + (z1 << (bits >> 1)) + z0

    print(F"xy:{xy:0{bits>>1}X}")
    print()

# karastuba(49, 49, 8)
# karastuba(0x78, 0x9A, 8)
# karastuba(0xFF, 0xFF, 8)
# karastuba(0xF8, 0x0F, 8)
# karastuba(10, 100, 16)
# karastuba(0xDEAD, 0xBEEF, 16)
karastuba(0xF000, 0xF000, 16)