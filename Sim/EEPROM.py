class EEPROM:
    def __init__(self):
        self.value = [0]*(2**15)
               
    def get(self,addr):
        return self.value[addr & (0x7FFF)]

    def set(self,L,V):
        raise Exception("EEPROM write not supported")