# general imports
import os
import pytest
import shutil
from math import ceil
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

class PRBS:
    def __init__(self, val):
        self.val = val

    def get_next(self):
        out = (self.val >> 6) & 1
        newbit = ((self.val >> 6) ^ (self.val >> 5)) & 1
        self.val = ((self.val << 1) | newbit) & 0x7f
        return out

    def get_seq(self, num):
        return [self.get_next() for _ in range(num)]

def bv2int(bv):
    # msb first, lsb last
    retval = 0
    for k, bit in enumerate(bv):
        retval |= bit << (len(bv) - 1 - k)
    return retval

if SIMULATOR == 'vivado':
    pytest_params = [pytest.param(0, marks=pytest.mark.slow)]
else:
    pytest_params = [elem for elem in range(32)]
@pytest.mark.parametrize('n_delay', pytest_params)
def test_sim(n_delay, n_prbs=7, n_channels=16, n_shift_bits=4):
    # declare circuit
    class dut(m.Circuit):
        name = 'test_prbs_checker_core'
        io = m.IO(
            clk=m.ClockIn,
            rst=m.BitIn,
            prbs_cke=m.BitIn,
            rx_bits=m.In(m.Bits[n_channels]),
            rx_shift=m.In(m.Bits[n_shift_bits]),
            match=m.BitOut
        )

    # create tester
    t = fault.Tester(dut, dut.clk)

    # create PRBS generator
    prbs = PRBS(1)

    # initialize with given delay
    for _ in range((1<<n_prbs) - 1 - n_delay):
        prbs.get_next()

    # convenient function to get a block of values
    def get_next_block():
        retval = prbs.get_seq(n_channels)
        retval = retval[::-1]
        return bv2int(retval)

    # compute delay strategy
    n_delay_tot = n_delay + 2*n_channels
    n_cyc_cke_0 = int(ceil(n_delay_tot / n_channels))

    # initialize with given delay
    t.poke(dut.clk, 0)
    t.poke(dut.rst, 1)
    t.poke(dut.prbs_cke, 0)
    t.poke(dut.rx_bits, get_next_block())
    t.poke(dut.rx_shift, n_cyc_cke_0*n_channels - n_delay_tot)
    t.step(2)

    # stall PRBS generator for two cycles to account for lag in input
    t.poke(dut.rst, 0)
    for _ in range(n_cyc_cke_0):
        t.step(2)
        t.poke(dut.rx_bits, get_next_block())

    # release PRBS generator from stall
    t.poke(dut.prbs_cke, 1)
    for k in range((1<<n_prbs)-1):
        t.step(2)
        t.poke(dut.rx_bits, get_next_block())
        t.expect(dut.match, 1)

    # run the test
    t.compile_and_run(
        target='system-verilog',
        simulator=SIMULATOR,
        ext_srcs=[
            get_file('vlog/new_chip_src/prbs/prbs_generator.sv'),
            get_file('vlog/new_chip_src/prbs/prbs_checker_core.sv'),
            THIS_DIR / 'test_prbs_checker_core.sv'
        ],
        parameters={'n_prbs': n_prbs, 'n_channels': n_channels, 'n_shift_bits': n_shift_bits},
        ext_model_file=True,
        disp_type='realtime',
        dump_waveforms=False
    )