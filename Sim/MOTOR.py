import rpyc
import warnings

class MOTOR:
    def __init__(self):
        self.value = [0]*2
        try:
            self.conn = rpyc.connect('localhost', 18812, config={"allow_all_attrs": True})
        except:
            self.conn = None
            warnings.warn("Warning. Sim not connected!")
        
               
    def get(self,addr):
        if addr & 0x1 == 0:
            raise Exception("MOTOR read of addr 0 not supported")
        elif addr & 0x1 == 1:
            if self.conn is None:
                return 0
            else:
                d = self.conn.root.get()
                self.value[1] = (self.value[1] & 0xFE) | int(d['motoron'])
                return self.value[1]


    def set(self,addr,V):
        self.value[addr & (0x1)] = V & 0xFF
        if self.conn is not None:
            if addr & 0x1 == 0:
                self.conn.root.update(encsetpoint_=self.value[0])
            elif addr & 0x1 == 1:
                self.conn.root.update(motoron_=self.value[1]&0x01)
