from enum import Enum
import FreeSimpleGUI as sg





class SD_VERSION(Enum):
    SD_NONE = None # no disk present
    SD_V1 = 1
    SD_V2 = 2

class SD_STATE(Enum):
    UNDEF = 0
    IDLE = 1
    ACMD = 2
    BUSY_INIT = 3
    BUSY_READ = 4

class SD_CMD(Enum):
    CMD0 = 0
    CMD8 = 8
    CMD17 = 17
    CMD55 = 55
    CMD58 = 58
    ACMD41 = 41

class SDCARD:

    def __init__(self,size=2**24,sd_vers=SD_VERSION.SD_NONE.value):
        self.size = size
        self.value = [0x00]*(self.size)
        
        self.ctrl_cs = 0 # chip select
        self.ctrl_cd = 0 # card detect
        self.ctrl_busy = 0 # busy

        self.busy_timer = 0

        self.output_buf = 0xFF
        self.input_buf = 0xFF

        # sd simulation
        self.card_internal_input_buffer = []
        self.card_internal_output_buffer = []
        self.state = SD_STATE.UNDEF
        self.sd_cmd_history = []
        self.max_cmd_history = 256
        self.block_addr = 0x0
        self.set_version(sd_vers)


    def set_version(self, sd_vers):
        self.sd_vers = sd_vers
        if self.sd_vers == SD_VERSION.SD_NONE.value:
            self.ctrl_cd = 0
        elif self.sd_vers == SD_VERSION.SD_V1.value:
            self.ctrl_cd = 1
            self.supported_cmds = [ SD_CMD.CMD0, SD_CMD.CMD17, SD_CMD.CMD55, SD_CMD.CMD58, SD_CMD.ACMD41 ]
        elif self.sd_vers == SD_VERSION.SD_V2.value:
            self.ctrl_cd = 1
            self.supported_cmds = [ SD_CMD.CMD0, SD_CMD.CMD8, SD_CMD.CMD17, SD_CMD.CMD55, SD_CMD.CMD58, SD_CMD.ACMD41  ]
        else:
            raise Exception(f"sd card version {self.sd_vers} not supported")
               
    def get(self,addr):
        if (addr&0x03) == 0x00:
            return self.input_buf
            return  input_val
        elif (addr&0x03) == 0x01:
            return (self.ctrl_cd<<2)|(self.ctrl_busy<<1)|self.ctrl_cs
        else:
            raise Exception(f"SDCARD byte {addr} not valid")

    def set(self, addr, V):
        if (addr&0x03) == 0x00:
            self.output_buf = (V&0xFF)
            # simulate the internals of the sdcard
            # write byte to sd card if cs is asserted
            if self.ctrl_cs:
                self.card_internal_input_buffer.append(self.output_buf)
                if len(self.card_internal_output_buffer):
                    self.input_buf = self.card_internal_output_buffer.pop(0)
                else:
                    self.input_buf = 0xFF
        elif (addr&0x03) == 0x01:
            self.ctrl_cs = (V&0x01)
        else:
            raise Exception(f"SDCARD byte {addr} not valid")



    def sim(self):
        # simulate the internals of the sdcard
        if self.ctrl_cs and self.ctrl_cd:
            if len(self.card_internal_input_buffer) >= 6:
                if self.card_internal_input_buffer[0] & 0x40: # if tranmission bit is set
                    match self.card_internal_input_buffer[0]&(~0x40):
                        case SD_CMD.CMD0.value if SD_CMD.CMD0 in self.supported_cmds:
                            self.busy_timer = 0
                            self.state = SD_STATE.IDLE
                            r1 = 0x01
                            self.sd_cmd_history.append(f"CMD0   {' '.join([f'{x:02X}' for x in self.card_internal_input_buffer[:6]])}   r1: {r1:02X}  state: {self.state.name}")
                            self.card_internal_input_buffer = self.card_internal_input_buffer[6:]
                            self.card_internal_output_buffer.append(r1)
                        case SD_CMD.CMD8.value if SD_CMD.CMD8 in self.supported_cmds:
                            self.busy_timer = 0
                            r7 = [0x01, 0x00, 0x00, 0x00, 0x00]
                            self.sd_cmd_history.append(f"CMD8   {' '.join([f'{x:02X}' for x in self.card_internal_input_buffer[:6]])}   r7: {' '.join([f'{x:02X}' for x in r7])} state: {self.state.name}")
                            self.card_internal_input_buffer = self.card_internal_input_buffer[6:]
                            self.card_internal_output_buffer = self.card_internal_output_buffer + r7
                        case SD_CMD.CMD17.value if SD_CMD.CMD17 in self.supported_cmds:
                            self.busy_timer = 0
                            self.state = SD_STATE.BUSY_READ
                            r1 = 0x01
                            self.block_addr =  (self.card_internal_input_buffer[1] << 24) | \
                                                (self.card_internal_input_buffer[2] << 16) | \
                                                 (self.card_internal_input_buffer[3] << 8) | \
                                                  (self.card_internal_input_buffer[4])
                            self.sd_cmd_history.append(f"CMD17  {' '.join([f'{x:02X}' for x in self.card_internal_input_buffer[:6]])}   r1: {r1:02X}  state: {self.state.name}")
                            self.card_internal_input_buffer = self.card_internal_input_buffer[6:]
                            self.card_internal_output_buffer.append(r1)
                        case SD_CMD.ACMD41.value if SD_CMD.ACMD41 in self.supported_cmds:
                            if self.state == SD_STATE.ACMD:
                                if self.busy_timer < 4:
                                    self.busy_timer += 1
                                    r1 = 0x01
                                    self.state = SD_STATE.BUSY_INIT
                                else:
                                    self.busy_timer = 0
                                    r1 = 0x00
                                    self.state = SD_STATE.IDLE
                            else:
                                r1 = 0x04
                            self.sd_cmd_history.append(f"ACMD41 {' '.join([f'{x:02X}' for x in self.card_internal_input_buffer[:6]])}   r1: {r1:02X}  state: {self.state.name}")
                            self.card_internal_input_buffer = self.card_internal_input_buffer[6:]
                            self.card_internal_output_buffer.append(r1)
                        case SD_CMD.CMD55.value if SD_CMD.CMD55 in self.supported_cmds:
                            self.state = SD_STATE.ACMD
                            r1 = 0x01
                            self.sd_cmd_history.append(f"CMD55  {' '.join([f'{x:02X}' for x in self.card_internal_input_buffer[:6]])}   r1: {r1:02X}  state: {self.state.name}")
                            self.card_internal_input_buffer = self.card_internal_input_buffer[6:]
                            self.card_internal_output_buffer.append(r1)
                        case SD_CMD.CMD58.value if SD_CMD.CMD58 in self.supported_cmds:
                            r3 = [0x01, 0x00, 0x04, 0x00, 0x00]
                            self.sd_cmd_history.append(f"CMD58  {' '.join([f'{x:02X}' for x in self.card_internal_input_buffer[:6]])}   r3: {' '.join([f'{x:02X}' for x in r3])} state: {self.state.name}")
                            self.card_internal_input_buffer = self.card_internal_input_buffer[6:]
                            self.card_internal_output_buffer = self.card_internal_output_buffer + r3
                        case _:
                            r1 = 0x04 # illegal command
                            self.sd_cmd_history.append(f"CMD{self.card_internal_input_buffer[0]&(~0x40):<3} {' '.join([f'{x:02X}' for x in self.card_internal_input_buffer[:6]])}   r1: {r1:02X}  state: {self.state.name}")
                            self.card_internal_input_buffer = self.card_internal_input_buffer[6:]
                            self.card_internal_output_buffer.append(r1)
            elif len(self.card_internal_input_buffer) >= 1:
                # discard leading 0xFFs
                if self.card_internal_input_buffer[0] == 0xFF:
                    if self.state in [SD_STATE.BUSY_INIT, SD_STATE.BUSY_READ]: self.busy_timer += 1
                    self.card_internal_input_buffer = self.card_internal_input_buffer[1:]

                    if self.state == SD_STATE.BUSY_READ:
                        if self.busy_timer > 5:
                            self.busy_timer = 0
                            self.state = SD_STATE.IDLE
                            self.card_internal_output_buffer.append(0xFE) # start token
                            self.card_internal_output_buffer = self.card_internal_output_buffer+ self.value[(self.block_addr<<9):(self.block_addr<<9)+512]
        else:
            # sd card i/o is cleared when CS is deaserted
            self.card_internal_input_buffer = []
            self.card_internal_output_buffer = []
        
        if len(self.sd_cmd_history) > self.max_cmd_history:
            self.sd_cmd_history.pop(0)
        


    def gui_get_layout(self):
        return   [[
            sg.Column([
                [
                    sg.T('CTRL    '),
                    sg.T(
                    text='',
                    size=(2,1),
                    justification='left',
                    text_color='black',
                    background_color='white',
                    key='_SDCARD_CTRL_'
                    )
                ],
                [
                    sg.T('OUT     '),
                    sg.T(
                    text='',
                    size=(2,1),
                    justification='left',
                    text_color='black',
                    background_color='white',
                    key='_SDCARD_OUT_'
                    )
                ],
                [
                    sg.T('IN      '),
                    sg.T(
                    text='',
                    size=(2,1),
                    justification='left',
                    text_color='black',
                    background_color='white',
                    key='_SDCARD_IN_'
                    )
                ],
                [
                    sg.T('BLKADDR '),
                    sg.T(
                    text='',
                    size=(8,1),
                    justification='left',
                    text_color='black',
                    background_color='white',
                    key='_SDCARD_BLK_ADDR_'
                    )
                ],
                [
                    sg.Multiline(
                        size=(14,50),
                        font=('courier new',8),
                        justification='left',
                        text_color='black',
                        background_color='white',
                        key='_SDCARD_IN_BUF_',
                        expand_y=True,
                        expand_x=True
                    ),
                    sg.Multiline(
                        size=(14,50),
                        font=('courier new',8),
                        justification='left',
                        text_color='black',
                        background_color='white',
                        key='_SDCARD_OUT_BUF_',
                        expand_y=True,
                        expand_x=True
                    ),
                    sg.Multiline(
                        size=(70,50),
                        font=('courier new',8),
                        justification='left',
                        text_color='black',
                        background_color='white',
                        key='_SDCARD_CMDS_',
                        expand_y=True,
                        expand_x=True
                    )
                ]
            ], vertical_alignment='t', expand_y=False, expand_x=False),
        ]]
    
    
    def gui_init(self, window):
        self.window = window

    
    def gui_update(self):
        self.window['_SDCARD_CTRL_'].update(f"{self.get(0x01):02X}")
        self.window['_SDCARD_OUT_'].update(f"{self.output_buf:02X}")
        self.window['_SDCARD_IN_'].update(f"{self.input_buf:02X}")
        self.window['_SDCARD_BLK_ADDR_'].update(f"{self.block_addr:08X}")
        self.window['_SDCARD_IN_BUF_'].update("\n".join([f"{n:02X}: {x:02X}" for n,x in enumerate(self.card_internal_input_buffer)]))
        self.window['_SDCARD_OUT_BUF_'].update("\n".join([f"{n:02X}: {x:02X}" for n,x in enumerate(self.card_internal_output_buffer)]))
        self.window['_SDCARD_CMDS_'].update("\n".join(self.sd_cmd_history))