import yaml
import os
import pygame as pg
import math
import rpyc
import threading
from rpyc.utils.server import ThreadedServer
from lib_dev.Localize.Maps.MapDef import *

RESOLUTION = 200 # pixels per m
EDGE_LENGTH = 3 # m
WIDTH = 1
HEIGHT = 1

min_lidar_range = int(0.75*RESOLUTION)
max_lidar_range = int(4*RESOLUTION)
        
class RoboSim:
    def __init__(self, robocfg_file="", map_file=""):
        self.FRAME_RATE = 60

        self.c = rpyc.connect('localhost', 18812, config={"allow_all_attrs": True})

        self.gray = pg.Color('gray15')
        self.blue = pg.Color('dodgerblue2')
        self.red = pg.Color('red')
        self.robocolor=self.blue
        self.clock = pg.time.Clock()    
        self.screen = pg.display.set_mode((RESOLUTION*EDGE_LENGTH, RESOLUTION*EDGE_LENGTH))

        self.v=0 # px/sec
        self.w=0 # rad/sec
        self.theta=math.pi/2 # rad

        self.motoron=0
        self.enccount=0
        self.override=0

        self.max_a=5 # px/s/s
        self.max_v=10# px/sec

        self.x=192
        self.last_x=0
        self.y=47
        self.last_y=0

        self.robocfg = {}

        with open(robocfg_file, 'r') as robocfg:
            self.robocfg = yaml.safe_load(robocfg)
        print(self.robocfg)
        

        self.g = MapDef()
        self.g.load_file(map_file)
        self.g_discrete = self.g.gen_discrete_map(200)
                

    def setMotor(self, en): # en: 1/0 for on/off
        self.motoron=en

    def getEnc(self):
        return int(self.enccount)&0xFF 

    def clrEnc(self):
        self.enccount=0
        
    def rotate(self, image, rect, angle):
        """Rotate the image while keeping its center."""
        # Rotate the original image without modifying it.
        new_image = pg.transform.rotate(image, angle)
        # Get a new rect with the center of the old rect.
        rect = new_image.get_rect(center=rect.center)
        return new_image, rect

    def draw_lidar2(self, pos):
        x,y,angle=pos
        # angle *= -1
        dat_ = []

        for a in [0,-0.25,-0.5,-1,-1.5,-2,-2.5,0.25,0.5,1,1.5,2,2.5]:
            ray = [
                (x, y),
                ((int( max_lidar_range*math.cos(math.radians(angle)+a)+x ),
                int( max_lidar_range*math.sin(math.radians(angle)+a)+y )))
            ]
            pg.draw.line(self.screen, (60,60,60), _point_to_pg(ray[0]), _point_to_pg(ray[1]))

            closest_distance = max_lidar_range
            closet_point = None
            for _line in self.g.walls:
                _start = _line[0]
                _end = _line[1]
                wall = ((_start[0]*RESOLUTION, _start[1]*RESOLUTION),
                        (_end[0]*RESOLUTION, _end[1]*RESOLUTION))
                inter = _line_intersection(ray, wall)
                if inter is not None:
                    dist = math.sqrt(math.pow(x-inter[0],2) + math.pow(y-inter[1],2))
                    if dist < closest_distance:
                        closest_distance = dist
                        closet_point = inter
                    # pg.draw.circle(self.screen, (0,150,0), _point_to_pg(inter), 2) # this will plot all possible intersections
                # print(inter)
            if closet_point is not None:
                pg.draw.circle(self.screen, (0,255,0), _point_to_pg(closet_point), 2)
                dat_.append((a,closest_distance/RESOLUTION))
        self.c.root.update(lidar_data_=dat_)
    
    def draw_pos(self, pos):
        x,y,angle=pos

        font = pg.font.Font(None, 20)
        text = font.render(f"{x:3.0f}, {y:3.0f}, {angle:3.0f}", True, (150, 50, 50))
        textpos = text.get_rect(centerx=self.screen.get_width() / 2, y=10)
        self.screen.blit(text, textpos)
        

    def draw_map(self):
        for _line in self.g.walls:
            _start_x = _line[0][0]*RESOLUTION
            _start_y = _line[0][1]*RESOLUTION
            _end_x = _line[1][0]*RESOLUTION
            _end_y = _line[1][1]*RESOLUTION
            pg.draw.line(self.screen, (200,200,200), *_line_to_pg([(_start_x,_start_y),(_end_x,_end_y)]))
        
        for _node in self.g.nav_nodes:
            x = _node[0]*RESOLUTION
            y = _node[1]*RESOLUTION
            pg.draw.circle(self.screen, (255,255,255), _point_to_pg((x,y)), 2)
            
    def drawrobo(self, pos): # pos: (x,y,angle)
        x,y,angle=pos
        robo_len=self.robocfg['robo_length']
        robo_wid=self.robocfg['robo_width']
        image = pg.Surface((robo_len*RESOLUTION, robo_wid*RESOLUTION), pg.SRCALPHA)
        pg.draw.polygon(image, self.robocolor, ((0, 0), (robo_len*RESOLUTION, robo_wid/2*RESOLUTION-robo_wid/3*RESOLUTION), (robo_len*RESOLUTION, robo_wid/2*RESOLUTION+robo_wid/3*RESOLUTION), (0, robo_wid*RESOLUTION)))
        orig_image = image
        rect = image.get_rect(center=_point_to_pg((x,y)))
        image, rect = self.rotate(orig_image, rect, angle)
        self.screen.blit(image, rect)

        self.draw_lidar2(pos)
        self.draw_map()

        self.draw_pos(pos)
        

    def main(self):        
        done = False
        pg.key.set_repeat(5, 5)
        while not done:
            for event in pg.event.get():
                if event.type == pg.QUIT:
                    done = True
                if event.type == pg.KEYDOWN:
                    if event.key == pg.K_LEFT:
                        self.theta += .005
                    if event.key == pg.K_RIGHT:
                        self.theta -= .005

            keys=pg.key.get_pressed()
            if keys[pg.K_UP]:
                self.override=1
                self.v=100
            elif keys[pg.K_DOWN]:
                self.override=1
                self.v=-100
            else:
                self.override=0
                self.v=0

            d=self.c.root.get()
            #self.motoron=d['motoron']
            #self.theta=d['theta']

            if d['encsetpoint'] > 0:
                self.enccount = d['encsetpoint']
                self.c.root.update(encsetpoint_=0)
                
            #print(d)
                    
            self.screen.fill(self.gray)

            self.robocolor=self.blue

            if len(d['do_drive']) > 0:
                dist_,theta_ = d['do_drive']
                do_drive_=[dist_,theta_]
                if theta_ > 0:
                   do_drive_[1] -= .05
                   self.theta += .05
                if theta_ < 0:
                   do_drive_[1] += .05
                   self.theta -= .05
                if dist_ > 0:
                   do_drive_[0] -= 5
                   self.x += math.cos(self.theta)*5
                   self.y += math.sin(self.theta)*5
                if dist_ < 0:
                   do_drive_[0] += 10
                   self.x -= math.cos(self.theta)*5
                   self.y -= math.sin(self.theta)*5
                if(dist_*do_drive_[0]) < 0:
                    do_drive_[0] = 0
                if(theta_*do_drive_[1]) < 0:
                    do_drive_[1] = 0
                self.c.root.update(do_drive_=do_drive_)

            if self.override:
                pass
            else:
                if self.motoron:
                    if self.getEnc() > 0x7F:
                        #back
                        self.v = self.v-self.max_a/self.FRAME_RATE
                        if self.v < -self.max_v*(2/5):
                            self.v = -self.max_v*(2/5)
                    else:
                        #fwd
                        self.v = self.v+self.max_a/self.FRAME_RATE
                        if self.v > self.max_v:
                            self.v = self.max_v
                else:
                    if self.v < 0:
                        #back
                        self.v = self.v+self.max_a/self.FRAME_RATE
                        if self.v > 0:
                            self.v = 0
                    elif self.v > 0:
                        #fwd
                        self.v = self.v-self.max_a/self.FRAME_RATE
                        if self.v < 0:
                            self.v = 0

            self.enccount-=self.v/self.FRAME_RATE
            if abs(self.getEnc()) < 1:
                #self.motoron = 0
                self.c.root.update(motoron_=0)
            if self.v!=0:
                self.c.root.update(enccount_=self.getEnc())
        
            self.x=self.x+math.cos(self.theta)*self.v/self.FRAME_RATE
            self.y=self.y+math.sin(self.theta)*self.v/self.FRAME_RATE
            self.theta=self.theta+self.w/self.FRAME_RATE


            if self.x>RESOLUTION*EDGE_LENGTH and self.x>self.last_x:
                self.x=RESOLUTION*EDGE_LENGTH
                self.robocolor=self.red
            elif self.x<0 and self.x<self.last_x:
                self.x=0
                self.robocolor=self.red
            if self.y>RESOLUTION*EDGE_LENGTH and self.y>self.last_y:
                self.y=RESOLUTION*EDGE_LENGTH
                self.robocolor=self.red
            elif self.y<0 and self.y<self.last_y:
                self.y=0
                self.robocolor=self.red
                
            self.drawrobo((self.x,self.y,math.degrees(self.theta)))


            self.c.root.update(pos_=(self.x,self.y,self.theta),v_=self.v,w_=self.w)#,theta_=self.theta)
    
            self.last_y = self.y
            self.last_x = self.x
           
            
            pg.display.flip()
            self.clock.tick(self.FRAME_RATE)


