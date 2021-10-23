class SRAM:
    def __init__(self):
        self.value = [None]*(2**14)
               
    def get(self,addr):
        v_ = self.value[addr & (0x3FFF)]
        if v_ is None:
            raise Exception("Tried to read unintialized SRAM at addr 0x{:04X}".format(addr))
        else:
            return v_

    def set(self,addr,V):
        self.value[addr & (0x3FFF)] = V & 0xFF