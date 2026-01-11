# SPDX-FileCopyrightText: © 2025 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
import random
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from tqv import TinyQV

PERIPHERAL_NUM = 39 

# (Q,N) = (8,16) => 1 sign-bit + 7 integer-bits + 8 fractional-bits = 16 total-bits
#                    |S|IIIIIII|FFFFFFFF|
FRAC_BITS = 8
MASK16 = 0xFFFF
SIGN16 = 0x8000

def float_to_q8_8(val):
    q = int(round(val * (1 << FRAC_BITS)))
    return q & MASK16

def to_s16(u16):
    return u16 - (1 << 16) if (u16 & SIGN16) else u16

def wrap16(signed_val):
    return signed_val & MASK16

def hw_affine_q8_8(a, b, d, e, tx, ty, x, y):
    a, b, d, e, tx, ty, x, y = map(to_s16, (a, b, d, e, tx, ty, x, y))
    tmpx = a * x + b * y
    tmpy = d * x + e * y
    ox = (tmpx >> FRAC_BITS) + tx
    oy = (tmpy >> FRAC_BITS) + ty
    return wrap16(ox), wrap16(oy)

# Registers
ADDR_CONTROL    = 0x00
ADDR_A          = 0x08
ADDR_B          = 0x0C
ADDR_D          = 0x10
ADDR_E          = 0x14
ADDR_TX         = 0x18
ADDR_TY         = 0x1C
ADDR_XIN        = 0x20
ADDR_YIN        = 0x24
ADDR_XOUT       = 0x28
ADDR_YOUT       = 0x2C


async def dut_test(dut, tqv, desc, a, b, d, e, tx, ty, x, y):
    qa  = float_to_q8_8(a)
    qb  = float_to_q8_8(b)
    qd  = float_to_q8_8(d)
    qe  = float_to_q8_8(e)
    qtx = float_to_q8_8(tx)
    qty = float_to_q8_8(ty)
    qx  = float_to_q8_8(x)
    qy  = float_to_q8_8(y)

    await tqv.write_word_reg(ADDR_A, qa)
    await tqv.write_word_reg(ADDR_B, qb)
    await tqv.write_word_reg(ADDR_D, qd)
    await tqv.write_word_reg(ADDR_E, qe)
    await tqv.write_word_reg(ADDR_TX, qtx)
    await tqv.write_word_reg(ADDR_TY, qty)
    await tqv.write_word_reg(ADDR_XIN, qx)
    await tqv.write_word_reg(ADDR_YIN, qy)
    await tqv.write_word_reg(ADDR_CONTROL, 1)

    await ClockCycles(dut.clk, 200)


    out_x = (await tqv.read_word_reg(ADDR_XOUT)) & MASK16
    out_y = (await tqv.read_word_reg(ADDR_YOUT)) & MASK16

    exp_x, exp_y = hw_affine_q8_8(qa, qb, qd, qe, qtx, qty, qx, qy)

    assert out_x == exp_x, f"{desc}: X mismatch ({out_x:#06x} != {exp_x:#06x})"
    assert out_y == exp_y, f"{desc}: Y mismatch ({out_y:#06x} != {exp_y:#06x})"

    dut._log.info(f"[{desc}] pass (x={x}, y={y} -> {out_x:#06x},{out_y:#06x})")


