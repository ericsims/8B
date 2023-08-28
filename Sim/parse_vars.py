def parse_vars(file_name):
    annotations_file_path = file_name+'.annotated'
    symbols_file_path = file_name+'.symbols'

    symbols = {}

    vars = []

    with open(symbols_file_path, 'r') as symbols_file:
        try:
            for line in symbols_file.readlines():
                dat = str(line).split('=')
                dat = list(map(str.strip, dat))
                # print(f"l: {dat}")
                try:
                    symbols[int(dat[1], 0)] = dat[0]
                except:
                     # ignore symbols/labels that obviously not addrs
                     pass
        except:
            print(f"An exception occurred loading {symbols_file_path}")
            return vars, symbols

    with open(annotations_file_path, 'r') as annotations_file:
        try:
            for line in annotations_file.readlines():
                dat = str(line).split('|')
                dat = list(map(str.strip, dat))
                try:
                    # print(f"l: {dat}")
                    addr = int(dat[1], 16)
                    # TODO: RAM range is hard coded
                    if addr >= 0x8000 and addr <= 0xBFFF:
                        # print(f"{symbols[addr]}")
                        vars.append({symbols[addr]: addr})
                except:
                    pass    
        except:
            print(f"An exception occurred loading {annotations_file_path}")
            return vars, symbols
    # print(vars)
    
    return vars, symbols