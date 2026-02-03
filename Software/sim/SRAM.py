class SRAM:
    def __init__(self, size):
        self.size = size
        self.value = [None]*(self.size)
        self.writes = []
        self.reads = []
               
    def get(self,addr,ignore_uninit=False,log=False):
        v_ = self.value[addr & (self.size-1)]
        
        if v_ is None:
            if ignore_uninit:
                return 0
            else:
                raise Exception("Tried to read unintialized SRAM at addr 0x{:04X}".format(addr))
        else:
            if log: self.reads.append(addr & (self.size-1))
            return v_


    def set(self,addr,V,log=False):
        if log: self.writes.append(addr & (self.size-1))
        self.value[addr & (self.size-1)] = V & 0xFF
    
    def clear_read_write_log(self):
        self.writes = []
        self.reads = []