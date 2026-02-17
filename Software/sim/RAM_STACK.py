import FreeSimpleGUI as sg

class STACK:
    def __init__(self, mems,symbols=None):
        self.stack_ptr_initialized=False
        self.starting_addr=0x0000
        self.pointer = 0
        self.max_used = 0
        self.mems = mems
        self.window = None # gui window
        self.symbols = symbols # symbols list for computing variables

    def get_pointer(self):
        return self.starting_addr+self.pointer

    def push(self,V, log=False):
        if self.stack_ptr_initialized:
            self.mems.set(self.starting_addr+self.pointer, V,log=log)
        else:
            self.stack_ptr_not_init()

    def dec(self):
        if self.stack_ptr_initialized:
            # if self.pointer <= 0:
            #     raise Exception("dec from stack ptr when empty")
            self.pointer -= 1
        else:
            self.stack_ptr_not_init()

    def inc(self):
        if self.stack_ptr_initialized:
            self.pointer += 1
            if self.pointer > self.max_used:
                self.max_used = self.pointer
        else:
            self.stack_ptr_not_init()


    def pop(self, log=False):
        if self.stack_ptr_initialized:
            if self.pointer < 0:
                raise Exception("pop from stack when empty")
            v = self.mems.get(self.starting_addr+self.pointer,log=log)
            #self.mems.set(self.starting_addr-self.pointer, 0)
            return v
        else:
            self.stack_ptr_not_init()
    
    def get(self,L=0):
        if self.stack_ptr_initialized:
            if L < 0 or L > 1:
                raise Exception("invalid PC byte")
            return ((self.starting_addr+self.pointer) >> (L*8)) & 0xFF
        else:
            self.stack_ptr_not_init()

    def set(self,V,L=0,reinit=False):
        if self.stack_ptr_initialized == 3 and not reinit:
            newp = None
            if L == 0:
                newp = ((self.get_pointer() & 0xFF00) | V) & 0xFFFF
            elif L == 1:
                newp = ((self.get_pointer() & 0x00FF) | (V<<8)) & 0xFFFF
            else:
                raise Exception("invalid PC byte")
            if newp:
                # print(f"{self.get_pointer():04X} {newp:04X} {self.get_pointer()-newp:04X}")
                self.pointer -= self.get_pointer()-newp
        else:
            # print("reinit stack pointer")
            self.pointer = 0
            if L == 0:
                self.starting_addr = ((self.starting_addr & 0xFF00) | V) & 0xFFFF
                self.stack_ptr_initialized |= 0x01
            elif L == 1:
                self.starting_addr = ((self.starting_addr & 0x00FF) | (V<<8)) & 0xFFFF
                self.stack_ptr_initialized |= 0x02
            else:
                raise Exception("invalid PC byte")

    def stack_ptr_not_init(self):
        raise Exception("tried to do a stack operation without initializing the SP first")
    
    def gui_get_layout(self):
        return [[
            sg.Column([
            [sg.Multiline(
                size=(30,70),
                autoscroll=True,
                font=('courier new',8),
                justification='left',
                text_color='black',
                background_color='white',
                write_only = True,
                disabled = True,
                key='_STACK_',
                expand_y=True,
                expand_x=True
            )]
            ], vertical_alignment='t', expand_y=True, expand_x=True),
            sg.Column([
            [
                sg.T('Current Usage   '),
                sg.T(
                text='',
                size=(12,1),
                justification='left',
                text_color='black',
                background_color='white',
                key='_STACK_USAGE_'
                )
            ],
            [
                sg.T('Max Stack Usage '),
                sg.T(
                text='',
                size=(12,1),
                justification='left',
                text_color='black',
                background_color='white',
                key='_STACK_MAX_USAGE_'
                )
            ],
            [
                sg.T('Current Function '),
                sg.T(
                text='',
                size=(30,1),
                justification='left',
                text_color='black',
                background_color='white',
                key='_CUR_FUNC_'
                )
            ],
            [sg.Listbox(
                values=[],
                select_mode=sg.LISTBOX_SELECT_MODE_SINGLE,
                size=(90,50),
                font=('courier new',8),
                justification='left',
                text_color='black',
                background_color='white',
                key='_LOC_VARS_',
                expand_y=True,
                expand_x=True
            )]
            ], vertical_alignment='t', expand_y=True, expand_x=True)
        ]]

    def gui_init(self, window):
        self.window = window
    
    def gui_update(self, base_ptr_val=None, current_call=None):
        self.window['_STACK_USAGE_'].update(self.pointer)
        self.window['_STACK_MAX_USAGE_'].update(self.max_used)
        

        # display
        stack_values = ""
        for n in range(self.starting_addr,self.starting_addr+self.pointer):
            stack_values += f"0x{n:04X}: {self.mems.get(n,ignore_uninit=True):02X} {n-base_ptr_val:02X} {' <-- BP' if n==base_ptr_val else ''}\n"

        stack_scroll_pos = self.window['_STACK_'].Widget.yview()[0]
        self.window['_STACK_'].update(stack_values)
        self.window['_STACK_'].Widget.yview_moveto(stack_scroll_pos)

        
        # dont bother computing local vars if not in a function
        if base_ptr_val is None or current_call is None:
            return

        # display local variables on stack for current function
        self.window['_CUR_FUNC_'].update(current_call['symbol'])
        local_vars = []
        # print(f'{base_ptr_val:04X}')
        if self.symbols is not None: 
            for s in self.symbols:
                a = [ None, None, None, None ]
                if s.startswith(current_call['symbol']+'.param') or \
                    s.startswith(current_call['symbol']+'.local'):
                    a = [ self.mems.get(base_ptr_val+self.symbols[s]+nn,ignore_uninit=True) for nn in range(4)]

                if s.startswith(current_call['symbol']+'.param8') or \
                    s.startswith(current_call['symbol']+'.local8'):
                    local_vars.append({'addr': self.symbols[s], 'name': s, 'size': 8, 'value': \
                                        f"{'??' if a[0] is None else f'{a[0]:02X}'}"})
                elif s.startswith(current_call['symbol']+'.param16') or \
                    s.startswith(current_call['symbol']+'.local16'):
                    local_vars.append({'addr': self.symbols[s], 'name': s, 'size': 16, 'value': \
                                        f"{'??' if a[0] is None else f'{a[0]:02X}'}"+\
                                        f"{'??' if a[1] is None else f'{a[1]:02X}'}"})
                elif s.startswith(current_call['symbol']+'.param32') or \
                    s.startswith(current_call['symbol']+'.local32'):
                    local_vars.append({'addr': self.symbols[s], 'name': s, 'size': 32, 'value': \
                                        f"{'??' if a[0] is None else f'{a[0]:02X}'}"+\
                                        f"{'??' if a[1] is None else f'{a[1]:02X}'}"+\
                                        f"{'??' if a[2] is None else f'{a[2]:02X}'}"+\
                                        f"{'??' if a[3] is None else f'{a[3]:02X}'}"})

        self.window['_LOC_VARS_'].update(values=[f"{v['addr']:04X} {v['name']} {v['value']}" for v in local_vars])
    