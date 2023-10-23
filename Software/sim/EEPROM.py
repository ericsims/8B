class EEPROM:
    def __init__(self):
        self.size = (2**15)
        self.value = [0]*self.size
               
    def get(self,addr):
        return self.value[addr & (self.size-1)]

    def set(self,addr,V):
        raise Exception("EEPROM write not supported")