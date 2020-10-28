# general imports
import shutil
import pytest
from pathlib import Path

# AHA imports
import fault
import magma as m

# DragonPHY-specific imports
from dragonphy import get_file
from dragonphy.prbs_util import verify_prbs, count_prbs_err

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

def test_sim(simulator_name, dump_waveforms,
             prbs_eqn=0b1100000, n_prbs=32):
    # set defaults
    if simulator_name is None:
        if shutil.which('iverilog'):
            simulator_name = 'iverilog'
        else:
            simulator_name = 'ncsim'

    # declare circuit
    class dut(m.Circuit):
        name = 'prbs_generator_syn'
        io = m.IO(
            clk=m.ClockIn,
            rst=m.BitIn,
            cke=m.BitIn,
            init_val=m.In(m.Bits[n_prbs]),
            eqn=m.In(m.Bits[n_prbs]),
            inj_err=m.BitIn,
            inv_chicken=m.In(m.Bits[2]),
            out=m.BitOut
        )

    # create tester
    t = fault.Tester(dut, dut.clk)

    # initialize with the right equation
    t.zero_inputs()
    t.poke(dut.rst, 1)
    t.poke(dut.cke, 1)
    t.poke(dut.init_val, 1)
    t.poke(dut.eqn, prbs_eqn)

    # reset
    for _ in range(3):
        t.step(2)

    # test 1
    t.poke(dut.rst, 0)
    prbs_vals_1 = []
    for k in range(200):
        t.step(2)
        prbs_vals_1.append(t.get_value(dut.out))

    # test 2
    prbs_vals_2 = []
    for k in range(100):
        t.poke(dut.inj_err, 1 if k==50 else 0)
        t.step(2)
        prbs_vals_2.append(t.get_value(dut.out))

    # test 3
    prbs_vals_3 = []
    for k in range(100):
        t.step(2)
        prbs_vals_3.append(t.get_value(dut.out))

    # run the test
    t.compile_and_run(
        target='system-verilog',
        simulator=simulator_name,
        ext_srcs=[
            get_file('vlog/chip_src/prbs/prbs_generator_syn.sv'),
        ],
        ext_model_file=True,
        disp_type='realtime',
        dump_waveforms=dump_waveforms,
        directory=BUILD_DIR,
        num_cycles=1e12
    )

    # get results
    prbs_vals_1 = [x.value for x in prbs_vals_1]
    prbs_vals_2 = [x.value for x in prbs_vals_2]
    prbs_vals_3 = [x.value for x in prbs_vals_3]

    # check test 1
    prbs_vals_1 = prbs_vals_1[50:]
    verify_prbs(prbs_vals=prbs_vals_1, prbs_eqn=prbs_eqn, n_ti=1, n_prbs=n_prbs)

    # check test 2
    err_count = count_prbs_err(prbs_vals=prbs_vals_2, prbs_eqn=prbs_eqn, n_ti=1, n_prbs=n_prbs)
    assert err_count == 3

    # check test 3
    verify_prbs(prbs_vals=prbs_vals_3, prbs_eqn=prbs_eqn, n_ti=1, n_prbs=n_prbs)

    # declare success
    print('Success!')