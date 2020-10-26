# general imports
import shutil
from pathlib import Path

# AHA imports
import fault
import magma as m

# DragonPHY-specific imports
from dragonphy import get_deps_cpu_sim
from dragonphy.prbs_util import verify_prbs

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

# operating modes
RESET = 0
CONSTANT = 1
PULSE = 2
SQUARE = 3
PRBS = 4

def test_tx_data_gen(simulator_name, dump_waveforms, n_prbs=32,
                     n_ti=16, sq_per=4, pulse_per=3, const_val=42,
                     prbs_eqn=0x100002):
    # set defaults
    if simulator_name is None:
        if shutil.which('iverilog'):
            simulator_name = 'iverilog'
        else:
            simulator_name = 'ncsim'

    # declare circuit
    class dut(m.Circuit):
        name = 'test'
        io = m.IO(
            clk=m.ClockIn,
            rst=m.BitIn,
            data_mode=m.In(m.Bits[3]),
            data_per=m.In(m.Bits[16]),
            data_in=m.In(m.Bits[n_ti]),
            data_out=m.Out(m.Bits[n_ti]),
            prbs_eqn=m.In(m.Bits[n_prbs])
        )

    # create tester
    t = fault.Tester(dut, dut.clk)

    # initialize with the right equation
    t.zero_inputs()
    t.poke(dut.rst, 1)
    t.poke(dut.data_mode, CONSTANT)
    t.poke(dut.data_in, const_val)
    t.poke(dut.prbs_eqn, prbs_eqn)

    # reset
    for _ in range(3):
        t.step(2)

    # run CONSTANT mode
    t.poke(dut.rst, 0)
    const_vals = []
    for _ in range(50):
        t.step(2)
        const_vals.append(t.get_value(dut.data_out))

    # reset
    t.poke(dut.rst, 1)
    for _ in range(3):
        t.step(2)

    # run PULSE mode
    t.poke(dut.rst, 0)
    t.poke(dut.data_mode, PULSE)
    t.poke(dut.data_in, 1)
    t.poke(dut.data_per, pulse_per-1)
    pulse_vals = []
    for _ in range(50):
        t.step(2)
        pulse_vals.append(t.get_value(dut.data_out))

    # reset
    t.poke(dut.rst, 1)
    for _ in range(3):
        t.step(2)

    # run SQUARE mode
    t.poke(dut.rst, 0)
    t.poke(dut.data_mode, SQUARE)
    t.poke(dut.data_per, sq_per-1)
    square_vals = []
    for _ in range(50):
        t.step(2)
        square_vals.append(t.get_value(dut.data_out))

    # reset
    t.poke(dut.rst, 1)
    for _ in range(3):
        t.step(2)

    # run PRBS mode
    t.poke(dut.rst, 0)
    t.poke(dut.data_mode, PRBS)
    prbs_vals = []
    for _ in range(50):
        t.step(2)
        prbs_vals.append(t.get_value(dut.data_out))

    # run the test
    ext_srcs = get_deps_cpu_sim(impl_file=THIS_DIR / 'test.sv')
    parameters = {
        'Nti': n_ti,
        'Nprbs': n_prbs
    }
    t.compile_and_run(
        target='system-verilog',
        simulator=simulator_name,
        ext_srcs=ext_srcs,
        parameters=parameters,
        ext_model_file=True,
        disp_type='realtime',
        dump_waveforms=dump_waveforms,
        directory=BUILD_DIR,
        num_cycles=1e12
    )

    # process results
    const_vals = [x.value for x in const_vals]
    pulse_vals = [x.value for x in pulse_vals]
    square_vals = [x.value for x in square_vals]
    prbs_vals = [x.value for x in prbs_vals]

    # check constant results
    const_vals = const_vals[5:]
    assert all(x==const_val for x in const_vals)

    # check pulse results
    pulse_vals = pulse_vals[pulse_vals.index(1):]
    pulse_vals = pulse_vals[:(len(pulse_vals)//pulse_per)*pulse_per]
    assert pulse_vals == ([1] + [0]*(pulse_per-1)) * (len(pulse_vals)//pulse_per)

    # check square wave results
    sq_hi = (1<<n_ti)-1
    sq_lo = 0
    square_vals = square_vals[square_vals.index(sq_hi):]
    square_vals = square_vals[:(len(square_vals)//(2*sq_per))*(2*sq_per)]
    assert square_vals == ([sq_hi]*sq_per + [sq_lo]*sq_per) * (len(square_vals)//(2*sq_per))

    # check PRBS results
    prbs_vals = prbs_vals[5:]  # first couple of values are invalid
    verify_prbs(prbs_vals=prbs_vals, prbs_eqn=prbs_eqn, n_ti=n_ti, n_prbs=n_prbs)

    # declare success
    print('Success!')
