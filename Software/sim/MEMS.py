from EEPROM import EEPROM
from SRAM import SRAM
from UART import UART
from MOTOR import MOTOR
from Extended_EEPROM import Extended_EEPROM
from SDCARD import SDCARD


class MEMS:
    def __init__(self, sim=None):
        self.sim = sim
        self.eeprom = EEPROM()
        self.sram = SRAM(2**15)
        self.uart = UART()
        self.motor = MOTOR(self.sim)
        self.sdcard = SDCARD(2**24)
               
    def get(self,addr,ignore_uninit=False,log=False):
        addr = addr & 0xFFFF
        if addr >=0x0000 and addr < 0x0000+0x4000:
            return self.eeprom.get(addr)
        elif addr >= 0x4000 and addr < 0x4000+0x8000:
            return self.sram.get(addr,ignore_uninit=ignore_uninit,log=log)
        elif addr >= 0xE004 and addr < 0xE004+0x002:
            return self.motor.get(addr,log)
        elif addr >= 0xE002 and addr < 0xE002+0x002:
            return self.uart.get(addr)
        elif addr >= 0xE010 and addr < 0xE010+0x008:
            return self.sdcard.get(addr)
        elif not ignore_uninit:
            raise Exception("Tried to read mem at invalid addr 0x{:04X}".format(addr))

    def set(self,addr,V,log=False):
        addr = addr & 0xFFFF
        if addr >=0x0000 and addr < 0x0000+0x4000:
            return self.eeprom.set(addr,V)
        elif addr >= 0x4000 and addr < 0x4000+0x8000:
            return self.sram.set(addr,V,log=log)
        elif addr >= 0xE004 and addr < 0xE004+0x002:
            return self.motor.set(addr,V)
        elif addr >= 0xE002 and addr < 0xE002+0x002:
            return self.uart.set(addr,V)
        elif addr >= 0xE010 and addr < 0xE010+0x008:
            return self.sdcard.set(addr,V)
        else:
            raise Exception("Tried to write mem at invalid addr 0x{:04X}".format(addr))
            