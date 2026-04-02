# Generate Cosine binary radian lookup table

# Binary radians. 0 to 256 = 0 to 2pi
# Output is first quadrant of 16bit fixed point output

import math
import struct

x = range(0,65)
y = []
for x_ in x:
    cos_float = math.cos(x_/256.0*(2*math.pi))
    y.append(int(round(cos_float*2**8)))



# import matplotlib.pyplot as plt
# plt.rcParams['figure.figsize'] = [25, 15]
# plt.plot(x,y, drawstyle='steps-post')
# plt.show()

for x_, y_ in zip(x,y):
    s = f"{y_:04x}"
    print(s)
