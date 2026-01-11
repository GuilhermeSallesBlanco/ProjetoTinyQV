# SPDX-FileCopyrightText: © 2025 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from tqv import TinyQV
from user_peripherals.CORDIC.fixed_point import *
import math 
from user_peripherals.CORDIC.test_utils import use_multiplication_mode_input_float, use_division_mode_float_input
import random

# When submitting your design, change this to the peripheral number
# in peripherals.v.  e.g. if your design is i_user_peri05, set this to 5.
# The peripheral number is not used by the test harness.
PERIPHERAL_NUM = 12

@cocotb.test()
async def test_multiplication(dut):
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

    # Check the magic value and if its ready
    val = await tqv.read_word_reg(0)
    assert val == 0xBADCaffe, "reg0 should return magic 0xBADCaffe"
    assert await tqv.read_byte_reg(6) == 0, "status must be READY (0)"
    
    # DUT numeric formats
    WIDTH = 16
    XY_INT = 5   # out1/out2 integer bits for X/Y domain
    Z_INT  = 5   # Z integer bits (if used by DUT)
    FRAC   = WIDTH - XY_INT
    LSB    = 2**(-(WIDTH- XY_INT))
    
    # alpha-one bit position to test
    alpha_positions = [9,10,11]
    
    # Basic vectors of hand-picked cases
    cases = [
        (0.0, 0.0),
        (0.0, 3.25),
        (1.0, 5.5),
        (-1.0, 5.5),
        (0.5, -3.75),
        (-2.0, -2.0),
        (1.25, 2.5),
        (0.75, 2.0),
        (1.1, 0.341),
        (3.0, 3.0),           
        (0.125, 0.512),
    ]
    
    # per case checks 
    for a, b in cases:
        for alpha in alpha_positions:
            # check the testcase
            xr, yr = await use_multiplication_mode_input_float(dut, tqv, a, b, alpha, width=WIDTH, rtol=1e-2, atol=1e-2)
            
            # Commutativity check 
            xr2, yr2 = await use_multiplication_mode_input_float(dut, tqv, b, a, alpha, width=WIDTH, rtol=1e-2, atol=1e-2)


    # randomized property tests (but fix seed to make CI deterministic)
    random.seed(1234)
    checks = 20
    
    for i in range(checks):
        a = random.uniform(-4.0, 4.0)
        b = random.uniform(-4.0, 4.0)
        
        for alpha in alpha_positions:
            # check the testcase
            xr, yr = await use_multiplication_mode_input_float(dut, tqv, a, b, alpha, width=WIDTH, rtol=1e-2, atol=1e-2)
            
            # Commutativity check 
            xr2, yr2 = await use_multiplication_mode_input_float(dut, tqv, b, a, alpha, width=WIDTH, rtol=1e-2, atol=1e-2)

@cocotb.test()
async def test_division(dut):
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

    # Check the magic value and if its ready
    val = await tqv.read_word_reg(0)
    assert val == 0xBADCaffe, "reg0 should return magic 0xBADCaffe"
    assert await tqv.read_byte_reg(6) == 0, "status must be READY (0)"
    
    # DUT numeric formats
    WIDTH = 16
    XY_INT = 5   # out1/out2 integer bits for X/Y domain
    Z_INT  = 5   # Z integer bits (if used by DUT)
    FRAC   = WIDTH - XY_INT
    LSB    = 2**(-(WIDTH- XY_INT))
    
    
    alpha_one_position = 11
    # basic cases 
    basic = [
        (0.6, 1.5),
        (0.6, 2.0),
        (6.3, 9.12),
        (8.12, 11.22),
        (1.25, 2.5),
        (0.75, -2.25),
    ]
    
    for a, b in basic:
        
        xr, _ = await use_division_mode_float_input(dut, tqv, a, b, alpha_one_position,
                                                    width=WIDTH, tol=1e-2)
        q = fixed_to_float(xr, WIDTH, XY_INT)
        

    # randomized property tests (but fix seed to make CI deterministic)
    random.seed(42)
    for _ in range(40):
        a = random.uniform(0.5, 3.2)
        b = random.uniform(0.2, 5.0)
        xr, _ = await use_division_mode_float_input(dut, tqv, a, b, alpha_one_position,
                                                    width=WIDTH, tol=1e-2)
        q = fixed_to_float(xr, WIDTH, XY_INT)