# general imports
import yaml
import numpy as np
from pathlib import Path
from math import floor

# AHA imports
import magma as m
import fault

# FPGA-specific imports
from svreal import get_svreal_header
from msdsl import get_msdsl_header

# DragonPHY imports
from dragonphy import get_file

BUILD_DIR = Path(__file__).resolve().parent / 'build'

# read YAML file that was used to configure the generated model
CFG = yaml.load(open(get_file('config/fpga/rx_adc.yml'), 'r'), Loader=yaml.Loader)

def model(in_):
    # determine sign
    if in_ < 0:
        sgn = 0
    else:
        sgn = 1

    # determine magnitude
    in_abs = abs(in_)
    mag_real = (abs(in_abs) / CFG['vref']) * ((2**(CFG['n']-1)) - 1)
    mag_unclamped = int(floor(mag_real))
    mag = min(max(mag_unclamped, 0), (2**(CFG['n']-1))-1)

    # return result
    return sgn, mag

def test_adc_model(simulator_name, should_print=False):
    # set defaults
    if simulator_name is None:
        simulator_name = 'vivado'

    # declare circuit
    class dut(m.Circuit):
        name = 'test_adc_model'
        io = m.IO(
            in_=fault.RealIn,
            clk_val=m.BitIn,
            out_mag=m.Out(m.Bits[CFG['n']]),
            out_sgn=m.BitOut,
            noise_seed=m.In(m.Bits[32]),
            noise_rms=fault.RealIn,
            emu_rst=m.BitIn,
            emu_clk=m.ClockIn
        )

    # create the tester
    t = fault.Tester(dut, dut.emu_clk)

    # initialize
    t.zero_inputs()
    t.poke(dut.emu_rst, 1)
    t.step(4)

    # clear reset
    t.poke(dut.emu_rst, 0)
    t.step(4)

    # create mechanism to run trials
    def run_trial(in_):
        # set input
        t.poke(dut.in_, in_)
        t.step(4)

        # toggle clock
        t.poke(dut.clk_val, 1)
        t.step(4)
        t.poke(dut.clk_val, 0)
        t.step(4)

        # print output if desired
        if should_print:
            t.print('in_: %0f, out_sgn: %0d, out_mag: %0d\n',
                    dut.in_, dut.out_sgn, dut.out_mag)

        # get expected output
        expct_sgn, expct_mag = model(in_=in_)

        # check results
        t.expect(dut.out_sgn, expct_sgn)
        t.expect(dut.out_mag, expct_mag)

    # specify trials to be run
    delta = 0.1*CFG['vref']
    for in_ in np.linspace(-CFG['vref']-delta, CFG['vref']+delta, 100):
        run_trial(in_=in_)

    # run the simulation
    t.compile_and_run(
        target='system-verilog',
        directory=BUILD_DIR,
        simulator=simulator_name,
        ext_srcs=[get_file('build/fpga_models/rx_adc_core/rx_adc_core.sv'),
                  get_file('tests/fpga_block_tests/adc_model/test_adc_model.sv')],
        inc_dirs=[get_svreal_header().parent, get_msdsl_header().parent],
        ext_model_file=True,
        disp_type='realtime',
        parameters={'n': CFG['n']},
        dump_waveforms=False
    )
