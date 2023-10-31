import matplotlib.pyplot as plt
from lib_dev.Localize.Maps.MapDef import *
from lib_dev.PathPlan.Navigate import *

# cd 8B/Software
# python -m  lib_dev.PathPlan.nav_ex

g = MapDef()
g.load_file('lib_dev/Localize/Maps/tcffhr_l1.yaml')
happy_mappy = g.gen_discrete_map(50)
for index, nn in enumerate(g.nav_nodes):
    x = int(nn[0]*g.resolution)
    y = int(nn[1]*g.resolution)
    plt.annotate(index, (x,y))

path, dist = dijkstra(g, 13, 5)
print(path)

# last_node = None
# pose = (g.nav_nodes[last_node][0]*200, g.nav_nodes[last_node][1]*200, 1.5)
# for node in path:
#     # print(node)
#     if last_node is not None:
#         g._plot_line(happy_mappy, g.resolution, (g.nav_nodes[last_node], g.nav_nodes[node]), MAP_OBJS.ANNO.value)
#     last_node = node

plt.imshow(happy_mappy.T, origin='lower', cmap=COLOR_MAP, norm=NORMALIZE)
plt.show()