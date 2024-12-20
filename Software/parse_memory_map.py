#!/usr/bin/env python

"""parse memory_map.yaml
Then generate the mems.asm definitions for custom_asm
"""

import yaml

with open('memory_map.yaml', 'r') as instream:
    cfg_fie = yaml.safe_load(instream)

    with open('src/mems.asm', 'w') as outstream:
        outstream.write('; autogenerated memory map\n\n')

        for m in cfg_fie['layout']:
            addr = m
            size = cfg_fie['layout'][m]['size']
            label = cfg_fie['layout'][m]['label']
            loc = cfg_fie['layout'][m]['location']
            outstream.write(f'; {label}\n')
            outstream.write(f'; MEM slot {loc}\n')
            outstream.write(f'{label:<16} = 0x{addr:04X}\n')
            outstream.write(f'{f"{label}_SIZE":<16} = 0x{size:04X}\n\n')


    with open('ADDR_ROM.bin', 'wb') as outstream:
        decode = [0]*(2**16)
        for m in cfg_fie['layout']:
            addr = m
            size = cfg_fie['layout'][m]['size']
            loc = int(cfg_fie['layout'][m]['location'])
            label = cfg_fie['layout'][m]['label']

            for x in range(addr, addr+size):
                if decode[x]: raise Exception(f"{label} overlaps with another memory range")
                decode[x] = loc

        for x in decode:
            outstream.write(int(x).to_bytes(1, 'big'))
            
        

