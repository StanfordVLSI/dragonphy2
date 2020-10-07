# general imports
import shutil
import pytest
from pathlib import Path

# AHA imports
import fault
import magma as m

# DragonPHY-specific imports
from dragonphy import get_deps_cpu_sim

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

def list_head(lis, n=25):
    trimmed = lis[:n]
    if len(lis) > n:
        trimmed += ['...']
    return str(trimmed)

@pytest.mark.parametrize('ndiv', list(range(16)))
def test_sim(simulator_name, ndiv, N=4, nper=5):
    # set defaults
    if simulator_name is None:
        if shutil.which('iverilog'):
            simulator_name = 'iverilog'
        else:
            simulator_name = 'ncsim'

    # declare circuit
    class dut(m.Circuit):
        name = 'avg_pulse_gen'
        io = m.IO(
            clk=m.ClockIn,
            rstb=m.BitIn,
            ndiv=m.In(m.Bits[N]),
            out=m.BitOut
        )

    # create tester
    t = fault.Tester(dut, dut.clk)

    # initialize
    t.zero_inputs()
    t.poke(dut.ndiv, ndiv)

    # run a few cycles
    t.step(10)
    t.poke(dut.rstb, 1)

    # capture output
    results = []
    for k in range(nper*(2**ndiv)):
        results.append(t.get_value(dut.out))
        t.step(2)

    ##################
    # run simulation #
    ##################

    t.compile_and_run(
        target='system-verilog',
        simulator=simulator_name,
        ext_srcs=get_deps_cpu_sim(cell_name='avg_pulse_gen'),
        parameters={
            'N': N,
        },
        ext_model_file=True,
        disp_type='realtime',
        dump_waveforms=False,
        directory=BUILD_DIR,
        num_cycles=1e12
    )

    ##################
    # convert values #
    ##################

    results = [elem.value for elem in results]

    ################
    # check values #
    ################

    # trim initial zeros
    results = results[results.index(1):]

    # print the beginning of the list
    print('results', list_head(results))

    # trim to an integer number of periods
    nper_meas = len(results) // (2**ndiv)
    assert nper_meas >= (nper-1), 'Not enough output periods observed.'
    results = results[:nper_meas * (2**ndiv)]

    # check that results match expectations
    expct = []
    for _ in range(nper_meas):
        expct += [1]
        expct += [0]*((2**ndiv)-1)

    # compare observed and expected outputs
    assert results == expct, 'Mismatch in measured vs. expected outputs.'

    ###################
    # declare success #
    ###################

    print('Success!')
