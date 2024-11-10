#!/usr/bin/env python

import math

ITERS = 16
BITSIZE = 32
FRACSIZE = 16

def float_to_fixed(x):
    return round(x * (2**FRACSIZE))

def sincoeffs():
    print(f"{'i':^4}   {'ki':^8}   {'ki (fix)':^8}   {'x':^8}")
    k_fix = [0]*ITERS
    x=1
    for i in range(ITERS):
        ki = math.atan(2**-i)
        ki_fix = float_to_fixed(ki)
        x = x*math.cos(ki)
        k_fix[i] = ki_fix
        print(f"{i:>4}   {ki:>8.5f}  {ki_fix:>08X}  {x:>8.5f}")
    x_fix = float_to_fixed(x)
    print(f"x: {x_fix:>08X}")
    with open('cordic_sin_coeffs.dat', 'w') as file:
        [file.write(f"{k:08X}\n") for k in k_fix]


if __name__ == '__main__':
    sincoeffs()