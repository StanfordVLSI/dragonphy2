# general imports
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
else:
    SIMULATOR = 'ncsim'

@pytest.mark.parametrize('n_prbs', [7, 9, 11, 15, 17, 20, 23, 29, 31])
def test_sim(n_prbs, n_channels=16, n_trials=256):
    # determine the right equation
    if n_prbs == 7:
        eqn = (1 << 6) | (1 << 5)
    elif n_prbs == 9:
        eqn = (1 << 8) | (1 << 4)
    elif n_prbs == 11:
        eqn = (1 << 10) | (1 << 8)
    elif n_prbs == 15:
        eqn = (1 << 14) | (1 << 13)
    elif n_prbs == 17:
        eqn = (1 << 16) | (1 << 13)
    elif n_prbs == 20:
        eqn = (1 << 19) | (1 << 2)
    elif n_prbs == 23:
        eqn = (1 << 22) | (1 << 17)
    elif n_prbs == 29:
        eqn = (1 << 28) | (1 << 26)
    elif n_prbs == 31:
        eqn = (1 << 30) | (1 << 27)
    else:
        raise Exception(f'Unknown value for n_prbs: {n_prbs}')

    # declare circuit
    class dut(m.Circuit):
        name = 'test_prbs_checker_core'
        io = m.IO(
            rst=m.BitIn,
            eqn=m.In(m.Bits[n_prbs]),
            delay=m.In(m.Bits[5]),
            clk_div=m.BitOut,
            err=m.BitOut,
            clk_bogus=m.ClockIn  # need to have clock signal in order to wait on posedges (possible fault bug?)
        )

    # create tester
    t = fault.Tester(dut, dut.clk_bogus)

    # initialize with the right equation
    t.poke(dut.rst, 1)
    t.poke(dut.eqn, eqn)
    t.poke(dut.delay, randint(0, 31))
    for _ in range(10):
        t.wait_until_posedge(dut.clk_div)

    # release from reset and run for a bit
    t.poke(dut.rst, 0)
    for _ in range(2*n_prbs):
        t.wait_until_posedge(dut.clk_div)

    # check for errors
    for _ in range(n_trials):
        t.wait_until_posedge(dut.clk_div)
        t.expect(dut.err, 0)

    # initialize with the wrong equation
    t.poke(dut.rst, 1)
    t.poke(dut.eqn, eqn+1)
    for _ in range(10):
        t.wait_until_posedge(dut.clk_div)

    # release from reset and run for a bit
    t.poke(dut.rst, 0)
    for _ in range(2*n_prbs):
        t.wait_until_posedge(dut.clk_div)

    # check for errors
    vals_with_wrong_equation = []
    for _ in range(n_trials):
        t.wait_until_posedge(dut.clk_div)
        vals_with_wrong_equation.append(t.get_value(dut.err))

    # run the test
    t.compile_and_run(
        target='system-verilog',
        simulator=SIMULATOR,
        ext_srcs=[
            get_file('vlog/tb/prbs_generator.sv'),
            get_file('vlog/chip_src/prbs/prbs_checker_core.sv'),
            THIS_DIR / 'test_prbs_checker_core.sv'
        ],
        parameters={
            'n_prbs': n_prbs,
            'n_channels': n_channels
        },
        ext_model_file=True,
        disp_type='realtime',
        dump_waveforms=False,
        directory=BUILD_DIR
    )

    # post-process results
    errors_with_wrong_equation = 0
    for elem in vals_with_wrong_equation:
        errors_with_wrong_equation += elem.value

    assert errors_with_wrong_equation > 0, \
        'Should have detected errors when using the wrong equation.'

    print('Success!')