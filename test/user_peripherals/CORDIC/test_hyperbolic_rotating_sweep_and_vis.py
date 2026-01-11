# SPDX-FileCopyrightText: © 2025 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from tqv import TinyQV
from user_peripherals.CORDIC.fixed_point import *
import math 
import numpy as np 
import matplotlib.pyplot as plt 
import os 
from pathlib import Path

from user_peripherals.CORDIC.fixed_point import fixed_to_float
from user_peripherals.CORDIC.test_utils import test_sinh_cosh

# When submitting your design, change this to the peripheral number
# in peripherals.v.  e.g. if your design is i_user_peri05, set this to 5.
# The peripheral number is not used by the test harness.
PERIPHERAL_NUM = 12

@cocotb.test()
async def test_hyperbolic_sweep_and_vis(dut):
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

    # Test register write and read back
    value = await tqv.read_word_reg(0) 

    # read the identificator
    assert value == 0xbadcaffe, "when reading from reg 0, we should see magic string '0xbadcaffe'"

    # Check the status register : we don't yet run anything, it should be 0
    assert await tqv.read_byte_reg(6) == 0, "status register should be 0 (READY TO BE RUN)"

    # Fixed-point format for hyperbolic rotating mode (Q2.14)
    WIDTH = 16
    INT_BITS = 2
    FRAC_BITS = WIDTH - INT_BITS
    LSB = 2.0 ** (-FRAC_BITS)

    # Per-point tolerances (used inside helper): a few LSBs abs + modest rtol
    rtol = 1e-3
    atol = 1e-3
    
    # Sweep the valid domain inclusively
    xs = np.linspace(-1.1161, 1.1161, 225, dtype=np.float64)
    sinh_true = np.sinh(xs)
    cosh_true = np.cosh(xs)

    sinh_vals = []
    cosh_vals = []
    
    
    for x in xs:
        # Runs op + asserts cosh/sinh against truth + invariant check
        out1_raw, outw_raw = await test_sinh_cosh(dut, tqv, float(x), width=WIDTH, rtol=rtol, atol=atol)
        # Read back floats for metrics/plots
        cosh_pred = fixed_to_float(out1_raw, 16, 2) 
        sinh_pred = fixed_to_float(outw_raw, 16, 2)

        cosh_vals.append(cosh_pred)
        sinh_vals.append(sinh_pred)

    cosh_vals = np.array(cosh_vals, dtype=np.float64)
    sinh_vals = np.array(sinh_vals, dtype=np.float64)

    # Metrics
    err_sinh = sinh_vals - sinh_true
    err_cosh = cosh_vals - cosh_true
    mae_sinh = float(np.mean(np.abs(err_sinh)))
    mae_cosh = float(np.mean(np.abs(err_cosh)))
    rmse_sinh = float(np.sqrt(np.mean(err_sinh**2)))
    rmse_cosh = float(np.sqrt(np.mean(err_cosh**2)))
    maxerr_sinh = float(np.max(np.abs(err_sinh)))
    maxerr_cosh = float(np.max(np.abs(err_cosh)))

    # Hyperbolic invariant residual: cosh^2 - sinh^2 - 1
    invariant_resid = cosh_vals**2 - sinh_vals**2 - 1.0
    rms_invariant = float(np.sqrt(np.mean(invariant_resid**2)))
    max_invariant = float(np.max(np.abs(invariant_resid)))

    dut._log.info(f"MAE(sinh)={mae_sinh:.6g}")
    dut._log.info(f"MAE(cosh)={mae_cosh:.6g}")
    dut._log.info(f"RMSE(sinh)={rmse_sinh:.6g}") 
    dut._log.info(f"RMSE(cosh)={rmse_cosh:.6g}")
    dut._log.info(f"MAXERR(sinh)={maxerr_sinh:.6g}")
    dut._log.info(f"MAXERR(cosh)={maxerr_cosh:.6g}")
    dut._log.info(f"RMS(cosh^2-sinh^2-1)={rms_invariant:.6g}, MAX(...)={max_invariant:.6g}, LSB={LSB:.6g}")

    # Artifacts dir
    OUTDIR = Path(os.getenv("CORDIC_PLOTS_DIR", os.getenv("GITHUB_WORKSPACE", "."))) / "artifacts/cordic"
    OUTDIR.mkdir(parents=True, exist_ok=True)

    # make sinh plot
    plt.figure(figsize=(14, 4))
    plt.subplot(1, 2, 1)
    plt.title(f"Sinh Sweep: MAE={mae_sinh:.5f}, RMSE={rmse_sinh:.5f}")
    plt.plot(xs, sinh_true, label="True sinh")
    plt.plot(xs, sinh_vals, "--", label="CORDIC sinh")
    plt.xlabel("x")
    plt.ylabel("sinh(x)")
    plt.legend()
    plt.grid(True, alpha=0.3)

    # make plot for sinh residual 
    plt.subplot(1, 2, 2)
    plt.title("Residual: sinh_pred - sinh_true")
    plt.plot(xs, err_sinh, label="Residual")
    plt.xlabel("x")
    plt.ylabel("Error")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.savefig(OUTDIR / "sinh.png", dpi=180, bbox_inches="tight")
    plt.close()
    
    # make cosh plot
    plt.figure(figsize=(14, 4))
    plt.subplot(1, 2, 1)
    plt.title(f"Cosh Sweep: MAE={mae_cosh:.5f}, RMSE={rmse_cosh:.5f}")
    plt.plot(xs, cosh_true, label="True cosh")
    plt.plot(xs, cosh_vals, "--", label="CORDIC cosh")
    plt.xlabel("x")
    plt.ylabel("cosh(x)")
    plt.legend()
    plt.grid(True, alpha=0.3)

    # make plot for cosh residual
    plt.subplot(1, 2, 2)
    plt.title("Residual: cosh_pred - cosh_true")
    plt.plot(xs, err_cosh, label="Residual")
    plt.xlabel("x")
    plt.ylabel("Error")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.savefig(OUTDIR / "cosh.png", dpi=180, bbox_inches="tight")
    plt.close()

    # Invariant plot
    plt.figure(figsize=(7, 4))
    plt.title(f"Hyperbolic invariant: cosh²-sinh²-1  (RMS={rms_invariant:.5e}, MAX={max_invariant:.5e})")
    plt.plot(xs, invariant_resid, label="Residual")
    plt.xlabel("x")
    plt.ylabel("Residual")
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.savefig(OUTDIR / "hyperbolic_invariant.png", dpi=180, bbox_inches="tight")
    plt.close()

    # CSVs
    np.savetxt(OUTDIR / "sinh_vs_true.csv",
               np.c_[xs, sinh_true, sinh_vals, err_sinh],
               delimiter=",", header="x,true_sinh,cordic_sinh,residual", comments="")
    np.savetxt(OUTDIR / "cosh_vs_true.csv",
               np.c_[xs, cosh_true, cosh_vals, err_cosh],
               delimiter=",", header="x,true_cosh,cordic_cosh,residual", comments="")
    np.savetxt(OUTDIR / "hyperbolic_invariant.csv",
               np.c_[xs, invariant_resid],
               delimiter=",", header="x,cosh2_minus_sinh2_minus_1", comments="")

    # Reasonable thresholds (keep generous for CI; tighten later if you like)
    assert mae_sinh < 0.003, "Mean absolute error (sinh) too large"
    assert mae_cosh < 0.003, "Mean absolute error (cosh) too large"
    assert max_invariant < 0.03,  "Hyperbolic invariant residual too large"