def _line_intersection(line1, line2):
    x1, x2, x3, x4 = line1[0][0], line1[1][0], line2[0][0], line2[1][0]
    y1, y2, y3, y4 = line1[0][1], line1[1][1], line2[0][1], line2[1][1]

    dx1 = x2 - x1
    dx2 = x4 - x3
    dy1 = y2 - y1
    dy2 = y4 - y3
    dx3 = x1 - x3
    dy3 = y1 - y3

    det = dx1 * dy2 - dx2 * dy1
    det1 = dx1 * dy3 - dx3 * dy1
    det2 = dx2 * dy3 - dx3 * dy2

    if det == 0.0:  # lines are parallel
        if det1 != 0.0 or det2 != 0.0:  # lines are not co-linear
            return None  # so no solution

        if dx1:
            if x1 < x3 < x2 or x1 > x3 > x2:
                return None
                # return math.inf  # infinitely many solutions
        else:
            if y1 < y3 < y2 or y1 > y3 > y2:
                return None
                # return math.inf  # infinitely many solutions

        if line1[0] == line2[0] or line1[1] == line2[0]:
            return line2[0]
        elif line1[0] == line2[1] or line1[1] == line2[1]:
            return line2[1]

        return None  # no intersection

    s = det1 / det
    t = det2 / det

    if 0.0 < s < 1.0 and 0.0 < t < 1.0:
        return x1 + t * dx1, y1 + t * dy1

