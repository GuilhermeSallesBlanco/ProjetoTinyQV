# SPDX-FileCopyrightText: © 2025 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from tqv import TinyQV
from user_peripherals.CORDIC.fixed_point import *
import math 
from user_peripherals.CORDIC.fixed_point import fixed_to_float
from user_peripherals.CORDIC.test_utils import test_sinh_cosh  
import numpy as np 

# When submitting your design, change this to the peripheral number
# in peripherals.v.  e.g. if your design is i_user_peri05, set this to 5.
# The peripheral number is not used by the test harness.
PERIPHERAL_NUM = 12

@cocotb.test()
async def test_hyperbolic_basic(dut):
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

    # Reset & sanity
    await tqv.reset()
    value = await tqv.read_word_reg(0)
    assert value == 0xbadcaffe, "reg0 must return magic 0xbadcaffe"
    assert await tqv.read_byte_reg(6) == 0, "status should be READY (0)"

    
    # fixed-point format for hyperbolic rotating mode (Q2.14)
    WIDTH = 16
    INT_BITS = 2
    LSB = 2.0 ** (-(WIDTH - INT_BITS))
    
    # few well known values with edge cases and bounds 
    tests = [0.0, math.log(2), -math.log(2),
             1.0, -1.0, math.log(3), -math.log(3),
             math.log(2)/2, -math.log(2)/2,
             1.10, -1.1, 
             1.115, -1.115]
    
    max_abs_err_cosh = 0.0
    max_abs_err_sinh = 0.0
    
    rtol = 1e-3
    atol = 1e-3

    for x in tests:
        # This runs the op and asserts:
        #   cosh ≈ truth, sinh ≈ truth, and cosh^2 - sinh^2 ≈ 1
        out1_raw, out2_raw = await test_sinh_cosh(dut, tqv, x, width=WIDTH, rtol=rtol, atol=atol)

        cosh_pred = fixed_to_float(out1_raw, 16, 2)
        sinh_pred = fixed_to_float(out2_raw, 16, 2)


        # Record actual errors for a run-wide summary (handy for CI logs)
        cosh_t, sinh_t = math.cosh(x), math.sinh(x)
        max_abs_err_cosh = max(max_abs_err_cosh, abs(cosh_pred - cosh_t))
        max_abs_err_sinh = max(max_abs_err_sinh, abs(sinh_pred - sinh_t))

    dut._log.info(
        f"[summary] max |cosh error|={max_abs_err_cosh:.6g}, "
        f"max |sinh error|={max_abs_err_sinh:.6g}, LSB={LSB:.6g}"
    )