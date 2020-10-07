# general imports
import shutil
from random import randint, shuffle, seed
from pathlib import Path

# AHA imports
import fault
import magma as m

# DragonPHY-specific imports
from dragonphy import get_deps_cpu_sim

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

RESET  = 0b000
CLEAR  = 0b001
RUN    = 0b010
FREEZE = 0b011
HOLD   = 0b100

def test_sim(simulator_name, n_data=8, n_count=64):
    # set the random seed for repeatable results
    seed(1)

    # set defaults
    if simulator_name is None:
        if shutil.which('iverilog'):
            simulator_name = 'iverilog'
        else:
            simulator_name = 'ncsim'

    # determine the stimulus vector
    counts = [randint(0, 4) for _ in range(1<<n_data)]
    data_vec = []
    for k, count in enumerate(counts):
        data_vec += [k]*count
    shuffle(data_vec)

    # declare circuit
    class dut(m.Circuit):
        name = 'histogram'
        io = m.IO(
            clk=m.ClockIn,
            sram_ceb=m.BitIn,
            mode=m.In(m.Bits[3]),
            data=m.In(m.Bits[n_data]),
            addr=m.In(m.Bits[n_data]),
            count=m.Out(m.Bits[n_count]),
            total=m.Out(m.Bits[n_count])
        )

    # create tester
    t = fault.Tester(dut, dut.clk)

    # initialize inputs
    t.zero_inputs()
    t.poke(dut.data, data_vec[0])

    # run a few cycles
    t.step(10)

    # clear the memory
    t.poke(dut.mode, CLEAR)
    t.step(2*300)

    # write values
    t.poke(dut.mode, RUN)
    for elem in data_vec[1:]:
        t.poke(dut.data, elem)
        t.step(2)

    # poke one final value
    # (will not be included in histogram)
    t.poke(dut.data, 0)
    t.step(2)

    # read values
    t.poke(dut.mode, FREEZE)

    results = []
    for k in range(1<<n_data):
        t.poke(dut.addr, k)
        t.step(8)
        results.append(t.get_value(dut.count))

    total = t.get_value(dut.total)

    # run the test
    t.compile_and_run(
        target='system-verilog',
        simulator=simulator_name,
        ext_srcs=get_deps_cpu_sim(cell_name='histogram'),
        parameters={
            'n_data': n_data,
            'n_count': n_count
        },
        ext_model_file=True,
        disp_type='realtime',
        dump_waveforms=False,
        directory=BUILD_DIR,
        num_cycles=1e12
    )

    # convert results
    results = [result.value for result in results]
    total = total.value

    # print results
    print(f'total: {total}')
    print(f'results: {results}')

    # check results
    assert sum(results) == total, 'Mismatch between sum of bins and reported total.'
    assert sum(counts) == total, 'Total number of counts is unexpected.'
    assert counts == results, 'Mismatch in one or more histogram bins.'

    # declare success
    print('Success!')
