import math
import numpy as np
import matplotlib.pyplot as plt
from pf import *
from Position import *
from LidarSim import *


SIZE_X = 200
SIZE_Y = 100

# init a map, and draw some arbitrary shapes
MAP = np.zeros([SIZE_X, SIZE_Y])
MAP[:,0] = 1
MAP[:,99] = 1
MAP[0,:] = 1
MAP[199,:] = 1
MAP[50:150,80] = 1
# plt.imshow(MAP.T, origin='lower', cmap='Blues')
# plt.colorbar()
# plt.show()

# starting pos
true_position = Position(50, 10, 1.5)
# list of movements
movements = [
    (30 , 0   ),
    (0  , -1.5),
    (30 , 0   ),
    (0  , -1.5),
    (30 , 0   ),
    (0  , 1.5 ),
    (30 , 0   ),
    (0  , 1.5),
    (30 , 0   ),
    (0  , -1.5),
    (30 , 0   ),
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

 # Init filter
pf = PF(position=true_position, map=MAP, particle_cnt=50, pos_sd=3, rot_sd=0.35)
# plot_pf_qvr(pf.particles, map=MAP, true_position=true_position)
true_path.append(Position(true_position.x, true_position.y, true_position.theta))
estimated_path.append(Position(pf.best_guess.x, pf.best_guess.y, pf.best_guess.theta))

for mov in movements:
    # assume some movement forward from odometry
    dx = mov[0]
    dtheta = mov[1]
    pf.propagate_odom(dx, dtheta, 2, 0.3)
    update_pos(true_position, dx, dtheta)
    # plot_pf_qvr(pf.particles, map=MAP, true_position=true_position)

    # sample lidar
    observed_lidar = LidarSim()
    lidar_map, observed_lidar_data = observed_lidar.getRays(true_position, MAP)
    # plot_pf_qvr(particles=pf.particles, map=lidar_map, true_position=true_position)

    # update weights based of estimated lidar from each particle
    pf.update_weights(observed_lidar_data)
    pf.normalize_weights()
    pf.update_best_guess()
    # plot_pf_qvr(pf.particles, map=MAP, true_position=true_position, best_guess=pf.best_guess)

    # check distribution of weights
    ns = []
    ws = []
    for n in range(pf.particle_cnt):
        ns.append(n)
        ws.append(pf.particles[n].weight)

    # plt.stem(ns, ws)
    # plt.show()

    # resample points
    cdf, samps = pf.resample(0.9)
    # print(samps)
    # plt.plot(cdf)
    # plt.show()

    # plot new particle field
    # plot_pf_qvr(pf.particles, map=MAP, true_position=true_position, best_guess=pf.best_guess)

    #plot current and guess
    #plot_pf_qvr(particles=None, map=MAP, true_position=true_position, best_guess=pf.best_guess)

    true_path.append(Position(true_position.x, true_position.y, true_position.theta))
    estimated_path.append(Position(pf.best_guess.x, pf.best_guess.y, pf.best_guess.theta))

plot_path(particles=pf.particles, map=MAP, true_path=true_path, estimated_path=estimated_path, true_position=true_position, best_guess=pf.best_guess)
