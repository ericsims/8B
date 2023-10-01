import matplotlib.pyplot as plt
from matplotlib import colors
from lib_dev.Localize.Maps.MapDef import *
from lib_dev.PathPlan.Navigate import *

def follow_links_depth_first(g, current, visited):
    visited[current] = 1
    print(current)
    for nextnode in g.nav_paths[current]:
        if visited[nextnode] == 1: continue
        follow_links_depth_first(g, nextnode, visited)

def explore_map_depth_first(g, start=0):
    visited = [0]*len(g.nav_paths)
    follow_links_depth_first(g, start, visited)
    # print("",*[f"{n}: {p}, v:{visited[n]}\n" for n,p in enumerate(g.nav_paths)])



def follow_links_breadthish_first(g, current, visited, next, path):
    visited[current] = 1
    # print(current)
    for nextnode in g.nav_paths[current]:
        if visited[nextnode] == 1: continue
        if nextnode in next: continue
        next.append(nextnode)
    while len(next)>0:
        n = next.pop()
        # print(f"{current} -> {n}")
        path.append(n)
        follow_links_breadthish_first(g, n, visited, next, path)

def explore_map_breadthish_first(g, start=0):
    visited = [0]*len(g.nav_paths)
    next = []
    path = []
    follow_links_breadthish_first(g, start, visited, next, path)
    return path
    # print("",*[f"{n}: {p}, v:{visited[n]}\n" for n,p in enumerate(g.nav_paths)])

g = MapDef()
g.load_file('lib_dev/Localize/Maps/tcffhr_l1.yaml')
dis_map = g.gen_discrete_map(100)
for index, nn in enumerate(g.nav_nodes):
    x = int(nn[0]*g.resolution)
    y = int(nn[1]*g.resolution)
    plt.annotate(index, (x,y))

# explore_map_depth_first(g)
start = 7
path_to_follow = explore_map_breadthish_first(g, start)

current_pos = start
for node in path_to_follow:
    shortpath, dist = dijkstra(g, current_pos, node)
    print(shortpath) #shortpath = shortpath[1:]
    current_pos = node
    # print(f"{node:<3}", *[f"-> {edge:<3}" for edge in shortpath])

plt.imshow(dis_map.T, origin='lower', cmap=COLOR_MAP, norm=NORMALIZE)
plt.show()