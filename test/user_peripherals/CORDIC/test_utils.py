from user_peripherals.CORDIC.fixed_point import *
import math 
from cocotb.triggers import ClockCycles
from enum import IntEnum

# When submitting your design, change this to the peripheral number
# in peripherals.v.  e.g. if your design is i_user_peri05, set this to 5.
# The peripheral number is not used by the test harness.
PERIPHERAL_NUM = 0

def to_u32(x: int) -> int:
    return x & 0xFFFFFFFF

def angle_to_rad(angle):
    return angle * math.pi / 180.

def assert_close(dut, name, pred, true, rtol=1e-3, atol=1e-3):
    
    dut._log.info(f"checking for {name} : predicted = {pred:.5f}, true = {true:.5f}, rtol={rtol}, atol={atol}")

    if not math.isfinite(pred) or not math.isfinite(true):
        raise AssertionError(f"{name}: non-finite value (pred={pred}, true={true})")
    if not (abs(pred - true) <= max(atol, rtol * abs(true))):
        raise AssertionError(f"{name}: {pred:.6g} vs {true:.6g} (rtol={rtol}, atol={atol})")    

# for checking trigonometric identities like cos^2(x) + sin^2(x) = 1
def assert_invariant(name, val, expected, tol=5e-3):
    if abs(val - expected) > tol:
        raise AssertionError(f"{name} invariant: {val:.6g} vs {expected:.6g} (tol={tol})")

def is_close_rtol(pred, true, r_tol = 1e-2):
    return abs(pred - true) / true < r_tol

def is_close_atol(pred, true, a_tol = 1e-2):
    return abs(pred - true)  < a_tol

def format_to_fixed_width(value, width):
    return format(value, f'0{width}b')


class Mode(IntEnum):
    CIRCULAR = 0
    LINEAR = 1
    HYPERBOLIC = 2

# BITS for mode
MODE_BITS           = 1
IS_ROTATING_BIT     = 3 


def pack_config(mode : Mode, is_rotating , start):
    v = 0
    v |= int(mode) << MODE_BITS
    v |= int(is_rotating) << IS_ROTATING_BIT
    v |= int(start) 
    return v

async def wait_done(dut,tqv, busy_val = 1, done_val = 2, 
                    status_addr=6, max_cycles_before_timeout=100):
    """ Poll status register until DONE or timeout. check BUSY"""
    
    await ClockCycles(dut.clk, 1)
    status = await tqv.read_byte_reg(status_addr)
    done_after = 1


    for _ in range(max_cycles_before_timeout):
        await ClockCycles(dut.clk, 1)
        done_after += 1
        status = await tqv.read_byte_reg(status_addr)
        if status == done_val:
            return done_after

    raise TimeoutError(f"Timeout waiting for DONE status (status={status}).")

async def read_out_pair_signed(dut, tqv, width=16):
    out1 = await tqv.read_hword_reg(4)
    out2 = await tqv.read_hword_reg(5)
    
    out1 = out1 & 0b111111111111111111
    out2 = out2 & 0b111111111111111111

    return sign_extend(out1, width), sign_extend(out2, width)



async def test_sin_cos(dut, tqv, angle_deg, width=16, rtol=0.01, atol=0.01):
    
    angle_rad = angle_to_rad(angle_deg)
    angle_fixed_point = float_to_fixed(angle_rad, 16, 2)  # 16 bits, 2 integer bits
    dut._log.info(f"[CIRC ROT] angle={angle_deg:.3f}° rad={angle_rad:.6f} z={format_bin(angle_fixed_point, width)}")
    await tqv.write_word_reg(1, to_u32(angle_fixed_point))


    # configure the cordic : set the mode to ROTATING, CIRCULAR, and running
    # this corresponds to setting it to       {1'b1,,  2'b00,         1'b1 }    
    config_to_write = pack_config(Mode.CIRCULAR, is_rotating=1, start=1)    
    dut._log.info(f"Configuring CORDIC with {config_to_write:#04x} ({bin(config_to_write)}) (mode={int(Mode.CIRCULAR)}, is_rotating=1, start=1)")
    await tqv.write_byte_reg(0, config_to_write)
    
    done_after = await wait_done(dut, tqv, busy_val=1, done_val=2, status_addr=6, max_cycles_before_timeout=20)
    dut._log.info(f"Started CORDIC, done after {done_after} cycles")
    
    out1_raw, out2_raw = await read_out_pair_signed(dut, tqv, width=width)  
    
    # conver to floating point for easier comparison
    cos_predicted = fixed_to_float(out1_raw, 16, 2)
    sin_predicted = fixed_to_float(out2_raw, 16, 2)
    sin_true = math.sin(angle_rad)
    cos_true = math.cos(angle_rad)

    # Check outputs
    assert_close(dut, f"cos({angle_deg})", cos_predicted, cos_true, rtol=rtol, atol=atol)
    assert_close(dut, f"sin({angle_deg})", sin_predicted, sin_true, rtol=rtol, atol=atol)

    # Invariant check : cos(x)^2 + sin(x)^2 = 1.0
    assert_invariant("circular", cos_predicted*cos_predicted + sin_predicted*sin_predicted, 1.0, tol=5e-3)
    return out1_raw, out2_raw

