class UART:
    def __init__(self):
        self.value = [0]
        self.callback=self.print_char
               
    def get(self,addr):
        raise Exception("UART read not supported")

    def set(self,addr,V):
        self.value[addr & (0x0)] = V & 0xFF
        #print("set the uart!!")
        #print('UART 0x{:02X} {} \'{}\''.format(self.value[0],self.value[0],chr(self.value[0])))
        self.callback(chr(self.value[0]))

    def print_char(self, char):
        print(char, end='', flush=True)