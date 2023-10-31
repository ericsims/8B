import math
import struct
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
from MapDef import *

# cd 8B/Software/lib_dev/Localize
# python Maps/gen_map_bin.py

g = MapDef()
g.load_file('Maps/tcffhr_l1.yaml')
happy_mappy = g.gen_discrete_map(50)
for index, nn in enumerate(g.nav_nodes):
    x = int(nn[0]*g.resolution)
    y = int(nn[1]*g.resolution)
    plt.annotate(index, (x,y))

# plt.imshow(happy_mappy.T, origin='lower', cmap=COLOR_MAP)
# plt.show()

name = g.name
print(f"name: {name}")

num_nodes = len(g.nav_nodes)
print(f"num_nodes: {num_nodes}")

def byte_to_str(byte_):
    return f"{(byte_&0xFF):02X} "

with open('Maps/map.dat', 'w') as map_dat:
    # byte for number of nodes in map
    map_dat.write(byte_to_str(num_nodes))
    map_dat.write("\n")

    # bytes for x and y, then four paths
    # x, y, p0, p1, p2, p3
    for idx in range(len(g.nav_nodes)):
        node = idx
        pos = [int(z*g.resolution) for z in g.nav_nodes[idx]]
        paths = [255]*4 # right, up, left, down

        for path in g.nav_paths[idx]:
            cur_node = idx
            next_node = path
            ang = math.atan2(
                (g.nav_nodes[next_node][1]-g.nav_nodes[cur_node][1]),
                (g.nav_nodes[next_node][0]-g.nav_nodes[cur_node][0]))
            path_index = round((ang/(math.pi/2)+4)%4)
            # print(f"{cur_node} -> {next_node}, {path_index}")
            paths[path_index] = next_node

        [map_dat.write(byte_to_str(z)) for z in pos]
        [map_dat.write(byte_to_str(z)) for z in paths]
        map_dat.write("\n")
        print(f"node {node:>3}, pos: {str(pos):<10}, paths: {paths}")
    
    # bytes for name
    [map_dat.write(byte_to_str(ord(c))) for c in g.name]
    map_dat.write(byte_to_str(0))