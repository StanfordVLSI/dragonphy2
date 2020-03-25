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
            emu_clk=m.In(m.Clock),
            emu_rst=m.BitIn
        )

    # create the t
    t = fault.Tester(dut, dut.emu_clk)

    def cycle(k=1):
        for _ in range(k):
            t.poke(dut.emu_clk, 1)
            t.delay(TPER/2)
            t.poke(dut.emu_clk, 0)
            t.delay(TPER/2)

    # initialize
    t.poke(dut.code, 230)
    t.poke(dut.emu_clk, 0)
    t.poke(dut.emu_rst, 1)

    # apply reset
    cycle()

    # clear reset
    t.poke(dut.emu_rst, 0)
    cycle()

    # run for awhile
    cycle(20)

    # run the simulation
    t.compile_and_run(
        target='system-verilog',
        directory=BUILD_DIR,
        simulator=SIMULATOR,
        ext_srcs=[get_file('build/fpga_models/clk_delay_core.sv'),
                  get_file('build/fpga_models/osc_model_core.sv'),
                  get_file('tests/test_clk_delay/test_clk_delay.sv')],
        inc_dirs=[get_svreal_header().parent, get_msdsl_header().parent],
        ext_model_file=True,
        defines={'DT_WIDTH': 27, 'DT_EXPONENT': -46},
        disp_type='realtime'
    )