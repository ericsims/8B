import math

def _distance(edge):
    _start_x = edge[0][0]
    _start_y = edge[0][1]
    _end_x = edge[1][0]
    _end_y = edge[1][1]
    return math.sqrt(math.pow(_start_x-_end_x,2)+math.pow(_start_y-_end_y,2))

def _reconstruct(prev, goal):
    current = goal
    path = []
    while current is not None:
        path.append(current)
        current = prev[current]
    return list(reversed(path))

def dijkstra(g, start, goal):
    dist = [None]*len(g.nav_nodes)
    prev = [None]*len(g.nav_nodes)
    visited = [0]*len(g.nav_nodes)

    dist[start] = 0
    u = start
    while sum(visited) < len(visited):
        # print(u
        visited[u] = 1
        if u == goal: break
        # update distances
        for next_node in g.nav_paths[u]:
            next_dist = _distance([g.nav_nodes[u], g.nav_nodes[next_node]]) + dist[u]
            if dist[next_node] is None or next_dist < dist[next_node]:
                dist[next_node] = next_dist
                prev[next_node] = u
        # print(dist)
        # move to closest
        smallest_distance = None
        for i, next_dist in enumerate(dist):
            if visited[i] == 1: continue
            if next_dist is None: continue
            if smallest_distance is None or next_dist < smallest_distance:
                smallest_distance = next_dist
                u = i
        # print(prev)
        # break
        # print(dist)
    
    # print(dist)
    # print(prev)
    path = _reconstruct(prev, goal)
    # print(f"best path: {path}")
    # print(f"total distance: {dist[goal]:0.2f}")

    return path, dist[goal]

def find_closest(g, pose):
    x, y, theta = pose
    closest_node = None
    closest_node_distance = None
    for n, node in enumerate(g.nav_nodes):
        d = _distance(((x,y), (node[0], node[1])))
        if closest_node is None:
            closest_node = n
            closest_node_distance = d
            continue
        if d < closest_node_distance:
            closest_node = n
            closest_node_distance = d
    return closest_node, closest_node_distance

def _find_heading(pose, next_pose):
    x, y, theta = pose
    next_x, next_y = next_pose

    dy = (next_y-y)
    dx = (next_x-x)

    heading_angle = math.atan2((next_y-y),(next_x-x))

    delta_theta = (heading_angle-theta)%(2*math.pi)
    if delta_theta > math.pi:
        delta_theta = -(2*math.pi - delta_theta)

    return delta_theta

def path_plan(g, pose, next):
    x, y, theta = pose
    next_x, next_y = g.nav_nodes[next]

    dtheta = _find_heading((x,y,theta), (next_x, next_y))
    dz = _distance(((x,y), (next_x, next_y)))
    if abs(dtheta) > math.radians(5):
        # robo needs to turn
        # print(f"turn: {dtheta:0.2f}")
        return dz, (0, dtheta)
    # print(f"drive: {dz:0.2f}")
    return dz, (dz, 0)
