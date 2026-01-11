# SPDX-FileCopyrightText: © 2025 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from tqv import TinyQV
from user_peripherals.CORDIC.fixed_point import *
import math 
from user_peripherals.CORDIC.test_utils import test_vectoring_hyperbolic, _run_vectoring_once
import numpy as np 
import matplotlib.pyplot as plt
import os 
from pathlib import Path

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

    # Reset
    await tqv.reset()

    dut._log.info("Start square root via hyperbolic vectoring")
    
    # Test register write and read back
    value = await tqv.read_word_reg(0) 

    # read the identificator
    assert value == 0xbadcaffe, "when reading from reg 0, we should see magic string '0xbadcaffe'"

    # Check the status register : we don't yet run anything, it should be 0
    assert await tqv.read_byte_reg(6) == 0, "status register should be 0 (READY TO BE RUN)"
    
    
    WIDTH = 16
    XY_INT = 5
    Z_INT = 2
    K_m1 = 0.82816
    K = 1 / K_m1

    # Sweep s in [0.5, 10], avoid s=0 singularity for z
    s = np.linspace(0.5, 10.0, 120, dtype=np.float64)
    r_true = 2.0 * np.sqrt(s)           # sqrt(x^2 - y^2) = 2*sqrt(s)
    z_true = 0.5 * np.log(s)            # atanh((s-1)/(s+1)) = 0.5*ln(s)

    r_meas = []
    z_meas = []
        
    for val in s:
        x, y = (val + 1.0), (val - 1.0)
        r_out, z_out, *_ = await _run_vectoring_once(dut, tqv, x, y, WIDTH=WIDTH, XY_INT=XY_INT)
        # Normalize r to the true magnitude r = 2*sqrt(s)
        r_norm = K * r_out
        r_meas.append(r_norm)
        z_meas.append(z_out)

        dut._log.info(f"Input: {x}, {y} | Output: {r_norm}, {z_out}")
        

    r_meas = np.array(r_meas)
    z_meas = np.array(z_meas)

    # Metrics
    err_r = r_meas - r_true
    err_z = z_meas - z_true
    mae_r = float(np.mean(np.abs(err_r)))
    mae_z = float(np.mean(np.abs(err_z)))
    max_r = float(np.max(np.abs(err_r)))
    max_z = float(np.max(np.abs(err_z)))

    dut._log.info(f"sqrt(s) MAE={mae_r:.6g}, MAX={max_r:.6g}")
    dut._log.info(f"|z=0.5ln(s) MAE={mae_z:.6g}, MAX={max_z:.6g}")

    OUTDIR = Path(os.getenv("CORDIC_PLOTS_DIR", os.getenv("GITHUB_WORKSPACE", "."))) / "artifacts/cordic"
    OUTDIR.mkdir(parents=True, exist_ok=True)

    plt.figure(figsize=(14, 4))
    plt.subplot(1, 2, 1)
    plt.title(f"2*sqrt(s) from vectoring  (MAE={mae_r:.5f})")
    plt.plot(s, r_true, label="True 2*sqrt(s)")
    plt.plot(s, r_meas, "--", label="CORDIC (normalized)")
    plt.xlabel("s"); plt.ylabel("2*sqrt(s)"); plt.legend(); plt.grid(True, alpha=0.3)

    plt.subplot(1, 2, 2)
    plt.title("Residual: (2*sqrt(s))_pred - (2*sqrt(s))_true")
    plt.plot(s, err_r, label="Residual")
    plt.xlabel("s")
    plt.ylabel("Error")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(OUTDIR / "sqrt.png", dpi=180, bbox_inches="tight")
    plt.close()

    plt.figure(figsize=(14, 4))
    plt.subplot(1, 2, 1)
    plt.title("z output vs 0.5*ln(s)")
    plt.plot(s, z_true, label="0.5*ln(s)")
    plt.plot(s, z_meas, "--", label="CORDIC z")
    plt.xlabel("s")
    plt.ylabel("z")
    plt.legend()
    plt.grid(True, alpha=0.3)

    plt.subplot(1, 2, 2)
    plt.title("Residual: z_pred - 0.5*ln(s)")
    plt.plot(s, err_z, label="Residual")
    plt.xlabel("s")
    plt.ylabel("Error")
    plt.legend()
    plt.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(OUTDIR / "ln.png", dpi=180, bbox_inches="tight")
    plt.close()

    # CSVs
    np.savetxt(OUTDIR / "sqrt_vs_true.csv",
               np.c_[s, r_true, r_meas, err_r],
               delimiter=",", header="s,2sqrt_s,true_norm,err", comments="")
    np.savetxt(OUTDIR / "z_vs_half_ln_s.csv",
               np.c_[s, z_true, z_meas, err_z],
               delimiter=",", header="s,0.5lns,cordic_z,err", comments="")

    assert mae_r < 0.01,  "Mean abs error for 2*sqrt(s) too large"
    assert max_r < 0.05,  "Max error for 2*sqrt(s) too large"
    assert mae_z < 0.02,  "Mean abs error for z=0.5*ln(s) too large"