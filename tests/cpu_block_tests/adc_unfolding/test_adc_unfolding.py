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

# Default values in JTAG register map
Nadc=8
Nrange=4
Navg=10
Nbin=6
DZ=3

def adc_model(data, offset):
    # calculate magnitude / sign
    mag = [abs(elem) for elem in data]
    sgn = [1 if elem>=0 else 0 for elem in data]

    # add offset
    mag = [elem+offset for elem in mag]

    # clamp magnitudes
    mag = [elem if elem < (1<<(Nadc-1)) else ((1<<(Nadc-1))-1)
           for elem in mag]

    # return results
    return sgn, mag

# declare circuit
class dut(m.Circuit):
    name = 'adc_unfolding'
    io = m.IO(

        rstb=m.BitIn,
        clk=m.ClockIn,
        update=m.BitIn,
        din=m.In(m.Bits[Nadc]),
        sign_out=m.BitIn,

        en_pfd_cal=m.BitIn,
        en_ext_pfd_offset=m.BitIn,
        ext_pfd_offset=m.In(m.Bits[Nadc]),
        Nbin=m.In(m.Bits[Nrange]),
        Navg=m.In(m.Bits[Nrange]),
        DZ=m.In(m.Bits[Nrange]),

        dout=m.Out(m.SInt[Nadc]),
        dout_avg=m.Out(m.SInt[Nadc]),
        dout_sum=m.Out(m.SInt[Nadc+(2**Nrange)]),
        hist_center=m.Out(m.Bits[2**Nrange]),
        hist_side=m.Out(m.Bits[2**Nrange]),
        pfd_offset=m.Out(m.SInt[Nadc])
    )

def test_ext_offset(simulator_name):
    # set defaults
    if simulator_name is None:
        if shutil.which('iverilog'):
            simulator_name = 'iverilog'
        else:
            simulator_name = 'ncsim'

    # create tester
    t = fault.Tester(dut, dut.clk)

    # initialize
    t.zero_inputs()

    # run a few cycles
    t.step(10)
    t.poke(dut.rstb, 1)
    t.step(2)

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
        directory=BUILD_DIR
    )

    ##################
    # convert values #
    ##################

    ################
    # check values #
    ################

    ###################
    # declare success #
    ###################

    print('Success!')
