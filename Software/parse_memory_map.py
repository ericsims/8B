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
            outstream.write(f'; {label}\n')
            outstream.write(f'{label:<16} = 0x{addr:04X}\n')
            outstream.write(f'{f"{label}_SIZE":<16} = 0x{size:04X}\n\n')
