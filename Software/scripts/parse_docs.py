#!/usr/bin/env python
import sys
import yaml
import argparse

OPTIONS_LONG = ['input =', 'output = ']

parser = argparse.ArgumentParser("parse_docs")
parser.add_argument("input_file", help="input file path")
parser.add_argument("output_file", help="output file path")
args = vars(parser.parse_args())

print(f"generating docs for {args['input_file']}...")

COM_CHAR = ';'
CMD_CHAR = '@'

def getFile(file,n,tokens=None):
    return {'file':args['input_file']}

def setAuthor(file,n,tokens=None):
    auth = ''
    for t in tokens: auth = auth+t+' '
    auth = auth.strip()
    return {'author':auth}

def setCoverage(file,n,tokens=None):
    cov = list(tokens)
    return {'coverage':cov}

def setBrief(file,n,tokens=None):
    b = ''
    for t in tokens: b = b+t+' '
    b = b.strip()
    return {'brief':b}

def setSection(file,n,tokens=None):
    b = ''
    for t in tokens: b = b+t+' '
    b = b.strip()
    return {'section':b}

def setFunction(file,n,tokens=None):
    fnc = None
    for m,l in enumerate(file):
        if m < n: continue
        j = l.split(':')
        if len(j)>1:
            fnc = j[0]
            break
    return {'function': fnc}

def setParam(file,n,tokens=None):
    if len(tokens) > 1:
        b = ''
        for t in tokens[1:]: b = b+t+' '
        b = b.strip()
        return {'param':tokens[0].lstrip('.'), 'body':[b]}
    else:
        return {'param':tokens[0].lstrip('.')}

def setReturn(file,n,tokens=None):
    if len(tokens) > 1:
        b = ''
        for t in tokens[1:]: b = b+t+' '
        b = b.strip()
        return {'return':tokens[0].lstrip('.'), 'body':[b]}
    else:
        return {'return':tokens[0].lstrip('.')}

COMMANDS = {
    'file': getFile,
    'author': setAuthor,
    'section': setSection,
    'coverage': setCoverage,
    'brief': setBrief,
    'function': setFunction,
    'param': setParam,
    'return': setReturn,
}

# def extract_any_top_token(list_of_dicts, key):
#     for d in list_of_dicts:
#         if key in d.keys(): return d[key]
#     return None

def rep_printer1(output):
    br = True
    print()
    for s in output:
        if 'break' in s.keys(): 
            if br:
                continue
            else:
                print()
                br=True
                continue
        br=False
        for k in s.keys():
            if k == 'body': continue
            print(f"{k.upper()}: {s[k]}")
            if 'body' in s.keys():
                for l in s['body']:
                    print(f"  {l}")

def rep_printer2(output):
     with open(args['output_file'], 'w') as yaml_file:
        yaml.dump(output, yaml_file, default_flow_style=False)

with open(args['input_file'], 'r') as f:
    output = []
    file_text = f.read().splitlines()
    for n, l in enumerate(file_text):
        l = l.strip()
        if len(l) == 0: continue # skip empty line
        if l[0] == COM_CHAR:
            if l == ';;': output.append({'break':True})
            comment = l[1:].lstrip(' ;*')
            if len(comment) == 0: continue
            # print(f'comment: {comment}')

            tokens = comment.rsplit(' ')
            # print(tokens)
            if tokens[0][0] == CMD_CHAR:
                cmd_str = tokens[0][1:]
                # print(f"CMD: {cmd_str}")
                if cmd_str not in COMMANDS.keys():
                    print(f"**command '{cmd_str}' unknown")
                    continue
                if COMMANDS[cmd_str] is None: continue
                output.append(COMMANDS[cmd_str](file_text,n,tokens[1:]))
                continue
            
            # append body
            if len(output) == 0: continue
            if 'section' in output[-1].keys():
                if 'body' not in output[-1].keys(): output[-1]['body'] = []
                output[-1]['body'].append(comment)
    
    # print(output)
    rep_printer2(output)