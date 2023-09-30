import matplotlib.pyplot as plt
from lib_dev.Localize.Maps.MapDef import *
from lib_dev.PathPlan.Navigate import *

g = MapDef()
g.load_file('lib_dev/Localize/Maps/tcffhr_l1.yaml')
happy_mappy = g.gen_discrete_map(100)
for index, nn in enumerate(g.nav_nodes):
    x = int(nn[0]*g.resolution)
    y = int(nn[1]*g.resolution)
    plt.annotate(index, (x,y))

path, dist = dijkstra(g, 8, 15)
last_node = None

for node in path:
    # print(node)
    if last_node is not None:
        g._plot_line(happy_mappy, g.resolution, (g.nav_nodes[last_node], g.nav_nodes[node]), MAP_OBJS.ANNO.value)
    last_node = node

plt.imshow(happy_mappy.T, origin='lower', cmap=COLOR_MAP, norm=NORMALIZE)
plt.show()