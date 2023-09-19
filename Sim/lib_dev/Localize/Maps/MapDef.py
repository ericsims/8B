from enum import Enum
import yaml
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap

class MAP_OBJS(int, Enum):
    EMPTY     = 0, (1.0, 1.0, 1.0, 1.0)
    WALL      = 1, (0.0, 0.0, 0.0, 1.0)
    DOORWAY   = 2, (0.0, 0.0, 0.0, 0.05)
    NAV_NODE  = 3, plt.cm.Set1(1)
    DOOR_NODE = 4, plt.cm.Set1(0)
    def __new__(cls, value, color=(0.0, 0.0, 0.0, 1.0)):
        obj = int.__new__(cls, value)
        obj._value_ = value
        obj.color = color
        return obj

COLOR_MAP = ListedColormap([e.color for e in MAP_OBJS])

class MapDef:
    def __init__(self, size=None, units=None, bounded=None):
        self.walls      = []
        self.doorways   = []
        self.door_nodes = []
        self.nav_nodes  = []
        self.size       = size
        self.units      = units
        self.bounded    = bounded

    def load_file(self, file):
        with open(file, 'r') as map_cfg_file:
            map_cfg = yaml.safe_load(map_cfg_file)
            self.size    = list(map_cfg['size'],)
            self.units   = map_cfg['units'],
            self.bounded = map_cfg['bounded']
            if 'walls' in map_cfg:
                for wall in map_cfg['walls']:
                    self.walls.append(wall)
            if 'nav_nodes' in map_cfg:
                for nav_node in map_cfg['nav_nodes']:
                    self.nav_nodes.append(nav_node)
            if 'doorways' in map_cfg:
                for doorway in map_cfg['doorways']:
                    self.doorways.append(doorway)
                    x0 = doorway[0][0]
                    y0 = doorway[0][1]
                    x1 = doorway[1][0]
                    y1 = doorway[1][1]
                    mid_point = [(x0+x1)/2, (y0+y1)/2]
                    self.door_nodes.append(mid_point)


    def gen_discrete_map(self, resolution=None):
        # resolution in px per unit
        if resolution is None:
            raise "must provide resolution to generate discrete map"
        
        dis_map = np.full((int(resolution*self.size[0]+1), int(resolution*self.size[1]+1)), MAP_OBJS.EMPTY.value)

        # doors
        for door in self.doorways:
            self._plot_line(dis_map, resolution, door, MAP_OBJS.DOORWAY.value)
        for door_node in self.door_nodes:
            self._plot_point(dis_map, resolution, door_node, MAP_OBJS.DOOR_NODE.value)
        
        # nav
        for nav_node in self.nav_nodes:
            self._plot_point(dis_map, resolution, nav_node, MAP_OBJS.NAV_NODE.value)


        # walls and boundries
        for wall in self.walls:
            self._plot_line(dis_map, resolution, wall, MAP_OBJS.WALL.value)
        if self.bounded:
            x0 = 0
            x1 = self.size[0]
            y0 = 0
            y1 = self.size[1]
            self._plot_line(dis_map, resolution, [[x0,y0], [x1,y0]], MAP_OBJS.WALL.value)
            self._plot_line(dis_map, resolution, [[x1,y0], [x1,y1]], MAP_OBJS.WALL.value)
            self._plot_line(dis_map, resolution, [[x1,y1], [x0,y1]], MAP_OBJS.WALL.value)
            self._plot_line(dis_map, resolution, [[x0,y1], [x0,y0]], MAP_OBJS.WALL.value)

        return dis_map
    
    def _plot_point(self, dis_map, resolution, node, value):
        x = int(node[0]*resolution)
        y = int(node[1]*resolution)
        if x < 0 or x > resolution*self.size[0] or y < 0 or y > resolution*self.size[1]: return
        dis_map[x,y] = value

    def _plot_line(self, dis_map, resolution, edge, value):
        # Bresenham algo
        x0 = int(edge[0][0]*resolution)
        y0 = int(edge[0][1]*resolution)
        x1 = int(edge[1][0]*resolution)
        y1 = int(edge[1][1]*resolution)

        dx = abs(x1 - x0)
        if x0 < x1:
            sx = 1
        else:
            sx = -1
        dy = -abs(y1 - y0)
        if y0 < y1:
            sy = 1
        else:
            sy = -1
        error = dx + dy

        while True:
            if x0 < 0 or x0 > resolution*self.size[0] \
            or y0 < 0 or y0 > resolution*self.size[1]: break
            dis_map[x0, y0] = value
            if x0 == x1 and y0 == y1: break
            e2 = 2 * error
            if e2 >= dy:
                if x0 == x1: break
                error += dy
                x0 += sx
            if e2 <= dx:
                if y0 == y1: break
                error += dx
                y0 += sy
