import PySimpleGUI as sg
import time

from PC import PC
from II import II
from MAR import MAR
from REG import REG
from STACK import STACK
from MEMS import MEMS

pc = PC()
mar = MAR()
ii = II()
mems = MEMS()
a = REG()
b = REG()
stack = STACK(16)

clk_counter = 0

addr = 0
data = 0
UCC = 0

flags = {
    'ZF' : 0,
    'CF' : 0,
    'NF' : 0
}

breakpt = 0

ctrl = {
    'Ln' : 0, # bus byte indictor (2 bits)
    'PO' : 0, # Program counter out
    'PI' : 0, # Program counter in
    'CE' : 0, # Program counter increment
    'MA' : 0, # MAR in
    'MC' : 0, # MAR increment
    'MI' : 0, # Memory in
    'MO' : 0, # Memory out
    'II' : 0, # Instruciotn register in
    'AO' : 0, # A out
    'AI' : 0, # A in
    'BI' : 0, # Bi in
    'HT' : 0, # Halt
    'Mn' : 0, # ALU mode (4 bits)
    'PP' : 0, # Pop Stack
    'PH' : 0, # Push Stack
    'FI' : 0, # CPU Flag refresh
    'RU' : 0  # reset ucode counter
}

inst = {
    'NOP' : 0x00,
    'HLT' : 0x01,
    'LAI' : 0x02,
    'LBI' : 0x03,
    'ADD' : 0x04,
    'JMP' : 0x05,
    'SUB' : 0x06,
    'JMZ' : 0x07,
    'JNZ' : 0x08,
    'STA' : 0x09,
    'LBA' : 0x0A,
    'LDA' : 0x0B,
    'LDB' : 0x0C,
    'JMC' : 0x0D,
    'JNC' : 0x0E,
    'STI' : 0x0F,
    'CAL' : 0x10,
    'RET' : 0x11,
    'JMN' : 0x12,
    'RLC' : 0x13,
    'RRC' : 0x14,
    'PHA' : 0x15,
    'SSA' : 0x17,
    'LSA' : 0x18
}


layout_regs = [
    [sg.T('Regs')],
    [sg.T('PC  '), sg.T('0x0000', size=(6,1), justification='left', text_color='black', background_color='white', key='_PC_')],
    [sg.T('MAR '), sg.T('0x0000', size=(6,1), justification='left', text_color='black', background_color='white', key='_MAR_')],
    [sg.T('INST'), sg.T('0x00', size=(6,1), justification='left', text_color='black', background_color='white', key='_INST_')],
    [sg.T('UCC '), sg.T('0x0', size=(6,1), justification='left', text_color='black', background_color='white', key='_UCC_')],
    [sg.T('A   '), sg.T('0x00', size=(6,1), justification='left', text_color='black', background_color='white', key='_A_')],
    [sg.T('B   '), sg.T('0x00', size=(6,1), justification='left', text_color='black', background_color='white', key='_B_')],
    [sg.T('DATA'), sg.T('0x00', size=(6,1), justification='left', text_color='black', background_color='white', key='_DATA_')],
    [sg.T('ADDR'), sg.T('0x0000', size=(6,1), justification='left', text_color='black', background_color='white', key='_ADDR_')],
    [sg.T('STCK'), sg.T('', size=(6,stack.len), justification='left', text_color='black', background_color='white', key='_STCK_')],
    [sg.T('STPR'), sg.T('', size=(6,1), justification='left', text_color='black', background_color='white', key='_STPR_')]
]

layout_flags = [
    [sg.T('Flags')],
    [sg.T('ZF  '), sg.T('\u2B24', size=(2,1), justification='left', text_color='gray', key='_ZF_')],
    [sg.T('CF  '), sg.T('\u2B24', size=(2,1), justification='left', text_color='gray', key='_CF_')],
    [sg.T('NF  '), sg.T('\u2B24', size=(2,1), justification='left', text_color='gray', key='_NF_')],
    [],
    [sg.Button('STEP')],
    [sg.T('CNT '), sg.T('0x0000', size=(12,1), justification='left', text_color='black', background_color='white', key='_CNT_')]
]

