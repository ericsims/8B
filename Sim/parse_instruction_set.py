"""parse instruction_set.yaml for errors
Then generate the instructions.asm definitions for custom_asm
"""

import itertools
import yaml
from yaml.resolver import Resolver
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

def generate_ucode(iss):
    """generate ucode files for writing to ucode ROM"""

    ctrl = []
    ctrl_map = {}
    ctrl_map_sizes = {}
    ctrl_inversion = {}
    # append control signals to ROM output
    for ct_ in iss['control_signals']:
        k = list(ct_.keys())[0]
        if isinstance(ct_[k],list):
            ctrl_map_sizes[k] = ct_['bits']
            for n in range(0, ct_['bits']):
                ctrl.append(f"{k}{n}")
                ctrl_inversion[f"{k}{n}"] = 0
            for idx, key in enumerate(ct_[k]):
                if list(key.keys())[0] != 'NONE':
                    ctrl_map[list(key.keys())[0]] = [k, idx]
        else:
            ctrl.append(k)
            if ct_['active'] == 'high':
                ctrl_inversion[k] = 0
            elif ct_['active'] == 'low':
                ctrl_inversion[k] = 1
            else:
                raise Exception(f"***ERROR: {k} instruction is not active 'high' or 'low'")

    # error if the ctrl signals are not byte divisible!
    if len(ctrl) % 8 != 0:
        raise Exception("***ERROR: number of ctrl signals must be divisible by 8")

    print('control signals: ', ctrl)
    print('control map: ', ctrl_map)
    print('control map sizes: ', ctrl_map_sizes)
    print('control inversion: ', ctrl_inversion)

    inpt = []
    flags = []
    # append control signals to ROM output
    for in_ in iss['input']:
        k = list(in_.keys())[0]
        if 'bits' in in_:
            for n in range(0, in_['bits']):
                inpt.append(f"{k}{n}")
        else:
            inpt.append(k)
            flags.append(k)
    #print('input signals: ', inpt)
    #print('flags: ', flags)

    # generate map microcode into ROM. Use inversion dict to initilze values to deasserted, regardless of active high/low
    # this is super memory inefficient, but im lazy
    ucode=[list(ctrl_inversion.values()) for _ in range(2**len(inpt))]

    for key, value in iss['instructions'].items():
        print(key)
        #print(value['opcode'])
        #print(value['ucode'])
        if key == 'default':
            #print("ignoring default instruction")
            continue
        if isinstance(value['ucode'], dict):
            if len(value['ucode']['conditions']) > 1:
                raise Exception(f"***ERROR: {key} has more than one condition")
            # gnerate list of do not care flags to populate all DNC ROM addreses
            for fs in [list(i) for i in itertools.product([0,1], repeat=len(flags))]:
                # genreate address and fill in flag values, defer ucode addressing until condition decoding
                addr = value['opcode'] << inpt.index('instruction0')
                for n,f in enumerate(flags):
                    addr |= fs[n] << inpt.index(f)
                # decode the ucode for the given flag we care about
                condit = (addr & 1 << inpt.index(value['ucode']['conditions'][0])>0)
                for idx, sigs in enumerate(value['ucode'][condit]):
                    addr |= idx << inpt.index('ucode_count0')
                    #print('  ', condit, idx, sigs)
                    for sig in sigs:
                        if sig in ctrl:
                            # set control bit high, if its a normal output bit. invert if necessry using xor
                            ucode[addr][ctrl.index(sig)] = 1 ^ ctrl_inversion[sig]
                        else:
                            # handle multi bit outputs mapping
                            for bit_index in range(0, ctrl_map_sizes[ctrl_map[sig][0]]):
                                # set control bit high. invert if necessry using xor
                                ucode[addr][ctrl.index(f"{ctrl_map[sig][0]}{bit_index}")] = (int((ctrl_map[sig][1] & (1<<bit_index)) > 0)) ^ ctrl_inversion[f"{ctrl_map[sig][0]}{bit_index}"]
        else:
            for idx, sigs in enumerate(value['ucode']):
                # gnerate list of do not care flags to populate all DNC ROM addreses
                for fs in [list(i) for i in itertools.product([0,1], repeat=len(flags))]:
                    # genreate address and fill in flag values
                    addr = idx << inpt.index('ucode_count0') | value['opcode'] << inpt.index('instruction0')
                    for n,f in enumerate(flags):
                        addr |= fs[n] << inpt.index(f)
                    for sig in sigs:
                        if sig in ctrl:
                            # set control bit high, if its a normal output bit. invert if necessry using xor
                            ucode[addr][ctrl.index(sig)] = 1 ^ ctrl_inversion[sig]
                        else:
                            # handle multi bit outputs mapping
                            for bit_index in range(0, ctrl_map_sizes[ctrl_map[sig][0]]):
                                ucode[addr][ctrl.index(f"{ctrl_map[sig][0]}{bit_index}")] = (int((ctrl_map[sig][1] & (1<<bit_index)) > 0)) ^ ctrl_inversion[f"{ctrl_map[sig][0]}{bit_index}"]
                    #print(" {addr} {ucode[addr][::-1]}")
    

    # write ucode to ROM bit files
    # for each from
    for rr in range(0,int(len(ctrl)/8)):
        print(f"ROM_{rr}")
        with open(f"ROM_{rr}.bin", 'wb') as f:
            for row in ucode:
                byte_ = int(''.join(['1' if i else '0' for i in row[(8*rr):(8*(rr+1))]][::-1]), 2)
                f.write(byte_.to_bytes(1, 'big'))
                #if(byte_ > 0):
                #    print(row[16:24][::-1],row[8:16][::-1],row[0:8][::-1], f"{(8*rr)}:{(8*(rr+1))}", F"{byte_:x}")





with open('instruction_set.yaml', 'r') as stream:

    # remove resolver entries for On/Off/Yes/No
    for ch in "OoYyNn":
        if len(Resolver.yaml_implicit_resolvers[ch]) == 1:
            del Resolver.yaml_implicit_resolvers[ch]
        else:
            Resolver.yaml_implicit_resolvers[ch] = [x for x in
                    Resolver.yaml_implicit_resolvers[ch] if x[0] != 'tag:yaml.org,2002:bool']

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

        inst_list = ['-']*int(2**8)

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


        generate_ucode(IS)

    except yaml.YAMLError as exc:
        raise Exception(exc)
