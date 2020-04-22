# general imports
import os
import numpy as np
import pytest
import shutil
from pathlib import Path

# AHA imports
import fault
import magma as m

# DragonPHY-specific imports
from dragonphy import get_file

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'
if shutil.which('iverilog'):
    SIMULATOR = 'iverilog'
elif 'FPGA_SERVER' in os.environ:
    SIMULATOR = 'vivado'
else:
    SIMULATOR = 'ncsim'

@pytest.mark.parametrize((), [pytest.param(marks=pytest.mark.slow) if SIMULATOR=='vivado' else ()])
def test_sim(n_prbs=7):
    # declare circuit
    class dut(m.Circuit):
        name = 'prbs_generator'
        io = m.IO(
            clk=m.ClockIn,
            rst=m.BitIn,
            cke=m.BitIn,
            init_val=m.In(m.Bits[n_prbs]),
            out=m.BitOut
        )

    # create tester
    t = fault.Tester(dut, dut.clk)

    # initialize
    t.poke(dut.clk, 0)
    t.poke(dut.rst, 1)
    t.poke(dut.cke, 1)
    t.poke(dut.init_val, 1)
    t.step(2)

    # get output values
    out_vals = []
    t.poke(dut.rst, 0)
    for _ in range((1<<n_prbs)-1):
        out_vals.append(t.get_value(dut.out))
        t.step(2)

    # run the test
    t.compile_and_run(
        target='system-verilog',
        simulator=SIMULATOR,
        ext_libs=[get_file('vlog/new_chip_src/prbs/prbs_generator.sv')],
        parameters={'n_prbs': n_prbs},
        ext_model_file=True,
        disp_type='realtime',
        dump_waveforms=False,
        directory=BUILD_DIR
    )

    # get output values (uncomment lines below to generate balanced, but non-random data)
    out_vals = [out_val.value for out_val in out_vals]
    # out_vals = np.repeat([0, 1], len(out_vals) // 2)
    # out_vals = np.tile([0, 1], len(out_vals) // 2)

    # convert output values to a numpy array
    out_vals = np.array(out_vals, dtype=float)

    # check properties
    ratio = np.sum(out_vals) / len(out_vals)
    print(f"Chance of getting a '1': {ratio}")
    assert 0.49 <= ratio <= 0.51, 'PRBS is unbalanced.'

    # remove the mean to avoid an offset (signal will now be +/- 0.5)
    no_mean = out_vals - np.mean(out_vals)
    # compute the full autocorrelation
    corr = np.correlate(no_mean, no_mean, 'full')
    # look at half the autocorrelation (so index 0 is completely aligned)
    corr = corr[len(corr) // 2 :]
    # discard first point
    corr = corr[1:]
    # compute peak correlation as a fraction of the theoretical peak correlation
    pk_corr = np.max(np.abs(corr))
    pk_corr_rel = pk_corr / (len(out_vals) / 4)

    # check the randomness
    print(f'Auto-correlation score (0.0-1.0; lower is better): {pk_corr_rel}')
    assert pk_corr_rel < 0.15, 'PRBS is not sufficiently random'