def _point_to_pg(pnt):
    return(pnt[0], RESOLUTION*EDGE_LENGTH-pnt[1])

def _line_to_pg(line):
    return (_point_to_pg(line[0]), _point_to_pg(line[1]))

global server

data={
    'pos':[],
    'v':0,
    'w':0,
    'theta':0,
    'motoron':0,
    'enccount':0,
    'encsetpoint':0,
    'do_drive': [],
    'lidar_data': []
}

class Service(rpyc.Service):

    def exposed_update(self,pos_=None,v_=None,w_=None,theta_=None,motoron_=None,enccount_=None,encsetpoint_=None,lidar_data_=None,do_drive_=None):
        if v_ is not None:
            data['v'] = v_
        if pos_ is not None:
            data['pos'] = pos_
        if w_ is not None:
            data['w'] = w_
        if theta_ is not None:
            data['theta'] = theta_
        if motoron_ is not None:
            data['motoron'] = motoron_
        if enccount_ is not None:
            data['enccount'] = enccount_
        if encsetpoint_ is not None:
            data['encsetpoint'] = encsetpoint_
        if lidar_data_ is not None:
            data['lidar_data'] = lidar_data_
        if do_drive_ is not None:
            data['do_drive'] = do_drive_

    def exposed_get(self):
        return data
        
    def exposed_echo(self, text):
        print(self.dumb,text)

def serve():
    global server
    server = ThreadedServer(Service, port = 18812)
    server.start()
    
        
def sim():
    pg.init()
    dir = os.path.dirname(__file__)
    sim = RoboSim(
        robocfg_file=os.path.join(dir, 'robocfg.yml'),
        map_file=os.path.join(dir, '../../lib_dev/Localize/Maps/tcffhr_l1.yaml'),
        )
    sim.main()
    pg.quit()

if __name__ == '__main__':
    global server
    server_t = threading.Thread(target=serve)
    server_t.start()
    sim_t = threading.Thread(target=sim)
    sim_t.start()
    sim_t.join()

    server.close()
    
    server_t.join()
