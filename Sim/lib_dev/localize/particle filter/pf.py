import math
import numpy as np

class PF:
    def __init__(self, position, particle_cnt=50, pos_sd=1, rot_sd=1):
        self.particles = [] # empty array to store particles
        self.particle_cnt = particle_cnt
        self.pos_sd = pos_sd # standard deviation on position odometry knowledge
        self.rot_sd = rot_sd # standard deviation on rotation odometry knowledge
        self.position = position
        
        x_ests = np.random.normal(self.position.x, self.pos_sd, self.particle_cnt)
        y_ests = np.random.normal(self.position.y, self.pos_sd, self.particle_cnt)
        theta_ests = np.random.normal(self.position.theta, self.rot_sd, self.particle_cnt)
        for n in range(particle_cnt):
            self.particles.append(Particle(x_ests[n], y_ests[n], theta_ests[n], weight=1.0))

    def propagate_odom(self, delta_dist, delta_theta, dist_sd=0, theta_sd=0):
        # update each particle with odometry data
        dist_ests = np.random.normal(delta_dist, dist_sd, self.particle_cnt)
        theta_ests = np.random.normal(delta_theta, theta_sd, self.particle_cnt)
        for n in range(self.particle_cnt):
            update_pos(self.particles[n], dist_ests[n], theta_ests[n])

class Position:
    def __init__(self, x, y, theta):
        self.x = x
        self.y = y
        self.theta = theta

class Particle(Position):
    def __init__(self, x, y, theta, weight=1.0):
        super().__init__(x, y, theta)
        self.weight = weight
    
def update_pos(position, delta_dist, delta_theta):
    # discretely updates particle positions, position first, then theta
    position.x += math.cos(position.theta)*delta_dist
    position.y += math.sin(position.theta)*delta_dist
    position.theta += delta_theta