layout_ctrl = [
    [sg.T('Ctrl')]
]

for ctrl_ in ctrl.keys():
    layout_ctrl.append([sg.T('{}  '.format(ctrl_)), sg.T('\u2B24', size=(2,1), justification='left', text_color='gray', key='_{}_'.format(ctrl_))])


layout_mem = [
    [sg.T('SRAM')],
    [sg.T('', size=(4*3,32), justification='left', text_color='black', background_color='white', key='_SRAM_')]
]

layout = [[
    sg.Column(layout_regs, vertical_alignment='t'),
    sg.Column(layout_ctrl, vertical_alignment='t'),
    sg.Column(layout_flags, vertical_alignment='t'),
    sg.Column(layout_mem, vertical_alignment='t')
]]

  
window = sg.Window('8B', layout, font=('courier new',11))

INDC_COLOR = ['gray', 'green']

# Fibonacci
##program = [
##    inst['STI'], 0x01, 0x80, 0x00,
##    inst['LAI'], 0x00,
##    inst['LDB'], 0x80, 0x00,
##    inst['STA'], 0xD0, 0x08,
##    inst['STA'], 0x80, 0x00,
##    inst['ADD'],
##    inst['LBA'],
##    inst['JNC'], 0x00, 0x06,
##    inst['HLT']
##]
##
##
##
##for addr, byte in enumerate(program):
##    mems.eeprom.value[addr] = byte

file = open('test.bin', 'rb')
eepr = 0
while 1:
    byte = file.read(1)         
    if not byte:
        break
    #print(byte)
    mems.eeprom.value[eepr] = ord(byte) & 0xFF
    eepr+=1
 
file.close()


event, values = window.Read(timeout=0)

update_rate = 1

