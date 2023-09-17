import math

class Position:
    def __init__(self, x, y, theta):
        self.x = x
        self.y = y
        self.theta = theta

def update_pos(position, delta_dist, delta_theta):
    # discretely updates particle positions, position first, then theta
    position.x += math.cos(position.theta)*delta_dist
    position.y += math.sin(position.theta)*delta_dist
    position.theta += delta_theta