#!/usr/bin/env python
import sys
import getopt
import warnings
import json
import yaml
import traceback
from enum import Enum
import FreeSimpleGUI as sg
from termcolor import colored
# import rpyc
from PIL import Image, ImageTk

from PC import PC
from II import II
from MAR import MAR
from REG import REG
from RAM_STACK import STACK
from MEMS import MEMS

from parse_vars import *

# TODO: dead code analysis
# TODO: call graph to include call/ret/jumps. add subgraph for subroutines
# TODO: extended memory

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


uart_print_buf = ""

class dbg(Enum):
  CONTINUE = 1
  BREAK_IMM = 2
  BREAK_AFTER_INST = 3
  BREAK_AFTER_RET = 4


def get_sram_char_pos(addr):
  row_num = int((addr-0x4000)/32)
  col_num = ((addr-0x4000)-row_num*32)*3
  col_num += int(col_num/3/8)
  col_num += 4
  return row_num,col_num

def main():

  FILE_NAME = 'bin/001_test_a_reg.bin' # default file
  DISK = None
  EXIT_ON_HALT = False
  SIM = True
  GUI = True
  DEAD_CODE = False
  IGNORE_UNINIT = False

  BP_ADDR = 0x4000

  # process flags

  OPTIONS = "f:" #TODO: no abbreviated options.
  OPTIONS_LONG = ['file =', 'exit-on-halt', 'no-gui', 'no-sim', 'dead-code', 'disk =', 'ignore-uninit-mem']

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
      elif arg_ in ("--disk"):
        DISK = val_
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
    ],
    [sg.Image(key="-MAP-", size=(128,128))],
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
  layout_sram = [[
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
  layout_stack = [[
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


  layout_uart = [
    [
      sg.Input(
        justification='left',
        text_color='black',
        background_color='white',
        key='_UART_IN_',
        expand_x = True
      )
    ],
    [sg.Multiline(
      autoscroll=True,
      font=('courier new',11),
      justification='left',
      text_color='black',
      background_color='white',
      key='_UART_OUT_',
      expand_y = True,
      expand_x = True,
      write_only=True,
      disabled=True
    )]
  ]
  layout_sdcard = [[
    sg.Column([
      [
        sg.T('ADDR POINTER   '),
        sg.T(
          text='',
          size=(8,1),
          justification='left',
          text_color='black',
          background_color='white',
          key='_SDCARD_ADDR_'
        )
      ],
      [sg.Multiline(
        size=(138,70),
        font=('courier new',8),
        justification='left',
        text_color='black',
        background_color='white',
        key='_SDCARD_',
        expand_y=True,
        expand_x=True
      )]
    ], vertical_alignment='t', expand_y=False, expand_x=False),
  ]]
  
  tabs_layout = [[
    sg.TabGroup([[
      sg.Tab('DEBUG', layout_debug, expand_x=True, expand_y=True),
      sg.Tab('SRAM', layout_sram, expand_x=True, expand_y=True),
      sg.Tab('STACK', layout_stack, expand_x=True, expand_y=True),
      sg.Tab('VARS', layout_vars, expand_x=True, expand_y=True),
      sg.Tab('TIME', layout_time, expand_x=True, expand_y=True),
      sg.Tab('UART', layout_uart, expand_x=True, expand_y=True),
      sg.Tab('SDCARD', layout_sdcard, expand_x=True, expand_y=True),
      ]])
    ]]

  layout = [[
    sg.Column(layout_regs,  vertical_alignment='t', expand_y=True),
    sg.Column(layout_ctrl,  vertical_alignment='t', expand_y=True),
    sg.Column(layout_flags, vertical_alignment='t', expand_y=True),
    sg.Column(tabs_layout,  vertical_alignment='t',expand_x=True, expand_y=True)
  ]]
  
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
  
  if DISK is not None:
    with open(DISK, 'rb') as file:
      sd_ptr = 0
      while 1:
        byte = file.read(1)
        if not byte:
          break
        mems.sdcard.value[sd_ptr] = ord(byte) & 0xFF
        sd_ptr+=1
        if sd_ptr >= 0x200000: break # only load first 2MB for now



  if GUI:
    window = sg.Window(f'8B - {FILE_NAME}', layout, font=('courier new',11), resizable=True, finalize=True)
    window['_SRAM_'].Widget.tag_config('WRITES', foreground='red')
    window['_SRAM_'].Widget.tag_config('READS', foreground='blue')
  else:
    window = None

  def update_uart(char):
    if GUI:
      global uart_print_buf
      # TODO: this leaks memory, trim at some length please
      uart_print_buf = f"{uart_print_buf}{char}"
      window['_UART_OUT_'].update(uart_print_buf)
    else:
      print(f"{bcolors.OKCYAN}{char}{bcolors.ENDC}", end='')
      pass
  mems.uart.callback = update_uart

  INDC_COLOR = ['gray', 'green']

  vars, labels, symbols, code = parse_vars(FILE_NAME)
  list_addrs = list(enumerate([c['addr'] for c in code]))
  max_var_width = max([len(list(var.keys())[0]) for var in vars])
  debug_code_highlight = []

  dbg_state = dbg.CONTINUE

  if GUI:
    event, values = window.Read(timeout=0)
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
              event, _ = window.Read(timeout=0)

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
          if ii.value == 0x6B: # call)
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

            sram_values = [
              f"{i:04X} "
              +f"{' '.join([f'{x:02X}' if x is not None else '--' for x in mems.sram.value[i:i+8]])}  "
              +f"{' '.join([f'{x:02X}' if x is not None else '--' for x in mems.sram.value[i+8:i+16]])}  "
              +f"{' '.join([f'{x:02X}' if x is not None else '--' for x in mems.sram.value[i+16:i+24]])}  "
              +f"{' '.join([f'{x:02X}' if x is not None else '--' for x in mems.sram.value[i+24:i+32]])}  "
              +f"{''.join([f'{chr(x)}' if x is not None and x >= 0x20 and x <= 0x7E else '.' for x in mems.sram.value[i:i+32]])}"
              for i in range(0x4000,0x4000+0x8000,32)]

            # mark stack pointer with '*'
            row,col = get_sram_char_pos(stack.get_pointer())
            sram_values[row] = sram_values[row][0:col]+"*"+sram_values[row][col+1:]
            sram_scroll_pos = window['_SRAM_'].Widget.yview()[0]
            window['_SRAM_'].update("\n".join(sram_values))
            window['_SRAM_'].Widget.yview_moveto(sram_scroll_pos)

            for read in mems.sram.reads:
              row,col = get_sram_char_pos(read)
              window['_SRAM_'].Widget.tag_add('READS', f'1.0 + {row*138+col} chars', f'1.0 + {row*138+col+3} chars')
            for write in mems.sram.writes:
              row,col = get_sram_char_pos(write)
              window['_SRAM_'].Widget.tag_add('WRITES', f'1.0 + {row*138+col} chars', f'1.0 + {row*138+col+3} chars')
            mems.sram.clear_read_write_log()




            # STACK
            bf = (mems.get(BP_ADDR,ignore_uninit=True)<<8)+mems.get(BP_ADDR+1,ignore_uninit=True)

            stack_values = ""
            for n in range(stack.starting_addr,stack.starting_addr+stack.pointer):
              stack_values += f"0x{n:04X}: {mems.get(n,ignore_uninit=True):02X} {n-bf:02X} {' <-- BP' if n==bf else ''}\n"


            stack_scroll_pos = window['_STACK_'].Widget.yview()[0]
            window['_STACK_'].update(stack_values)
            window['_STACK_'].Widget.yview_moveto(stack_scroll_pos)
            window['_STACK_USAGE_'].update(stack.pointer)
            window['_STACK_MAX_USAGE_'].update(stack.max_used)
            window['_CUR_FUNC_'].update(call_graph[current_call]['symbol'])
            local_vars = []
            # print(f'{bf:04X}')
            for s in symbols:
              a = [ None, None, None, None ]
              if s.startswith(call_graph[current_call]['symbol']+'.param') or \
                    s.startswith(call_graph[current_call]['symbol']+'.local'):
                a = [ mems.get(bf+symbols[s]+nn,ignore_uninit=True) for nn in range(4)]

              if s.startswith(call_graph[current_call]['symbol']+'.param8') or \
                    s.startswith(call_graph[current_call]['symbol']+'.local8'):
                local_vars.append({'addr': symbols[s], 'name': s, 'size': 8, 'value': \
                                   f"{'??' if a[0] is None else f'{a[0]:02X}'}"})
              elif s.startswith(call_graph[current_call]['symbol']+'.param16') or \
                    s.startswith(call_graph[current_call]['symbol']+'.local16'):
                local_vars.append({'addr': symbols[s], 'name': s, 'size': 16, 'value': \
                                   f"{'??' if a[0] is None else f'{a[0]:02X}'}"+\
                                   f"{'??' if a[1] is None else f'{a[1]:02X}'}"})
              elif s.startswith(call_graph[current_call]['symbol']+'.param32') or \
                    s.startswith(call_graph[current_call]['symbol']+'.local32'):
                local_vars.append({'addr': symbols[s], 'name': s, 'size': 32, 'value': \
                                   f"{'??' if a[0] is None else f'{a[0]:02X}'}"+\
                                   f"{'??' if a[1] is None else f'{a[1]:02X}'}"+\
                                   f"{'??' if a[2] is None else f'{a[2]:02X}'}"+\
                                   f"{'??' if a[3] is None else f'{a[3]:02X}'}"})
            window['_LOC_VARS_'].update(values=[f"{v['addr']:04X} {v['name']} {v['value']}" for v in local_vars])


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
            else:
              window['_INST_NAME_'].update("?")

          

            inst_stats_str = ""
            for x in sorted(inst_stats.items(), key=lambda item: item[1]['calls'], reverse=True):
              name = x[0]
              stats = x[1]
              inst_stats_str += f"{name:<20} {stats}\n"
            window['_TIME_ANALYSIS_'].update(inst_stats_str)  

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

            # SD CARD
            window['_SDCARD_ADDR_'].update(f"{mems.sdcard.addr_reg:08X}")

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