async def test_sinh_cosh(dut, tqv, x, width=16, rtol=0.01, atol=0.01):

    angle_fixed_point = float_to_fixed(x, 16, 2)  # 16 bits, 2 integer bits
    dut._log.info(f"[HYPERBOLIC ROT] inp={x:.4f} z={format_bin(angle_fixed_point, width)}")
    await tqv.write_word_reg(1, to_u32(angle_fixed_point))

    # configure the cordic : set the mode to ROTATING, hyperbolic, and running
    # this corresponds to setting it to       {1'b1,  2'b10,         1'b1 }
    config_to_write = pack_config(Mode.HYPERBOLIC, is_rotating=1, start=1)
    dut._log.info(f"Configuring CORDIC with {config_to_write:#04x} ({bin(config_to_write)}) (mode={int(Mode.HYPERBOLIC)}, is_rotating=1, start=1)")
    await tqv.write_byte_reg(0, config_to_write)
   
    done_after = await wait_done(dut, tqv, busy_val=1, done_val=2, status_addr=6, max_cycles_before_timeout=20)
    dut._log.info(f"Started CORDIC, done after {done_after} cycles")

    out1_raw, out2_raw = await read_out_pair_signed(dut, tqv, width=width)  

    # conver to floating point for easier comparison
    cosh_predicted = fixed_to_float(out1_raw, 16, 2)
    sinh_predicted = fixed_to_float(out2_raw, 16, 2)
    sinh_true = math.sinh(x)
    cosh_true = math.cosh(x)

    # Check outputs
    assert_close(dut, f"cosh({x})", cosh_predicted, cosh_true, rtol=rtol, atol=atol)
    assert_close(dut, f"sinh({x})", sinh_predicted, sinh_true, rtol=rtol, atol=atol)

    # Invariant check : cosh^2(x) - sinh^2(x) = 1.0
    assert_invariant("hyperbolic", cosh_predicted*cosh_predicted - sinh_predicted*sinh_predicted, 1.0, tol=5e-3)
    return out1_raw, out2_raw

async def use_multiplication_mode_input_float(dut, tqv, a, b, alpha_one_position, 
                                              width=16, rtol=1e-2, atol=1e-3):
    
    XY_INT = width - alpha_one_position
    Z_INT = width - alpha_one_position

    A = float_to_fixed(a, width=width, integer_part=XY_INT)
    B = float_to_fixed(b, width=width, integer_part=Z_INT)

    await tqv.write_word_reg(1, to_u32(A))
    await tqv.write_word_reg(2, to_u32(B))
    await tqv.write_byte_reg(3, alpha_one_position)

    # configure the cordic : set the mode to ROTATING, LINEAR, and running
    # this corresponds to setting it to       {1'b1,,  2'b00,         1'b1 }
    
    config_to_write = pack_config(Mode.LINEAR, is_rotating=1, start=1) 
    dut._log.info(f"[LIN ROT MUL] a={a}, b={b}, A={format_bin(A,width)}, B={format_bin(B,width)}, alpha_pos={alpha_one_position}")
    dut._log.info(f"input to module is A={A}(float={a}, fixed={float_to_fixed(A, width, XY_INT)}), B={B}(float={b}, fixed={float_to_fixed(B, width, Z_INT)})")
    await tqv.write_byte_reg(0, config_to_write)
    
    await wait_done(dut, tqv)
   
    x_raw, y_raw = await read_out_pair_signed(dut, tqv, width=width)
    x_f = fixed_to_float(x_raw, width, XY_INT)
    y_f = fixed_to_float(y_raw, width, XY_INT)

    dut._log.info(f"in floating point a={a}, b={b}, prod={a * b}")
    dut._log.info(f"output from module is out1={x_raw}(float={x_f}, fixed=), out2={y_raw}(float={y_f})")

    prod_true = a * b

    # compare to
    assert_close(dut, f"mul({fixed_to_float(A, width, XY_INT)}, {fixed_to_float(B, width, Z_INT)})", x_f, prod_true, rtol=rtol, atol=atol)
    dut._log.info(f"\n")
    return x_raw, y_raw

