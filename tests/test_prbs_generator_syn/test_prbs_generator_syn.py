# general imports
import os
import pytest
import shutil
from random import randint
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

def test_sim():
    # declare circuit
    class dut(m.Circuit):
        name = 'prbs_generator_syn'
        io = m.IO(
            clk=m.ClockIn,
            rst=m.BitIn,
            cke=m.BitIn,
            init_val=m.In(m.Bits[32]),
            eqn=m.In(m.Bits[32]),
            inj_err=m.BitIn,
            inv_chicken=m.In(m.Bits[2]),
            out=m.BitOut
        )

    # create tester
    t = fault.Tester(dut, dut.clk)

    # initialize with the right equation
    t.poke(dut.clk, 0)
    t.poke(dut.rst, 1)
    t.poke(dut.cke, 1)
    t.poke(dut.init_val, 1)
    t.poke(dut.eqn, 0b1100000)
    t.poke(dut.inj_err, 0)
    t.poke(dut.inv_chicken, 0b00)

    # reset
    for _ in range(3):
        t.step(2)

    # release from reset and run for a bit
    t.poke(dut.rst, 0)
    for _ in range(50):
        t.step(2)

    # inject an error
    t.poke(dut.inj_err, 1)
    for _ in range(10):
        t.step(2)

    # run for a bit
    t.poke(dut.inj_err, 0)
    for _ in range(50):
        t.step(2)

    # run the test
    t.compile_and_run(
        target='system-verilog',
        simulator=SIMULATOR,
        ext_srcs=[
            get_file('vlog/new_chip_src/prbs/prbs_generator_syn.sv'),
        ],
        ext_model_file=True,
        disp_type='realtime',
        dump_waveforms=True,
        directory=BUILD_DIR
    )