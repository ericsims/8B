import math
import numpy as np
import rpyc
import warnings
import matplotlib.pyplot as plt
from ParticleFilter.PF import *
from ParticleFilter.Position import *
from ParticleFilter.LidarSim import *
from Maps.MapDef import *

try:
    conn = rpyc.connect('localhost', 18812, config={"allow_all_attrs": True})
except:
    conn = None
    warnings.warn("Warning. Sim not connected!")


g = MapDef()
g.load_file('./Maps/tcffhr_l1.yaml')
dis_map = g.gen_discrete_map(200)

SIZE_X = np.shape(dis_map)[0]
SIZE_Y = np.shape(dis_map)[1]

# plt.imshow(dis_map.T, origin='lower', cmap='Blues')
# plt.colorbar()
# plt.show()

# list of movements
movements = [
    (0  , 0   ),
    (0  , 0   ),
    (0  , 0   ),
]

true_path = []
estimated_path = []


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


if conn is not None:
    done = False

    # starting pos
    true_position = Position(*conn.root.get()['pos'])
    last_pos = Position(*conn.root.get()['pos'])
    # init filter
    pf = PF(position=true_position, map=dis_map, particle_cnt=50, pos_sd=5, rot_sd=0.3)
    # plot_pf_qvr(pf.particles, map=dis_map, true_position=true_position)


    # plot_path(particles=pf.particles, map=dis_map, true_path=true_path, estimated_path=estimated_path, true_position=true_position, best_guess=pf.best_guess)

    try:
    
        while not done:
            true_position = Position(*conn.root.get()['pos'])

            # assume some movement forward from odometry
            dx = math.sqrt(math.pow(true_position.x-last_pos.x,2)+math.pow(true_position.y-last_pos.y,2))# this only goes forward...
            dtheta = true_position.theta - last_pos.theta
            pf.propagate_odom(dx, dtheta, 5, 0.2)

            # plot_pf_qvr(pf.particles, map=dis_map, true_position=true_position)

            # sample lidar
            # observed_lidar = LidarSim()
            # lidar_map, observed_lidar_data1 = observed_lidar.getRays(true_position, dis_map)
            observed_lidar_data = conn.root.get()['lidar_data']
            observed_lidar_data = [(meas[0], int(meas[1]*g.resolution)) for meas in observed_lidar_data]
            print(observed_lidar_data)
            # plot_pf_qvr(particles=pf.particles, map=lidar_map, true_position=true_position)

            # update weights based of estimated lidar from each particle
            lidarSim = LidarSim()
            lidarSim.ray_angles=[0,-0.25,-0.5,-1,-1.5,-2,-2.5,0.25,0.5,1,1.5,2,2.5]
            pf.update_weights_inverse_dist(observed_lidar_data, lidarSim)
            pf.normalize_weights()
            pf.update_best_guess()
            # plot_pf_qvr(pf.particles, map=dis_map, true_position=true_position, best_guess=pf.best_guess)

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
            plot_pf_qvr(pf.particles, map=dis_map, true_position=true_position, best_guess=pf.best_guess)

            #plot current and guess
            # plot_pf_qvr(particles=None, map=dis_map, true_position=true_position, best_guess=pf.best_guess)

            true_path.append(Position(true_position.x, true_position.y, true_position.theta))
            estimated_path.append(Position(pf.best_guess.x, pf.best_guess.y, pf.best_guess.theta))

            last_pos.theta = true_position.theta
            last_pos.x = true_position.x
            last_pos.y = true_position.y
    except:
        pass
plot_path(particles=pf.particles, map=dis_map, true_path=true_path, estimated_path=estimated_path, true_position=true_position, best_guess=pf.best_guess)