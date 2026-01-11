# SPDX-FileCopyrightText: © 2025 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from tqv import TinyQV
from user_peripherals.CORDIC.fixed_point import *        # goes up to test/ then fixed_point.py
from user_peripherals.CORDIC.test_utils import test_sin_cos
import math 

# When submitting your design, change this to the peripheral number
# in peripherals.v.  e.g. if your design is i_user_peri05, set this to 5.
# The peripheral number is not used by the test harness.
PERIPHERAL_NUM = 12

def _isclose(pred, truth, rtol, atol):
    return abs(pred - truth) <= max(atol, rtol * abs(truth))

@cocotb.test()
async def test_trigonometric_basic(dut):
    dut._log.info("Start")

    # Set the clock period to 100 ns (10 MHz)
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    # Interact with your design's registers through this TinyQV class.
    # This will allow the same test to be run when your design is integrated
    # with TinyQV - the implementation of this class will be replaces with a
    # different version that uses Risc-V instructions instead of the SPI test
    # harness interface to read and write the registers.
    tqv = TinyQV(dut, PERIPHERAL_NUM)

    # Reset
    await tqv.reset()
    dut._log.info("Testing Project Behaviour : Test Trigonometric Simple ")

    # Test register write and read back
    value = await tqv.read_word_reg(0)
    assert value == 0xBADCaffe, "reg0 must return magic 0xBADCaffe"
    assert await tqv.read_byte_reg(6) == 0, "status should be 0 (READY)"
    
    # tolerances, sizes etc. 
    WIDTH = 16 
    INT_BITS = 2 # for circular mode, this is fixed format of Q2.14 
    FRAC_BITS = WIDTH - INT_BITS
    LSB = 2**(-FRAC_BITS)
    rtol = 1e-4
    atol = 1e-4
    
    # 1) compute few and well known simple values, using the CORDIC algorithm
    to_test = [90, 75, 60, 45, 30, 15, 0, -15, -30, -45, -60, -70, -90]
    
    max_abs_err_cos = float("-inf")
    max_abs_err_sin = float("-inf")
    
    for angle in to_test:
        cos_raw, sin_raw = await test_sin_cos(dut, tqv, angle_deg=angle)
        
        cos_pred = fixed_to_float(cos_raw, WIDTH, INT_BITS)
        sin_pred = fixed_to_float(sin_raw, WIDTH, INT_BITS)

        cos_true, sin_true = math.cos(math.radians(angle)), math.sin(math.radians(angle))
        max_abs_err_cos = max(max_abs_err_cos, abs(cos_pred - cos_true))
        max_abs_err_sin = max(max_abs_err_sin, abs(sin_pred - sin_true))
        
    dut._log.info(
        f"[summary] max |cos error|={max_abs_err_cos:.6g}, "
        f"max |sin error|={max_abs_err_sin:.6g}, LSB={LSB:.6g}")
    
    # 2) check for symmetry 
    rtol = 1e-3
    atol = 1e-3
    sym_angles = [15, 30, 45, 60, 75]
    for a in sym_angles:
        # +a
        cos_pos_raw, sin_pos_raw = await test_sin_cos(dut, tqv, angle_deg=a, width=WIDTH)
        cos_pred_pos = fixed_to_float(cos_pos_raw, WIDTH, INT_BITS)
        sin_pred_pos = fixed_to_float(sin_pos_raw, WIDTH, INT_BITS)

        # -a
        cos_neg_raw, sin_neg_raw = await test_sin_cos(dut, tqv, angle_deg=-a, width=WIDTH)
        cos_pred_neg = fixed_to_float(cos_neg_raw, WIDTH, INT_BITS)
        sin_pred_neg = fixed_to_float(sin_neg_raw, WIDTH, INT_BITS)

        assert _isclose(cos_pred_neg,  cos_pred_pos, rtol, atol), f"cos symmetry failed at {a}°"
        assert _isclose(sin_pred_neg, -sin_pred_pos, rtol, atol), f"sin oddness failed at {a}°"
        
    # 3) check boundaries and edges 
    angles = [-98, -0.01, 0, 0.01, 98]
    for angle in angles:
        cos_raw, sin_raw = await test_sin_cos(dut, tqv, angle_deg=angle)
        cos_pred = fixed_to_float(cos_raw, WIDTH, INT_BITS)
        sin_pred = fixed_to_float(sin_raw, WIDTH, INT_BITS)

        cos_true, sin_true = math.cos(math.radians(angle)), math.sin(math.radians(angle))
        assert _isclose(cos_pred, cos_true, rtol, atol), f"cos failed at {angle}°"
        assert _isclose(sin_pred, sin_true, rtol, atol), f"sin failed at {angle}°"