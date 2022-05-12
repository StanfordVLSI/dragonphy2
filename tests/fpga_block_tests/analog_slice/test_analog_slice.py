# general imports
from pathlib import Path
import random
from math import log2, ceil, floor
import yaml
import pytest

# AHA imports
import magma as m
import fault

# FPGA-specific imports
from svreal import (get_svreal_header, RealType, DEF_HARD_FLOAT_WIDTH,
                    get_hard_float_sources, get_hard_float_inc_dirs)
from msdsl import get_msdsl_header
from msdsl.function import PlaceholderFunction

# DragonPHY imports
from dragonphy import get_file, Filter, get_dragonphy_real_type

THIS_DIR = Path(__file__).resolve().parent
BUILD_DIR = THIS_DIR / 'build'

DELTA = 100e-9
TPER = 1e-6

# read YAML file that was used to configure the generated model
CFG = yaml.load(open(get_file('config/fpga/analog_slice_cfg.yml'), 'r'))

# read channel data
CHAN = Filter.from_file(get_file('build/chip_src/adapt_fir/chan.npy'))

def adc_model(in_):
    # determine sign
    if in_ < 0:
        sgn = 0
    else:
        sgn = 1

    # determine magnitude
    in_abs = abs(in_)
    mag_real = (abs(in_abs) / CFG['vref_rx']) * ((2**(CFG['n_adc']-1)) - 1)
    mag_unclamped = int(floor(mag_real))
    mag = min(max(mag_unclamped, 0), (2**(CFG['n_adc']-1))-1)

    # return result
    return sgn, mag

def channel_model(slice_offset, pi_ctl, all_bits):
    # compute sample time
    t_samp = (slice_offset + (pi_ctl / (2 ** CFG['pi_ctl_width']))) / CFG['freq_rx']

    # build up the sample value through superposition
    sample_value = 0
    for k, bit in enumerate(all_bits):
        weight = (2*(bit-0.5)) * CFG['vref_tx']  # +/- vref_tx
        t_rise = (CFG['slices_per_bank'] / CFG['freq_rx']) - (k + 1) * (1.0 / CFG['freq_tx'])
        t_fall = t_rise + (1.0 / CFG['freq_tx'])
        sample_value += weight * (CHAN.interp(t_samp-t_rise)-CHAN.interp(t_samp-t_fall))

    return sample_value

def check_adc_result(sgn_meas, mag_meas, sgn_expct, mag_expct):
    # compute measured value as signed integer
    # note that a sign bit of "0" (not "1") means that the value is negative
    meas = mag_meas
    if sgn_meas == 0:
        meas *= -1

    # compute expected value as signed integer
    expct = mag_expct
    if sgn_expct == 0:
        expct *= -1

    # check result
    if not ((expct-1) <= meas <= (expct+1)):
        raise Exception('BAD!')

