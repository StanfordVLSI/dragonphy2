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

if SIMULATOR == 'vivado':
    pytest_params = [pytest.param(0, marks=pytest.mark.slow)]
else:
    pytest_params = [k for k in range(32)]
@pytest.mark.parametrize('n_delay', pytest_params)
def test_sim(n_delay, n_prbs=7, n_channels=16, n_shift_bits=4):
    # declare circuit
    class dut(m.Circuit):
        name = 'test_prbs_checker_core'
        io = m.IO(
            clk_bogus=m.ClockIn,  # need to have clock signal in order to wait on posedges (possible fault bug?)
            clk_div=m.BitOut,
            rst=m.BitIn,
            prbs_cke=m.BitIn,
            prbs_del=m.In(m.Bits[8]),
            rx_shift=m.In(m.Bits[n_shift_bits]),
            match=m.BitOut
        )

    # create tester
    t = fault.Tester(dut, dut.clk_bogus)

    # compute delay strategy
    n_delay_tot = n_delay + 3*n_channels
    n_cyc_cke_0 = int(ceil(n_delay_tot / n_channels))
    print(n_cyc_cke_0)

    # initialize with given delay
    t.poke(dut.rst, 1)
    t.poke(dut.prbs_cke, 0)
    t.poke(dut.prbs_del, n_delay)
    t.poke(dut.rx_shift, n_cyc_cke_0*n_channels - n_delay_tot)
    t.wait_until_posedge(dut.clk_div)

    # stall PRBS generator to account for lag in input
    t.poke(dut.rst, 0)
    for _ in range(n_cyc_cke_0):
        t.wait_until_posedge(dut.clk_div)

    # release PRBS generator from stall
    t.poke(dut.prbs_cke, 1)
    for k in range((1<<n_prbs)-1):
        t.wait_until_posedge(dut.clk_div)
        t.eval()  # need to eval because the "match" output is available right after the clock edge
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