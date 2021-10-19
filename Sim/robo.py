import pygame as pg
import math
import rpyc
import threading
from rpyc.utils.server import ThreadedServer


class RoboSim:
    def __init__(self):
        self.FRAME_RATE = 60

        self.c = rpyc.connect('localhost', 18812, config={"allow_all_attrs": True})

        self.gray = pg.Color('gray15')
        self.blue = pg.Color('dodgerblue2')
        self.red = pg.Color('red')
        self.robocolor=self.blue
        self.clock = pg.time.Clock()
        self.screen = pg.display.set_mode((640, 480))

        self.v=0 # px/sec
        self.w=0 # rad/sec
        self.theta=0 # rad

        self.motoron=0
        self.enccount=0

        self.max_a=10 # px/s/s
        self.max_v=10# px/sec

        self.x=100
        self.last_x=0
        self.y=100
        self.last_y=0
    

    def setMotor(self, en): # en: 1/0 for on/off
        self.motoron=en

    def getEnc(self):
        return int(self.enccount)

    def clrEnc(self):
        self.enccount=0
        
    def rotate(self, image, rect, angle):
        """Rotate the image while keeping its center."""
        # Rotate the original image without modifying it.
        new_image = pg.transform.rotate(image, angle)
        # Get a new rect with the center of the old rect.
        rect = new_image.get_rect(center=rect.center)
        return new_image, rect

    def drawrobo(self, pos): # pos: (x,y,angle)
        x,y,angle=pos
        image = pg.Surface((320/5, 200/5), pg.SRCALPHA)
        pg.draw.polygon(image, self.robocolor, ((0, 0), (320/5, 100/5-10), (320/5, 100/5+10), (0, 200/5)))
        # Keep a reference to the original to preserve the image quality.
        orig_image = image
        rect = image.get_rect(center=(x, y))
        image, rect = self.rotate(orig_image, rect, angle)
        self.screen.blit(image, rect)

    def main(self):        
        done = False
        
        while not done:
            for event in pg.event.get():
                if event.type == pg.QUIT:
                    done = True

            d=self.c.root.get()
            self.motoron=d['motoron']
            #print(d)
                    
            self.screen.fill(self.gray)

            self.robocolor=self.blue

            if self.motoron:
                self.v=self.v+self.max_a/self.FRAME_RATE
            else:
                self.v=self.v-self.max_a/self.FRAME_RATE
                
            if self.v>self.max_v:
                self.v=self.max_v
            elif self.v<0:
                self.v=0

            self.enccount+=self.v/self.FRAME_RATE
        
            self.x=self.x+math.cos(self.theta)*self.v/self.FRAME_RATE
            self.y=self.y-math.sin(self.theta)*self.v/self.FRAME_RATE
            self.theta=self.theta+self.w/self.FRAME_RATE


            if self.x>640 and self.x>self.last_x:
                self.x=640
                self.robocolor=self.red
            elif self.x<0 and self.x<self.last_x:
                self.x=0
                self.robocolor=self.red
            if self.y>480 and self.y>self.last_y:
                self.y=480
                self.robocolor=self.red
            elif self.y<0 and self.y<self.last_y:
                self.y=0
                self.robocolor=self.red
                
            self.drawrobo((self.x,self.y,math.degrees(self.theta)))


            self.c.root.update(v_=self.v,w_=self.w,theta_=self.theta)
    
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
}

class Service(rpyc.Service):

    def exposed_update(self,v_=None,w_=None,theta_=None,motoron_=None,enccount_=None):
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
    