@pytest.mark.parametrize('slice_offset', [0, 1, 2, 3])
def test_analog_slice(simulator_name, slice_offset, dump_waveforms, num_tests=100):
    # set seed for repeatable behavior
    random.seed(0)

    # set defaults
    if simulator_name is None:
        simulator_name = 'vivado'

    # determine the real-number formatting
    real_type = get_dragonphy_real_type()
    if real_type in {RealType.FixedPoint, RealType.FloatReal}:
        func_widths = CFG['func_widths']
    elif real_type == RealType.HardFloat:
        func_widths = [DEF_HARD_FLOAT_WIDTH, DEF_HARD_FLOAT_WIDTH]
    else:
        raise Exception('Unsupported RealType.')

    # declare circuit
    class dut(m.Circuit):
        name = 'test_analog_slice'
        io = m.IO(
            chunk=m.In(m.Bits[CFG['chunk_width']]),
            chunk_idx=m.In(m.Bits[int(ceil(log2(CFG['num_chunks'])))]),
            pi_ctl=m.In(m.Bits[CFG['pi_ctl_width']]),
            slice_offset=m.In(m.Bits[int(ceil(log2(CFG['slices_per_bank'])))]),
            sample_ctl=m.BitIn,
            incr_sum=m.BitIn,
            write_output=m.BitIn,
            out_sgn=m.BitOut,
            out_mag=m.Out(m.Bits[CFG['n_adc']]),
            clk=m.BitIn,
            rst=m.BitIn,
            jitter_rms=fault.RealIn,
            noise_rms=fault.RealIn,
            wdata0=m.In(m.Bits[func_widths[0]]),
            wdata1=m.In(m.Bits[func_widths[1]]),
            waddr=m.In(m.Bits[11]),
            we=m.BitIn
        )

    # create the tester
    t = fault.Tester(dut)

    def cycle(k=1):
        for _ in range(k):
            t.delay(TPER/2 - DELTA)
            t.poke(dut.clk, 0)
            t.delay(TPER/2)
            t.poke(dut.clk, 1)
            t.delay(DELTA)

    def to_bv(lis):
        return int(''.join(str(elem) for elem in lis), 2)

    # build up a list of test cases
    test_cases = []
    for x in range(num_tests):
        pi_ctl = random.randint(0, (1 << CFG['pi_ctl_width']) - 1)
        all_bits = [random.randint(0, 1) for _ in range(CFG['chunk_width'] * CFG['num_chunks'])]
        test_cases.append([pi_ctl, all_bits])

    # initialize
    # two cycles of reset -- one to reset DFFs, then another to read out ROM values
    # after the addresses are no longer X
    t.zero_inputs()
    t.poke(dut.slice_offset, slice_offset)
    t.poke(dut.rst, 1)
    cycle(2)
    t.poke(dut.rst, 0)

    # initialize step response functions
    placeholder = PlaceholderFunction(domain=CFG['func_domain'], order=CFG['func_order'],
                                      numel=CFG['func_numel'], coeff_widths=CFG['func_widths'],
                                      coeff_exps=CFG['func_exps'], real_type=real_type)
    coeffs_bin = placeholder.get_coeffs_bin_fmt(CHAN.interp)
    t.poke(dut.we, 1)
    for i in range(placeholder.numel):
        t.poke(dut.wdata0, coeffs_bin[0][i])
        t.poke(dut.wdata1, coeffs_bin[1][i])
        t.poke(dut.waddr, i)
        cycle()
    t.poke(dut.we, 0)
    
    # f cycle
    t.poke(dut.chunk, 0)
    t.poke(dut.chunk_idx, 0)
    t.poke(dut.pi_ctl, test_cases[0][0])
    t.poke(dut.sample_ctl, 1)
    t.poke(dut.incr_sum, 1)
    t.poke(dut.write_output, 1)
    cycle()

    # loop through test cases
    for i in range(num_tests):
        for j in range(2+CFG['num_chunks']):
            if j < CFG['num_chunks']:
                t.poke(dut.chunk, to_bv(test_cases[i][1][(j*CFG['chunk_width']):((j+1)*CFG['chunk_width'])]))
                t.poke(dut.chunk_idx, j)
            else:
                t.poke(dut.chunk, 0)
                t.poke(dut.chunk_idx, 0)

            if j != (CFG['num_chunks']+1):
                t.poke(dut.sample_ctl, 0)
                t.poke(dut.write_output, 0)
            else:
                if i != (num_tests-1):
                    t.poke(dut.pi_ctl, test_cases[i+1][0])
                t.poke(dut.sample_ctl, 1)
                t.poke(dut.write_output, 1)

            if j != 1:
                t.poke(dut.incr_sum, 1)
            else:
                t.poke(dut.incr_sum, 0)

            cycle()

        # gather results
        test_cases[i].extend([t.get_value(dut.out_sgn), t.get_value(dut.out_mag)])

    # define macros
    defines = {}

    # include directories
    inc_dirs = [
        get_svreal_header().parent,
        get_msdsl_header().parent
    ]

    # source files
    ext_srcs = [
        get_file('build/fpga_models/analog_slice/analog_slice.sv'),
        THIS_DIR / 'test_analog_slice.sv'
    ]

    # adjust for HardFloat if needed
    if real_type == RealType.HardFloat:
        ext_srcs = get_hard_float_sources() + ext_srcs
        inc_dirs = get_hard_float_inc_dirs() + inc_dirs
        defines['HARD_FLOAT'] = None
        defines['FUNC_DATA_WIDTH'] = DEF_HARD_FLOAT_WIDTH

    # waveform dumping options
    flags = []
    if simulator_name == 'ncsim':
        flags += ['-unbuffered']

    # run the simulation
    t.compile_and_run(
        target='system-verilog',
        directory=BUILD_DIR,
        simulator=simulator_name,
        defines=defines,
        inc_dirs=inc_dirs,
        ext_srcs=ext_srcs,
        parameters={
            'chunk_width': CFG['chunk_width'],
            'num_chunks': CFG['num_chunks']
        },
        ext_model_file=True,
        disp_type='realtime',
        dump_waveforms=dump_waveforms,
        flags=flags,
        timescale='1fs/1fs',
        num_cycles=1e12
    )

    # process the results
    for k, (pi_ctl, all_bits, sgn_meas, mag_meas) in enumerate(test_cases):
        # compute the expected ADC value
        analog_sample = channel_model(slice_offset, pi_ctl, all_bits)
        sgn_expct, mag_expct = adc_model(analog_sample)

        # print measured and expected
        print(f'Test case #{k}: slice_offset={slice_offset}, pi_ctl={pi_ctl}, all_bits={all_bits}')
        print(f'[measured] sgn: {sgn_meas.value}, mag: {mag_meas.value}')
        print(f'[expected] sgn: {sgn_expct}, mag: {mag_expct}, analog_sample: {analog_sample}')

        # check result
        check_adc_result(sgn_meas.value, mag_meas.value, sgn_expct, mag_expct)

    # declare success
    print('Success!')