while True:
    if clk_counter % update_rate == 0 or ctrl['HT'] or breakpt:
            event, values = window.Read(timeout=0)
    clk_counter += 1
    if breakpt:
         event, values = window.Read()
    #time.sleep(0.01)


    #time.sleep(5)
    ## rising edge
    # outputs
    if ctrl['PO']+ctrl['MO']+ctrl['AO']+(ctrl['Mn']>0)+ctrl['PP'] > 1:
        raise Exception("more than one bus output enabled")
    if ctrl['PO']:
        data = pc.get(ctrl['Ln'])
    if ctrl['MO']:
        data = mems.get(addr)
    if ctrl['AO']:
        data = a.get()
    if ctrl['PP']:
        data = stack.pop()
    if ctrl['Mn'] == 0:
        #nop
        pass
    elif ctrl['Mn'] == 1:
        # Add
        data = (a.value+b.value) & 0xFF
    elif ctrl['Mn'] == 2:
        # Subtract
        data = (a.value+~(b.value)+1) & 0xFF
    elif ctrl['Mn'] == 6:
        # Left Shift 1
        data = (a.value << 1) & 0xFF
    elif ctrl['Mn'] == 7:
        # Right Shift 1
        data = (a.value >> 1) & 0xFF
    
    # CLK
    if ctrl['HT']:
         event, values = window.Read()
         breakpt = 1
    
    # PC
    if (ctrl['PO'] or ctrl['PI']) and ctrl['CE']:
        raise Exception("CE asserted during PC access")
    if ctrl['PI']:
        pc.set(ctrl['Ln'], data)
    if ctrl['CE']:
        pc.inc()

    
    # MAR
    if ctrl['MA'] and ctrl['MC']:
        raise Exception("CE asserted during PC access")
    if ctrl['MA']:
        mar.set(ctrl['Ln'], data)
        addr = mar.value
    if ctrl['MC']:
        mar.inc()
        addr = mar.value

    # MEM   
    if ctrl['MI']:
        mems.set(addr, data)

    # INST
    if ctrl['II']:
        ii.set(data)

    # A REG
    if ctrl['AI']:
        a.set(data)
        
    # B REG
    if ctrl['BI']:
        b.set(data)

    # STACK
    if ctrl['PH']:
        stack.push(data)

    # FLAGS
    if ctrl['FI']:
        flags['ZF'] = ( (data & 0xFF) == 0 )
        flags['NF'] = ( data & 0x80) > 0
        if ctrl['Mn'] == 0:
            raise Exception("should only update CF on ALU operation")
        elif ctrl['Mn'] == 1:
            # Add
            flags['CF'] = (a.value+b.value) > 0xFF
        elif ctrl['Mn'] == 2:
            # Subtract
            flags['CF'] = (a.value+~(b.value)+1) > 0xFF
        elif ctrl['Mn'] == 6:
            # Left Shift 1
            data = (a.value << 1) > 0xFF
        elif ctrl['Mn'] == 7:
            # Right Shift 1
            data = a.value & 0x01

    # U CODE
    UCC = (UCC + 1) & 0xF
    if ctrl['RU']:
        UCC = 0
       



    ## falling edge
    
    if UCC == 0:
        # set MAR LSB
        ctrl = dict.fromkeys(ctrl, 0)
        ctrl['PO'] = 1
        ctrl['MA'] = 1
        ctrl['Ln'] = 1

    elif UCC == 1:
        # set MAR MSB
        ctrl = dict.fromkeys(ctrl, 0)
        ctrl['PO'] = 1
        ctrl['MA'] = 1
        ctrl['Ln'] = 0

    elif UCC == 2:
        ctrl = dict.fromkeys(ctrl, 0)
        ctrl['CE'] = 1
        ctrl['MO'] = 1
        ctrl['II'] = 1

    elif UCC >= 3:
        ctrl = dict.fromkeys(ctrl, 0)
        if ii.value == inst['HLT']:
            if UCC == 3:
                ctrl['HT'] = 1

        if ii.value == inst['LAI']:
            if UCC == 3:
                ctrl['CE'] = 1
                ctrl['MC'] = 1
            elif UCC == 4:
                ctrl['AI'] = 1
                ctrl['MO'] = 1
                ctrl['RU'] = 1

        elif ii.value == inst['LBI']:
            if UCC == 3:
                ctrl['CE'] = 1
                ctrl['MC'] = 1
            elif UCC == 4:
                ctrl['BI'] = 1
                ctrl['MO'] = 1
                ctrl['RU'] = 1

        elif ii.value == inst['ADD']:
            if UCC == 3:
                ctrl['Mn'] = 1
                ctrl['AI'] = 1
                ctrl['RU'] = 1
                ctrl['FI'] = 1
                
        elif ii.value == inst['SUB']:
            if UCC == 3:
                ctrl['Mn'] = 2
                ctrl['AI'] = 1
                ctrl['RU'] = 1
                ctrl['FI'] = 1
                
        elif ii.value == inst['RLC']:
            if UCC == 3:
                ctrl['Mn'] = 6
                ctrl['AI'] = 1
                ctrl['RU'] = 1
                ctrl['FI'] = 1
                
        elif ii.value == inst['RRC']:
            if UCC == 3:
                ctrl['Mn'] = 7
                ctrl['AI'] = 1
                ctrl['RU'] = 1
                ctrl['FI'] = 1
                
        elif ii.value == inst['JMP']:
            if UCC == 3:
                ctrl['MC'] = 1
            elif UCC == 4:
                ctrl['PI'] = 1
                ctrl['Ln'] = 1
                ctrl['MO'] = 1
            elif UCC == 5:
                ctrl['MC'] = 1
            elif UCC == 6:
                ctrl['PI'] = 1
                ctrl['Ln'] = 0
                ctrl['MO'] = 1
                ctrl['RU'] = 1      
                
        elif ii.value == inst['JMZ']:
            if UCC == 3:
                if flags['ZF']:
                    ctrl['MC'] = 1
                else:
                    ctrl['CE'] = 1
            elif UCC == 4:
                if flags['ZF']:
                    ctrl['PI'] = 1
                    ctrl['Ln'] = 1
                    ctrl['MO'] = 1
                else:
                    ctrl['CE'] = 1
                    ctrl['RU'] = 1
            elif UCC == 5:
                if flags['ZF']:
                    ctrl['MC'] = 1
                else:
                    pass
            elif UCC == 6:
                if flags['ZF']:
                    ctrl['PI'] = 1
                    ctrl['Ln'] = 0
                    ctrl['MO'] = 1
                    ctrl['RU'] = 1
                else:
                    pass

                         
        elif ii.value == inst['JMN']:
            if UCC == 3:
                if flags['NF']:
                    ctrl['MC'] = 1
                else:
                    ctrl['CE'] = 1
            elif UCC == 4:
                if flags['NF']:
                    ctrl['PI'] = 1
                    ctrl['Ln'] = 1
                    ctrl['MO'] = 1
                else:
                    ctrl['CE'] = 1
                    ctrl['RU'] = 1
            elif UCC == 5:
                if flags['NF']:
                    ctrl['MC'] = 1
                else:
                    pass
            elif UCC == 6:
                if flags['NF']:
                    ctrl['PI'] = 1
                    ctrl['Ln'] = 0
                    ctrl['MO'] = 1
                    ctrl['RU'] = 1
                else:
                    pass

                
        elif ii.value == inst['JMC']:
            if UCC == 3:
                if flags['CF']:
                    ctrl['MC'] = 1
                else:
                    ctrl['CE'] = 1
            elif UCC == 4:
                if flags['CF']:
                    ctrl['PI'] = 1
                    ctrl['Ln'] = 1
                    ctrl['MO'] = 1
                else:
                    ctrl['CE'] = 1
                    ctrl['RU'] = 1
            elif UCC == 5:
                if flags['CF']:
                    ctrl['MC'] = 1
                else:
                    pass
            elif UCC == 6:
                if flags['CF']:
                    ctrl['PI'] = 1
                    ctrl['Ln'] = 0
                    ctrl['MO'] = 1
                    ctrl['RU'] = 1
                else:
                    pass
                
        elif ii.value == inst['JNZ']:
            if UCC == 3:
                if flags['ZF']:
                    ctrl['CE'] = 1
                else:
                    ctrl['MC'] = 1
            elif UCC == 4:
                if flags['ZF']:
                    ctrl['CE'] = 1
                    ctrl['RU'] = 1
                else:
                    ctrl['PI'] = 1
                    ctrl['Ln'] = 1
                    ctrl['MO'] = 1
            elif UCC == 5:
                if flags['ZF']:
                    pass
                else:
                    ctrl['MC'] = 1
            elif UCC == 6:
                if flags['ZF']:
                    pass
                else:
                    ctrl['PI'] = 1
                    ctrl['Ln'] = 0
                    ctrl['MO'] = 1
                    ctrl['RU'] = 1
                      
        elif ii.value == inst['JNC']:
            if UCC == 3:
                if flags['CF']:
                    ctrl['CE'] = 1
                else:
                    ctrl['MC'] = 1
            elif UCC == 4:
                if flags['CF']:
                    ctrl['CE'] = 1
                    ctrl['RU'] = 1
                else:
                    ctrl['PI'] = 1
                    ctrl['Ln'] = 1
                    ctrl['MO'] = 1
            elif UCC == 5:
                if flags['CF']:
                    pass
                else:
                    ctrl['MC'] = 1
            elif UCC == 6:
                if flags['CF']:
                    pass
                else:
                    ctrl['PI'] = 1
                    ctrl['Ln'] = 0
                    ctrl['MO'] = 1
                    ctrl['RU'] = 1

        elif ii.value == inst['STA']:
            if UCC == 3:
                ctrl['MC'] = 1
                ctrl['CE'] = 1
            elif UCC == 4:
                ctrl['MO'] = 1
                ctrl['PH'] = 1
            elif UCC == 5:
                ctrl['MC'] = 1
                ctrl['CE'] = 1
            elif UCC == 6:
                ctrl['MO'] = 1
                ctrl['PH'] = 1
            elif UCC == 7:
                ctrl['PP'] = 1
                ctrl['MA'] = 1
                ctrl['Ln'] = 0
            elif UCC == 8:
                ctrl['PP'] = 1
                ctrl['MA'] = 1
                ctrl['Ln'] = 1
            elif UCC == 9:
                ctrl['AO'] = 1
                ctrl['MI'] = 1
                ctrl['RU'] = 1

        elif ii.value == inst['LBA']:
            if UCC == 3:
                ctrl['BI'] = 1
                ctrl['AO'] = 1
                ctrl['RU'] = 1


        elif ii.value == inst['LDA']:
            if UCC == 3:
                ctrl['MC'] = 1
                ctrl['CE'] = 1
            elif UCC == 4:
                ctrl['MO'] = 1
                ctrl['PH'] = 1
            elif UCC == 5:
                ctrl['MC'] = 1
                ctrl['CE'] = 1
            elif UCC == 6:
                ctrl['MO'] = 1
                ctrl['PH'] = 1
            elif UCC == 7:
                ctrl['PP'] = 1
                ctrl['MA'] = 1
                ctrl['Ln'] = 0
            elif UCC == 8:
                ctrl['PP'] = 1
                ctrl['MA'] = 1
                ctrl['Ln'] = 1
            elif UCC == 9:
                ctrl['AI'] = 1
                ctrl['MO'] = 1
                ctrl['RU'] = 1


        elif ii.value == inst['LDB']:
            if UCC == 3:
                ctrl['MC'] = 1
                ctrl['CE'] = 1
            elif UCC == 4:
                ctrl['MO'] = 1
                ctrl['PH'] = 1
            elif UCC == 5:
                ctrl['MC'] = 1
                ctrl['CE'] = 1
            elif UCC == 6:
                ctrl['MO'] = 1
                ctrl['PH'] = 1
            elif UCC == 7:
                ctrl['PP'] = 1
                ctrl['MA'] = 1
                ctrl['Ln'] = 0
            elif UCC == 8:
                ctrl['PP'] = 1
                ctrl['MA'] = 1
                ctrl['Ln'] = 1
            elif UCC == 9:
                ctrl['BI'] = 1
                ctrl['MO'] = 1
                ctrl['RU'] = 1



        elif ii.value == inst['STI']:
            if UCC == 3:
                ctrl['MC'] = 1
                ctrl['CE'] = 1
            elif UCC == 4:
                ctrl['MO'] = 1
                ctrl['PH'] = 1
            elif UCC == 5:
                ctrl['MC'] = 1
                ctrl['CE'] = 1
            elif UCC == 6:
                ctrl['MO'] = 1
                ctrl['PH'] = 1
            elif UCC == 7:
                ctrl['MC'] = 1
                ctrl['CE'] = 1
            elif UCC == 8:
                ctrl['MO'] = 1
                ctrl['PH'] = 1
            elif UCC == 9:
                ctrl['PP'] = 1
                ctrl['MA'] = 1
                ctrl['Ln'] = 0
            elif UCC == 10:
                ctrl['PP'] = 1
                ctrl['MA'] = 1
                ctrl['Ln'] = 1
            elif UCC == 11:
                ctrl['PP'] = 1
                ctrl['MI'] = 1
                ctrl['RU'] = 1


        elif ii.value == inst['CAL']:
            if UCC == 3:
                ctrl['CE'] = 1
            elif UCC == 4:
                ctrl['CE'] = 1
            elif UCC == 5:
                ctrl['PH'] = 1
                ctrl['PO'] = 1
                ctrl['Ln'] = 1
            elif UCC == 6:
                ctrl['PH'] = 1
                ctrl['PO'] = 1
                ctrl['Ln'] = 0
                ctrl['MC'] = 1
            elif UCC == 7:
                ctrl['PI'] = 1
                ctrl['MO'] = 1
                ctrl['Ln'] = 1
            elif UCC == 8:
                ctrl['MC'] = 1                
            elif UCC == 9:
                ctrl['PI'] = 1
                ctrl['MO'] = 1
                ctrl['Ln'] = 0
                ctrl['RU'] = 1
                


        elif ii.value == inst['RET']:
            if UCC == 3:
                ctrl['PP'] = 1
                ctrl['PI'] = 1
                ctrl['Ln'] = 0
            elif UCC == 4:
                ctrl['PP'] = 1
                ctrl['PI'] = 1
                ctrl['Ln'] = 1
                ctrl['RU'] = 1
                


        elif ii.value == inst['PHA']:
            if UCC == 3:
                ctrl['AO'] = 1
                ctrl['PH'] = 1
                ctrl['RU'] = 1

        elif ii.value == inst['SSA']:
            if UCC == 3:
                ctrl['PP'] = 1
                ctrl['MA'] = 1
                ctrl['Ln'] = 1
            elif UCC == 4:
                ctrl['PP'] = 1
                ctrl['MA'] = 1
                ctrl['Ln'] = 0
            elif UCC == 5:
                ctrl['MI'] = 1
                ctrl['AO'] = 1
                ctrl['RU'] = 1
                
        elif ii.value == inst['LSA']:
            if UCC == 3:
                ctrl['PP'] = 1
                ctrl['MA'] = 1
                ctrl['Ln'] = 1
            elif UCC == 4:
                ctrl['PP'] = 1
                ctrl['MA'] = 1
                ctrl['Ln'] = 0
            elif UCC == 5:
                ctrl['MO'] = 1
                ctrl['AI'] = 1
                ctrl['RU'] = 1
                
    if event is None or event == 'Exit':
        break

    
    
    if clk_counter % update_rate == 0 or ctrl['HT'] or breakpt:
        window['_PC_'].Update('0x{:04X}'.format(pc.value))
        window['_MAR_'].Update('0x{:04X}'.format(mar.value))
        window['_INST_'].Update('0x{:02X}'.format(ii.value))
        window['_UCC_'].Update('0x{:01X}'.format(UCC))
        window['_A_'].Update('0x{:02X}'.format(a.value))
        window['_B_'].Update('0x{:02X}'.format(b.value))
        window['_DATA_'].Update('0x{:02X}'.format(data))
        window['_ADDR_'].Update('0x{:04X}'.format(addr))

        window['_ZF_'].Update(text_color=INDC_COLOR[flags['ZF']])
        window['_CF_'].Update(text_color=INDC_COLOR[flags['CF']])
        window['_NF_'].Update(text_color=INDC_COLOR[flags['NF']])


        for ctrl_ in ctrl.keys():
            window['_{}_'.format(ctrl_)].Update(text_color=INDC_COLOR[ctrl[ctrl_]>0])

        stack_values = ''
        if stack.pointer>0:
            for n in range(stack.pointer)[::-1]:
                stack_values += '0x{:02X}\n'.format(stack.value[n])
        window['_STCK_'].Update(stack_values)
        window['_STPR_'].Update('0x{:01X}'.format(stack.pointer))
        
        window['_CNT_'].Update('{:,}'.format(clk_counter))
        
        sram_values = ''
        for n in range(128):
            sram_values += '{:02X} '.format(mems.sram.value[n])
        window['_SRAM_'].Update(sram_values)
        


window.close()
    


