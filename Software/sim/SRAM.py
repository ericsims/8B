import FreeSimpleGUI as sg

class SRAM:
    def __init__(self, size):
        self.size = size
        self.value = [None]*(self.size)
        self.writes = []
        self.reads = []
        self.window = None
               
    def get(self,addr,ignore_uninit=False,log=False):
        v_ = self.value[addr & (self.size-1)]
        
        if v_ is None:
            if ignore_uninit:
                return 0
            else:
                raise Exception("Tried to read unintialized SRAM at addr 0x{:04X}".format(addr))
        else:
            if log: self.reads.append(addr & (self.size-1))
            return v_


    def set(self,addr,V,log=False):
        if log: self.writes.append(addr & (self.size-1))
        self.value[addr & (self.size-1)] = V & 0xFF
    
    def clear_read_write_log(self):
        self.writes = []
        self.reads = []
    
    def gui_get_layout(self):
        return [[
            sg.Column([
            [sg.Multiline(
                size=(138,70),
                font=('courier new',8),
                justification='left',
                text_color='black',
                background_color='white',
                key='_SRAM_',
                expand_y=True,
                expand_x=True
            )]
            ], vertical_alignment='t', expand_y=False, expand_x=False),
        ]]
    
    def gui_init(self, window):
        self.window = window
        self.window['_SRAM_'].Widget.tag_config('WRITES', foreground='red')
        self.window['_SRAM_'].Widget.tag_config('READS', foreground='blue')

    def gui_update(self,stack_pointer=None):
        return
        sram_values = [
            f"{i:04X} "
            +f"{' '.join([f'{x:02X}' if x is not None else '--' for x in self.value[i:i+8]])}  "
            +f"{' '.join([f'{x:02X}' if x is not None else '--' for x in self.value[i+8:i+16]])}  "
            +f"{' '.join([f'{x:02X}' if x is not None else '--' for x in self.value[i+16:i+24]])}  "
            +f"{' '.join([f'{x:02X}' if x is not None else '--' for x in self.value[i+24:i+32]])}  "
            +f"{''.join([f'{chr(x)}' if x is not None and x >= 0x20 and x <= 0x7E else '.' for x in self.value[i:i+32]])}"
            for i in range(0x4000,0x4000+0x8000,32)]

        # # mark stack pointer with '*'
        if stack_pointer is not None:
            row,col = SRAM._get_sram_char_pos(stack_pointer)
            sram_values[row] = sram_values[row][0:col]+"*"+sram_values[row][col+1:]

        # set values. keep scroll position
        sram_scroll_pos = self.window['_SRAM_'].Widget.yview()[0]
        self.window['_SRAM_'].update("\n".join(sram_values))
        self.window['_SRAM_'].Widget.yview_moveto(sram_scroll_pos)

        # label reads/writes with tags to be colorized
        for read in self.reads:
            row,col = SRAM._get_sram_char_pos(read)
            self.window['_SRAM_'].Widget.tag_add('READS', f'1.0 + {row*138+col} chars', f'1.0 + {row*138+col+3} chars')
        for write in self.writes:
            row,col = SRAM._get_sram_char_pos(write)
            self.window['_SRAM_'].Widget.tag_add('WRITES', f'1.0 + {row*138+col} chars', f'1.0 + {row*138+col+3} chars')
        self.clear_read_write_log()

    @staticmethod
    def _get_sram_char_pos(addr):
        row_num = int((addr-0x4000)/32)
        col_num = ((addr-0x4000)-row_num*32)*3
        col_num += int(col_num/3/8)
        col_num += 4
        return row_num,col_num
