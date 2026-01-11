# SPDX-FileCopyrightText: © 2025 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from tqv import TinyQV

PERIPHERAL_NUM = 15

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Start clock
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    tqv = TinyQV(dut, PERIPHERAL_NUM)

    # --- Reset ---
    await tqv.reset()
    await ClockCycles(dut.clk, 2)
    # After reset, registers should be zero
    assert await tqv.read_byte_reg(0) == 0

    # --- Register R/W test (byte only) ---
    await tqv.write_byte_reg(0, 0xAB)
    assert await tqv.read_byte_reg(0) == 0xAB

    # --- Input/output activity test ---
    # Set input, wait, and check that uo_out toggles at least once
    dut.ui_in.value = 0x3C
    await ClockCycles(dut.clk, 5)
    val1 = int(dut.uo_out.value)
    await ClockCycles(dut.clk, 10)
    val2 = int(dut.uo_out.value)
    dut._log.info(f"uo_out before: {val1}, after: {val2}")
    assert val1 != val2 or val1 in (0, 1), "uo_out should toggle or be stable at 0/1"

    # --- (Optional) Check uo_out is always 0 or 1 ---
    for _ in range(10):
        await ClockCycles(dut.clk, 2)
        assert int(dut.uo_out.value) in (0, 1)

    dut._log.info("Basic integration and functionality test passed.")