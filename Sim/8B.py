from PIL import Image, ImageTk
import PySimpleGUI as sg
import sys
import getopt
import rpyc
import warnings
import yaml

from PC import PC
from II import II
from MAR import MAR
from REG import REG
from RAM_STACK import STACK
from MEMS import MEMS


file_name = 'bin/3_test_add.bin' # default file
exit_on_halt = False
sim = True
GUI = True

# process flags

options = "f:" # TODO: no abviated options.
options_long = ['file =', 'exit-on-halt', 'no-gui', 'no-sim']

try:
    # grab flags
    args, vals = getopt.getopt(sys.argv[1:], options, options_long)
    for arg_, val_ in args:
        arg_ = arg_.strip()

        if arg_ in ("--file"):
            file_name = val_
        elif arg_ in ("--exit-on-halt"):
            exit_on_halt = True
        elif arg_ in ("--no-gui"):
            GUI = False
            exit_on_halt = True
        elif arg_ in ("--no-sim"):
            sim = False

except getopt.error as err:
    # output error, and return with an error code
    print (str(err))

if sim:
    try:
        conn = rpyc.connect('localhost', 18812, config={"allow_all_attrs": True})
    except:
        conn = None
        warnings.warn("Warning. Sim not connected!")
else:
    conn = None

print('running ${}'.format(file_name))

pc = PC()
mar = MAR()
ii = II()
mems = MEMS(sim=conn)
A = REG(8)
B = REG(8)
X = REG(8)
Y = REG(8)
HL = REG(16)
J = REG(16)
K = REG(16)
D = REG(16)
stack = STACK(mems.sram)

clk_counter = 0

update_rate = 1

IMG_HEI = 80
IMG_WID = 101
        
addr = 0
data = 0
UCC = 0

flags = {
    'ZF' : 0,
    'CF' : 0,
    'NF' : 0
}

ctrl = {
    # outs
    'PO' : 0, # Program counter out
    'AO' : 0, # A out
    'BO' : 0, # B out
    'MO' : 0, # Memory out
    'NO' : 0, # Stack pointer out
    'SO' : 0, # Stack out
    'HO' : 0, # HL register out
    'JO' : 0, # J Scratch register out
    'KO' : 0, # K Scratch register out
    'DO' : 0, # D Scratch register out
    'HT' : 0, # Halt
    # ins
    'PI' : 0, # Program counter in
    'II' : 0, # Instruction register in
    'XI' : 0, # Alu X Register in
    'YI' : 0, # Alu X Register in
    'AI' : 0, # A in
    'BI' : 0, # Bi in
    'HI' : 0, # HL register in
    'MA' : 0, # MAR in
    'MI' : 0, # Memory in
    'NI' : 0, # Stack Pointer in
    'SI' : 0, # Stack in
    'JI' : 0, # J Scratch register in
    'KI' : 0, # K Scratch register in
    'DI' : 0, # D Scratch register in
    # alu
    'ADD' : 0, # Add
    'SUB' : 0, # Subtract
    'AND' : 0, # Logical AND
    'OR'  : 0, # Logical OR
    'XOR' : 0, # Logical XOR
    'SHL' : 0, # Logical Shift Left
    'SHR' : 0, # Logical Shift Right
    'ONES': 0, # Ouputs 0xFF
    'INCR': 0, # Increment
    #misc
    'CE' : 0, # Program counter increment
    'FI' : 0, # CPU Flag refresh
    'MC' : 0, # MAR increment
    'IS' : 0, # increment stack pointer
    'DS' : 0, # decremetn stack pointer
    'LM' : 0, # bus byte indictor
    'RU' : 0  # reset ucode counter
}

breakpt = 0