@cocotb.test()
async def test_project(dut):
    dut._log.info("Starting affine transformation tests")
    
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    tqv = TinyQV(dut, PERIPHERAL_NUM)
    
    await tqv.reset()
    
    # Directed Test Cases
    await dut_test(dut, tqv, "Scale by2", 2, 0, 0, 2, 0, 0, 1.5, -2.25)
    await dut_test(dut, tqv, "Rotate 90", 0, -1, 1, 0, 0, 0, 1.5, -2.25)
    await dut_test(dut, tqv, "Reflect x", -1, 0, 0, 1, 0, 0, 1.5, -2.25)
    await dut_test(dut, tqv, "Reflect y", 1, 0, 0, -1, 0, 0, 1.5, -2.25)
    await dut_test(dut, tqv, "Shear xy", 1, 0.5, 0.5, 1, 0, 0, 1.5, -2.25)

    await dut_test(dut, tqv, "Scale half", 0.5, 0, 0, 0.5, 0, 0, 64.0, 64.0)
    await dut_test(dut, tqv, "Scale half frac", 0.5, 0, 0, 0.5, 0, 0, 10.5, -20.25)

    await dut_test(dut, tqv, "Rotate45 xaxis", 0.707, -0.707, 0.707, 0.707, 0, 0, 10.0, 0.0)
    await dut_test(dut, tqv, "Rotate45 yaxis", 0.707, -0.707, 0.707, 0.707, 0, 0, 0.0, 10.0)

    await dut_test(dut, tqv, "Shear1", 1.0, 0.3, 0.0, 1.0, 0, 0, 10.0, 5.0)
    await dut_test(dut, tqv, "Shear2", 1.0, 0.3, 0.0, 1.0, 0, 0, -20.0, 15.0)

    
    # Corner Cases
    await dut_test(dut, tqv, "Scale by2 zero", 2.0, 0, 0, 2.0, 0, 0, 0, 0)
    await dut_test(dut, tqv, "Scale by2 one", 2.0, 0, 0, 2.0, 0, 0, 1.0, 1.0)
    await dut_test(dut, tqv, "Scale by2 Frac", 2.0, 0, 0, 2.0, 0, 0, 1.5, -2.25)
    await dut_test(dut, tqv, "Scale by2 max positive", 2.0, 0, 0, 2.0, 0, 0, 127.0, 127.0)
    await dut_test(dut, tqv, "Scale by2 max negative", 2.0, 0, 0, 2.0, 0, 0, -128.0, -128.0)

    await dut_test(dut, tqv, "Rotate 90 zero", 0, -1.0, 1.0, 0, 0, 0, 0, 0)
    await dut_test(dut, tqv, "Rotate 90 one", 0, -1.0, 1.0, 0, 0, 0, 1.0, 1.0)
    await dut_test(dut, tqv, "Rotate 90 frac", 0, -1.0, 1.0, 0, 0, 0, 1.5, -2.25)
    await dut_test(dut, tqv, "Rotate 90 max positive", 0, -1.0, 1.0, 0, 0, 0, 127.0, 127.0)
    await dut_test(dut, tqv, "Rotate 90 max negative", 0, -1.0, 1.0, 0, 0, 0, -128.0, -128.0)

    await dut_test(dut, tqv, "ReflectX zero", -1.0, 0, 0, 1.0, 0, 0, 0, 0)
    await dut_test(dut, tqv, "ReflectX one", -1.0, 0, 0, 1.0, 0, 0, 1.0, 1.0)
    await dut_test(dut, tqv, "ReflectX frac", -1.0, 0, 0, 1.0, 0, 0, 1.5, -2.25)
    await dut_test(dut, tqv, "ReflectX max positive", -1.0, 0, 0, 1.0, 0, 0, 127.0, 127.0)
    await dut_test(dut, tqv, "ReflectX max negative", -1.0, 0, 0, 1.0, 0, 0, -128.0, -128.0)

    await dut_test(dut, tqv, "ReflectY zero", 1.0, 0, 0, -1.0, 0, 0, 0, 0)
    await dut_test(dut, tqv, "ReflectY one", 1.0, 0, 0, -1.0, 0, 0, 1.0, 1.0)
    await dut_test(dut, tqv, "ReflectY frac", 1.0, 0, 0, -1.0, 0, 0, 1.5, -2.25)
    await dut_test(dut, tqv, "ReflectY max positive", 1.0, 0, 0, -1.0, 0, 0, 127.0, 127.0)
    await dut_test(dut, tqv, "ReflectY max negative", 1.0, 0, 0, -1.0, 0, 0, -128.0, -128.0)

    await dut_test(dut, tqv, "ShearXY zero", 1.0, 0.5, 0.5, 1.0, 0, 0, 0, 0)
    await dut_test(dut, tqv, "ShearXY one", 1.0, 0.5, 0.5, 1.0, 0, 0, 1.0, 1.0)
    await dut_test(dut, tqv, "ShearXY frac", 1.0, 0.5, 0.5, 1.0, 0, 0, 1.5, -2.25)
    await dut_test(dut, tqv, "ShearXY max positive", 1.0, 0.5, 0.5, 1.0, 0, 0, 127.0, 127.0)
    await dut_test(dut, tqv, "ShearXY max negative", 1.0, 0.5, 0.5, 1.0, 0, 0, -128.0, -128.0)

    # Randomized Tests
    for i in range(40): 
        a  = random.uniform(-4.0, 4.0)
        b  = random.uniform(-4.0, 4.0)
        d  = random.uniform(-4.0, 4.0)
        e  = random.uniform(-4.0, 4.0)
        tx = random.uniform(-10.0, 10.0)
        ty = random.uniform(-10.0, 10.0)
        x  = random.uniform(-128.0, 127.0)
        y  = random.uniform(-128.0, 127.0)

        await dut_test(dut, tqv, f"Random-{i}", a, b, d, e, tx, ty, x, y)
        
    dut._log.info("All tests completed successfully!")