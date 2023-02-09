# general imports
from pathlib import Path
import random
from math import log2, ceil, floor

import matplotlib.pyplot as plt

import yaml

# AHA imports
import magma as m
import fault

# FPGA-specific imports
from svreal import (get_svreal_header, RealType, get_hard_float_inc_dirs,
                    get_hard_float_sources, DEF_HARD_FLOAT_WIDTH)
from msdsl import get_msdsl_header
from msdsl.function import PlaceholderFunction

# DragonPHY imports
from dragonphy import (get_file, get_dir, Filter, get_deps_fpga_emu,
                       get_dragonphy_real_type)

THIS_DIR = Path(__file__).resolve().parent
BUILD_DIR = THIS_DIR / 'build'

DELTA = 100e-9
TPER = 1e-6

# read YAML file that was used to configure the generated model
CFG = yaml.load(open(get_file('config/fpga/analog_slice_cfg.yml'), 'r'), Loader=yaml.Loader)

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

def test_analog_core(simulator_name, dump_waveforms, num_tests=100):
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

    # set up the IO definitions
    io_dict = {}
    io_dict['bits'] = m.In(m.Bits[16])
    for k in range(4):
        io_dict[f'ctl_pi_{k}'] = m.In(m.Bits[9])
    for k in range(16):
        io_dict[f'adder_out_{k}'] = m.Out(m.Bits[8])
    io_dict.update(dict(
        sign_out=m.Out(m.Bits[16]),
        clk=m.BitIn,
        rst= m.BitIn,
        jitter_rms_int= m.In(m.Bits[7]),
        noise_rms_int= m.In(m.Bits[11]),
        chan_wdata_0=m.In(m.Bits[func_widths[0]]),
        chan_wdata_1=m.In(m.Bits[func_widths[1]]),
        chan_waddr=m.In(m.Bits[int(ceil(log2(CFG['func_numel'])))]),
        chan_we=m.BitIn
    ))

    # declare circuit
    class dut(m.Circuit):
        name = 'test_analog_core'
        io = m.IO(**io_dict)

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

    def poke_bits(bits):
        t.poke(dut.bits, to_bv(bits))

    def poke_pi_ctl(pi_ctl):
        for k in range(4):
            t.poke(getattr(dut, f'ctl_pi_{k}'), pi_ctl[k])

    def get_adder_out():
        retval = []
        for k in range(16):
            retval.append(t.get_value(getattr(dut, f'adder_out_{k}')))
        return retval

    # build up a list of test cases
    test_cases = []
    for x in range(num_tests):
        pi_ctl = [0, 128, 256, 384] #[random.randint(0, (1 << CFG['pi_ctl_width']) - 1) for _ in range(4)]
        new_bits = [0]*7 + [1] + [0]*8 # [random.randint(0, 1) for _ in range(16)]
        test_cases.append([pi_ctl, new_bits])

    # initialize
    t.zero_inputs()
    t.poke(dut.rst, 1)
    cycle(2)
    t.poke(dut.rst, 0)
    for j in range(1 + CFG['num_chunks']):
        cycle()

    # initialize step response functions
    placeholder = PlaceholderFunction(domain=CFG['func_domain'], order=CFG['func_order'],
                                      numel=CFG['func_numel'], coeff_widths=CFG['func_widths'],
                                      coeff_exps=CFG['func_exps'], real_type=real_type)
    coeffs_bin = placeholder.get_coeffs_bin_fmt(CHAN.interp)
    t.poke(dut.chan_we, 1)
    for i in range(placeholder.numel):
        t.poke(dut.chan_wdata_0, coeffs_bin[0][i])
        t.poke(dut.chan_wdata_1, coeffs_bin[1][i])
        t.poke(dut.chan_waddr, i)
        cycle()
    t.poke(dut.chan_we, 0)

    # run test cases
    results = []
    for pi_ctl, new_bits in test_cases:
        poke_bits(new_bits)
        poke_pi_ctl(pi_ctl)
        for j in range(2+CFG['num_chunks']):
            cycle()
        results.append([t.get_value(dut.sign_out), get_adder_out()])

    # run a few cycles at the end for better waveform visibility
    cycle(5)

    # define macros
    defines = {
        'FPGA_MACRO_MODEL': True,
        'CHUNK_WIDTH': CFG['chunk_width'],
        'NUM_CHUNKS': CFG['num_chunks']
    }

    # include directories
    inc_dirs = [
        get_svreal_header().parent,
        get_msdsl_header().parent,
        get_dir('inc/fpga')
    ]

    # source files
    ext_srcs = get_deps_fpga_emu(impl_file=THIS_DIR/'test_analog_core.sv')

    # adjust for HardFloat if needed
    if real_type == RealType.HardFloat:
        ext_srcs = get_hard_float_sources() + ext_srcs
        inc_dirs = get_hard_float_inc_dirs() + inc_dirs
        defines['HARD_FLOAT'] = None
        defines['FUNC_DATA_WIDTH'] = DEF_HARD_FLOAT_WIDTH

    defines['FUNC_NUMEL'] = CFG['func_numel']

    # waveform dumping options
    flags = []
    if simulator_name == 'ncsim':
        flags += ['-unbuffered']
    if dump_waveforms:
        defines['DUMP_WAVEFORMS'] = None
        if simulator_name == 'ncsim':
            flags += ['-access', '+r']

    # run the simulation
    t.compile_and_run(
        target='system-verilog',
        directory=BUILD_DIR,
        simulator=simulator_name,
        defines=defines,
        inc_dirs=inc_dirs,
        ext_srcs=ext_srcs,
        ext_model_file=True,
        disp_type='realtime',
        dump_waveforms=False,
        flags=flags,
        timescale='1fs/1fs',
        num_cycles=1e12
    )

    # process the results
    for k in range(1, len(test_cases)-1):
        # extract out parameters
        pi_ctl, new_bits = test_cases[k]
        prev_bits = test_cases[k-1][1]

        # compute the expected ADC value
        analog_sample, sgn_expct, mag_expct = [], [], []
        all_bits = new_bits + prev_bits
        for idx in range(16):
            # determine the analog value sampled on this channel
            analog_sample.append(channel_model(idx%4, pi_ctl[idx//4], all_bits))

            # determine what the ADC output should be
            adc_out = adc_model(analog_sample[-1])
            sgn_expct.append(adc_out[0])
            mag_expct.append(adc_out[1])

        # extract out results
        sgn_meas = [(results[k+1][0].value >> idx) & 1 for idx in range(16)]
        mag_meas = [elem.value for elem in results[k+1][1]]

        def find_values(signs, vals):
            act_pos = [0, 4, 8, 12, 1, 5, 9, 13, 2, 6, 10, 14, 3, 7, 11, 15]
            return [vals[ii] if signs[ii] else -vals[ii] for ii in act_pos]

        plt.plot(find_values(sgn_meas, mag_meas))
        plt.plot(find_values(sgn_expct, mag_expct))
        plt.show()

        # print measured and expected
        print(f'Test case #{k}: pi_ctl={pi_ctl}, all_bits={new_bits}')
        print(f'[measured] sgn: {sgn_meas}, mag: {mag_meas}')
        print(f'[expected] sgn: {sgn_expct}, mag: {mag_expct}, analog_sample: {analog_sample}')

        # check results
        for sm, mm, se, me in zip(sgn_meas, mag_meas, sgn_expct, mag_expct):
            check_adc_result(sm, mm, se, me)

    # declare success
    print('Success!')
