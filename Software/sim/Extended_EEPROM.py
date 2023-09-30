class Extended_EEPROM:
    def __init__(self):
        self.size = 16
        self.value = [0xFF]*(2**self.size)
        self.addr_reg = 0x0000
               
    def get(self,addr):
        if (addr&0x03) == 0x00:
            return self.value[self.addr_reg & (2**self.size-1)]
        elif (addr&0x03) == 0x01:
            return (self.addr_reg >> 8) & 0xFF
        elif (addr&0x03) == 0x02:
            return self.addr_reg & 0xFF
        elif (addr&0x03) == 0x03:
            raise Exception("extended EEPROM byte 3 contains nothing. nothing to get!")

    def set(self, addr, V):
        if (addr&0x03) == 0x00:
            raise Exception("EEPROM write not supported")
            # self.value[self.addr_reg & (2**self.size-1)] = V & 0xFF
        elif (addr&0x03) == 0x01:
            self.addr_reg = (self.addr_reg & 0x00FF) | ((V & 0xFF) << 8)
        elif (addr&0x03) == 0x02:
            self.addr_reg = (self.addr_reg & 0xFF00) | (V & 0xFF)
        elif (addr&0x03) == 0x03:
            raise Exception("extended EEPROM byte 3 contains nothing. nothing to set!")