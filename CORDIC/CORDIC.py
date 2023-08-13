from math import atan2, sqrt, sin, cos, pi, radians
from fxpmath import Fxp

ITERS = 10
N_WORD = 32
N_FRAC = 16
theta_table = [atan2(1, 2**i) for i in range(ITERS)]

def compute_K(n):
    """
    Compute K(n) for n = ITERS. This could also be
    stored as an explicit constant if ITERS above is fixed.
    """
    k = 1.0
    for i in range(n):
        k *= 1 / sqrt(1 + 2 ** (-2 * i))
    return k

def CORDIC(alpha, n):
    K_n = compute_K(n)
    theta = 0.0
    x = 1.0
    y = 0.0
    P2i = 1  # This will be 2**(-i) in the loop below
    for arc_tangent in theta_table:
        sigma = +1 if theta < alpha else -1
        theta += sigma * arc_tangent
        x, y = x - sigma * y * P2i, sigma * P2i * x + y
        P2i /= 2
    return x * K_n, y * K_n

if __name__ == "__main__":
    # Print a table of computed sines and cosines, from -90° to +90°, in steps of 15°,
    # comparing against the available math routines.
    print("  x       sin(x)     diff. sine     cos(x)    diff. cosine ")
    for x in range(-90, 91, 15):
        cos_x, sin_x = CORDIC(radians(x), ITERS)
        print(
            f"{x:+05.1f}°  {sin_x:+.8f} ({sin_x-sin(radians(x)):+.8f}) {cos_x:+.8f} ({cos_x-cos(radians(x)):+.8f})"
        )

    print("  n    K  ")
    for n in range (1,40):
        print(f" {n: <3}  {compute_K(n)} {Fxp(compute_K(n), signed=True, n_word=N_WORD, n_frac=N_FRAC)}")

    print(Fxp(compute_K(5), signed=True, n_word=N_WORD, n_frac=N_FRAC).info(verbose=3))