"""parse instruction_set.yaml for errors
Then generate the instructions.asm definitions for custom_asm
"""

import yaml
from termcolor import colored
from tabulate import tabulate


def validate_length(inst):
    """validate that the duration field matches the number of steps in the ucode"""
    if inst['duration'] != len(inst['ucode']):
        print(colored(f"\t\t***WARNING: Advertised duration do not match number of ucode steps, {inst['duration']} != {len(inst['ucode'])}",'yellow'))
    if len(inst['ucode']) > 32:
        print(colored(f"\t\t##ERROR: ucode is longer than 32 steps. It includes {len(inst['ucode'])} steps!!!",'red'))


def validate_ucodereset(ucode):
    """validate that RU is asserted to reset the ucode counter at the end of the instruction"""
    # check conditional instructions true and false case
    if isinstance(ucode, dict):
        validate_ucodereset(ucode[False])
        validate_ucodereset(ucode[True])
    else:
        if 'RU' not in ucode[-1]:
            print(colored('\t\t***WARNING: ucode counter is not reset at end of instruction. RU not asserted.','yellow'))


def validate_programcounter(inst):
    """validate that the PC is incremetned to keep up with the number of bytes in the opcode + operand"""
    if isinstance(inst['ucode'], dict):
        print('\t\tskipping PC check for conditional instrucions')
    else:
        ce_counts = 0
        for step in inst['ucode']:
            if 'CE' in step:
                ce_counts += 1
        if inst['operands']+1 != ce_counts:
            print(colored(f"\t\t***WARNING: PC is not incremented properly. CE counts do not match number of bytes in instruction, {ce_counts} != {inst['operands']+1}",'yellow'))

def validate_opcode(inst):
    """validate that the opcode is in correct range"""
    if inst['opcode'] < int(0x00) or inst['opcode'] > int(0x7F):
        raise Exception(f"\t\t***ERROR: opcode 0x{inst['opcode']:02X} is out of range 0x00 - 0x7F")

def validate_control_signals(ucode):
    """validate that only control signals that make sense are asserted at the sametime"""
    invalid_control_signals = [
        {'condition':{'PO', 'CE'}, 'error':'can not incremnt PC while PC out is asserted'},
        {'condition':{'PI', 'CE'}, 'error':'can not incremnt PC while PC in is asserted'},
        {'condition':{'PO', 'PI'}, 'error':'can not load and output PC at the same time'},
        {'condition':{'AO', 'AI'}, 'error':'can not load and output A register at the same time'},
        {'condition':{'BO', 'BI'}, 'error':'can not load and output B register at the same time'},
        {'condition':{'HO', 'HI'}, 'error':'can not load and output HL register at the same time'},
        {'condition':{'JO', 'JI'}, 'error':'can not load and output J register at the same time'},
        {'condition':{'KO', 'KI'}, 'error':'can not load and output K register at the same time'},
        {'condition':{'DO', 'DI'}, 'error':'can not load and output D register at the same time'},
        {'condition':{'SO', 'SI'}, 'error':'can not push and pop stack at the same time'},
        {'condition':{'SO', 'NI'}, 'error':'can not pop stack while loading stack pointer'},
        {'condition':{'SI', 'NI'}, 'error':'can not push stack while loading stack pointer'},
        {'condition':{'SO', 'DS'}, 'error':'can not pop stack while decr stack pointer'},
        {'condition':{'SO', 'IS'}, 'error':'can not pop stack while incr stack pointer'},
        {'condition':{'SI', 'DS'}, 'error':'can not push stack while decr stack pointer'},
        {'condition':{'SI', 'IS'}, 'error':'can not push stack while incr stack pointer'},
        {'condition':{'NI', 'DS'}, 'error':'can not load stack pointer stack while decr stack pointer'},
        {'condition':{'NI', 'IS'}, 'error':'can not load stack pointer while incr stack pointer'},
        {'condition':{'IS', 'DS'}, 'error':'can not incr and decr stack pointer'},
        {'condition':{'MO', 'MI'}, 'error':'can not load and output memory at the tame'},
        {'condition':{'MO', 'MA'}, 'error':'can not output memory while loading MAR'},
        {'condition':{'MO', 'MC'}, 'error':'can not output memory while incrementing MAR'},
        {'condition':{'MO', 'SO'}, 'error':'can not output memory while pop from stack'},
        {'condition':{'MO', 'SI'}, 'error':'can not output memory while push to stack'},
        {'condition':{'MI', 'SO'}, 'error':'can not load memory while pop from stack'},
        {'condition':{'MI', 'SI'}, 'error':'can not load memory while push to stack'}
    ]

    # check conditional instructions true and false case
    if isinstance(ucode, dict):
        validate_control_signals(ucode[False])
        validate_control_signals(ucode[True])
    else:
    # check ucode against invalid_control_signals list
        for step in ucode:
            for ctrl_sigs in invalid_control_signals:
                if ctrl_sigs['condition'].issubset(set(step)):
                    raise Exception(f"\t\t***ERROR: {ctrl_sigs['error']}")

        # check for duplicates in ucode
        for step in ucode:
            if len(step) != len(set(step)):
                raise Exception(f"\t\t***ERROR: duplicate control signals in ucode line: {step}")

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
                raise Exception(f"***ERROR: duplicates opcode 0x{duplicate:02x}")

        inst_list = ['-']*int(0x80)

        # validate instrucions
        print('instructions validations:')
        for key, value in IS['instructions'].items():
            print(f"\t{key}:")
            validate_length(value)
            validate_programcounter(value)
            validate_control_signals(value['ucode'])
            if key != 'default':
                validate_ucodereset(value['ucode'])
                validate_opcode(value)
                inst_list[int(value['opcode'])] = key
            print()

        with open('instructions.asm', 'w') as asm:
            asm.write('; autogenerated instruction definitions\n\n')
            asm.write('#ruledef\n{\n\n')
            for key, value in IS['instructions'].items():
                if 'asm_def' in value:
                    asm.write(f"; {key}\n")
                    asm.write(f"; {value['description']}\n")
                    asm.write(f"; usage: {value['usage']}\n")
                    inst_def = value['asm_def'].replace('{OPCODE}', f"0x{value['opcode']:02X}")
                    asm.write(f"{inst_def}\n")
            asm.write('}\n')

        print('Instruction Table')
        print(tabulate((inst_list[i:i+4] for i in range(0, len(inst_list), 4))))

    except yaml.YAMLError as exc:
        raise Exception(exc)
