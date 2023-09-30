import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
from MapDef import *

g = MapDef()
g.load_file('tcffhr_l1.yaml')
happy_mappy = g.gen_discrete_map(100)
for index, nn in enumerate(g.nav_nodes):
    x = int(nn[0]*g.resolution)
    y = int(nn[1]*g.resolution)
    plt.annotate(index, (x,y))

plt.imshow(happy_mappy.T, origin='lower', cmap=COLOR_MAP)

def follow_links_depth_first(g, current, visited):
    visited[current] = 1
    print(current)
    for nextnode in g.nav_paths[current]:
        if visited[nextnode] == 1: continue
        follow_links_depth_first(g, nextnode, visited)

def explore_map_depth_first(g):
    visited = [0]*len(g.nav_paths)
    follow_links_depth_first(g, 0, visited)
    print(*[f"{n}: {p}, v:{visited[n]}\n" for n,p in enumerate(g.nav_paths)])

# explore_map_depth_first(g)

def follow_links_breadth_first(g, current, visited, next):
    visited[current] = 1
    print(current)
    for nextnode in g.nav_paths[current]:
        if visited[nextnode] == 1: continue
        if nextnode in next: continue
        next.append(nextnode)
    while len(next)>0:
        n = next.pop()
        follow_links_breadth_first(g, n, visited, next)

def explore_map_breadth_first(g):
    visited = [0]*len(g.nav_paths)
    next = []
    follow_links_breadth_first(g, 0, visited, next)
    print(*[f"{n}: {p}, v:{visited[n]}\n" for n,p in enumerate(g.nav_paths)])

explore_map_breadth_first(g)

plt.show()