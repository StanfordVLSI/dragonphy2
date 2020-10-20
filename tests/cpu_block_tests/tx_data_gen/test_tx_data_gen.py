# general imports
import shutil
from pathlib import Path

# AHA imports
import fault
import magma as m

# DragonPHY-specific imports
from dragonphy import get_deps_cpu_sim

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

def test_tx_data_gen(simulator_name, n_prbs=32, n_ti=16):
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
            data_out=m.Out(m.Bits[n_ti])
        )

    # create tester
    t = fault.Tester(dut, dut.clk)

    # initialize with the right equation
    t.zero_inputs()
    t.poke(dut.rst, 1)

    # reset
    for _ in range(3):
        t.step(2)

    # run normally
    t.poke(dut.rst, 0)
    for _ in range(100):
        t.step(2)

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
        dump_waveforms=True,
        directory=BUILD_DIR,
        num_cycles=1e12
    )