layout_regs = [
    [sg.T('Regs')],
    [sg.T('PC  '), sg.T('0x0000', size=(6,1), justification='left', text_color='black', background_color='white', key='_PC_')],
    [sg.T('MAR '), sg.T('0x0000', size=(6,1), justification='left', text_color='black', background_color='white', key='_MAR_')],
    [sg.T('INST'), sg.T('0x00', size=(6,1), justification='left', text_color='black', background_color='white', key='_INST_')],
    [sg.T('UCC '), sg.T('0x0', size=(6,1), justification='left', text_color='black', background_color='white', key='_UCC_')],
    [sg.T('A   '), sg.T('0x00', size=(6,1), justification='left', text_color='black', background_color='white', key='_A_')],
    [sg.T('B   '), sg.T('0x00', size=(6,1), justification='left', text_color='black', background_color='white', key='_B_')],
    [sg.T('HL  '), sg.T('0x0000', size=(6,1), justification='left', text_color='black', background_color='white', key='_HL_')],
    [sg.T('X   '), sg.T('0x00', size=(6,1), justification='left', text_color='black', background_color='white', key='_X_')],
    [sg.T('Y   '), sg.T('0x00', size=(6,1), justification='left', text_color='black', background_color='white', key='_Y_')],
    [sg.T('J   '), sg.T('0x0000', size=(6,1), justification='left', text_color='black', background_color='white', key='_J_')],
    [sg.T('K   '), sg.T('0x0000', size=(6,1), justification='left', text_color='black', background_color='white', key='_K_')],
    [sg.T('D   '), sg.T('0x0000', size=(6,1), justification='left', text_color='black', background_color='white', key='_D_')],
    [sg.T('DATA'), sg.T('0x00', size=(6,1), justification='left', text_color='black', background_color='white', key='_DATA_')],
    [sg.T('ADDR'), sg.T('0x0000', size=(6,1), justification='left', text_color='black', background_color='white', key='_ADDR_')],
    [sg.T('STPR'), sg.T('', size=(6,1), justification='left', text_color='black', background_color='white', key='_STPR_')]
]

layout_flags = [
    [sg.T('Flags')],
    [sg.T('ZF  '), sg.T('\u2B24', size=(2,1), justification='left', text_color='gray', key='_ZF_')],
    [sg.T('CF  '), sg.T('\u2B24', size=(2,1), justification='left', text_color='gray', key='_CF_')],
    [sg.T('NF  '), sg.T('\u2B24', size=(2,1), justification='left', text_color='gray', key='_NF_')],
    [],
    [sg.Button('STEP')],
    [sg.T('CNT '), sg.T('0x0000', size=(12,1), justification='left', text_color='black', background_color='white', key='_CNT_')],
    [sg.Image(key="-IMAGE-", size=(IMG_WID,IMG_HEI))],
    [sg.Image(key="-MAP-", size=(128,128))]
]

layout_ctrl = [
    [sg.T('Ctrl')]
]

for ctrl_ in ctrl.keys():
    layout_ctrl.append([sg.T('{:<5}'.format(ctrl_)), sg.T('\u2B24', size=(2,1), justification='left', text_color='gray', key='_{}_'.format(ctrl_))])


layout_mem = [
    [sg.T('SRAM')],
    [sg.T('', size=(128*3+16,128), font=('courier new',6), justification='left', text_color='black', background_color='white', key='_SRAM_')]
]

layout = [[
    sg.Column(layout_regs, vertical_alignment='t'),
    sg.Column(layout_ctrl, vertical_alignment='t'),
    sg.Column(layout_flags, vertical_alignment='t'),
    sg.Column(layout_mem, vertical_alignment='t')
]]

if GUI:
    window = sg.Window('8B', layout, font=('courier new',11))
else:
    window = None

INDC_COLOR = ['gray', 'green']

file = open(file_name, 'rb')
eepr = 0
while 1:
    byte = file.read(1)         
    if not byte:
        break
    #print(byte)
    mems.eeprom.value[eepr] = ord(byte) & 0xFF
    eepr+=1
 
file.close()

if GUI:
    event, values = window.Read(timeout=0)
else:
    event = None
    values = None

inst = []

