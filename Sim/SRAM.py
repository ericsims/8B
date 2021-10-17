class SRAM:
    def __init__(self):
        self.value = [0]*(2**14)
               
    def get(self,addr):
        return self.value[addr & (0x3FFF)]

    def set(self,addr,V):
        self.value[addr & (0x3FFF)] = V & 0xFF