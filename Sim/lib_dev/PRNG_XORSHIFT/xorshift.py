import matplotlib.pyplot as plt

# // returns values from 1 to 255 inclusive, period is 255
# uint8_t xorshift8(void) {
#     y8 ^= (y8 << 7);
#     y8 ^= (y8 >> 5);
#     return y8 ^= (y8 << 3);
# }

def xorshift8(rng):
    rng ^= (rng << 7) & 0xFF
    rng ^= (rng >> 5) & 0xFF
    rng ^= (rng << 3) & 0xFF
    return rng & 0xFF

rngs = []
rng_a = 1
for x in range(1):
    # print(f"{x} {rng_a}")
    for n in range(255):
        print(f"{n} 0x{rng_a:02X}")
        rngs.append(rng_a)
        rng_a = xorshift8(rng_a)
    rng_a = (rng_a+1)&0x0F

plt.hist(rngs,bins=(0,2**8+1))
# plt.show()