#!/usr/bin/env python
print("loading libs...")
import sys
import select
import getopt
import warnings
import json
import yaml
import traceback
from enum import Enum
import FreeSimpleGUI as sg
from termcolor import colored
# import rpyc
from bcolors import bcolors
from PC import PC
from II import II
from MAR import MAR
from REG import REG
from RAM_STACK import STACK
from MEMS import MEMS

from parse_vars import *

# TODO: dead code analysis
# TODO: extended memory

class dbg(Enum):
  CONTINUE = 1
  BREAK_IMM = 2
  BREAK_AFTER_INST = 3
  BREAK_AFTER_RET = 4

def main():

  FILE_NAME = 'bin/001_test_a_reg.bin' # default file
  DISK = None
  DISK_TYPE = None
  EXIT_ON_HALT = False
  SIM = True
  GUI = True
  DEAD_CODE = False
  IGNORE_UNINIT = False

  BP_ADDR = 0x4000

  # process flags

  OPTIONS = "f:" #TODO: no abbreviated options.
  OPTIONS_LONG = ['file =', 'exit-on-halt', 'no-gui', 'no-sim', 'dead-code', 'diskv1 =','diskv2 =', 'ignore-uninit-mem']

  try:
    # grab flags
    args, _ = getopt.getopt(sys.argv[1:], OPTIONS, OPTIONS_LONG)
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
      elif arg_ in ("--dead-code"):
        DEAD_CODE = True
      elif arg_ in ("--diskv1"):
        DISK = val_
        DISK_TYPE = 1
      elif arg_ in ("--diskv2"):
        DISK = val_
        DISK_TYPE = 2
      elif arg_ in ("--ignore-uninit-mem"):
        IGNORE_UNINIT = True

  except getopt.error as err:
    # output error, and return with an error code
    print(str(err), file=sys.stderr)
    return 2

  if SIM:
    try:
      conn = rpyc.connect("localhost", 18812, config={'allow_all_attrs': True})
    except:
      conn = None
      warnings.warn("Warning. Sim not connected!")
  else:
    conn = None
  
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


  # load program
  print(f"loading program ${FILE_NAME}...")
  eeprom_usage = 0
  with open(FILE_NAME, 'rb') as file:
    eep_ptr = 0
    while 1:
      byte = file.read(1)
      if not byte:
        break
      mems.eeprom.value[eep_ptr] = ord(byte) & 0xFF
      eeprom_usage += 1
      eep_ptr+=1
  
  # load annotations
  print("loading annoations...")
  vars, labels, symbols, code = parse_vars(FILE_NAME)
  
  # load disk
  if DISK is not None:
    print(f"loading disk {DISK}...")
    mems.sdcard.set_version(DISK_TYPE)
    with open(DISK, 'rb') as file:
      sd_ptr = 0
      while 1:
        byte = file.read(1)
        if not byte:
          break
        mems.sdcard.value[sd_ptr] = ord(byte) & 0xFF
        sd_ptr+=1
        if sd_ptr >= 0x200000: break # only load first 2MB for now
      

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
  
  ctrl_zeroed = dict.fromkeys(ctrl, 0)

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
    [sg.Button('uSTEP')],
    [sg.Button('STEP Inst.')],
    [sg.Button('STEP Out')],
    [sg.Button('Pause')],
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

  layout_debug = [[
    sg.Column([
      [sg.Listbox(
        values=[],
        select_mode=sg.LISTBOX_SELECT_MODE_SINGLE,
        size=(128,70),
        font=('courier new',8),
        justification='left',
        text_color='black',
        background_color='white',
        key='_DEBUG_',
        expand_y=True,
        expand_x=True
      )]
    ], vertical_alignment='t' ),
    sg.Column([
      [sg.Listbox(
        values=[],
        select_mode=sg.LISTBOX_SELECT_MODE_SINGLE,
        size=(70,50),
        font=('courier new',8),
        justification='left',
        text_color='black',
        background_color='white',
        key='_CALLS_',
        expand_y=True,
        expand_x=True
      )]
    ], vertical_alignment='t', expand_y=True, expand_x=True),
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
      key='_VARS_',
      expand_y=True,
      expand_x=True
    )
  ]]
  layout_time = [[
    sg.Multiline(
      size=(100,70),
      font=('courier new',8),
      justification='left',
      text_color='black',
      background_color='white',
      write_only = True,
      disabled = True,
      key='_TIME_ANALYSIS_',
      expand_y=True,
    )
  ]]
  
  tabs_layout = [
    [sg.TabGroup([[
      sg.Tab('DEBUG', layout_debug, expand_x=True, expand_y=True),
      sg.Tab('SRAM', mems.sram.gui_get_layout(), expand_x=True, expand_y=True),
      sg.Tab('STACK', stack.gui_get_layout(), expand_x=True, expand_y=True),
      sg.Tab('VARS', layout_vars, expand_x=True, expand_y=True),
      sg.Tab('TIME', layout_time, expand_x=True, expand_y=True),
      sg.Tab('SDCARD', mems.sdcard.gui_get_layout(), expand_x=True, expand_y=True),
      sg.Tab('RA8876', mems.ra8876.gui_get_layout(), expand_x=True, expand_y=True),
      sg.Tab('W5300', mems.w5300.gui_get_layout(), expand_x=True, expand_y=True),
      ]])],
    mems.uart.gui_get_layout()
  ]

  layout = [[
    sg.Column(layout_regs,  vertical_alignment='t', expand_y=True),
    sg.Column(layout_ctrl,  vertical_alignment='t', expand_y=True),
    sg.Column(layout_flags, vertical_alignment='t', expand_y=True),
    sg.Column(tabs_layout,  vertical_alignment='t',expand_x=True, expand_y=True)
  ]]
  



  if GUI:
    window = sg.Window(f'8B - {FILE_NAME}', layout, font=('courier new',11), resizable=True, finalize=True)
    mems.sram.gui_init(window)
    mems.uart.gui_init(window)
    mems.sdcard.gui_init(window)
    mems.ra8876.gui_init(window)
    mems.w5300.gui_init(window)
    stack.gui_init(window)
  else:
    window = None

 

  INDC_COLOR = ['gray', 'green']

  list_addrs = list(enumerate([c['addr'] for c in code]))
  max_var_width = max([len(list(var.keys())[0]) for var in vars])
  debug_code_highlight = []

  dbg_state = dbg.CONTINUE

  if GUI:
    if not EXIT_ON_HALT: dbg_state = dbg.BREAK_IMM

    window['_DEBUG_'].update(values=[f"{line['addr']:08x} {line['data']}" for line in code])

  else:
    event = None
    values = None

  inst = []
  inst_names = {}
  inst_stats = {}
  current_call = 0
  call_graph = [{'addr': 0, 'symbol': 'entry_point', 'stack_trace': [0], 'qty': 1, 'bk_on_ret': False, 'called_from':0}]

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
          
          if clk_counter % UPDATE_RATE == 0 or ctrl['HT'] or dbg_state == dbg.BREAK_IMM or dbg_state == dbg.BREAK_AFTER_INST:
            if dbg_state == dbg.BREAK_IMM:
              event, _ = window.Read()
            else:
              event, _ = window.Read(timeout=1)
            
            if event == "Pause":
              dbg_state = dbg.BREAK_IMM
              continue
            if event == "STEP Inst.":
              dbg_state = dbg.BREAK_AFTER_INST
            if event == "STEP Out":
              dbg_state = dbg.BREAK_AFTER_RET
              call_graph[current_call]['bk_on_ret'] = True
            if event == "Resume":
              dbg_state = dbg.CONTINUE
            if event == "uSTEP":
              pass
            if event is not None and '_UART_' in event:
              mems.uart.rcv_char(int(event[6:]))
              continue
        # else:
        #   while sys.stdin in select.select([sys.stdin], [], [], 0)[0]:
        #     line = sys.stdin.readline()
        #     if line:
        #       for char in line:
        #         mems.uart.rcv_char(ord(char))             



        clk_counter += 1

        ## rising edge
        # outputs
        #if ctrl['PO']+ctrl['MO']+ctrl['AO']+(ctrl['Mn']>0)+ctrl['PP'] > 1:
        #  raise Exception("more than one bus output enabled")
        if ctrl['PO']:
          data = pc.get(ctrl['LM'])
        elif ctrl['MO']:
          data = mems.get(addr,ignore_uninit=IGNORE_UNINIT,log=GUI)
          # store dead code info
          # TODO: this is very slow
          if DEAD_CODE:
            indices = [i for i, x in list_addrs if x == addr]
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
          data = stack.pop(log=GUI)
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
            flags['CF'] = 1 # pullup
            # raise Exception("should only update CF on ALU operation")

        # CLK
        if ctrl['HT']:
          if EXIT_ON_HALT:
            break
          dbg_state = dbg.BREAK_IMM

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
          mems.set(addr, data, log=GUI)

        # INST
        if ctrl['II']:
          ii.set(data)
          # calls
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
          stack.push(data,log=GUI)
        elif ctrl['IS']:
          stack.inc()
        elif ctrl['DS']:
          stack.dec()
        elif ctrl['NI']:
          stack.set(data,ctrl['LM'],reinit=(ii.value==0x1B))

        # check if this is a jmp/call/ret instruction
        if ctrl['PI'] and ctrl['RU']:
          if ii.value == 0x6B or ii.value == 0x63: # call
            dup = None
            stack_trace = [call_graph[n]['addr'] for n in call_graph[current_call]['stack_trace']]+[pc.value]
            for k in range(len(call_graph)):
              test_trace = [call_graph[n]['addr'] for n in call_graph[k]['stack_trace']]
              # print(f"  {k} {stack_trace}")
              if test_trace == stack_trace:
                dup = k
                break

            call_addr = mems.get(stack.get_pointer()-2,ignore_uninit=True)*256+mems.get(stack.get_pointer()-1,ignore_uninit=True)-3
            if dup is None:
              symbol = "???"
              if pc.value in labels:
                symbol = labels[pc.value] 
              call_graph.append({'addr':pc.value, 'symbol':symbol, 'stack_trace':call_graph[current_call]['stack_trace']+[len(call_graph)], 'qty':1, 'bk_on_ret':False, 'called_from':call_addr})
              current_call = len(call_graph)-1
            else:
              current_call = dup
              call_graph[current_call]['qty'] += 1
              call_graph[current_call]['called_from'] = call_addr
            # print(f"called {call_graph[current_call]['symbol']} from {call_addr:04X}")
            # print("call")
          elif ii.value == 0x74: # return
            if call_graph[current_call]['bk_on_ret']: 
              call_graph[current_call]['bk_on_ret'] = False
              dbg_state = dbg.BREAK_IMM
            current_call = call_graph[current_call]['stack_trace'][-2]
            # print("return")
          else: # some kind of jump
            pass

        # U CODE
        UCC = (UCC + 1) & 0x1F
        if ctrl['RU']:
          UCC = 0

        ## falling edge
        # handle ucode
        ctrl = dict(ctrl_zeroed) # set to zeros
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
        elif UCC < len(inst[ii.value]):
          for u in inst[ii.value][UCC]:
            ctrl[u] = 1

          # handle the assert instructions. Only do anything on the last cycle
          if ctrl['RU']:
            if ii.value == int(IS['instructions']['assert_a']['opcode']):
              if mems.get(addr,log=GUI) == A.value:
                print(f"pass, a = 0x{A.value:02X}")
              else:
                raise Exception(f"test case failed, a = 0x{A.value:02X}, expected 0x{mems.get(addr):02X}\n")
            elif ii.value == int(IS['instructions']['assert_b']['opcode']):
              if mems.get(addr,log=GUI) == B.value:
                print(f"pass, b = 0x{B.value:02X}")
              else:
                raise Exception(f"test case failed, b = 0x{B.value:02X}, expected 0x{mems.get(addr):02X}\n")
            elif ii.value == int(IS['instructions']['assert_hl']['opcode']):
              if (mems.get(addr-1,log=GUI)<<8)+(mems.get(addr,log=GUI)) == HL.value:
                print(f"pass, HL = 0x{HL.value:04X}")
              else:
                raise Exception(f"test case failed, HL = 0x{HL.value:04X}, expected 0x{((mems.get(addr-1)<<8)+(mems.get(addr))):04X}\n")
            elif ii.value == int(IS['instructions']['assert_zf']['opcode']):
              if mems.get(addr,log=GUI) == flags['ZF']:
                print(f"pass, ZF = {flags['ZF']}")
              else:
                raise Exception(f"test case failed, ZF = {flags['ZF']}, expected {mems.get(addr)}\n")
            elif ii.value == int(IS['instructions']['assert_cf']['opcode']):
              if mems.get(addr,log=GUI) == flags['CF']:
                print(f"pass, CF = {flags['CF']}")
              else:
                raise Exception(f"test case failed, CF = {flags['CF']}, expected {mems.get(addr)}\n")
            elif ii.value == int(IS['instructions']['assert_nf']['opcode']):
              if mems.get(addr,log=GUI) == flags['NF']:
                print(f"pass, NF = {flags['NF']}")
              else:
                raise Exception(f"test case failed, NF = {flags['NF']}, expected {mems.get(addr)}\n")

        
        mems.sdcard.sim()
        mems.ra8876.sim()
        mems.w5300.sim()

        if GUI:
          if UCC == 0 and dbg_state == dbg.BREAK_AFTER_INST:
            dbg_state = dbg.BREAK_IMM

          if event is None or event == 'Exit':
            print()
            break

          if clk_counter % UPDATE_RATE == 0 or dbg_state == dbg.BREAK_IMM:
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


            if UCC == 0:
              new_debug_code_highlight = [i for i, x in list_addrs if x == pc.value]
              # print(pc.value, debug_code_highlight,[i for i, x in list_addrs if x == pc.value])
              if len(new_debug_code_highlight)>0:
                for l in debug_code_highlight:
                  window['_DEBUG_'].Widget.itemconfig(l, fg='black', bg='white')
                debug_code_highlight=new_debug_code_highlight
                window['_DEBUG_'].update(scroll_to_index=max([debug_code_highlight[0]-10,0]))
                for l in debug_code_highlight:
                  window['_DEBUG_'].Widget.itemconfig(l, fg='red', bg='light blue')
            U2506 = '\u2506'
            U251C = '\u251C'
            window['_CALLS_'].update(values=[f"{len(call['stack_trace']):2} {call['addr']:04X} {f' {U2506} ' * (len(call['stack_trace'])-1)} {U251C} {call['symbol']} {call['qty']}" for call in call_graph])
            window['_CALLS_'].Widget.itemconfig(current_call, fg='red', bg='light blue')
            window['_CALLS_'].update(scroll_to_index=max([current_call-10,0]))


            
            for ctrl_sig,val in ctrl.items():
              window[f'_{ctrl_sig}_'].update(text_color=INDC_COLOR[val>0])

            window['_STPR_'].update(f"0x{stack.get_pointer():04X}")

            window['_CNT_'].update(f"{clk_counter:,}")

            # SRAM
            mems.sram.gui_update(stack_pointer=stack.get_pointer())

            # STACK
            base_ptr_val = (mems.get(BP_ADDR,ignore_uninit=True)<<8)+mems.get(BP_ADDR+1,ignore_uninit=True)
            stack.gui_update(base_ptr_val=base_ptr_val, current_call=call_graph[current_call])


            # GLOBALS
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
              pass
            else:
              window['_INST_NAME_'].update("?")

          

            inst_stats_str = ""
            for x in sorted(inst_stats.items(), key=lambda item: item[1]['calls'], reverse=True):
              name = x[0]
              stats = x[1]
              inst_stats_str += f"{name:<20} {stats}\n"
            window['_TIME_ANALYSIS_'].update(inst_stats_str)  

            # SD CARD
            mems.sdcard.gui_update()

            # TFT
            mems.ra8876.gui_update()

            # ETH
            mems.w5300.gui_update()

      print()
      print(f"max stack usage {stack.max_used} bytes")
      print(f"eeprom usage {eeprom_usage}/{mems.eeprom.size} bytes ({eeprom_usage/2**16*100:0.2f}%)")
      print(f"clk cycles {clk_counter}")


      # dead code
      if DEAD_CODE:
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
      print(exc, file=sys.stderr)
      return 2
    
    except Exception as exc:
      print(f"{bcolors.FAIL}{traceback.format_exc()}{bcolors.ENDC}", file=sys.stderr)
      # print(f"{bcolors.FAIL}{exc}{bcolors.ENDC}", file=sys.stderr)
      print(f"{bcolors.FAIL}stack trace{bcolors.ENDC}", file=sys.stderr)
      for call in call_graph[current_call]['stack_trace']:
        print(f"{bcolors.FAIL}  {call_graph[call]['called_from']:04X} {call_graph[call]['symbol']}{bcolors.ENDC}", file=sys.stderr)
      print(f"{bcolors.FAIL}  {pc.value:04X} <-- PC{bcolors.ENDC}", file=sys.stderr)
      print("", file=sys.stderr)
      return 1



if __name__ == "__main__":
  sys.exit(main())