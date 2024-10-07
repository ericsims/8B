#!/usr/bin/env python
import glob
import yaml
import argparse
from pathlib import Path

OPTIONS_LONG = ['input =', 'output = ']

parser = argparse.ArgumentParser("parse_docs")
parser.add_argument("instruction_set", help="instruction set input file path")
parser.add_argument("irdocs", help="irdocs folder")
args = vars(parser.parse_args())

print(f'generating instruction test coverage report...')


report = {}
with open(args['instruction_set'], 'r') as f:
    IS = yaml.safe_load(f)
    instructions = IS['instructions']
    for a in instructions:
        if a == 'default': continue
        report[a] = []
    irfiles = glob.glob(f"{args['irdocs']}/*.yml")
    for doc_f in irfiles:
        with open(doc_f, 'r') as doc:
            ir = yaml.safe_load(doc)
            for l in ir:
                if not isinstance(l, dict): continue
                if 'coverage' in l.keys():
                    for inst in l['coverage']:
                        report[inst].append(Path(doc_f).stem)


for r in report:
    print(f"{r:<20} {report[r]}")

    
