from EEPROM import EEPROM
from SRAM import SRAM
from UART import UART
from MOTOR import MOTOR


class MEMS:
    def __init__(self, sim=None):
        self.sim = sim
        self.eeprom = EEPROM()
        self.sram = SRAM(2**14)
        self.dpram = SRAM(2**10)
        self.uart = UART()
        self.motor = MOTOR(self.sim)
               
    def get(self,addr,ignore_uninit=False):
        addr = addr & 0xFFFF
        if addr >=0 and addr <= 0x7FFF:
            return self.eeprom.get(addr)
        elif addr >= 0x8000 and addr <= 0xBFFF:
            return self.sram.get(addr,ignore_uninit=ignore_uninit)
        elif addr >= 0xC000 and addr <= 0xC3FF:
            return self.dpram.get(addr)
        elif addr >= 0xD002 and addr <= 0xD003:
            return self.motor.get(addr)
        elif addr == 0xD008:
            return self.uart.get(addr)
        else:
            raise Exception("Tried to read mem at invalid addr 0x{:04X}".format(addr))

    def set(self,addr,V):
        addr = addr & 0xFFFF
        if addr >=0 and addr <= 0x7FFF:
            return self.eeprom.set(addr,V)
        elif addr >= 0x8000 and addr <= 0xBFFF:
            return self.sram.set(addr,V)
        elif addr >= 0xC000 and addr <= 0xC3FF:
            return self.dpram.set(addr,V)
        elif addr >= 0xD002 and addr <= 0xD003:
            return self.motor.set(addr,V)
        elif addr == 0xD008:
            return self.uart.set(addr,V)
        else:
            raise Exception("Tried to write mem at invalid addr 0x{:04X}".format(addr))
            