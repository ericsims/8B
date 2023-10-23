
import sys
import getopt
import warnings
import rpyc
import json
import yaml
from PIL import Image, ImageTk
import PySimpleGUI as sg
from termcolor import colored

from PC import PC
from II import II
from MAR import MAR
from REG import REG
from RAM_STACK import STACK
from MEMS import MEMS

from parse_vars import *
from print_call_graph import *


# TODO: dead code analysis
# TODO: call graph to include call/ret/jumps. add subgraph for subroutines
# TODO: extended memory

def main():

  FILE_NAME = 'bin/01_test_a_reg.bin' # default file
  EXIT_ON_HALT = False
  SIM = True
  GUI = True

  # process flags

  OPTIONS = "f:" #TODO: no abbreviated options.
  OPTIONS_LONG = ['file =', 'exit-on-halt', 'no-gui', 'no-sim']

  try:
    # grab flags
    args, vals = getopt.getopt(sys.argv[1:], OPTIONS, OPTIONS_LONG)
    for arg_, val_ in args:
      arg_ = arg_.strip()

      if arg_ in ("--file"):
        FILE_NAME = val_
      elif arg_ in ("--exit-on-halt"):
        EXIT_ON_HALT = True
      elif arg_ in ("--no-gui"):
        GUI = False
        EXIT_ON_HALT = True
      elif arg_ in ("--no-sim"):
        SIM = False

  except getopt.error as err:
    # output error, and return with an error code
    print (str(err))

  if SIM:
    try:
      conn = rpyc.connect("localhost", 18812, config={'allow_all_attrs': True})
    except:
      conn = None
      warnings.warn("Warning. Sim not connected!")
  else:
    conn = None

  print(f"running ${FILE_NAME}")

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
  stack = STACK(mems)

  clk_counter = 0

  UPDATE_RATE = 10000

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
    'ONES': 0, # Outputs 0xFF
    'ZERO': 0, # Outputs 0x00
    'ONE' : 0, # Outputs 0x01
    #misc
    'CE' : 0, # Program counter increment
    'FI' : 0, # CPU Flag refresh
    'MC' : 0, # MAR increment
    'IS' : 0, # increment stack pointer
    'DS' : 0, # decrement stack pointer
    'LM' : 0, # bus byte indictor
    'RU' : 0  # reset ucode counter
  }

  breakpt = False
  finish_inst = False

  DEFAULT_REG_LAYOUT = {
    'size':(6,1),
    'justification':'left',
    'text_color':'black',
    'background_color':'white'
  }

  layout_regs = [
    [sg.T('Regs')],
    [sg.T('PC  '), sg.T('0x0000', **DEFAULT_REG_LAYOUT, key='_PC_')],
    [sg.T('MAR '), sg.T('0x0000', **DEFAULT_REG_LAYOUT, key='_MAR_')],
    [sg.T('INST'), sg.T('0x00  ', **DEFAULT_REG_LAYOUT, key='_INST_')],
    [sg.T('UCC '), sg.T('0x00  ', **DEFAULT_REG_LAYOUT, key='_UCC_')],
    [sg.T('A   '), sg.T('0x00  ', **DEFAULT_REG_LAYOUT, key='_A_')],
    [sg.T('B   '), sg.T('0x00  ', **DEFAULT_REG_LAYOUT, key='_B_')],
    [sg.T('HL  '), sg.T('0x0000', **DEFAULT_REG_LAYOUT, key='_HL_')],
    [sg.T('X   '), sg.T('0x00  ', **DEFAULT_REG_LAYOUT, key='_X_')],
    [sg.T('Y   '), sg.T('0x00  ', **DEFAULT_REG_LAYOUT, key='_Y_')],
    [sg.T('J   '), sg.T('0x0000', **DEFAULT_REG_LAYOUT, key='_J_')],
    [sg.T('K   '), sg.T('0x0000', **DEFAULT_REG_LAYOUT, key='_K_')],
    [sg.T('D   '), sg.T('0x0000', **DEFAULT_REG_LAYOUT, key='_D_')],
    [sg.T('DATA'), sg.T('0x00  ', **DEFAULT_REG_LAYOUT, key='_DATA_')],
    [sg.T('ADDR'), sg.T('0x0000', **DEFAULT_REG_LAYOUT, key='_ADDR_')],
    [sg.T('STPR'), sg.T('0x0000', **DEFAULT_REG_LAYOUT, key='_STPR_')],
  ]

  DEFAULT_INDICATOR_LAYOUT = {
    'text':'\u2B24',
    'size':(2,1),
    'justification':'left',
    'text_color':'gray',
  }

  layout_flags = [
    [sg.T('Flags')],
    [sg.T('ZF  '), sg.T(**DEFAULT_INDICATOR_LAYOUT, key='_ZF_')],
    [sg.T('CF  '), sg.T(**DEFAULT_INDICATOR_LAYOUT, key='_CF_')],
    [sg.T('NF  '), sg.T(**DEFAULT_INDICATOR_LAYOUT, key='_NF_')],
    [],
    [sg.Button('uSTEP'), sg.Button('STEP Inst.')],
    [sg.Button('Resume')],
    [sg.T('CLK  '), sg.T(
      text='',
      size=(12,1),
      justification='left',
      text_color='black',
      background_color='white',
      key='_CNT_'
    )],
    [sg.T('INST '), sg.T(
      text='inst??',
      size=(21,1),
      justification='left',
      text_color='black',
      background_color='white',
      font=('courier new',7),
      key='_INST_NAME_')
    ],
    [sg.Image(key="-IMAGE-", size=(IMG_WID,IMG_HEI))],
    [sg.Image(key="-MAP-", size=(128,128))],
    [sg.T('UART')],
    [
      sg.Multiline(
        size=(30,24),
        autoscroll=True,
        font=('courier new',7),
        justification='left',
        text_color='black',
        background_color='white',
        key='_UART_'
      )
    ]
  ]

  layout_ctrl = [
    [sg.T('Ctrl')]
  ]

  for ctrl_sig,val in ctrl.items():
    layout_ctrl.append([
      sg.T(text=f"{ctrl_sig:<5}"),
      sg.T(**DEFAULT_INDICATOR_LAYOUT, key=f'_{ctrl_sig}_')
    ])


  layout_sram = [[
    sg.T(
      text='',
      size=(128*3+16,128),
      font=('courier new',6),
      justification='left',
      text_color='black',
      background_color='white',
      key='_SRAM_'
    )
  ]]
  layout_stack = [[
    sg.Column([
      [
        sg.Multiline(
          size=(12,70),
          autoscroll=True,
          font=('courier new',8),
          justification='left',
          text_color='black',
          background_color='white',
          write_only = True,
          disabled = True,
          key='_STACK_'
        )
      ]
    ], vertical_alignment='t' ),
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
      ]
    ], vertical_alignment='t' )
  ]]
  layout_vars = [[
    sg.Multiline(
      size=(100,70),
      font=('courier new',8),
      justification='left',
      text_color='black',
      background_color='white',
      write_only = True,
      disabled = True,
      key='_VARS_'
    )
  ]]
  layout_ext_rom = [
    [
      sg.T('EXT ROM Addr Ptr   '),
      sg.T(
        text='',
        size=(6,1),
        justification='left',
        text_color='black',
        background_color='white',
        key='_EXT_ROM_ADDR_'
      )
    ],
    [
      sg.T('EXT ROM Current Val'),
      sg.T(
        text='',
        size=(4,1),
        justification='left',
        text_color='black',
        background_color='white',
        key='_EXT_ROM_VAL_'
      )
    ],
    [
      sg.T(
        text='',
        size=(32*3+10,65),
        font=('courier new',6),
        justification='left',
        text_color='black',
        background_color='white',
        key='_EXT_ROM_'
      )
    ]
  ]
  layout_time = [[
    sg.Multiline(
      size=(100,70),
      font=('courier new',8),
      justification='left',
      text_color='black',
      background_color='white',
      write_only = True,
      disabled = True,
      key='_TIME_ANALYSIS_'
    )
  ]]

  tabs_layout = [[
    sg.TabGroup([[
      sg.Tab('SRAM', layout_sram),
      sg.Tab('STACK', layout_stack),
      sg.Tab('VARS', layout_vars),
      sg.Tab('EXT_ROM', layout_ext_rom),
      sg.Tab('TIME', layout_time),
      ]])
    ]]

  layout = [[
    sg.Column(layout_regs,  vertical_alignment='t'),
    sg.Column(layout_ctrl,  vertical_alignment='t'),
    sg.Column(layout_flags, vertical_alignment='t'),
    sg.Column(tabs_layout,  vertical_alignment='t')
  ]]

  if GUI:
    window = sg.Window('8B', layout, font=('courier new',11))
  else:
    window = None

  def update_uart(char):
    if GUI:
      window['_UART_'].update(char, append=True)
    else:
      pass
  mems.uart.callback = update_uart

  INDC_COLOR = ['gray', 'green']

  eeprom_usage = 0

  file = open(FILE_NAME, 'rb')
  eep_ptr = 0
  while 1:
    byte = file.read(1)
    if not byte:
      break
    mems.eeprom.value[eep_ptr] = ord(byte) & 0xFF
    eeprom_usage += 1
    # TODO: load real ext_rom bin
    mems.ext_eeprom.value[eep_ptr] = ord(byte) & 0xFF
    eep_ptr+=1

  file.close()

  vars, symbols, code = parse_vars(FILE_NAME)
  max_var_width = max([len(list(var.keys())[0]) for var in vars])

  if GUI:
    event, values = window.Read(timeout=0)
  else:
    event = None
    values = None

  inst = []
  inst_names = {}
  inst_stats = {}
  call_graph = [0x0000]
  previous_pc = 0x0000

  with open('instruction_set.yaml', 'r') as stream:
    try:
      IS = yaml.safe_load(stream)
      inst = [IS['instructions']['default']['ucode']]*int(0x80)
      for key, value in IS['instructions'].items():
        if key != 'default':
          inst[int(value['opcode'])] = value['ucode']
          inst_names[int(value['opcode'])] = key
          inst_stats[key] = {
            'calls': 0,
          }

      while True:
        if GUI:
          if clk_counter % UPDATE_RATE == 0 or ctrl['HT'] or breakpt:
            event, values = window.Read(timeout=0)

          if breakpt and not finish_inst:
            event, values = window.Read()
            if event == "STEP Inst.":
              finish_inst = True
            if event == "Resume":
              finish_inst = False
              breakpt = False
            if event == "uSTEP":
              pass
              

        clk_counter += 1

        ## rising edge
        # outputs
        #if ctrl['PO']+ctrl['MO']+ctrl['AO']+(ctrl['Mn']>0)+ctrl['PP'] > 1:
        #  raise Exception("more than one bus output enabled")
        if ctrl['PO']:
          data = pc.get(ctrl['LM'])
        elif ctrl['MO']:
          data = mems.get(addr)
          # store dead code info
          list_addrs = [c['addr'] for c in code]
          indices = [i for i, x in enumerate(list_addrs) if x == addr]
          for i in indices:
            if ctrl['II']: code[i]['execs'] += 1
            code[i]['dead'] = False
        elif ctrl['NO']:
          data = stack.get(ctrl['LM'])
        elif ctrl['AO']:
          data = A.get()
        elif ctrl['BO']:
          data = B.get()
        elif ctrl['HO']:
          data = HL.get(ctrl['LM'])
        elif ctrl['JO']:
          data = J.get(ctrl['LM'])
        elif ctrl['KO']:
          data = K.get(ctrl['LM'])
        elif ctrl['DO']:
          data = D.get(ctrl['LM'])
        elif ctrl['SO']:
          data = stack.pop()
        elif ctrl['ADD']:
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
        elif ctrl['ZERO']:
          data = 0x00
        elif ctrl['ONES']:
          data = 0xFF
        elif ctrl['ONE']:
          data = 0x01

        # FLAGS
        if ctrl['FI']:
          flags['ZF'] = ( (data & 0xFF) == 0 )
          flags['NF'] = ( data & 0x80) > 0
          if ctrl['ADD']:
            # Add
            flags['CF'] = ((X.value+Y.value) > 0xFF) or ((X.value+Y.value) < 0x00)
          elif ctrl['SUB']:
            # Subtract
            flags['CF'] = ((X.value+~(Y.value)+1) > 0xFF) or ((X.value+~(Y.value)+1) < 0x00)
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
          if EXIT_ON_HALT:
            break
          #if GUI:
          #  event, values = window.Read()
          breakpt = True

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
          inst_stats[inst_names[ii.value]]['calls'] += 1
          # print(pc.value)

        # A REG
        if ctrl['AI']:
          A.set(data)
        # B REG
        if ctrl['BI']:
          B.set(data)
        # HL REG
        if ctrl['HI']:
          HL.set(data,ctrl['LM'])
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
        elif ctrl['IS']:
          stack.inc()
        elif ctrl['DS']:
          stack.dec()
        elif ctrl['NI']:
          stack.set(data,ctrl['LM'])

        # check if this is a jmp/call/ret instruction
        if ctrl['PI'] and ctrl['RU']:
          # if call_graph[-1] != previous_pc:
          #   call_graph.append(previous_pc)
          # TODO: not really sure what i want my call graphs to look like in this mess
          if ii.value == 0x73: # call
            pass
          elif ii.value == 0x74: # return
            pass
          else: # some kind of jump
            pass
          call_graph.append(pc.value)

        # U CODE
        UCC = (UCC + 1) & 0x1F
        if ctrl['RU']:
          UCC = 0
        
        if UCC == 0:
          previous_pc = pc.value


        ## falling edge
        # handle ucode
        ctrl = dict.fromkeys(ctrl, 0)
        if isinstance(inst[ii.value], dict):
          # branch/conditional instruction
          condition = True
          for c in inst[ii.value]['conditions']:
            if not flags[c]:
              condition = False
          if UCC < len(inst[ii.value][condition]):
            for u in inst[ii.value][condition][UCC]:
              ctrl[u] = 1

        # normal sequential instruction
        elif  UCC < len(inst[ii.value]):
          for u in inst[ii.value][UCC]:
            ctrl[u] = 1

          # handle the assert instructions. Only do anything on the last cycle
          if ctrl['RU']:
            if ii.value == int(IS['instructions']['assert_a']['opcode']):
              if mems.get(addr) == A.value:
                print(f"pass, a = 0x{A.value:02X}")
              else:
                raise Exception(f"test case failed, a = 0x{A.value:02X}, expected 0x{mems.get(addr):02X}\nPC=0x{pc.value:04X}")
            elif ii.value == int(IS['instructions']['assert_b']['opcode']):
              if mems.get(addr) == B.value:
                print(f"pass, b = 0x{B.value:02X}")
              else:
                raise Exception(f"test case failed, b = 0x{B.value:02X}, expected 0x{mems.get(addr):02X}\nPC=0x{pc.value:04X}")
            elif ii.value == int(IS['instructions']['assert_hl']['opcode']):
              if (mems.get(addr-1)<<8)+(mems.get(addr)) == HL.value:
                print(f"pass, HL = 0x{HL.value:04X}")
              else:
                raise Exception(f"test case failed, HL = 0x{HL.value:04X}, expected 0x{((mems.get(addr-1)<<8)+(mems.get(addr))):04X}\nPC=0x{pc.value:04X}")
            elif ii.value == int(IS['instructions']['assert_zf']['opcode']):
              if mems.get(addr) == flags['ZF']:
                print(f"pass, ZF = {flags['ZF']}")
              else:
                raise Exception(f"test case failed, ZF = {flags['ZF']}, expected {mems.get(addr)}\nPC=0x{pc.value:04X}")

        if GUI:
          if finish_inst:
            if UCC == 0:
              finish_inst = False

          if event is None or event == 'Exit':
            print()
            break

          if clk_counter % UPDATE_RATE == 0 or breakpt:
            window['_PC_'].update(f"0x{pc.value:04X}")
            window['_MAR_'].update(f"0x{mar.value:04X}")
            window['_INST_'].update(f"0x{ii.value:02X}")
            window['_UCC_'].update(f"0x{UCC:02X}")
            window['_A_'].update(f"0x{A.value:02X}")
            window['_B_'].update(f"0x{B.value:02X}")
            window['_HL_'].update(f"0x{HL.value:04X}")
            window['_X_'].update(f"0x{X.value:02X}")
            window['_Y_'].update(f"0x{Y.value:02X}")
            window['_J_'].update(f"0x{J.value:04X}")
            window['_K_'].update(f"0x{K.value:04X}")
            window['_D_'].update(f"0x{D.value:04X}")
            window['_DATA_'].update(f"0x{data:02X}")
            window['_ADDR_'].update(f"0x{addr:04X}")

            window['_ZF_'].update(text_color=INDC_COLOR[flags['ZF']])
            window['_CF_'].update(text_color=INDC_COLOR[flags['CF']])
            window['_NF_'].update(text_color=INDC_COLOR[flags['NF']])

            for ctrl_sig,val in ctrl.items():
              window[f'_{ctrl_sig}_'].update(text_color=INDC_COLOR[val>0])

            window['_STPR_'].update(f"0x{stack.get_pointer():04X}")

            window['_CNT_'].update(f"{clk_counter:,}")

            sram_values = ""
            for n in range(2**14):
              if mems.sram.value[n] is None:
                sram_values += "--"
              else:
                sram_values += f"{mems.sram.value[n]:02X}"
              # TODO: sram address is hard coded...
              if (n == stack.get_pointer()-0x8000-1):
                sram_values += "*"
              else:
                sram_values += " "
              if (n+1)%8 == 0:
                sram_values += " "

            window['_SRAM_'].update(sram_values)

            stack_values = ""
            for n in range(stack.starting_addr,stack.starting_addr-stack.pointer,-1):
              stack_values += f"0x{n:04X}:  {mems.get(n):02X}\n"

            window['_STACK_'].update(stack_values)
            window['_STACK_USAGE_'].update(stack.pointer)
            window['_STACK_MAX_USAGE_'].update(stack.max_used)

            var_values = ""
            for var in vars:
              # print(var, max_var_width)
              var_name = list(var.keys())[0]
              var_addr = list(var.values())[0]
              var_bytes = [None]*4
              for n in range(len(var_bytes)):
                var_bytes[n] = mems.get(var_addr+n,ignore_uninit=True)
              
              var_values += f"0x{var_addr:04X} {var_name:<{max_var_width}} "
              if var_bytes[0] is not None:
                var_values += f"0x{var_bytes[0]:02X} "
              else:
                var_values += "?"
              if not (None in var_bytes[0:2]):
                var_values += f"0x{var_bytes[0]:02X}{var_bytes[1]:02X} "
              if not (None in var_bytes):
                var_values += f"0x{var_bytes[0]:02X}{var_bytes[1]:02X}{var_bytes[2]:02X}{var_bytes[3]:02X} "
              var_values += "\n"            
            window['_VARS_'].update(var_values)

            if  ii.value in inst_names:
              window['_INST_NAME_'].update(inst_names[ii.value])
            else:
              window['_INST_NAME_'].update("?")


            window['_EXT_ROM_ADDR_'].update(f"0x{mems.ext_eeprom.addr_reg:04X}")
            window['_EXT_ROM_VAL_'].update(f"0x{mems.ext_eeprom.get(0x00):02X}")

            ext_rom_values = ""
            ext_rom_base_addr = mems.ext_eeprom.addr_reg & (~(2**11-1))
            for n in range(2**11):
              rom_addr = ext_rom_base_addr + n
              if n%32 == 0:
                ext_rom_values += f"\n {rom_addr:04X} "
              elif(n)%8 == 0:
                ext_rom_values += " "
              if (rom_addr == mems.ext_eeprom.addr_reg):
                ext_rom_values += "*"
              else:
                ext_rom_values += " "
              if mems.ext_eeprom.value[rom_addr] is None:
                ext_rom_values += "--"
              else:
                ext_rom_values += f"{mems.ext_eeprom.value[rom_addr]:02X}"

            window['_EXT_ROM_'].update(ext_rom_values)
            

            inst_stats_str = ""
            for x in sorted(inst_stats.items(), key=lambda item: item[1]['calls'], reverse=True):
              name = x[0]
              stats = x[1]
              inst_stats_str += f"{name:<20} {stats}\n"
            window['_TIME_ANALYSIS_'].update(inst_stats_str)  

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

      print()
      print(f"max stack usage {stack.max_used} bytes")
      print(f"eeprom usage {eeprom_usage}/{mems.eeprom.size} bytes ({eeprom_usage/mems.eeprom.size*100:0.2f}%)")
      print(f"clk cycles {clk_counter}")

      # call graph
      if 1:
        print_call_graph(call_graph, symbols)

      # dead code
      if 0:
        print("** DEAD CODE REPORT **")
        print(\
          "legend: ",
          colored("read", None),
          colored("executed", 'blue'),
          colored("dead", 'red'),
          )
        print()
        for l in code:
          # print(l)
          color = None
          if l['dead']: color = 'red'
          elif l['execs'] > 0: color = 'blue'
          print(colored(f"{l['addr']} | {l['data']}", color))


      if GUI:
        window.close()

    except yaml.YAMLError as exc:
      print(exc)

if __name__ == "__main__":
  main()