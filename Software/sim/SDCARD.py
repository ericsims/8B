class SDCARD:
    def __init__(self,size=2**24):
        self.size = size
        self.value = [0x00]*(self.size)
        self.addr_reg = 0x00
               
    def get(self,addr):
        if (addr&0x07) == 0x00:
            return (self.addr_reg >> 8 >> 8 >> 8) & 0xFF
        elif (addr&0x07) == 0x01:
            return (self.addr_reg >> 8 >> 8) & 0xFF
        elif (addr&0x07) == 0x02:
            return (self.addr_reg >> 8) & 0xFF
        elif (addr&0x07) == 0x03:
            return self.addr_reg & 0xFF
        elif (addr&0x07) == 0x04:
            return self.value[self.addr_reg & (self.size-1)]
        else:
            raise Exception(f"SDCARD control byte {addr&0x07} not valid")

    def set(self, addr, V):
        if (addr&0x07) == 0x00:
            self.addr_reg = (self.addr_reg & 0x00FFFFFF) | ((V & 0xFF) << 8 << 8 << 8)
        elif (addr&0x07) == 0x01:
            self.addr_reg = (self.addr_reg & 0xFF00FFFF) | ((V & 0xFF) << 8 << 8)
        elif (addr&0x07) == 0x02:
            self.addr_reg = (self.addr_reg & 0xFFFF00FF) | ((V & 0xFF) << 8)
        elif (addr&0x07) == 0x03:
            self.addr_reg = (self.addr_reg & 0xFFFFFF00) | (V & 0xFF)
        elif (addr&0x07) == 0x04:
            raise Exception("SDCARD write not supported")
            # self.value[self.addr_reg & (2**self.size-1)] = V & 0xFF
        else:
            raise Exception(f"SDCARD control byte {addr&0x07} not valid")