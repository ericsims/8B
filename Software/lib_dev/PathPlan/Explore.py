import sys
import time
import matplotlib.pyplot as plt
from matplotlib import colors
import rpyc
import warnings
from lib_dev.Localize.Maps.MapDef import *
from lib_dev.PathPlan.Navigate import *
from lib_dev.Localize.ParticleFilter.Position import *
from lib_dev.Localize.ParticleFilter.PF import *
from lib_dev.Localize.ParticleFilter.LidarSim import *

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

try:
    conn = rpyc.connect('localhost', 18812, config={"allow_all_attrs": True})
except:
    conn = None
    warnings.warn("Warning. Sim not connected!")

g = MapDef()
g.load_file('lib_dev/Localize/Maps/tcffhr_l1.yaml')
dis_map = g.gen_discrete_map(100)
for index, nn in enumerate(g.nav_nodes):
    x = int(nn[0]*g.resolution)
    y = int(nn[1]*g.resolution)
    plt.annotate(index, (x,y))

g_pf = MapDef()
g_pf.load_file('lib_dev/Localize/Maps/tcffhr_l1.yaml')
dis_map_pf = g_pf.gen_discrete_map_walls_only(200)

SIZE_X = np.shape(dis_map_pf)[0]
SIZE_Y = np.shape(dis_map_pf)[1]

true_path = []
estimated_path = []

def plot_path(particles=None, map=None, true_path=None, estimated_path=None, true_position=None, best_guess=None):
    if particles is not None:
        for particle in particles:
            # print(particle.x, particle.y, particle.theta, particle.weight)
            plt.quiver(particle.x, particle.y, particle.weight*math.cos(particle.theta), particle.weight*math.sin(particle.theta), width=0.005, scale=20)

    if map is not None:
        plt.imshow(map.T, origin='lower', cmap='Blues')
        plt.colorbar()

    if true_path is not None:
        xs = [point.x for point in true_path]
        ys = [point.y for point in true_path]
        print(xs, ys)
        plt.plot(xs, ys, marker = '.')
    if estimated_path is not None:
        xs = [point.x for point in estimated_path]
        ys = [point.y for point in estimated_path]
        print(xs, ys)
        plt.plot(xs, ys, marker = '.')

    if true_position is not None:
        plt.quiver(true_position.x, true_position.y, math.cos(true_position.theta), math.sin(true_position.theta), width=0.005, scale=20, color='r')
    if best_guess is not None:
        plt.quiver(best_guess.x, best_guess.y, math.cos(best_guess.theta), math.sin(best_guess.theta), width=0.005, scale=20, color='g')
    plt.ylim(0, SIZE_Y)
    plt.xlim(0, SIZE_X)
    plt.show()

def plot_pf_qvr(particles=None, map=None, true_position=None, best_guess=None):
    if particles is not None:
        for particle in particles:
            # print(particle.x, particle.y, particle.theta, particle.weight)
            plt.quiver(particle.x, particle.y, particle.weight*math.cos(particle.theta), particle.weight*math.sin(particle.theta), width=0.005, scale=20)
    if map is not None:
        plt.imshow(map.T, origin='lower', cmap='Blues')
        plt.colorbar()
    if true_position is not None:
        plt.quiver(true_position.x, true_position.y, math.cos(true_position.theta), math.sin(true_position.theta), width=0.005, scale=20, color='r')
    if best_guess is not None:
        plt.quiver(best_guess.x, best_guess.y, math.cos(best_guess.theta), math.sin(best_guess.theta), width=0.005, scale=20, color='g')
    plt.ylim(0, SIZE_Y)
    plt.xlim(0, SIZE_X)
    plt.show()

