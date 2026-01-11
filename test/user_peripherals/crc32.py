# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from tqv import TinyQV
import zlib

PERIPHERAL_NUM = 27


# Compute CRC32 from zlib as reference
def ref_crc32(data_in):
    if isinstance(data_in, list):
        data_in = bytes(data_in)
    elif isinstance(data_in, str):
        data_in = data_in.encode('utf-8')
    
    return zlib.crc32(data_in) & 0xFFFFFFFF

# Reset the CRC32 computation status
async def clear_crc(tqv):
    await tqv.write_reg(0, 1)

# Input sequence of bytes to CRC32 peripheral and return computed CRC32 value
async def input_bytes(tqv, data_in):
    for byte in data_in:
        uint8 = byte & 0xFF
        await tqv.write_reg(1, uint8)
    await ClockCycles(tqv.dut.clk, len(data_in))  # Wait for processing

# Read 32-bit CRC32 computed value
async def read_CRC32(tqv):
    byte0 = await tqv.read_reg(2)
    byte1 = await tqv.read_reg(3)
    byte2 = await tqv.read_reg(4)
    byte3 = await tqv.read_reg(5)

    crc32 = (byte3 << 24) | (byte2 << 16) | (byte1 << 8) | byte0
    return crc32



@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock frequency to 64 Mhz
    clock = Clock(dut.clk, 15.624, units="ns")
    cocotb.start_soon(clock.start())

    tqv = TinyQV(dut, PERIPHERAL_NUM)

    # Reset
    await tqv.reset()

    dut._log.info("Test CRC32 peripheral")


    # 1. Check initial state after reset
    dut._log.info("Checking initial CRC32 value")
    initial_crc = await read_CRC32(tqv)
    expected_crc = ~0xFFFFFFFF & 0xFFFFFFFF     # Result in python is 0x00000000
    assert initial_crc == expected_crc, f"Initial CRC32 value should be {expected_crc:#08x}, got {initial_crc:#08x}"

    # 2. Test single byte
    dut._log.info("Testing single byte input")
    data_in = [0x12]
    await clear_crc(tqv)
    expected_crc = ref_crc32(data_in)
    await input_bytes(tqv, data_in)
    computed_crc = await read_CRC32(tqv)
    assert computed_crc == expected_crc, f"Computed CRC32 value should be {expected_crc:08x}, got {computed_crc:08x}"

    # 3. Test Clear functionality
    dut._log.info("Testing Clear functionality")
    await clear_crc(tqv)
    expected_crc = ~0xFFFFFFFF & 0xFFFFFFFF
    computed_crc = await read_CRC32(tqv)
    assert computed_crc == expected_crc, f"CRC32 value after clear should be {expected_crc:08x}, got {computed_crc}"

    # 4. Test Multi-byte sequence
    dut._log.info("Testing multi-byte input")
    data_in = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]
    await clear_crc(tqv)
    expected_crc = ref_crc32(data_in)
    await input_bytes(tqv, data_in)
    computed_crc = await read_CRC32(tqv)
    assert computed_crc == expected_crc, f"Computed CRC32 value should be {expected_crc:08x}, got {computed_crc}"
    
    # 5. Test all possible byte values
    dut._log.info("Testing all possible byte values")
    all_bytes = [byte for byte in range(256)]
    await clear_crc(tqv)
    expected_crc = ref_crc32(all_bytes)
    await input_bytes(tqv, all_bytes)
    computed_crc = await read_CRC32(tqv)
    assert computed_crc == expected_crc, f"Computed CRC32 value for all bytes should be {expected_crc:08x}, got {computed_crc}"



