# general imports
import shutil
import pytest
import random
from pathlib import Path
from math import sin, pi

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
    mag = abs(data)
    sgn = 1 if data>=0 else 0

    # add offset
    mag += offset

    # clamp magnitudes
    mag = mag if mag <= ((1<<Nadc)-1) else ((1<<Nadc)-1)

    # return results
    return sgn, mag

def int_is_close(meas, expct):
    return (expct-1) <= meas <= (expct+1)

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

@pytest.mark.parametrize('offset', [0, 10, 42, 127])
def test_ext_offset(simulator_name, offset):
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
    t.poke(dut.en_pfd_cal, 0)
    t.poke(dut.en_ext_pfd_offset, 1)
    t.poke(dut.ext_pfd_offset, offset)
    t.poke(dut.Nbin, Nbin)
    t.poke(dut.Navg, Navg)
    t.poke(dut.DZ, DZ)

    # run a few cycles
    t.step(10)
    t.poke(dut.rstb, 1)
    t.step(2)

    # send in data
    data_in = []
    data_out = []
    for k in range(-((1<<Nadc)-1), 1<<Nadc):
        data_in.append(k)
        sgn, mag = adc_model(k, offset=offset)
        t.poke(dut.sign_out, sgn)
        t.poke(dut.din, mag)
        t.step(2)
        data_out.append(t.get_value(dut.dout))

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

    def to_signed(x, n):
        if x >= (1<<(n-1)):
            return x - (1<<n)
        else:
            return x

    data_out = [to_signed(elem.value, Nadc)
                for elem in data_out]

    ################
    # check values #
    ################

    for x, y in zip(data_in, data_out):
        if x <= -(1<<(Nadc-1)):
            assert y == -(1<<(Nadc-1))
        elif x >= (1<<(Nadc-1))-1:
            assert y == (1<<(Nadc-1))-1
        else:
            assert x == y

    ###################
    # declare success #
    ###################

    print('Success!')

def test_int_offset(simulator_name, offset=16):
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
    t.poke(dut.en_pfd_cal, 1)
    t.poke(dut.en_ext_pfd_offset, 0)
    t.poke(dut.ext_pfd_offset, 0)
    t.poke(dut.Nbin, Nbin)
    t.poke(dut.Navg, Navg)
    t.poke(dut.DZ, DZ)

    # run a few cycles
    t.step(10)
    t.poke(dut.rstb, 1)
    t.step(2)

    # send in data
    n_data = 25*(1<<Navg)
    data_in = [int(round(100*sin(2*pi*n/123.456)))
               for n in range(n_data)]
    data_out = []

    for k in range(n_data):
        # manage the update pulse
        if k%(1<<Navg) == 0:
            t.poke(dut.update, 1)
        else:
            t.poke(dut.update, 0)

        # send in the data
        sgn, mag = adc_model(data_in[k], offset=offset)
        t.poke(dut.sign_out, sgn)
        t.poke(dut.din, mag)
        t.step(2)
        data_out.append(t.get_value(dut.dout))

    # read out the pfd offset
    pfd_offset = t.get_value(dut.pfd_offset)

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

    def to_signed(x, n):
        if x >= (1<<(n-1)):
            return x - (1<<n)
        else:
            return x

    pfd_offset = to_signed(pfd_offset.value, Nadc)

    print('pfd_offset', pfd_offset)

    data_out = [to_signed(elem.value, Nadc)
                for elem in data_out]

    ################
    # check values #
    ################

    assert int_is_close(pfd_offset, offset), 'Estimated pfd_offset is wrong.'

    for x, y in zip(data_in[-1000:], data_out[-1000:]):
        assert int_is_close(x, y), 'Mismatch in input and output data'

    ###################
    # declare success #
    ###################

    print('Success!')
