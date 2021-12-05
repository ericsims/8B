import pygame as pg
import math
import rpyc
import threading
from rpyc.utils.server import ThreadedServer


RESOLUTION = 100 # pixels per ft
EDGE_LENGTH = 8 # ft

min_lidar_range = int(0.75*RESOLUTION)
max_lidar_range = int(6*RESOLUTION)
        
class RoboSim:
    def __init__(self):
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
        self.theta=0 # rad

        self.motoron=0
        self.enccount=0
        self.override=0

        self.max_a=5 # px/s/s
        self.max_v=10# px/sec

        self.x=100
        self.last_x=0
        self.y=100
        self.last_y=0
        
    

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

    def draw_lidar(self, pos): # pos: (x,y,angle)
        x,y,angle=pos
        angle *= -1
        dat_ = []
        for a in range(0,360,30):
            pg.draw.line(self.screen, (200,0,0), (x, y),
                         (int( max_lidar_range*math.cos(math.radians(angle)+math.radians(a))+x ),
                          int( max_lidar_range*math.sin(math.radians(angle)+math.radians(a))+y)) )
            for r in range(min_lidar_range,max_lidar_range): # lidar range. only return points between 1 and 4 ft
                x_test = int(r*math.cos(math.radians(angle)+math.radians(a))+x)
                y_test = int(r*math.sin(math.radians(angle)+math.radians(a))+y)
                if x_test <= 0 or y_test <= 0 or x_test >= EDGE_LENGTH*RESOLUTION or y_test >= EDGE_LENGTH*RESOLUTION:
                    dat_.append((a,r/RESOLUTION))
                    pg.draw.circle(self.screen, (0,255,0), (x_test,y_test), 4)
                    break
        self.c.root.update(lidar_data_=dat_)

    def drawrobo(self, pos): # pos: (x,y,angle)
        x,y,angle=pos
        robo_len=1.0
        robo_wid=0.83
        image = pg.Surface((robo_len*RESOLUTION, robo_wid*RESOLUTION), pg.SRCALPHA)
        pg.draw.polygon(image, self.robocolor, ((0, 0), (robo_len*RESOLUTION, robo_wid/2*RESOLUTION-robo_wid/3*RESOLUTION), (robo_len*RESOLUTION, robo_wid/2*RESOLUTION+robo_wid/3*RESOLUTION), (0, robo_wid*RESOLUTION)))
        orig_image = image
        rect = image.get_rect(center=(x, y))
        image, rect = self.rotate(orig_image, rect, angle)
        self.screen.blit(image, rect)

        self.draw_lidar(pos)


        

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
            self.y=self.y-math.sin(self.theta)*self.v/self.FRAME_RATE
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


            self.c.root.update(v_=self.v,w_=self.w)#,theta_=self.theta)
    
            self.last_y = self.y
            self.last_x = self.x
           
            
            pg.display.flip()
            self.clock.tick(self.FRAME_RATE)


global server

data={
    'v':0,
    'w':0,
    'theta':0,
    'motoron':0,
    'enccount':0,
    'encsetpoint':0,
    'lidar_data': []
}

class Service(rpyc.Service):

    def exposed_update(self,v_=None,w_=None,theta_=None,motoron_=None,enccount_=None,encsetpoint_=None,lidar_data_=None):
        if v_ is not None:
            data['v'] = v_
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
    sim = RoboSim()
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
    



