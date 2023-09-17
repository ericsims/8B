import math
import numpy as np
from Position import *

class LidarSim:
    def __init__(self):
        self.ray_angles = [
            0,
            math.pi/8.0,
            -math.pi/8.0,
            math.pi/4.0,
            -math.pi/4.0,
            math.pi*3.0/8.0,
            -math.pi*3.0/8.0,
            math.pi/2.0,
            -math.pi/2.0,
        ]
        self.max_range = 1000

    def getRays(self, position, map):
        new_map = np.copy(map)
        distances = [self.max_range]*len(self.ray_angles)
        for n, ray in enumerate(self.ray_angles):
            for dist in np.arange(0, self.max_range, 0.5):
                x = int(position.x + math.cos(ray + position.theta)*dist)
                y = int(position.y + math.sin(ray + position.theta)*dist)
                if x >= np.shape(new_map)[0] or y >= np.shape(new_map)[1]:
                    break
                if x < 0 or y < 0:
                    break
                if map[x, y] < 0.8:
                    new_map[x, y] = 0.2
                else:
                    distances[n] = dist
                    break
        return new_map, list(zip(self.ray_angles, distances))