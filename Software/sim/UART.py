from queue import Queue
from queue import Empty
from bcolors import bcolors
import FreeSimpleGUI as sg

class UART:
    def __init__(self):
        self.value = [0]
        self.out_callback=self.print_char
        self.in_fifo = Queue(maxsize=16) # real FIFO is only 16 deep 
        self.window = None
               
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
        if self.window:
            if char == '\b':
                # TODO: is there a better way to backspace
                self.window['_UART_'].update(self.window['_UART_'].get()[:-2])
            else:
                self.window['_UART_'].print(char, end='')
        else:
            print(f"{bcolors.OKCYAN}{char}{bcolors.ENDC}", end='')

    def rcv_char(self, char):
        self.in_fifo.put(char, block=False)
    
    def gui_get_layout(self):
        return [
            sg.Multiline(
            autoscroll=True,
            font=('courier new',11),
            justification='left',
            text_color='black',
            background_color='white',
            key='_UART_',
            expand_y = True,
            expand_x = True,
            disabled=True,
            rstrip=False)
        ]
    
    def gui_init(self, window):
        self.window = window
        
        # register key events for the _UART_ window
        for char in '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~ \t\n\r\x0b\x0c':
            self.window['_UART_'].bind(char,ord(char))
        self.window['_UART_'].bind("<Return>",ord('\n'))
        self.window['_UART_'].bind("<space>",ord(' '))
        self.window['_UART_'].bind("<BackSpace>",ord('\b'))

    
    def gui_update(self):
        pass