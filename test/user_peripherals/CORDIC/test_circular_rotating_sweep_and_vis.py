# SPDX-FileCopyrightText: © 2025 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from tqv import TinyQV
from user_peripherals.CORDIC.fixed_point import *
import math 
import numpy as np
from pathlib import Path

import os
import matplotlib
import matplotlib.pyplot as plt

from user_peripherals.CORDIC.test_utils import test_sin_cos

matplotlib.use("Agg")  # headless backend


# BITS for mode
MODE_BITS           = 1
CIRCULAR_MODE       = 0
LINEAR_MODE         = 1
HYPERBOLIC_MODE     = 2

# 
IS_ROTATING_BIT     = 3 

# When submitting your design, change this to the peripheral number
# in peripherals.v.  e.g. if your design is i_user_peri05, set this to 5.
# The peripheral number is not used by the test harness.
PERIPHERAL_NUM = 12

@cocotb.test()
async def test_trigonometric_sweep_and_vis(dut):
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
    dut._log.info("Test project behavior: Sweep of sine and cosine")

    # Test register write and read back
    value = await tqv.read_word_reg(0) 

    # read the identificator
    assert value == 0xbadcaffe, "when reading from reg 0, we should see magic string '0xbadcaffe'"

    # Check the status register : we don't yet run anything, it should be 0
    assert await tqv.read_byte_reg(6) == 0, "status register should be 0 (READY TO BE RUN)"
 
    # Fixed-point format for circular mode (Q2.14)
    WIDTH = 16
    INT_BITS = 2 
    FRAC_BITS = WIDTH - INT_BITS
    LSB = 2.0 ** (-FRAC_BITS)

    # Tolerances
    rtol = 1e-4
    atol = 1e-4
    
    # sweep angles in 1 degrees steps, inclusive
    degs = np.arange(-90., 91.0, 1.0)

    sin_true = np.sin(np.deg2rad(degs))
    cos_true = np.cos(np.deg2rad(degs))
    
    sins = []
    coss = []

    for ang in degs:
            # Runs the op + per-angle checks (incl. invariant)
            cos_raw, sin_raw = await test_sin_cos(dut, tqv, angle_deg=ang)
        
            
            # Read back produced values as float, to store for plots/metrics
            cos_pred = fixed_to_float(cos_raw, WIDTH, INT_BITS)
            sin_pred = fixed_to_float(sin_raw, WIDTH, INT_BITS)
            
            coss.append(cos_pred)
            sins.append(sin_pred)
             
    sins = np.array(sins)
    coss = np.array(coss)

    # Metrics
    sin_err = sins - sin_true
    cos_err = coss - cos_true
    mae_sin = float(np.mean(np.abs(sin_err)))
    mae_cos = float(np.mean(np.abs(cos_err)))
    rmse_sin = float(np.sqrt(np.mean(sin_err**2)))
    rmse_cos = float(np.sqrt(np.mean(cos_err**2)))
    maxerr_sin = float(np.max(np.abs(sin_err)))
    maxerr_cos = float(np.max(np.abs(cos_err)))

    # Unit-circle residual (should be ~0)
    unit_resid = coss**2 + sins**2 - 1.0
    rms_unit = float(np.sqrt(np.mean(unit_resid**2)))
    max_unit = float(np.max(np.abs(unit_resid)))

    dut._log.info("\n\n---- Summary of the sweep ----")
    dut._log.info(f"LSB = {LSB:.6g}")
    dut._log.info(f"MAE(sin)={mae_sin:.6g} : in LSBs {mae_sin/LSB:.3f}")
    dut._log.info(f"MAE(cos)={mae_cos:.6g} : in LSBs {mae_cos/LSB:.3f}")
    dut._log.info(f"RMSE(sin)={rmse_sin:.6g}) : in LSBs {rmse_sin/LSB:.3f}")
    dut._log.info(f"RMSE(cos)={rmse_cos:.6g} : in LSBs {rmse_cos/LSB:.3f}")
    dut._log.info(f"MAXERR(sin)={maxerr_sin:.6g} : in LSBs {maxerr_sin/LSB:.3f}")
    dut._log.info(f"MAXERR(cos)={maxerr_cos:.6g} : in LSBs {maxerr_cos/LSB:.3f}")
    dut._log.info(f"RMS(unit_resid)={rms_unit:.6g} : in LSBs {rms_unit/LSB:.3f}")
    dut._log.info(f"MAX(unit_resid)={max_unit:.6g} : in LSBs {max_unit/LSB:.3f}")

    # output directory for saving the artificats 
    OUTDIR = Path(os.getenv("CORDIC_PLOTS_DIR", os.getenv("GITHUB_WORKSPACE", "."))) / "artifacts/cordic"
    OUTDIR.mkdir(parents=True, exist_ok=True)

    # plot sine
    plt.figure(figsize=(14, 4))
    plt.subplot(1, 2, 1)
    plt.title(f"Sine Sweep: MAE={mae_sin:.5f}, RMSE={rmse_sin:.5f}")
    plt.plot(degs, sin_true, label="True sin")
    plt.plot(degs, sins, "--", label="CORDIC sin")
    plt.xlabel("Angle (deg)")
    plt.ylabel("sin(x)")
    plt.xticks(range(-90, 91, 15))
    plt.legend()
    plt.grid(True, alpha=0.3)

    # plot residual
    plt.subplot(1, 2, 2)
    plt.title("Residual: sin_pred - sin_true")
    plt.plot(degs, sin_err, label="Residual")
    plt.xlabel("Angle (deg)")
    plt.ylabel("Error")
    plt.xticks(range(-90, 91, 15))
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.savefig(OUTDIR / "sine.png", dpi=180, bbox_inches="tight")
    plt.close()

    # plot cosine
    plt.figure(figsize=(14, 4))
    plt.subplot(1, 2, 1)
    plt.title(f"Cosine Sweep: MAE={mae_cos:.5f}, RMSE={rmse_cos:.5f}")
    plt.plot(degs, cos_true, label="True cos")
    plt.plot(degs, coss, "--", label="CORDIC cos")
    plt.xlabel("Angle (deg)")
    plt.ylabel("cos(x)")
    plt.xticks(range(-90, 91, 15))
    plt.legend()
    plt.grid(True, alpha=0.3)
    
    # plot residual
    plt.subplot(1, 2, 2)
    plt.title("Residual: cos_pred - cos_true")
    plt.plot(degs, cos_err, label="Residual")
    plt.xlabel("Angle (deg)")
    plt.ylabel("Error")
    plt.xticks(range(-90, 91, 15))
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.savefig(OUTDIR / "cosine.png", dpi=180, bbox_inches="tight")
    plt.close()

    # Plot unit-circle residual
    plt.figure(figsize=(7, 4))
    plt.title(f"Unit-circle residual (cos²+sin²-1): RMS={rms_unit:.5e}, MAX={max_unit:.5e}")
    plt.plot(degs, unit_resid, label="cos²+sin²-1")
    plt.xlabel("Angle (deg)")
    plt.ylabel("Residual")
    plt.xticks(range(-90, 91, 15))
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.savefig(OUTDIR / "unit_circle_residual.png", dpi=180, bbox_inches="tight")
    plt.close()

    # CSVs
    np.savetxt(
        OUTDIR / "sine_vs_true.csv",
        np.c_[degs, sin_true, sins, sin_err],
        delimiter=",",
        header="deg,true_sin,cordic_sin,residual",
        comments=""
    )
    np.savetxt(
        OUTDIR / "cosine_vs_true.csv",
        np.c_[degs, cos_true, coss, cos_err],
        delimiter=",",
        header="deg,true_cos,cordic_cos,residual",
        comments=""
    )
    np.savetxt(
        OUTDIR / "unit_circle_residual.csv",
        np.c_[degs, unit_resid],
        delimiter=",",
        header="deg,cos2_plus_sin2_minus_1",
        comments=""
    )
    
    # fairly big mae tolerances
    assert mae_sin < 0.01, f"Mean absolute error (sin) should be < 0.01, is {mae_sin:.6g}"
    assert mae_cos < 0.01, f"Mean absolute error (cos) should be < 0.01, is {mae_cos:.6g}"

    # residual for invariant shouldn't be big
    assert max_unit < 0.03, f"Max unit-circle residual too large, is {max_unit:.6g}"