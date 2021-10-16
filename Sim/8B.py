import PySimpleGUI as sg
import time

from PC import PC
from II import II
from MAR import MAR
from REG import REG

from EEPROM import EEPROM

pc = PC()
mar = MAR()
ii = II()
eeprom = EEPROM()
a = REG()
b = REG()

addr = 0
data = 0
UCC = 0

ctrl = {
    'Ln' : 0,
    'PO' : 0,
    'PI' : 0,
    'CE' : 0,
    'MA' : 0,
    'MC' : 0,
    'MI' : 0,
    'MO' : 0,
    'II' : 0,
    'AO' : 0,
    'AI' : 0,
    'BI' : 0,
    'HT' : 0,
    'Mn' : 0,
    'RU' : 0
}

inst = {
    'NOP' : 0x00,
    'HLT' : 0x01,
    'LAI' : 0x02,
    'LBI' : 0x03,
    'ADD' : 0x04
}


layout = [[sg.T('PC  '), sg.T('0x0000', size=(6,1), justification='left', text_color='black', background_color='white', key='_PC_')],
          [sg.T('MAR '), sg.T('0x0000', size=(6,1), justification='left', text_color='black', background_color='white', key='_MAR_')],
          [sg.T('II  '), sg.T('0x00', size=(6,1), justification='left', text_color='black', background_color='white', key='_II_')],
          [sg.T('UCC '), sg.T('0x0', size=(6,1), justification='left', text_color='black', background_color='white', key='_UCC_')],
          [sg.T('A   '), sg.T('0x00', size=(6,1), justification='left', text_color='black', background_color='white', key='_A_')],
          [sg.T('B   '), sg.T('0x00', size=(6,1), justification='left', text_color='black', background_color='white', key='_B_')],
          [sg.T('DATA'), sg.T('0x00', size=(6,1), justification='left', text_color='black', background_color='white', key='_DATA_')],
          [sg.T('ADDR'), sg.T('0x0000', size=(6,1), justification='left', text_color='black', background_color='white', key='_ADDR_')]]

window = sg.Window('8B', layout, font=('courier new',11))


program = [
    inst['LAI'], 0xAB,
    inst['LBI'], 0xCD,
    inst['ADD'],
    inst['HLT']]

for addr, byte in enumerate(program):
    eeprom.value[addr] = byte

    
while True:
    print("loop")
    event, values = window.Read(timeout=0)
    time.sleep(1)


    #time.sleep(5)
    ## rising edge
    # outputs
    if ctrl['PO']+ctrl['MO']+ctrl['AO']+(ctrl['Mn']>0) > 1:
        raise Exception("more than one bus output enabled")
    if ctrl['PO']:
        data = pc.get(ctrl['Ln'])
    if ctrl['MO']:
        data = eeprom.get(addr)
    if ctrl['AO']:
        data = a.get(addr)
    if ctrl['Mn'] == 0:
        #nop
        pass
    elif ctrl['Mn'] == 1:
        data = (a.value+b.value) & 0xFF
    
    # CLK
    if ctrl['HT']:
         event, values = window.Read()
    
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


    # INST
    if ctrl['II']:
        ii.set(data)

    # A REG
    if ctrl['AI']:
        a.set(data)
    # B REG
    if ctrl['BI']:
        b.set(data)
       



    ## falling edge
    if UCC == 0:
        # set MAR LSB
        ctrl = dict.fromkeys(ctrl, 0)
        ctrl['PO'] = 1
        ctrl['MA'] = 1
        ctrl['Ln'] = 0

    elif UCC == 1:
        # set MAR MSB
        ctrl = dict.fromkeys(ctrl, 0)
        ctrl['PO'] = 1
        ctrl['MA'] = 1
        ctrl['Ln'] = 1

    elif UCC == 2:
        ctrl = dict.fromkeys(ctrl, 0)
        ctrl['CE'] = 1
        ctrl['MO'] = 1
        ctrl['II'] = 1

    elif UCC == 3:
        ctrl = dict.fromkeys(ctrl, 0)
        if ii.value == inst['HLT']:
            ctrl['HT'] = 1
        elif ii.value == inst['LAI']:
            ctrl['CE'] = 1
            ctrl['MC'] = 1
        elif ii.value == inst['LBI']:
            ctrl['CE'] = 1
            ctrl['MC'] = 1
        elif ii.value == inst['ADD']:
            ctrl['Mn'] = 1
            ctrl['AI'] = 1
            ctrl['RU'] = 1
    
 
    elif UCC == 4:
        ctrl = dict.fromkeys(ctrl, 0)
        if ii.value == inst['LAI']:
            ctrl['AI'] = 1
            ctrl['MO'] = 1
            ctrl['RU'] = 1
        if ii.value == inst['LBI']:
            ctrl['BI'] = 1
            ctrl['MO'] = 1
            ctrl['RU'] = 1

    



    
    
    window['_PC_'].Update('0x{:04X}'.format(pc.value))
    window['_MAR_'].Update('0x{:04X}'.format(mar.value))
    window['_II_'].Update('0x{:02X}'.format(ii.value))
    window['_UCC_'].Update('0x{:01X}'.format(UCC))
    window['_A_'].Update('0x{:02X}'.format(a.value))
    window['_B_'].Update('0x{:02X}'.format(b.value))
    window['_DATA_'].Update('0x{:02X}'.format(data))
    window['_ADDR_'].Update('0x{:04X}'.format(addr))

    
    # U CODE
    UCC = (UCC + 1) & 0xF
    if ctrl['RU']:
        UCC = 0
    
    if event is None or event == 'Exit':
        break

window.close()
    


