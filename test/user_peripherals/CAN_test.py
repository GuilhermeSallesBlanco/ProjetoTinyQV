# SPDX-FileCopyrightText: © 2025 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb

PERIPHERAL_NUM = 7

from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from tqv import TinyQV

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 100 ns (10 MHz)
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    # Interact with your design's registers through this TinyQV class.
    # This will allow the same test to be run when your design is integrated
    # with TinyQV - the implementation of this class will be replaces with a
    # different version that uses Risc-V instructions instead of the SPI 
    # interface to read and write the registers.
    # tqv = TinyQV(dut)
    
    tqv = TinyQV(dut, PERIPHERAL_NUM)
    
    # Reset
    await tqv.reset()

    dut._log.info("Test project behavior")

    # Set an input value, in the example this will be added to the register value
    dut.ui_in.value = 2

    # Test register write ID, DATA0, DATA1, DLCF
    await tqv.write_word_reg(0x0, 0x92345678)  
    await tqv.write_word_reg(0x8, 0x67452301)  
    await tqv.write_word_reg(0xc, 0xefcdab89)  
    await tqv.write_word_reg(0x4, 0x00100108)  
    

    # Wait for two clock cycles to see the output values, because ui_in is synchronized over two clocks,
    # and a further clock is required for the output to propagate.
    await ClockCycles(dut.clk, 3000)
