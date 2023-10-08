from enum import Enum
import yaml
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import colors

# ENUM for objects/features in map
class MAP_OBJS(int, Enum):
    EMPTY     = 0, (1.0, 1.0, 1.0, 1.0)
    WALL      = 1, (0.0, 0.0, 0.0, 1.0)
    DOORWAY   = 2, (0.0, 0.0, 0.0, 0.05)
    DOOR_NODE = 3, (1.0, 0.0, 0.0, 1.0)
    NAV_NODE  = 4, (0.5, 0.5, 1.0, 1.0)
    NAV_PATH  = 5, (1.0, 0.9, 0.0, 0.3)
    ANNO      = 6, (1.0, 0.0, 0.0, 1.0)
    def __new__(cls, value, color=(0.0, 0.0, 0.0, 1.0)):
        obj = int.__new__(cls, value)
        obj._value_ = value
        obj.color = color
        return obj

# generate colormap for use in plots
COLOR_MAP = colors.ListedColormap([e.color for e in MAP_OBJS])
NORMALIZE = colors.Normalize(vmin=0, vmax=max(MAP_OBJS).value)

class MapDef:
    def __init__(self, size=None, units=None, bounded=None):
        self.walls      = []
        self.doorways   = []
        self.door_nodes = []
        self.nav_nodes  = []
        self.nav_paths  = []
        self.size       = size
        self.units      = units
        self.bounded    = bounded
        self.resolution = None
        self.name       = ""

    def load_file(self, file):
        self.name = file
        with open(file, 'r') as map_cfg_file:
            map_cfg = yaml.safe_load(map_cfg_file)
            # print(map_cfg)
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
                    # x0 = doorway[0][0]
                    # y0 = doorway[0][1]
                    # x1 = doorway[1][0]
                    # y1 = doorway[1][1]
                    # mid_point = [(x0+x1)/2, (y0+y1)/2]
                    # self.door_nodes.append(mid_point)
            if self.bounded:
                x0 = 0
                x1 = self.size[0]
                y0 = 0
                y1 = self.size[1]
                self.walls.append([[x0,y0], [x1,y0]])
                self.walls.append([[x1,y0], [x1,y1]])
                self.walls.append([[x1,y1], [x0,y1]])
                self.walls.append([[x0,y1], [x0,y0]])

    def gen_discrete_map(self, resolution=None):
        # resolution in px per unit
        if resolution is None:
            raise "must provide resolution to generate discrete map"
        self.resolution = resolution
        
        dis_map = np.full((int(resolution*self.size[0]+1), int(resolution*self.size[1]+1)), MAP_OBJS.EMPTY.value)

        # doors
        # for door in self.doorways:
        #     self._plot_line(dis_map, resolution, door, MAP_OBJS.DOORWAY.value)
        # # for door_node in self.door_nodes:
        # #     self._plot_point(dis_map, resolution, door_node, MAP_OBJS.DOOR_NODE.value)
        
        # nav
        nav_nodes_dis = []
        for idx, nav_node in enumerate(self.nav_nodes):
            self._plot_point(dis_map, resolution, nav_node, MAP_OBJS.NAV_NODE.value)
            nav_nodes_dis.append([round(nav_node[0]*resolution),round(nav_node[1]*resolution)])
        
        # walls and boundaries
        for wall in self.walls:
            self._plot_line(dis_map, resolution, wall, MAP_OBJS.WALL.value)
        # if self.bounded:
        #     x0 = 0
        #     x1 = self.size[0]
        #     y0 = 0
        #     y1 = self.size[1]
        #     self._plot_line(dis_map, resolution, [[x0,y0], [x1,y0]], MAP_OBJS.WALL.value)
        #     self._plot_line(dis_map, resolution, [[x1,y0], [x1,y1]], MAP_OBJS.WALL.value)
        #     self._plot_line(dis_map, resolution, [[x1,y1], [x0,y1]], MAP_OBJS.WALL.value)
        #     self._plot_line(dis_map, resolution, [[x0,y1], [x0,y0]], MAP_OBJS.WALL.value)

        for idx, nav_node in enumerate(self.nav_nodes):
            self.nav_paths.append([])
            for dir in [[1,0], [0,1], [-1,0], [0,-1]]:
                xp = round(nav_node[0]*resolution)
                yp = round(nav_node[1]*resolution)
                # print(dir)
                xp += dir[0]
                yp += dir[1]
                while 1:
                    # print(f"x:{xp} y:{yp} x:{int(nav_node[0]*resolution)} y:{int(nav_node[1]*resolution)} ")
                    xp += dir[0]
                    yp += dir[1]
                    if xp < 0 or xp > int(resolution*self.size[0]) or yp < 0 or yp > int(resolution*self.size[1]): break
                    pt_val = dis_map[xp, yp]
                    if (int(pt_val) == 1):
                        break # i hit a wall before another nav node
                    #    self._plot_point(dis_map, resolution, [xp/resolution,yp/resolution], MAP_OBJS.NAV_PATH_MISS.value)
                    # if int(pt_val) == int(MAP_OBJS.NAV_NODE.value):
                    if [xp,yp] in nav_nodes_dis:
                        # print(f"x:{xp} y:{yp} v:{int(pt_val)} x:{int(nav_node[0]*resolution)} y:{int(nav_node[1]*resolution)} ")
                        self._plot_line(dis_map, resolution, [[nav_node[0],nav_node[1]], [xp/resolution,yp/resolution]], MAP_OBJS.NAV_PATH.value)
                        self._plot_point(dis_map, resolution, [xp/resolution,yp/resolution], MAP_OBJS.NAV_NODE.value)
                        self._plot_point(dis_map, resolution, [nav_node[0],nav_node[1]], MAP_OBJS.NAV_NODE.value)
                        self.nav_paths[idx].append(nav_nodes_dis.index([xp,yp]))
                        break
        # print(*[f"{n}: {p}\n" for n,p in enumerate(self.nav_paths)])
        return dis_map

    def gen_discrete_map_walls_only(self, resolution=None):
        if resolution is None:
            raise "must provide resolution to generate discrete map"
        self.resolution = resolution
        
        dis_map = np.full((int(resolution*self.size[0]+1), int(resolution*self.size[1]+1)), MAP_OBJS.EMPTY.value)
        for wall in self.walls:
            self._plot_line(dis_map, resolution, wall, MAP_OBJS.WALL.value)
        return dis_map

    def _plot_point(self, dis_map, resolution, node, value):
        x = round(node[0]*resolution)
        y = round(node[1]*resolution)
        if x < 0 or x > round(resolution*self.size[0]) or y < 0 or y > round(resolution*self.size[1]): return
        dis_map[x,y] = value

    def _plot_line(self, dis_map, resolution, edge, value):
        # Bresenham algo
        x0 = round(edge[0][0]*resolution)
        y0 = round(edge[0][1]*resolution)
        x1 = round(edge[1][0]*resolution)
        y1 = round(edge[1][1]*resolution)

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
