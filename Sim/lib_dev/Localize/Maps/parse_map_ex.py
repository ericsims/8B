import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
from MapDef import *

g = MapDef()
g.load_file('tcffhr_l1.yaml')
happy_mappy = g.gen_discrete_map(100)
plt.imshow(happy_mappy.T, origin='lower', cmap=COLOR_MAP)
plt.show()