import matplotlib.pyplot as plt
import math
import inspect

def is_a_lambda(v):
  LAMBDA = lambda:0
  return isinstance(v, type(LAMBDA)) and v.__name__ == LAMBDA.__name__

def byte_to_str(byte_):
    return f"{(byte_&0xFF):02X} "

# y = func(x)
def gen_reverse_lookup(file, func, min_v=0, max_v=2**16-1):
    # print header to console
    if is_a_lambda(func):
        fname = inspect.getsource(func).rstrip()
    else:
        fname = func.__name__
    print(f"Generating reverse lookup table for '{fname}' for {min_v} to {max_v}")


    # generate reverse lut
    result_x = []
    result_y = []
    for x in range(min_v,max_v+1):
        y = math.floor(func(float(x)))
        if y in result_y:
            continue
        else:
            result_y.append(y)
            result_x.append(x)
            # print(f" {y:>5}, {x:>5}")
    # plt.step(result_x, result_y)
    # plt.show()

    # save lut to file
    # format is -x[15:8], -x[7:0], y[7:0] for each entry.
    # xs are stored as negative to make comparison easier
    lut_len = 0
    for y,x in zip(result_y, result_x):
        # test lookup
        # nx = (-x)&0xFFFFFFFF
        # t = 2
        # print(f" {x:>5}, {y:>5} {nx:>10} {t:>10} {(nx+t)&0xFFFFFFFF}")
        lut_file.write(byte_to_str((-x)>>8))
        lut_file.write(byte_to_str(-x))
        lut_file.write(byte_to_str(y))
        lut_file.write('\n')
        lut_len += 3

    
    lut_file.write(byte_to_str(0))
    lut_file.write(byte_to_str(0))
    lut_len += 2
    print(f"lut length: {lut_len} bytes")


with open('lib_dev/Math/rev_lookup_sqrt.dat', 'w') as lut_file:
    gen_reverse_lookup(lut_file, math.sqrt, min_v=1, max_v=2**16-1)

with open('lib_dev/Math/rev_lookup_ln.dat', 'w') as lut_file:
    gen_reverse_lookup(lut_file, math.log, min_v=1, max_v=2**16-1)

# gen_reverse_lookup(file, lambda x:math.log(x,10), min_v=1, max_v=2**16-1)