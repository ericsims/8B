import matplotlib.pyplot as plt
import math
import inspect

def is_a_lambda(v):
  LAMBDA = lambda:0
  return isinstance(v, type(LAMBDA)) and v.__name__ == LAMBDA.__name__

def byte_to_str(byte_):
    return f"{(byte_&0xFF):02X} "

# y = func(x)
def gen_reverse_lookup(func, min_v=0, max_v=2**16-1):
    # print header
    if is_a_lambda(func):
        fname = inspect.getsource(func).rstrip()
    else:
        fname = func.__name__
    print(f"Generating reverse lookup table for '{fname}' for {min_v} to {max_v}")

    result_x = []
    result_y = []
    for x in range(min_v,max_v):
        y = math.floor(func(float(x)))
        if y in result_y:
            continue
        else:
            result_y.append(y)
            result_x.append(x)
            # print(f" {y:>5}, {x:>5}")
    # plt.step(result_x, result_y)
    # plt.show()
    return zip(result_y, result_x)

with open('lib_dev/Math/rev_lookup_sqrt.dat', 'w') as lut_file:
    lut_vals = gen_reverse_lookup(math.sqrt, min_v=0, max_v=2**16-1)
    lut_len=0
    for y,x in lut_vals:
        # print(f" {y:>5}, {x:>5}")
        lut_file.write(byte_to_str(y))
        lut_file.write(byte_to_str(x>>8))
        lut_file.write(byte_to_str(x))
        lut_file.write('\n')
        lut_len += 3
    print(f"lut length: {lut_len} bytes")

# gen_reverse_lookup(lambda x:math.log(x), min_v=1, max_v=2**16-1)