with open('instruction_set.yaml', 'r') as stream:
    try:
        IS = yaml.safe_load(stream)
        inst = [IS['instructions']['default']['ucode']]*int(0x80)
        print('instructions:')
        for key, value in IS['instructions'].items():
            if key != 'default':
                inst[int(value['opcode'])] = value['ucode']

        while True:
            if GUI:
                if clk_counter % update_rate == 0 or ctrl['HT'] or breakpt:
                        event, values = window.Read(timeout=0)
            
                if breakpt:
                    event, values = window.Read()

            clk_counter += 1

            ## rising edge
            # outputs
            #if ctrl['PO']+ctrl['MO']+ctrl['AO']+(ctrl['Mn']>0)+ctrl['PP'] > 1:
            #    raise Exception("more than one bus output enabled")
            if ctrl['PO']:
                data = pc.get(ctrl['LM'])
            if ctrl['MO']:
                data = mems.get(addr)
            if ctrl['AO']:
                data = A.get()
            if ctrl['BO']:
                data = B.get()
            if ctrl['JO']:
                data = J.get(ctrl['LM'])
            if ctrl['KO']:
                data = K.get(ctrl['LM'])
            if ctrl['DO']:
                data = D.get(ctrl['LM'])
            if ctrl['SO']:
                data = stack.pop()
            if ctrl['ADD']:
                # Add
                data = (X.value+Y.value) & 0xFF
            elif ctrl['SUB']:
                # Subtract
                data = (X.value+~(Y.value)+1) & 0xFF
            elif ctrl['AND']:
                # And
                data = (X.value & Y.value) & 0xFF
            elif ctrl['OR']:
                # Or
                data = (X.value | Y.value) & 0xFF
            elif ctrl['XOR']:
                # Xor
                data = (X.value ^ Y.value) & 0xFF
            elif ctrl['SHL']:
                # Left Shift 1
                data = (X.value << 1) & 0xFF
            elif ctrl['SHR']:
                # Right Shift 1
                data = (X.value >> 1) & 0xFF

            # FLAGS
            if ctrl['FI']:
                flags['ZF'] = ( (data & 0xFF) == 0 )
                flags['NF'] = ( data & 0x80) > 0
                if ctrl['ADD']:
                    # Add
                    flags['CF'] = ( (X.value+Y.value) > 0xFF ) or ( (X.value+Y.value) < 0x00 )
                elif ctrl['SUB']:
                    # Subtract
                    flags['CF'] = ( (X.value+(~Y.value)+1) > 0xFF ) or ( (X.value+(~Y.value)+1) < 0x00 )
                elif ctrl['AND']:
                    flags['CF'] = 0
                elif ctrl['OR']:
                    flags['CF'] = 0
                elif ctrl['XOR']:
                    flags['CF'] = 0
                elif ctrl['SHL']:
                    # Left Shift 1
                    flags['CF'] = (X.value << 1) > 0xFF
                elif ctrl['SHR']:
                    # Right Shift 1
                    flags['CF'] = X.value & 0x01
                else:
                    raise Exception("should only update CF on ALU operation")
            
            # CLK
            if ctrl['HT']:
                if exit_on_halt:
                    break
                if GUI:
                    event, values = window.Read()
                breakpt = 1
            
            # PC
            if (ctrl['PO'] or ctrl['PI']) and ctrl['CE']:
                raise Exception("CE asserted during PC access")
            if ctrl['PI']:
                pc.set(ctrl['LM'], data)
            if ctrl['CE']:
                pc.inc()

            
            # MAR
            if ctrl['MA'] and ctrl['MC']:
                raise Exception("CE asserted during PC access")
            if ctrl['MA']:
                mar.set(ctrl['LM'], data)
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
                A.set(data)
            # B REG
            if ctrl['BI']:
                B.set(data)
            # X ALU REG
            if ctrl['XI']:
                X.set(data)
            # Y ALU REG
            if ctrl['YI']:
                Y.set(data)
            # J REG
            if ctrl['JI']:
                J.set(data,ctrl['LM'])
            # K REG
            if ctrl['KI']:
                K.set(data,ctrl['LM'])
            # D REG
            if ctrl['DI']:
                D.set(data,ctrl['LM'])

            # STACK
            if ctrl['SI']:
                stack.push(data)
            if ctrl['IS']:
                stack.inc()
            if ctrl['DS']:  
                stack.dec()

            # U CODE
            UCC = (UCC + 1) & 0xF
            if ctrl['RU']:
                UCC = 0
            



            ## falling edge
            # handle ucode
            ctrl = dict.fromkeys(ctrl, 0)
            if UCC < len(inst[ii.value]):
                for u in inst[ii.value][UCC]:
                    ctrl[u] = 1
                if ii.value == int(IS['instructions']['assert_a']['opcode']): # specical test instuction
                    if UCC == 4:
                        if mems.get(addr) == A.value:
                            print('pass, a = 0x{:02X}'.format(A.value))
                        else:
                            raise Exception("test case failed, a = 0x{:02X}, expected 0x{:02X}\nPC=0x{:04X}".format(A.value, mems.get(addr), pc.value))
                if ii.value == int(IS['instructions']['assert_b']['opcode']): # specical test instuction
                    if UCC == 4:
                        if mems.get(addr) == B.value:
                            print('pass, b = 0x{:02X}'.format(B.value))
                        else:
                            raise Exception("test case failed, b = 0x{:02X}, expected 0x{:02X}\nPC=0x{:04X}".format(B.value, mems.get(addr), pc.value))
                elif ii.value == int(IS['instructions']['assert_zf']['opcode']): # specical test instuction
                    if UCC == 4:
                        if mems.get(addr) == flags['ZF']:
                            print('pass, ZF = {}'.format(flags['ZF']))
                        else:
                            raise Exception("test case failed, ZF = {}, expected {}\nPC=0x{:04X}".format(flags['ZF'], mems.get(addr), pc.value))

                        

                        

                # if ii.value == inst['TTC']: # specical test instuction
                #     if UCC == 3:
                #         ctrl['MC'] = 1
                #         ctrl['CE'] = 1
                #     elif UCC == 4:
                #         if mems.get(addr) == flags['CF']:
                #             print('pass, CF = {}'.format(flags['CF']))
                #         else:
                #             raise Exception("test case failed, CF = {}, expected {}\nPC=0x{:04X}".format(flags['CF'], mems.get(addr), pc.value))
                #         ctrl['RU'] = 1
                # if ii.value == inst['TTN']: # specical test instuction
                #     if UCC == 3:
                #         ctrl['MC'] = 1
                #         ctrl['CE'] = 1
                #     elif UCC == 4:
                #         if mems.get(addr) == flags['NF']:
                #             print('pass, NF = {}'.format(flags['NF']))
                #         else:
                #             raise Exception("test case failed, NF = {}, expected {}\nPC=0x{:04X}".format(flags['NF'], mems.get(addr), pc.get()))
                #         ctrl['RU'] = 1

                        
            if GUI and (event is None or event == 'Exit'):
                break

            
            
            if GUI and (clk_counter % update_rate == 0 or ctrl['HT'] or breakpt):
                window['_PC_'].Update('0x{:04X}'.format(pc.value))
                window['_MAR_'].Update('0x{:04X}'.format(mar.value))
                window['_INST_'].Update('0x{:02X}'.format(ii.value))
                window['_UCC_'].Update('0x{:01X}'.format(UCC))
                window['_A_'].Update('0x{:02X}'.format(A.value))
                window['_B_'].Update('0x{:02X}'.format(B.value))
                window['_HL_'].Update('0x{:02X}'.format(HL.value))
                window['_X_'].Update('0x{:02X}'.format(X.value))
                window['_Y_'].Update('0x{:02X}'.format(Y.value))
                window['_J_'].Update('0x{:02X}'.format(J.value))
                window['_K_'].Update('0x{:02X}'.format(K.value))
                window['_D_'].Update('0x{:02X}'.format(D.value))
                window['_DATA_'].Update('0x{:02X}'.format(data))
                window['_ADDR_'].Update('0x{:04X}'.format(addr))

                window['_ZF_'].Update(text_color=INDC_COLOR[flags['ZF']])
                window['_CF_'].Update(text_color=INDC_COLOR[flags['CF']])
                window['_NF_'].Update(text_color=INDC_COLOR[flags['NF']])


                for ctrl_ in ctrl.keys():
                    window['_{}_'.format(ctrl_)].Update(text_color=INDC_COLOR[ctrl[ctrl_]>0])

                window['_STPR_'].Update('0x{:01X}'.format(stack.pointer))
                
                window['_CNT_'].Update('{:,}'.format(clk_counter))
                
                sram_values = ''
                for n in range(2**14):
                    if mems.sram.value[n] is None:
                        sram_values += '--'
                    else:
                        sram_values += '{:02X}'.format(mems.sram.value[n])
                    if (n+1)%8 == 0:
                        sram_values += '  '
                    else:
                        sram_values += ' '
                        
                window['_SRAM_'].Update(sram_values)


                img = Image.new('L', [IMG_WID,IMG_HEI], 255)
                pixels = img.load()
                
                for row in range(IMG_HEI):
                    for col in range(IMG_WID):
                        dr_addr = int(row/8)+col*10
                        v = 100
                        if mems.dpram.value[dr_addr] is not None:
                            v = ((mems.dpram.value[dr_addr] >> (row%8)) & 0x01) * 255
                        pixels[col,row] = v
                window["-IMAGE-"].update(data=ImageTk.PhotoImage(image=img))


                
                mp = Image.new('L', [128,128], 255)
                mp_pixels = mp.load()
                
                for row in range(128):
                    for col in range(128):
                        dr_addr = int(col/4)+row*int(128/4)
                        v = 100
                        if mems.sram.value[(dr_addr+0xA000)&(mems.sram.size-1)] is not None:
                            v = ((mems.sram.value[(dr_addr+0xA000)&(mems.sram.size-1)] >> (6-((col%4)*2)) ) & 0b11) * 85
                            #print(row,col,dr_addr,(col%4)*2,v)
                        mp_pixels[col,row] = v
                window["-MAP-"].update(data=ImageTk.PhotoImage(image=mp))
                        


        print("max stack usage {} bytes".format(stack.max_used))
        print("clk cylces {}".format(clk_counter))


        if GUI:
            window.close()

    except yaml.YAMLError as exc:
        print(exc)