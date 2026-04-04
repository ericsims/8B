# Generate a lookup table for multiply two 4 bit unsigned numbers

import math
import struct

num_bits = 4

for x in range (0,2**num_bits):
    for y in range (0,2**num_bits):
        s = f"{x*y:02x}"
        print(s)

