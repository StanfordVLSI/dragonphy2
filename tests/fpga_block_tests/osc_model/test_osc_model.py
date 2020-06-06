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
SIMULATOR = 'vivado'

# DUT options
T_PER = 1e-9
DEL_PREC = 0.6e-12

# simulator options
TCLK = 1e-6
DELTA = 0.1*TCLK

@pytest.mark.parametrize('float_real', [False, True])
def test_osc_model(float_real):
    # declare circuit
    class dut(m.Circuit):
        name = 'test_osc_model'
        io = m.IO(
            clk_val=m.BitIn,
            dt_req=fault.RealIn,
            emu_dt=fault.RealOut,
            emu_clk=m.In(m.Clock),
            emu_rst=m.BitIn
        )

    # create the tester
    t = fault.Tester(dut, dut.emu_clk)

    # utility function for easier waveform debug
    def check_result(emu_dt=None, clk_val=None, abs_tol=DEL_PREC):
        t.delay((TCLK/2)-DELTA)
        t.poke(dut.emu_clk, 0)
        t.delay(TCLK/2)
        if emu_dt is not None:
            t.expect(dut.emu_dt, emu_dt, abs_tol=abs_tol)
        if clk_val is not None:
            t.expect(dut.clk_val, clk_val)
        t.poke(dut.emu_clk, 1)
        t.delay(DELTA)

    # initialize
    t.poke(dut.dt_req, 0.0)
    t.poke(dut.emu_clk, 0)
    t.poke(dut.emu_rst, 1)

    # apply reset
    t.poke(dut.emu_clk, 1)
    t.delay(TCLK/2)
    t.poke(dut.emu_clk, 0)
    t.delay(TCLK/2)

    # clear reset
    t.poke(dut.emu_rst, 0)

    # run a few cycles
    for _ in range(3):
        t.poke(dut.emu_clk, 1)
        t.delay(TCLK/2)
        t.poke(dut.emu_clk, 0)
        t.delay(TCLK/2)
    t.poke(dut.emu_clk, 1)
    t.delay(DELTA)

    # run main test
    # note that for this test:
    # t_del = 0.5e-9
    # t_lo = 0.4e-9
    # t_hi = 0.6e-9

    t.poke(dut.dt_req, 0.123e-9)
    check_result(0.123e-9, 0)

    t.poke(dut.dt_req, 0.234e-9)
    check_result(0.234e-9, 0)

    t.poke(dut.dt_req, 0.345e-9)
    check_result(0.143e-9, 1)

    t.poke(dut.dt_req, 0.456e-9)
    check_result(0.456e-9, 1)

    t.poke(dut.dt_req, 0.567e-9)
    check_result(0.144e-9, 0)

    t.poke(dut.dt_req, 0.678e-9)
    check_result(0.4e-9, 1)

    t.poke(dut.dt_req, 0.789e-9)
    check_result(0.6e-9, 0)

    # run the simulation
    defines = {
        'DT_WIDTH': 27,
        'DT_EXPONENT': -46
    }
    if float_real:
        defines['FLOAT_REAL'] = None
    t.compile_and_run(
        target='system-verilog',
        directory=BUILD_DIR,
        simulator=SIMULATOR,
        ext_srcs=[get_file('build/fpga_models/osc_model_core/osc_model_core.sv'),
                  get_file('tests/fpga_block_tests/osc_model/test_osc_model.sv')],
        inc_dirs=[get_svreal_header().parent, get_msdsl_header().parent],
        ext_model_file=True,
        defines=defines,
        parameters={'t_lo': 0.4e-9, 't_hi': 0.6e-9},
        disp_type='realtime'
    )