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

# DUT options
N_BITS = 9
T_PER = 250.0e-12
DEL_CODE = 50
DEL_PREC = 62.5e-12

# simulator options
TCLK = 1e-6
DELTA = 0.1*TCLK

@pytest.mark.parametrize('float_real', [False, True])
def test_clk_delay(simulator_name, float_real):
    # set defaults
    if simulator_name is None:
        simulator_name = 'vivado'

    # declare circuit
    class dut(m.Circuit):
        name = 'test_clk_delay'
        io = m.IO(
            code=m.In(m.Bits[N_BITS]),
            clk_i_val=m.BitIn,
            clk_o_val=m.BitOut,
            dt_req=fault.RealIn,
            emu_dt=fault.RealOut,
            jitter_rms=fault.RealIn,
            emu_clk=m.In(m.Clock),
            emu_rst=m.BitIn
        )

    # create the tester
    t = fault.Tester(dut, dut.emu_clk)

    # utility function for easier waveform debug
    def check_result(emu_dt, clk_val, abs_tol=DEL_PREC):
        t.delay((TCLK/2)-DELTA)
        t.poke(dut.emu_clk, 0)
        t.delay(TCLK/2)
        t.expect(dut.emu_dt, emu_dt, abs_tol=abs_tol)
        t.expect(dut.clk_o_val, clk_val)
        t.poke(dut.emu_clk, 1)
        t.delay(DELTA)

    # compute nominal delay
    del_nom = (DEL_CODE / (2.0**N_BITS)) * T_PER

    # initialize
    t.zero_inputs()
    t.poke(dut.code, DEL_CODE)
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

    # raise clock val
    t.poke(dut.clk_i_val, 1)
    t.poke(dut.dt_req, (0.123e-9)/4)
    check_result((0.123e-9)/4, 0)

    # wait some time (expect dt_req ~ 0.1 ns)
    t.poke(dut.clk_i_val, 1)
    t.poke(dut.dt_req, 0.234e-9)
    check_result(del_nom, 1)

    # lower clk_val, wait some time (expect dt_req ~ 0.345 ns)
    t.poke(dut.clk_i_val, 0)
    t.poke(dut.dt_req, (0.345e-9)/4)
    check_result((0.345e-9)/4, 1)

    # wait some time (expect dt_req ~ 0.1 ns)
    t.poke(dut.clk_i_val, 0)
    t.poke(dut.dt_req, (0.456e-9)/4)
    check_result(del_nom, 0)

    # raise clk_val, wait some time (expect dt_req ~ 0.567 ns)
    t.poke(dut.clk_i_val, 1)
    t.poke(dut.dt_req, (0.567e-9)/4)
    check_result((0.567e-9)/4, 0)

    # wait some time (expect dt_req ~ 0.1 ns)
    t.poke(dut.clk_i_val, 1)
    t.poke(dut.dt_req, (0.678e-9)/4)
    check_result(del_nom, 1)

    # lower clk_val, wait some time (expect dt_req ~ 0.789 ns)
    t.poke(dut.clk_i_val, 0)
    t.poke(dut.dt_req, (0.789e-9)/4)
    check_result((0.789e-9)/4, 1)

    # run the simulation
    defines = {
        'DT_WIDTH': 25,
        'DT_EXPONENT': -46
    }
    if float_real:
        defines['FLOAT_REAL'] = None
    t.compile_and_run(
        target='system-verilog',
        directory=BUILD_DIR,
        simulator=simulator_name,
        ext_srcs=[get_file('build/fpga_models/clk_delay_core/clk_delay_core.sv'),
                  get_file('tests/fpga_block_tests/clk_delay/test_clk_delay.sv')],
        inc_dirs=[get_svreal_header().parent, get_msdsl_header().parent],
        ext_model_file=True,
        defines=defines,
        disp_type='realtime'
    )
