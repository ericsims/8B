from EEPROM import EEPROM
from SRAM import SRAM
from UART import UART


class MEMS:
    def __init__(self):
        self.eeprom = EEPROM()
        self.sram = SRAM()
        self.uart = UART()
               
    def get(self,addr):
        addr = addr & 0xFFFF
        if addr >=0 and addr <= 0x7FFF:
            return self.eeprom.get(addr)
        elif addr >= 0x8000 and addr <= 0xBFFF:
            return self.sram.get(addr)
        elif addr == 0xD008:
            return self.uart.get(addr)

    def set(self,addr,V):
        addr = addr & 0xFFFF
        if addr >=0 and addr <= 0x7FFF:
            return self.eeprom.set(addr,V)
        elif addr >= 0x8000 and addr <= 0xBFFF:
            return self.sram.set(addr,V)
        elif addr == 0xD008:
            return self.uart.set(addr,V)