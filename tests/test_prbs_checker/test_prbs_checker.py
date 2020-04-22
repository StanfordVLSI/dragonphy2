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

# PRBS checker modes
PRBS_RESET = 0
PRBS_ALIGN = 1
PRBS_TEST = 2

if SIMULATOR == 'vivado':
    pytest_params = [pytest.param(0, marks=pytest.mark.slow)]
else:
    pytest_params = [k for k in range(16)]
@pytest.mark.parametrize('n_delay', pytest_params)
def test_sim(n_delay, n_prbs=7, n_channels=16, n_shift_bits=4):
    # declare circuit
    class dut(m.Circuit):
        name = 'test_prbs_checker'
        io = m.IO(
            # checker inputs
            rst=m.BitIn,
            checker_mode=m.In(m.Bits[2]),
            # stimulus configuration
            prbs_init=m.In(m.Bits[n_prbs]),
            prbs_del=m.In(m.Bits[8]),
            # outputs
            clk_div=m.BitOut,
            total_bits=m.Out(m.Bits[64]),
            correct_bits=m.Out(m.Bits[64]),
            rx_shift=m.Out(m.Bits[n_shift_bits]),
            # bogus input needed for fault
            clk_bogus=m.ClockIn,  # need to have clock signal in order to wait on posedges (possible fault bug?)
        )

    # create tester
    t = fault.Tester(dut, dut.clk_bogus)

    # initialize with given delay
    t.poke(dut.rst, 1)
    t.poke(dut.checker_mode, PRBS_RESET)
    t.poke(dut.prbs_init, 15)
    t.poke(dut.prbs_del, n_delay)
    t.wait_until_posedge(dut.clk_div)
    t.eval()

    # release from reset
    t.poke(dut.rst, 0)
    t.wait_until_posedge(dut.clk_div)
    t.eval()

    # align the PRBS tester
    t.poke(dut.checker_mode, PRBS_ALIGN)
    t.delay(20e-3)

    # run PRBS test
    t.poke(dut.checker_mode, PRBS_TEST)
    t.delay(20e-3)

    # get results
    correct_bits = t.get_value(dut.correct_bits)
    total_bits = t.get_value(dut.total_bits)
    rx_shift = t.get_value(dut.rx_shift)

    # run the test
    t.compile_and_run(
        target='system-verilog',
        simulator=SIMULATOR,
        ext_srcs=[
            get_file('vlog/new_chip_src/prbs/prbs_generator.sv'),
            get_file('vlog/new_chip_src/prbs/prbs_checker_core.sv'),
            get_file('vlog/new_chip_src/prbs/prbs_checker.sv'),
            THIS_DIR / 'test_prbs_checker.sv'
        ],
        parameters={'n_prbs': n_prbs, 'n_channels': n_channels, 'n_shift_bits': n_shift_bits},
        ext_model_file=True,
        disp_type='realtime',
        dump_waveforms=False,
        director=BUILD_DIR
    )

    # check results
    correct_bits = correct_bits.value
    total_bits = total_bits.value
    rx_shift = rx_shift.value

    print(f'n_delay: {n_delay}')
    print(f'total_bits: {total_bits}')
    print(f'correct_bits: {correct_bits}')
    print(f'rx_shift: {rx_shift}')

    assert total_bits >= 9500, 'Not enough bits transmitted '
    assert correct_bits == total_bits, 'Bit error detected.'