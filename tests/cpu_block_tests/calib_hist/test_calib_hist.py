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

def model(data, Nbin, DZ):
    # thresholds
    th_l2 = -((Nbin*3)+1)-1
    th_l1 = -Nbin-1
    th_r1 = +Nbin+1
    th_r2 = +((Nbin*3)+1)+1

    # dead zone
    DZ_l = -(1<<DZ)
    DZ_r = +(1<<DZ)

    # compute histogram
    left, center, right = 0, 0, 0
    for din in data:
        if th_l2 < din <= th_l1:
            left += 1
        elif th_l1 < din < th_r1:
            center += 1
        elif th_r1 <= din < th_r2:
            right += 1

    # compute summary metrics
    side = (left + right) >> 1
    diff = center - side

    # compute comparator output
    if center==0 and side==0:
        comp = +1  # TODO: why isn't this "0"?
    elif diff > DZ_r:
        comp = -1
    elif diff < DZ_l:
        comp = +1
    else:
        comp = 0

    # return results
    return center, side, comp

def test_sim(simulator_name, Nadc=8, Nrange=4, Navg=7,
             Nbin=6, DZ=3):
    # set defaults
    if simulator_name is None:
        if shutil.which('iverilog'):
            simulator_name = 'iverilog'
        else:
            simulator_name = 'ncsim'

    # declare circuit
    class dut(m.Circuit):
        name = 'calib_hist_measure'
        io = m.IO(
            rstb=m.BitIn,
            clk=m.ClockIn,
            update=m.BitIn,
            din=m.In(m.SInt[Nadc]),
            din_avg=m.In(m.SInt[Nadc]),
            Nbin=m.In(m.Bits[Nrange]),
            DZ=m.In(m.Bits[Nrange]),
            flip_feedback=m.BitIn,
            hist_center=m.Out(m.Bits[2**Nrange]),
            hist_side=m.Out(m.Bits[2**Nrange]),
            hist_comp_out=m.Out(m.SInt[2])
        )

    # create tester
    t = fault.Tester(dut, dut.clk)

    # define data vectors
    data_vecs = [
        [0]*(1<<Navg),
        [+13]*(1<<Navg),
        [-13]*(1<<Navg),
        [+25]*(1<<Navg),
        [-25]*(1<<Navg),
        [random.randint(-25, 25)
         for _ in range(1<<Navg)],
        [random.randint(0, 25)
         for _ in range(1<<Navg)],
        [random.randint(-25, 0)
         for _ in range(1<<Navg)],
    ]

    # define averaging test
    def run_hist(data):
        # first value
        t.poke(dut.update, 1)
        t.poke(dut.din, data[0])
        t.step(2)

        # middle values
        t.poke(dut.update, 0)
        for elem in data[1:]:
            t.poke(dut.din, elem)
            t.step(2)

        # get values for average and sum
        hist_center = t.get_value(dut.hist_center)
        hist_side = t.get_value(dut.hist_side)
        hist_comp_out = t.get_value(dut.hist_comp_out)

        return hist_center, hist_side, hist_comp_out

    # initialize
    t.zero_inputs()
    t.poke(dut.din_avg, 0)
    t.poke(dut.Nbin, Nbin)
    t.poke(dut.DZ, DZ)

    # run a few cycles
    t.step(10)
    t.poke(dut.rstb, 1)
    t.step(2)

    # run averaging trials
    results = []
    for k in range(len(data_vecs)):
        results.append(run_hist(data_vecs[k]))

    # run a few extra cycles for better visibility
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

    results = [(res[0].value, res[1].value, to_signed(res[2].value, 2))
               for res in results]

    print('results', results)

    ################
    # check values #
    ################

    for result, data_vec in zip(results, data_vecs):
        assert result == model(data=data_vec, Nbin=Nbin, DZ=DZ), \
            'Mismatch in measured vs. expected results.'

    ###################
    # declare success #
    ###################

    print('Success!')
