import yaml
from termcolor import colored



# validate that the duration field matches the number of steps in the ucode
def validate_length(op):
    if op['duration'] == len(op['ucode']):
        print('\t\tlen correct')
    else:
        print(colored('\t\t***WARNING: Advertised duration do not match number of ucode steps, {} != {}'.format(op['duration'], len(op['ucode'])),'yellow'))
    if len(op['ucode']) > 32:
        print(colored('\t\t##ERROR: ucode is longer than 32 steps. It includes {} steps!!!'.format(len(op['ucode'])),'red'))


# validate that RU is asserted to reset the ucode counter at the end of the instruction
def validate_ucodereset(op):
    if 'RU' in op['ucode'][-1]:
        print('\t\tucode is reset')
    else:
        print(colored('\t\t***WARNING: ucode counter is not reset at end of instruction. RU not asserted.','yellow'))

# validate that the PC is incremetned to keep up with the number of bytes in the opcode + operand
def validate_programcounter(op):
    ce_counts = 0
    for step in op['ucode']:
        if 'CE' in step:
            ce_counts += 1
    if op['operands']+1 == ce_counts:
        print('\t\tprogram counter matches number of bytes in instruction')
    else:
        print(colored('\t\t***WARNING: PC is not incremented properly. CE counts do not match number of bytes in instruction, {} != {}'. format(ce_counts, op['operands']+1),'yellow'))

# validate that only control signals that make sense are asserted at the sametime
def validate_control_signals(op):
    invalid_control_signals = [
    {'condition':['PO', 'CE'], 'error':'can not incremnt PC while PC out is asserted'},
    {'condition':['PI', 'CE'], 'error':'can not incremnt PC while PC in is asserted'},
    {'condition':['PO', 'PI'], 'error':'can not load and output PC at the same time'},
    {'condition':['AO', 'AI'], 'error':'can not load and output A register at the same time'},
    {'condition':['BO', 'BI'], 'error':'can not load and output B register at the same time'},
    {'condition':['HO', 'HI'], 'error':'can not load and output HL register at the same time'},
    {'condition':['JO', 'JI'], 'error':'can not load and output J register at the same time'},
    {'condition':['KO', 'KI'], 'error':'can not load and output K register at the same time'},
    {'condition':['DO', 'DI'], 'error':'can not load and output D register at the same time'},
    {'condition':['SO', 'SI'], 'error':'can not push and pop stack at the same time'},
    {'condition':['SO', 'NI'], 'error':'can not pop stack while loading stack pointer'},
    {'condition':['SI', 'NI'], 'error':'can not push stack while loading stack pointer'},
    {'condition':['SO', 'DS'], 'error':'can not pop stack while decr stack pointer'},
    {'condition':['SO', 'IS'], 'error':'can not pop stack while incr stack pointer'},
    {'condition':['SI', 'DS'], 'error':'can not push stack while decr stack pointer'},
    {'condition':['SI', 'IS'], 'error':'can not push stack while incr stack pointer'},
    {'condition':['NI', 'DS'], 'error':'can not load stack pointer stack while decr stack pointer'},
    {'condition':['NI', 'IS'], 'error':'can not load stack pointer while incr stack pointer'},
    {'condition':['MO', 'MI'], 'error':'can not load and output memory at the tame'},
    {'condition':['MO', 'MA'], 'error':'can not output memory, while loading MAR'},
    {'condition':['MO', 'MC'], 'error':'can not output memory, while incrementing MAR'},
    {'condition':['MO', 'SO'], 'error':'can not output memory, while pop from stack'},
    {'condition':['MO', 'SI'], 'error':'can not output memory, while push to stack'},
    {'condition':['MI', 'SO'], 'error':'can not load memory, while pop from stack'},
    {'condition':['MI', 'SI'], 'error':'can not load memory, while push to stack'}
]

with open('instruction_set.yaml', 'r') as stream:
    try:
        IS = yaml.safe_load(stream)

        print('control signals:')
        for l in IS['control_signals'] :
            print('\t', l)

        # Verify no duplicate opcodes
        opcode_list = ([ value['opcode'] for key, value in IS['instructions'].items() ])
        dupes = list(set([x for x in opcode_list if opcode_list.count(x) > 1]))
        if len(dupes) > 0:
            for duplicate in dupes:
                print(colored('##ERROR: duplicates opcode 0x{:02x}!!!'.format(duplicate),'red'))
            exit(-1)
        
        # validate instrucions
        print('instructions validations:')
        for key, value in IS['instructions'].items() :
            print('\t{}:'.format(key))
            validate_length(value)
            validate_ucodereset(value)
            validate_programcounter(value)
            #for u in value['ucode']:
            #    print(u)
            print()

    except yaml.YAMLError as exc:
        print(exc)
