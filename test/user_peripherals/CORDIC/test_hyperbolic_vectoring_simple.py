# SPDX-FileCopyrightText: © 2025 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from tqv import TinyQV
from user_peripherals.CORDIC.fixed_point import *
import math 
from user_peripherals.CORDIC.test_utils import test_vectoring_hyperbolic, _run_vectoring_once, assert_close
import numpy as np 
import random

# When submitting your design, change this to the peripheral number
# in peripherals.v.  e.g. if your design is i_user_peri05, set this to 5.
# The peripheral number is not used by the test harness.
PERIPHERAL_NUM = 12

@cocotb.test()
async def test_hyperbolic_vectoring_basic(dut):
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

    dut._log.info("Test project behavior")

    # Reset & ID
    await tqv.reset()
    value = await tqv.read_word_reg(0)
    assert value == 0xbadcaffe, "reg0 should return 0xbadcaffe"
    assert await tqv.read_byte_reg(6) == 0, "status must be READY (0)"
    
    # Formats
    WIDTH  = 16
    XY_INT = 5    # Q5.11 for X/Y/r
    Z_INT  = 2    # Q2.14 for Z

    K_m1 = 0.82816
    K = 1 / K_m1
    
    test_vectors = [
        (5.0, 4.0), 
        (3.0, 2.0), 
        (2.0, 1.0),
        (1.5, 1.0), 
        (1.25, 0.75),
        (1.75, -0.5), 
        (2.5, -1.0),
    ]
 
    for x, y in test_vectors:
        out1, out2, *_ = await _run_vectoring_once(dut, tqv, x, y, WIDTH=16, XY_INT=XY_INT)

        out1 *= K
        
        r_true = math.sqrt(x*x - y*y)
        z_true = math.atanh(y/x)
        
        s = f"{x}^2 + {y}^2"
        assert_close(dut, "testing R = \sqrt{" + s + "}", out1, r_true,  rtol=1e-3, atol=2e-3)
        assert_close(dut, "testing Z = atanh(" + str(y) + "/" + str(x) + ")", out2, z_true, rtol=1e-3, atol=2e-3)        
    