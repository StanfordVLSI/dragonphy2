# general imports
import os
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

DELTA = 100e-9
TPER = 1e-6

def test_clk_delay():
    # declare circuit
    class dut(m.Circuit):
        name = 'test_clk_delay'
        io = m.IO(
            code=m.In(m.Bits[8]),
            clk_i_val=m.BitIn,
            clk_o_val=m.BitOut,
            dt_req=fault.RealIn,
            emu_dt=fault.RealOut,
            emu_clk=m.In(m.Clock),
            emu_rst=m.BitIn
        )

    # create the t
    t = fault.Tester(dut, dut.emu_clk)

    def cycle():
        t.delay(TPER/2 - DELTA)
        t.poke(dut.emu_clk, 0)
        t.delay(TPER/2)
        t.poke(dut.emu_clk, 1)
        t.delay(DELTA)

    # initialize
    t.poke(dut.code, 25)
    t.poke(dut.clk_i_val, 0)
    t.poke(dut.dt_req, 0.0)
    t.poke(dut.emu_clk, 0)
    t.poke(dut.emu_rst, 1)

    # apply reset
    t.poke(dut.emu_clk, 1)
    t.delay(TPER/2)
    t.poke(dut.emu_clk, 0)
    t.delay(TPER/2)

    # clear reset
    t.poke(dut.emu_rst, 0)
    t.poke(dut.emu_clk, 1)
    t.delay(DELTA)

    # run a few cycles
    cycle()
    cycle()
    cycle()

    # raise clock val
    t.poke(dut.clk_i_val, 1)
    t.poke(dut.dt_req, 0.123e-9)
    cycle()

    # wait some time (expect dt_req ~ 0.1 ns)
    t.poke(dut.clk_i_val, 1)
    t.poke(dut.dt_req, 0.234e-9)
    cycle()

    # lower clk_val, wait some time (expect dt_req ~ 0.345 ns)
    t.poke(dut.clk_i_val, 0)
    t.poke(dut.dt_req, 0.345e-9)
    cycle()

    # wait some time (expect dt_req ~ 0.1 ns)
    t.poke(dut.clk_i_val, 0)
    t.poke(dut.dt_req, 0.456e-9)
    cycle()

    # raise clk_val, wait some time (expect dt_req ~ 0.567 ns)
    t.poke(dut.clk_i_val, 1)
    t.poke(dut.dt_req, 0.567e-9)
    cycle()

    # wait some time (expect dt_req ~ 0.1 ns)
    t.poke(dut.clk_i_val, 1)
    t.poke(dut.dt_req, 0.678e-9)
    cycle()

    # lower clk_val, wait some time (expect dt_req ~ 0.789 ns)
    t.poke(dut.clk_i_val, 0)
    t.poke(dut.dt_req, 0.789e-9)
    cycle()

    # run the simulation
    t.compile_and_run(
        target='system-verilog',
        directory=BUILD_DIR,
        simulator=SIMULATOR,
        ext_srcs=[get_file('build/fpga_models/clk_delay_core.sv'),
                  get_file('tests/test_clk_delay/test_clk_delay.sv')],
        inc_dirs=[get_svreal_header().parent, get_msdsl_header().parent],
        ext_model_file=True,
        defines={'DT_WIDTH': 27, 'DT_EXPONENT': -46},
        disp_type='realtime'
    )