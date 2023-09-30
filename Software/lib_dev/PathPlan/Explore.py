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



def follow_links_breadthish_first(g, current, visited, next, pathfinder):
    visited[current] = 1
    # print(current)
    for nextnode in g.nav_paths[current]:
        if visited[nextnode] == 1: continue
        if nextnode in next: continue
        next.append(nextnode)
    while len(next)>0:
        n = next.pop()
        if pathfinder is None:
            print(f"{current} -> {n}")
        else:
            path, dist = pathfinder(g, current, n)
            path = path[1:]
            print(f"{current:<3}", *[f"-> {edge:<3}" for edge in path])
        follow_links_breadthish_first(g, n, visited, next, pathfinder)

def explore_map_breadthish_first(g, start=0, pathfinder=None):
    visited = [0]*len(g.nav_paths)
    next = []
    follow_links_breadthish_first(g, start, visited, next, pathfinder)
    # print("",*[f"{n}: {p}, v:{visited[n]}\n" for n,p in enumerate(g.nav_paths)])



g = MapDef()
g.load_file('lib_dev/Localize/Maps/tcffhr_l1.yaml')
happy_mappy = g.gen_discrete_map(100)
for index, nn in enumerate(g.nav_nodes):
    x = int(nn[0]*g.resolution)
    y = int(nn[1]*g.resolution)
    plt.annotate(index, (x,y))

# explore_map_depth_first(g)
explore_map_breadthish_first(g, 7, pathfinder=dijkstra)

plt.imshow(happy_mappy.T, origin='lower', cmap=COLOR_MAP, norm=NORMALIZE)
plt.show()