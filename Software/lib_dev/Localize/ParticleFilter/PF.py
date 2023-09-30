import math
import numpy as np
from .Position import *
from .LidarSim import *

class PF:
    def __init__(self, position, map, particle_cnt=50, pos_sd=1, rot_sd=1):
        self.particles = [] # empty array to store particles
        self.particle_cnt = particle_cnt
        self.map = map
        self.pos_sd = pos_sd # standard deviation on position odometry knowledge
        self.rot_sd = rot_sd # standard deviation on rotation odometry knowledge
        self.best_guess = Position(position.x, position.y, position.theta)
        
        x_ests = np.random.normal(self.best_guess.x, self.pos_sd, self.particle_cnt)
        y_ests = np.random.normal(self.best_guess.y, self.pos_sd, self.particle_cnt)
        theta_ests = np.random.normal(self.best_guess.theta, self.rot_sd, self.particle_cnt)
        for n in range(particle_cnt):
            self.particles.append(Particle(x_ests[n], y_ests[n], theta_ests[n], weight=1.0))

    def propagate_odom(self, delta_dist, delta_theta, dist_sd=0, theta_sd=0):
        # update each particle with odometry data
        # TODO: consider better propagation algo that assumes theta uncertainty is a function of distance traveled. i.e. robot follows curved path
        dist_ests = np.random.normal(delta_dist, dist_sd, self.particle_cnt)
        theta_ests = np.random.normal(delta_theta, theta_sd, self.particle_cnt)
        for n in range(self.particle_cnt):
            update_pos(self.particles[n], dist_ests[n], theta_ests[n])

    def update_weights(self, observed_lidar_data):
        # update each particle weights based on lidar data
        # observed_lidar_data contains observed landmarks
        # use lidar sim to estimate lidar data 
        lidar = LidarSim()
        for n in range(self.particle_cnt):
            observed_landmarks = []
            predicted_landmarks = []
            for coord in observed_lidar_data:
                # lidar_data in format: angle, distance, in robot frame
                observed_landmark_x = max(0, int(self.particles[n].x + math.cos(coord[0] + self.particles[n].theta)*coord[1]))
                observed_landmark_y = max(0, int(self.particles[n].y + math.sin(coord[0] + self.particles[n].theta)*coord[1]))
                observed_landmarks.append((observed_landmark_x, observed_landmark_y))

            _, predicted_lidar_data = lidar.getRays(self.particles[n], self.map)
            for coord in predicted_lidar_data:
                # lidar_data in format: angle, distance, in robot frame
                predicted_landmark_x = int(self.particles[n].x + math.cos(coord[0] + self.particles[n].theta)*coord[1])
                predicted_landmark_y = int(self.particles[n].y + math.sin(coord[0] + self.particles[n].theta)*coord[1])
                predicted_landmarks.append((predicted_landmark_x, predicted_landmark_y))
            
            new_weight = None
            for ob in range(0, len(observed_landmarks)):
                sigma_x = 10.0 # landmark certainty
                sigma_y = 10.0 # landmark certainty
                x, y = observed_landmarks[ob]
                mu_x, mu_y = predicted_landmarks[ob]
                # print(x ,y, mu_x, mu_y)
                weight = 1.0 / (2.0 * math.pi * sigma_x * sigma_y) * math.exp(-((math.pow(x - mu_x, 2.0) / (2.0 * math.pow(sigma_x, 2.0))) + (math.pow(y - mu_y, 2) / (2.0 * math.pow(sigma_y, 2)))))
                # print(weight)
                if new_weight is None:
                    new_weight = weight
                else:
                    new_weight *= weight
            self.particles[n].weight = new_weight
            # print("weight:", new_weight)

    
    def update_weights_inverse_dist(self, observed_lidar_data):
        # update each particle weights based on lidar data
        # this uses 1/euclidean distance, instead of probability
        # observed_lidar_data contains observed landmarks
        # use lidar sim to estimate lidar data 
        lidar = LidarSim()
        for n in range(self.particle_cnt):
            observed_landmarks = []
            predicted_landmarks = []
            for coord in observed_lidar_data:
                # lidar_data in format: angle, distance, in robot frame
                observed_landmark_x = max(0, int(self.particles[n].x + math.cos(coord[0] + self.particles[n].theta)*coord[1]))
                observed_landmark_y = max(0, int(self.particles[n].y + math.sin(coord[0] + self.particles[n].theta)*coord[1]))
                observed_landmarks.append((observed_landmark_x, observed_landmark_y))

            _, predicted_lidar_data = lidar.getRays(self.particles[n], self.map)
            for coord in predicted_lidar_data:
                # lidar_data in format: angle, distance, in robot frame
                predicted_landmark_x = int(self.particles[n].x + math.cos(coord[0] + self.particles[n].theta)*coord[1])
                predicted_landmark_y = int(self.particles[n].y + math.sin(coord[0] + self.particles[n].theta)*coord[1])
                predicted_landmarks.append((predicted_landmark_x, predicted_landmark_y))
            
            sum_of_sqrs = 0
            for ob in range(0, len(observed_landmarks)):
                x, y = observed_landmarks[ob]
                mu_x, mu_y = predicted_landmarks[ob]
                sum_of_sqrs += (x - mu_x)**2 + (y - mu_y)**2
            
            if sum_of_sqrs > 0:
                # self.particles[n].weight = min(1, 1.0/math.sqrt(sum_of_sqrs))
                self.particles[n].weight = min(1, 1.0/sum_of_sqrs)
            else:
                self.particles[n].weight = 1
            # print("weight:", new_weight)
    
    def normalize_weights(self, scale=1):
        weights = [particle.weight for particle in self.particles]
        min_weight = min(weights)
        max_weight = max(weights)
        total_weights = sum(weights)
        if total_weights == 0.0:
            return
        for n in range(self.particle_cnt):
            self.particles[n].weight = self.particles[n].weight*scale/total_weights
    
    def update_best_guess(self):
        best_guess_index = np.argmax([particle.weight for particle in self.particles])
        self.best_guess.x = self.particles[best_guess_index].x
        self.best_guess.y = self.particles[best_guess_index].y
        self.best_guess.theta = self.particles[best_guess_index].theta
    
    def resample(self, resample_ratio=1.0):
        if resample_ratio < 0 or resample_ratio > 1.0:
            raise "resample ratio must be 0-1"
        weights = [particle.weight for particle in self.particles]
        cdf = np.cumsum(weights)
        samps = []
        new_particles = []
        num_pnts_to_resamp = int(self.particle_cnt*resample_ratio)
        num_pnts_to_randomize = self.particle_cnt-num_pnts_to_resamp

        # resample from cdf
        for n in range(0, num_pnts_to_resamp):
            a = np.random.uniform(0, 1)
            new_x = np.argmax(cdf>=a)
            samps.append(new_x)
            new_particles.append(Particle(
                self.particles[new_x].x,
                self.particles[new_x].y,
                self.particles[new_x].theta,
                weight=1.0))
            
        # random samples from best estimate
        # assume SD should be the same as initial guess
        x_ests = np.random.normal(self.best_guess.x, self.pos_sd, num_pnts_to_randomize)
        y_ests = np.random.normal(self.best_guess.y, self.pos_sd, num_pnts_to_randomize)
        theta_ests = np.random.normal(self.best_guess.theta, self.rot_sd, num_pnts_to_randomize)
        
        for n in range(num_pnts_to_randomize):
            new_particles.append(Particle(
                x_ests[n],
                y_ests[n],
                theta_ests[n],
                weight=1.0))
        
        for n in range(self.particle_cnt):
            self.particles[n] = new_particles[n]




        return cdf, samps



class Particle(Position):
    def __init__(self, x, y, theta, weight=1.0):
        super().__init__(x, y, theta)
        self.weight = weight
