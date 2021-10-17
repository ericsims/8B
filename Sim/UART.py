class UART:
    def __init__(self):
        self.value = [0]
               
    def get(self,addr):
        raise Exception("UART read not supported")

    def set(self,addr,V):
        self.value[addr & (0x0)] = V & 0xFF
        print('UART 0x{:02X} {}'.format(self.value[0],self.value[0]))