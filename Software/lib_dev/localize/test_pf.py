import math
import numpy as np
import matplotlib.pyplot as plt
from ParticleFilter.PF import *
from ParticleFilter.Position import *
from ParticleFilter.LidarSim import *
from Maps.MapDef import *


g = MapDef()
g.load_file('./Maps/tcffhr_l1.yaml')
dis_map = g.gen_discrete_map(100)

SIZE_X = np.shape(dis_map)[0]
SIZE_Y = np.shape(dis_map)[1]

plt.imshow(dis_map.T, origin='lower', cmap='Blues')
plt.colorbar()
plt.show()

# starting pos
true_position = Position(50, 50, 1.5)
# list of movements
movements = [
    (0  , 0   ),
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

 # init filter
pf = PF(position=true_position, map=dis_map, particle_cnt=30, pos_sd=3, rot_sd=0.5)
# plot_pf_qvr(pf.particles, map=dis_map, true_position=true_position)

for mov in movements:
    # assume some movement forward from odometry
    dx = mov[0]
    dtheta = mov[1]
    pf.propagate_odom(dx, dtheta, 2, 0.3)
    if dx == 0:
        dx_actual = 0
    else:
        dx_actual = np.random.normal(dx, 1, 1)[0]
    dtheta_actual = np.random.normal(dtheta, 0.1, 1)[0]
    update_pos(true_position, dx_actual, dtheta_actual)
    # plot_pf_qvr(pf.particles, map=dis_map, true_position=true_position)

    # sample lidar
    observed_lidar = LidarSim()
    lidar_map, observed_lidar_data = observed_lidar.getRays(true_position, dis_map)
    # plot_pf_qvr(particles=pf.particles, map=lidar_map, true_position=true_position)

    # update weights based of estimated lidar from each particle
    pf.update_weights_inverse_dist(observed_lidar_data)
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
    # plot_pf_qvr(pf.particles, map=dis_map, true_position=true_position, best_guess=pf.best_guess)

    #plot current and guess
    #plot_pf_qvr(particles=None, map=dis_map, true_position=true_position, best_guess=pf.best_guess)

    true_path.append(Position(true_position.x, true_position.y, true_position.theta))
    estimated_path.append(Position(pf.best_guess.x, pf.best_guess.y, pf.best_guess.theta))

plot_path(particles=pf.particles, map=dis_map, true_path=true_path, estimated_path=estimated_path, true_position=true_position, best_guess=pf.best_guess)
