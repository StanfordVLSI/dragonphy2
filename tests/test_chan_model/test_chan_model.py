# general imports
import os
import pytest
from pathlib import Path

# AHA imports
import magma as m
import fault

# FPGA-specific imports
from svreal import get_svreal_header
from msdsl import get_msdsl_header

# DragonPHY imports
from dragonphy import get_file, Filter

BUILD_DIR = Path(__file__).resolve().parent / 'build'
SIMULATOR = 'ncsim' if 'FPGA_SERVER' not in os.environ else 'iverilog'

ABS_TOL = 0.02

DELTA = 100e-9
TPER = 1e-6

@pytest.mark.parametrize('float_real', [False, True])
def test_chan_model(float_real):
    # declare circuit
    class dut(m.Circuit):
        name = 'test_chan_model'
        io = m.IO(
            in_=fault.RealIn,
            out=fault.RealOut,
            out_valid=m.BitOut,
            dt_sig=fault.RealIn,
            clk=m.In(m.Clock),
            cke=m.BitIn,
            rst=m.BitIn
        )

    # create the t
    t = fault.Tester(dut, dut.clk)

    # utility function to cycle the clock in a way that produces more easily readable waveforms
    def check_output(out=None, out_valid=None, abs_tol=ABS_TOL):
        t.delay(TPER/2 - DELTA)
        t.poke(dut.clk, 0)
        t.delay(TPER/2)
        if out_valid is not None:
            t.expect(dut.out_valid, out_valid)
        t.poke(dut.clk, 1)
        t.delay(DELTA)
        if out is not None:
            t.expect(dut.out, out, abs_tol=abs_tol)

    # utility function to

    # initialize
    t.poke(dut.in_, 0.0)
    t.poke(dut.dt_sig, 0.0)
    t.poke(dut.clk, 0)
    t.poke(dut.cke, 0)
    t.poke(dut.rst, 1)

    # apply reset
    t.poke(dut.clk, 1)
    t.delay(TPER/2)
    t.poke(dut.clk, 0)
    t.delay(TPER/2)

    # clear reset
    t.poke(dut.rst, 0)
    t.poke(dut.clk, 1)
    t.delay(DELTA)

    # values
    val1 = +1.23
    val2 = -2.34
    val3 = +3.45

    # timesteps
    dt0 = 1e-9
    dt1 = 2e-9
    dt2 = 3e-9
    dt3 = 4e-9
    dt4 = 5e-9
    dt5 = 6e-9
    dt6 = 7e-9
    dt7 = 8e-9
    dt8 = 9e-9

    # compute expected outputs
    chan = Filter.from_file(get_file('build/adapt_fir/chan.npy'))
    f = chan.interp
    expt1 = 0
    expt2 = val1*f(dt2)
    expt3 = val1*f(dt2+dt3)
    expt4 = val1*f(dt2+dt3+dt4)
    expt5 = val1*(f(dt2+dt3+dt4+dt5)-f(dt5)) + val2*f(dt5)
    expt6 = val1*(f(dt2+dt3+dt4+dt5+dt6)-f(dt5+dt6)) + val2*f(dt5+dt6)
    expt7 = (val1*(f(dt2+dt3+dt4+dt5+dt6+dt7)-f(dt5+dt6+dt7))
             + val2*(f(dt5+dt6+dt7)-f(dt7))
             + val3*f(dt7))

    # action sequence
    t.poke(dut.cke, 0)
    t.poke(dut.dt_sig, dt0)
    t.poke(dut.in_, 0.0)
    check_output()

    t.poke(dut.cke, 1)
    t.poke(dut.dt_sig, dt1)
    t.poke(dut.in_, 0.0)
    check_output(expt1, 0)

    t.poke(dut.cke, 0)
    t.poke(dut.dt_sig, dt2)
    t.poke(dut.in_, val1)
    check_output(expt2, 0)

    t.poke(dut.cke, 0)
    t.poke(dut.dt_sig, dt3)
    t.poke(dut.in_, val1)
    check_output(expt3, 0)

    t.poke(dut.cke, 1)
    t.poke(dut.dt_sig, dt4)
    t.poke(dut.in_, val1)
    check_output(expt4, 0)

    t.poke(dut.cke, 0)
    t.poke(dut.dt_sig, dt5)
    t.poke(dut.in_, val2)
    check_output(expt5, 0)

    t.poke(dut.cke, 1)
    t.poke(dut.dt_sig, dt6)
    t.poke(dut.in_, val2)
    check_output(expt6, 0)

    t.poke(dut.cke, 0)
    t.poke(dut.dt_sig, dt7)
    t.poke(dut.in_, val3)
    check_output(expt7, 0)

    t.poke(dut.cke, 0)
    t.poke(dut.dt_sig, dt8)
    t.poke(dut.in_, val3)
    check_output()

    # run the simulation
    defines = {}
    if float_real:
        defines['FLOAT_REAL'] = None
    t.compile_and_run(
        target='system-verilog',
        directory=BUILD_DIR,
        simulator=SIMULATOR,
        ext_srcs=[get_file('build/fpga_models/chan_core.sv'),
                  get_file('tests/test_chan_model/test_chan_model.sv')],
        inc_dirs=[get_svreal_header().parent, get_msdsl_header().parent],
        ext_model_file=True,
        defines=defines,
        disp_type='realtime'
    )