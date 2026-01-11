# SPDX-FileCopyrightText: © 2025 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from tqv import TinyQV

import os
import random
from pathlib import Path

import numpy as np
from user_peripherals.npu.utils import *

# When submitting your design, change this to the peripheral number
# in peripherals.v.  e.g. if your design is i_user_peri05, set this to 5.
# The peripheral number is not used by the test harness.
PERIPHERAL_NUM = 4
FAST = int(os.getenv("FAST", 0)) # skip the mlp test
NCOLS = 1
NROWS = 4
ACC_WIDTH = 16

@cocotb.test()
async def test_project(dut):
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

    # test reading unscaled 16bits acc reg
    rv = random.randint(*dtype_to_bounds(ACC_WIDTH, True))
    await tqv.write_hword_reg(0x02, rv & (1 << ACC_WIDTH) - 1)
    assert as_signed([await tqv.read_hword_reg(0x02)], ACC_WIDTH)[0] == rv

    # quantized fully connected
    for _ in range(10):
        relu, output_zp, shamts = bool(random.getrandbits(1)), random.randint(-8, 7), np.random.randint(0, 31, size=(NCOLS,))
        bias = np.random.randint(*dtype_to_bounds(ACC_WIDTH, True), size=(NCOLS,), dtype=np.int16)
        qmuls = np.random.randint(0, (1 << ACC_WIDTH - 1) - 1, size=(NCOLS,), dtype=np.int16)
        w = np.random.randint(*dtype_to_bounds(4, True), size=(NROWS, NCOLS), dtype=np.int8)
        a = np.random.randint(*dtype_to_bounds(4, True), size=(1, NROWS), dtype=np.int8)
        expected = qfc(a, w, bias, output_zp, qmuls, shamts, relu=relu, width=4, signed=True)
        np.testing.assert_array_equal(await tb_qfc(tqv, a, w, bias, output_zp, qmuls, shamts,
            nrows=NROWS, ncols=NCOLS, acc_width=ACC_WIDTH, relu=relu, progress=False), expected)
                
@cocotb.test(skip=FAST)
async def test_mnist_mlp(dut):
    # baseline model accuracy
    # ==========================
    assetdir = Path(__file__).parent / "assets"
    model = NumpyModel(assetdir / "model.json", assetdir / "tensors.bin")

    _, _, x_test, y_test = fetch_mnist(assetdir)
    x_test = x_test.astype(np.float32) / 255.0
    x = resize_bilinear(x_test.reshape(-1, 28, 28), 12, 12)

    qmin, qmax = dtype_to_bounds(4, True)
    s, z = 1.0 / (qmax - qmin), qmin
    x = (x / s + z).astype(np.int8)

    y = model(x)
    correct = sum(y.argmax(axis=-1) == y_test)
    print(f"{correct}/{len(x_test)} correct predictions, {100.0 * correct / len(x_test):.0f}% accuracy")

    # cocotb inference of a single MNIST image
    # ========================================
    tqv = TinyQV(dut, PERIPHERAL_NUM)

    dut._log.info("Start")

    # Set the clock period to 100 ns (10 MHz)
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    await tqv.reset()

    tb_model = CocotbModel(tqv, assetdir / "model.json", assetdir / "tensors.bin", acc_width=ACC_WIDTH)
    amt = 4
    dut._log.info(f"Running inference of {amt} random mnist images")
    for idx in [random.randint(0, len(x) - 1) for _ in range(amt)]:
        display_image(((x[idx].reshape(-1) + 8) / 15) * 255, size=(12, 12))
        tb_y = await tb_model(x[idx])
        display_outputs(tb_y[0], y_test[idx])
        np.testing.assert_array_equal(tb_y[0], y[idx])
    # correct = sum(tb_y.argmax(axis=-1) == y_test) print(f"{correct}/{len(x_test)} correct predictions, {100.0 * correct / len(x_test):.0f}% accuracy")
