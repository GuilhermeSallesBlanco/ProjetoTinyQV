

def format_bin(n, bits=8):
    return format(n & (2**bits - 1), f'0{bits}b')

def signed_to_bin(value, width):
    return value & ((1 << width) - 1)

def simulate_overflow(a, width):
    mask = (1 << width) - 1
    a &= mask
    # sign-extend
    if a & (1 << (width - 1)):
        a -= (1 << width)
    return a

def fixed_add(a, b, width):
    result = a + b
    return simulate_overflow(result, width)

def fixed_sub(a, b, width):
    return fixed_add(a, -b, width)

def fixed_to_float(a, width, integer_part):
    # integer_part = number of integer bits including sign
    frac = width - integer_part
    return a / (2**frac)

def float_to_fixed(a, width, integer_part):
    frac = width - integer_part
    v = int(round(a * (2**frac)))
    return simulate_overflow(v, width)

def fixed_mul(a, b, width, integer_part):
    # integer_part = number of integer bits including sign for both operands
    frac = width - integer_part
    product = a * b
    product >>= frac
    return simulate_overflow(product, width)


def sign_extend(value, width): 
    if value & (1 << (width - 1)):
        value -= (1 << width)
    return value


