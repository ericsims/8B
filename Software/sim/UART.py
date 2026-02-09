from queue import Queue
from queue import Empty

class UART:
    def __init__(self):
        self.value = [0]
        self.out_callback=self.print_char
        self.in_fifo = Queue(maxsize=128) # real FIOF is only 16 deep 
               
    def get(self,addr):
        try:
            return self.in_fifo.get(block=False)
        except Empty:
            return 0

    def set(self,addr,V):
        self.value[addr & (0x0)] = V & 0xFF
        #print("set the uart!!")
        #print('UART 0x{:02X} {} \'{}\''.format(self.value[0],self.value[0],chr(self.value[0])))
        self.out_callback(chr(self.value[0]))

    def print_char(self, char):
        print(char, end='', flush=True)

    def rcv_char(self, char):
        self.in_fifo.put(char, block=False)
    