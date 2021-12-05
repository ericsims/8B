import rpyc
import warnings
import math
import pygame as pg

RESOLUTION = 30 # pixels per ft
EDGE_LENGTH = 16 # ft

FRAME_RATE = 60

try:
    conn = rpyc.connect('localhost', 18812, config={"allow_all_attrs": True})
except:
    conn = None
    warnings.warn("Warning. Sim not connected!")


if conn is not None:
    clock = pg.time.Clock()
    screen = pg.display.set_mode((RESOLUTION*EDGE_LENGTH, RESOLUTION*EDGE_LENGTH))

    done = False
    pg.key.set_repeat(5, 5)
    while not done:
        for event in pg.event.get():
            if event.type == pg.QUIT:
                done = True

        screen.fill(pg.Color('gray15'))

        lidar_data = conn.root.get()['lidar_data']

        center = RESOLUTION*EDGE_LENGTH/2

        for p in lidar_data:
            a = p[0]-90
            r = p[1]*RESOLUTION

            x=int( r*math.cos(math.radians(a))+center )
            y=int( r*math.sin(math.radians(a))+center )
            pg.draw.line(screen, (200,0,0), (center, center), (x,y) )
            pg.draw.circle(screen, (0,255,0), (x,y), 2)

        pg.display.flip()
        clock.tick(FRAME_RATE)
