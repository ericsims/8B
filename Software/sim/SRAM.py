class SRAM:
    def __init__(self, size):
        self.size = size
        self.value = [None]*(self.size)
               
    def get(self,addr,ignore_uninit=False):
        v_ = self.value[addr & (self.size-1)]

        if (v_ is not None) or ignore_uninit:
            return v_
        else:
            raise Exception("Tried to read unintialized SRAM at addr 0x{:04X}".format(addr))

    def set(self,addr,V):
        self.value[addr & (self.size-1)] = V & 0xFF