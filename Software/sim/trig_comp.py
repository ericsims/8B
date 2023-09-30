import matplotlib.pyplot as plt
import math

x_arr = []
y_arr = []

LUT_SIZE = 2**6

print("LUT_SZE", LUT_SIZE)

for x in range(LUT_SIZE):
    x_arr.append(x)
    y_ = math.sin(2*math.pi*x/LUT_SIZE)*127
    y_arr.append(y_)

plt.step(x_arr,y_arr)
plt.show()
    