async def use_division_mode_float_input(dut, tqv, a, b, alpha_one_position, width=16, tol_mode="rel", tol=0.01):

    XY_INT = width - alpha_one_position
    Z_INT  = width - alpha_one_position

    # compute b / a
    A = float_to_fixed(a, width=width, integer_part=XY_INT)
    B = float_to_fixed(b, width=width, integer_part=Z_INT) 

    dut._log.info(f"[LIN ROT MUL] a={a}, b={b}, A={format_bin(A,width)}, B={format_bin(B,width)}, alpha_pos={alpha_one_position}")
    dut._log.info(f"input to module is A={A}(float={a}, fixed={float_to_fixed(A, width, XY_INT)}), B={B}(float={b}, fixed={float_to_fixed(B, width, Z_INT)})")    
    await tqv.write_word_reg(1, to_u32(A))
    await tqv.write_word_reg(2, to_u32(B))
    await tqv.write_byte_reg(3, alpha_one_position)
    
    cfg = pack_config(Mode.LINEAR, is_rotating=0, start=1)

    dut._log.info(f"[LIN VEC DIV] a={a}, b={b}, A={format_bin(A,width)}, B={format_bin(B,width)}, alpha_pos={alpha_one_position}")
    await tqv.write_byte_reg(0, cfg)
    await wait_done(dut, tqv)
    
    x_raw, y_raw = await read_out_pair_signed(dut, tqv, width=width)
    x_f = fixed_to_float(x_raw, width, XY_INT)
    y_f = fixed_to_float(y_raw, width, XY_INT)
    
    div_true = b / a

    dut._log.info(f"in floating point a={a}, b={b}, div={b/a}")
    dut._log.info(f"output from module is out1={x_raw}(float={x_f}, fixed=), out2={y_raw}(float={y_f})")
    
    # compare against output
    assert_close(dut, f"div({fixed_to_float(B, width, Z_INT)}, {fixed_to_float(A, width, XY_INT)})", x_f, div_true, rtol=tol if tol_mode=="rel" else 0, atol=tol if tol_mode=="abs" else 0)
    dut._log.info(f"\n")
    return x_raw, y_raw

async def test_vectoring_hyperbolic(dut, tqv, a, b, alpha_one_position, 
                                    width=16, XY_INT=5, Z_INT=5, rtol=1e-2, atol=1e-3):

    x_float = float_to_fixed(a, 16, XY_INT)  # 16 bits, 5 integer bits
    y_float = float_to_fixed(b, 16, Z_INT)   # 16 bits, 5 integer bits

    # write the valeus 
    await tqv.write_word_reg(1, to_u32(x_float))
    await tqv.write_word_reg(2, to_u32(y_float))

    # configure the cordic : set the mode to Vectoring, Hyperbolic, and running
    # this corresponds to setting it to       {1'b0,  2'b10,         1'b1 }    
    dut._log.info(f"[HYP VEC] a={a}, b={b}, A={format_bin(x_float,width)}, B={format_bin(y_float,width)}, alpha_pos={alpha_one_position}")

    # configure the cordic : set the mode to HYPERBOLIC, VECTORING, and running
    # this corresponds to setting it to       {1'b0,,  2'b10,         1'b1 }    
    config_to_write = pack_config(Mode.HYPERBOLIC, is_rotating=0, start=1)    
    dut._log.info(f"Configuring CORDIC with {config_to_write:#04x} ({bin(config_to_write)}) (mode={int(Mode.HYPERBOLIC)}, is_rotating=0, start=1)")
    await tqv.write_byte_reg(0, config_to_write)

    done_after = await wait_done(dut, tqv, busy_val=1, done_val=2, status_addr=6, max_cycles_before_timeout=20)
    dut._log.info(f"Started CORDIC, done after {done_after} cycles")

    out1_raw, out2_raw = await read_out_pair_signed(dut, tqv, width=width)  

    # convert to floating point for easier comparison
    out1_float = fixed_to_float(out1_raw, 16, width=width)
    out2_float = fixed_to_float(out2_raw, 16, width=width)

    return  out1_raw, out1_float, out2_raw, out2_float

async def _run_vectoring_once(dut, tqv, x_float, y_float, WIDTH=16, XY_INT=5):
    
    A = float_to_fixed(x_float, WIDTH, XY_INT)
    B = float_to_fixed(y_float, WIDTH, XY_INT)
    
    await tqv.write_word_reg(1, to_u32(A)) # write first input 
    await tqv.write_word_reg(2, to_u32(B)) # write second input
    
    # Configure Hyperbolic Vectoring mode
    cfg = pack_config(Mode.HYPERBOLIC, is_rotating=0, start=1)
    await tqv.write_byte_reg(0, cfg)
    await wait_done(dut, tqv)
    
    # read results 
    out1_raw, out2_raw = await read_out_pair_signed(dut, tqv, width=WIDTH)
    
    r_out = fixed_to_float(out1_raw, WIDTH, XY_INT)  # decode with XY format
    z_out = fixed_to_float(out2_raw, WIDTH, 2)   # decode with Z format (Q2.14)
    return r_out, z_out, out1_raw, out2_raw