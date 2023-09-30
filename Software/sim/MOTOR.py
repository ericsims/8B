
class MOTOR:
    def __init__(self, sim):
        self.sim = sim
        self.value = [0]*2        
               
    def get(self,addr):
        if addr & 0x1 == 0:
            raise Exception("MOTOR read of addr 0 not supported")
        elif addr & 0x1 == 1:
            if self.sim is None:
                return 0
            else:
                d = self.sim.root.get()
                self.value[1] = (self.value[1] & 0xFE) | int(d['motoron'])
                return self.value[1]


    def set(self,addr,V):
        self.value[addr & (0x1)] = V & 0xFF
        if self.sim is not None:
            if addr & 0x1 == 0:
                self.sim.root.update(encsetpoint_=self.value[0])
            elif addr & 0x1 == 1:
                self.sim.root.update(motoron_=self.value[1]&0x01)
