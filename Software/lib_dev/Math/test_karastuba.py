#!/usr/bin/env python3

x = 0x78
y = 0x9A

print(F"{x:02X} * {y:02X} = {x*y:04X}")

x1 = (x >> 4) & 0xF
x0 = x & 0xF

y1 = (y >> 4) & 0xF
y0 = y & 0xF

z2 = x1*y1
z1 = x1*y0 + x0*y1
z0 = x0*y0


print(F"z0:{z0:02X} z1:{z1:02X} z2:{z2:02X} ")

xy = (z2<<8) + (z1<<4) + z0

print(F"xy:{xy:04X}")