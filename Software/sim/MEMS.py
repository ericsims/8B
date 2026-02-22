from EEPROM import EEPROM
from SRAM import SRAM
from UART import UART
from MOTOR import MOTOR
from Extended_EEPROM import Extended_EEPROM
from SDCARD import SDCARD
from MEM_TFT_RA8876 import TFT_RA8876
from MEM_ETH_W5300 import ETH_W5300

class MEMS:
    def __init__(self, sim=None):
        self.sim = sim
        self.eeprom = EEPROM()
        self.sram = SRAM(2**16)
        self.uart = UART()
        self.motor = MOTOR(self.sim)
        self.sdcard = SDCARD(2**24)
        self.ra8876 = TFT_RA8876()
        self.w5300 = ETH_W5300()
               
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
        elif addr >= 0xE006 and addr < 0xE006+0x002:
            return self.ra8876.get(addr)
        elif addr >= 0xE010 and addr < 0xE010+0x002:
            return self.sdcard.get(addr)
        elif addr >= 0xE400 and addr < 0xE400+0x400:
            return self.w5300.get(addr)
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
        elif addr >= 0xE006 and addr < 0xE006+0x002:
            return self.ra8876.set(addr,V)
        elif addr >= 0xE010 and addr < 0xE010+0x002:
            return self.sdcard.set(addr,V)
        elif addr >= 0xE400 and addr < 0xE400+0x400:
            return self.w5300.set(addr,V)
        else:
            raise Exception("Tried to write mem at invalid addr 0x{:04X}".format(addr))
            