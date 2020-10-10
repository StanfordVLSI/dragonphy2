# general imports
import shutil
import random
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

def test_sim(simulator_name, Nadc=8, Nrange=4, Navg=10):
    # set defaults
    if simulator_name is None:
        if shutil.which('iverilog'):
            simulator_name = 'iverilog'
        else:
            simulator_name = 'ncsim'

    # declare circuit
    class dut(m.Circuit):
        name = 'calib_sample_avg'
        io = m.IO(
            din=m.In(m.SInt[Nadc]),
            Navg=m.In(m.Bits[Nrange]),
            clk=m.ClockIn,
            update=m.BitIn,
            rstb=m.BitIn,
            avg_out=m.Out(m.SInt[Nadc]),
            sum_out=m.Out(m.SInt[Nadc+(2**Nrange)])
        )

    # create tester
    t = fault.Tester(dut, dut.clk)

    # define data vectors
    data_vecs = [
        [-42]*(1<<Navg),
        [+42]*(1<<Navg),
        [0]*(1<<Navg),
        [random.randint(-(1<<(Nadc-1)), (1<<(Nadc-1))-1)
         for _ in range(1<<Navg)],
        [random.randint(0,(1<<(Nadc-1))-1)
         for _ in range(1<<Navg)],
        [random.randint(-(1<<(Nadc-1)), 0)
         for _ in range(1 << Navg)]
    ]

    # define averaging test
    def run_avg(data, last):
        # middle values
        t.poke(dut.update, 0)
        for elem in data[1:]:
            t.poke(dut.din, elem)
            t.step(2)

        # final value
        t.poke(dut.update, 1)
        t.poke(dut.din, last)
        t.step(2)

        # get values for average and sum
        avg_out = t.get_value(dut.avg_out)
        sum_out = t.get_value(dut.sum_out)

        return avg_out, sum_out

    # initialize
    t.zero_inputs()
    t.poke(dut.Navg, Navg)

    # run a few cycles
    t.step(10)
    t.poke(dut.rstb, 1)
    t.step(2)

    # first value
    t.poke(dut.update, 1)
    t.poke(dut.din, data_vecs[0][0])
    t.step(2)

    # run averaging trials
    results = []
    for k in range(len(data_vecs)):
        if k <= (len(data_vecs)-2):
            last = data_vecs[k+1][0]
        else:
            last = 0
        results.append(run_avg(data_vecs[k], last))

    # run a few extra cycles for better visibility
    t.poke(dut.update, 0)
    t.step(10)

    ##################
    # run simulation #
    ##################

    t.compile_and_run(
        target='system-verilog',
        simulator=simulator_name,
        ext_srcs=get_deps_cpu_sim(cell_name=dut.name),
        parameters={
            'Nadc': Nadc,
            'Nrange': Nrange
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

    def to_signed(x, n):
        if x >= (1<<(n-1)):
            return x - (1<<n)
        else:
            return x

    results = [(to_signed(res[0].value, Nadc),
                to_signed(res[1].value, Nadc + (2**Nrange)))
               for res in results]

    print('results', results)

    ################
    # check values #
    ################

    for (avg_out, sum_out), data_vec in zip(results, data_vecs):
        assert sum_out == sum(data_vec), 'Mismatch in sum.'
        assert avg_out == sum(data_vec)>>Navg, 'Mismatch in average.'

    ###################
    # declare success #
    ###################

    print('Success!')