if conn is not None:
    done = False 

    # starting pos
    true_position = conn.root.get()['pos']
    true_position_pf = Position(*conn.root.get()['pos'])
    last_pos_pf = Position(*conn.root.get()['pos'])
    true_position = (true_position[0]/200, true_position[1]/200, true_position[2])

    # init filter
    pf = PF(position=true_position_pf, map=dis_map_pf, particle_cnt=100, pos_sd=5, rot_sd=0.3)

    # explore_map_depth_first(g)
    print(f"truepos: {true_position}")
    start, d = find_closest(g, true_position)
    print(f"estimated sart: {start}")
    path_to_follow = [start, *explore_map_breadthish_first(g, start)]

    print("anticipated path:")
    for node in path_to_follow:
        print(f"  {node}")


    VISITED_THRES = 0.1


    current_path_index = 0
    current_pos = start
    macro_goal = path_to_follow[0]

    plt.imshow(dis_map.T, origin='lower', cmap=COLOR_MAP, norm=NORMALIZE)
    plt.show()

    # try:
    while done == False:
        true_position = conn.root.get()['pos']
        true_position_pf = Position(*conn.root.get()['pos'])
        do_drive = conn.root.get()['do_drive']
        true_position = (true_position[0]/200, true_position[1]/200, true_position[2]%(2*math.pi))
        
        # time.sleep(0.5)
        # dont do anything if we are still moving
        if len(do_drive) > 0:
            # print(do_drive)
            if do_drive[0] != 0 or do_drive[1] != 0:
                continue

        print("a")
        ### PF ###
        # assume some movement forward from odometry
        # dx = math.sqrt(math.pow(true_position_pf.x-last_pos_pf.x,2)+math.pow(true_position_pf.y-last_pos_pf.y,2))# this only goes forward...
        # dtheta = true_position_pf.theta - last_pos_pf.theta
        # pf.propagate_odom(dx, dtheta, 5, 0.2)

        observed_lidar_data = conn.root.get()['lidar_data']
        observed_lidar_data = [(meas[0], int(meas[1]*g_pf.resolution)) for meas in observed_lidar_data]
        # print(observed_lidar_data)

        lidarSim = LidarSim()
        lidarSim.ray_angles=[0,-0.25,-0.5,-1,-1.5,-2,-2.5,0.25,0.5,1,1.5,2,2.5]
        pf.update_weights_inverse_dist(observed_lidar_data, lidarSim)
        pf.normalize_weights()
        pf.update_best_guess()

        # check distribution of weights
        ns = []
        ws = []
        for n in range(pf.particle_cnt):
            ns.append(n)
            ws.append(pf.particles[n].weight)

        # plt.stem(ns, ws)
        # plt.show()

        # resample points
        cdf, samps = pf.resample(.75)
        # print(samps)
        # plt.plot(cdf)
        # plt.show()


        # plot new particle field
        plot_pf_qvr(pf.particles, map=dis_map_pf, true_position=true_position_pf, best_guess=pf.best_guess)

        #plot current and guess
        # plot_pf_qvr(particles=None, map=dis_map_pf, true_position=true_position_pf, best_guess=pf.best_guess)

        true_path.append(Position(true_position_pf.x, true_position_pf.y, true_position_pf.theta))
        estimated_path.append(Position(pf.best_guess.x, pf.best_guess.y, pf.best_guess.theta))


        last_pos_pf.theta = true_position_pf.theta
        last_pos_pf.x = true_position_pf.x
        last_pos_pf.y = true_position_pf.y




        ### path finding ###
        micro_goal = macro_goal
        micropath, _ = dijkstra(g, current_pos, macro_goal)
        if len(micropath) > 1:
            micro_goal = micropath[1]

        pos_use2 = (pf.best_guess.x/200, pf.best_guess.y/200, pf.best_guess.theta%(2*math.pi))
        pos_use = true_position
        print(f"t:{pos_use}, g:{pos_use2}")
        dist, instruction = path_plan(g, pos_use2, micro_goal)
        print(f"trying to get from {current_pos} -> {macro_goal}, dist to goal: {dist:0.3f}")
        print(f"taking path: {micropath}")
        if dist > VISITED_THRES:
            print(f"drive: {instruction[0]:0.2f}, turn: {instruction[1]:0.2f}")
            conn.root.update(do_drive_=(instruction[0]*200,instruction[1]))
            pf.propagate_odom(instruction[0]*200, instruction[1], 5, 0.2)
        else:
            current_pos = micro_goal
            # only update macro_goal if we are at the macro goal destination
            if len(micropath) <= 2:
                if current_path_index+1 >= len(path_to_follow):
                    print("end of path!")
                    break
                current_path_index +=1 
                macro_goal = path_to_follow[current_path_index]
            continue

        # data = input("")
        # if data.strip() == 'q':
        #     done = True


    # except Exception as e: 
    #     print(e)
    plot_path(particles=pf.particles, map=dis_map_pf, true_path=true_path, estimated_path=estimated_path, true_position=true_position_pf, best_guess=pf.best_guess)