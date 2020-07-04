# general imports
from pathlib import Path
import random
from math import floor
import yaml

# AHA imports
import magma as m
import fault

# FPGA-specific imports
from svreal import get_svreal_header
from msdsl import get_msdsl_header

# DragonPHY imports
from dragonphy import get_file, get_dir, Filter, get_deps_fpga_emu

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

def test_analog_core(simulator_name, dump_waveforms, num_tests=100):
    # set seed for repeatable behavior
    random.seed(0)

    # set defaults
    if simulator_name is None:
        simulator_name = 'vivado'

    # set up the IO definitions
    io_dict = {}
    io_dict['bits'] = m.In(m.Bits[16])
    for k in range(4):
        io_dict[f'ctl_pi_{k}'] = m.In(m.Bits[9])
    for k in range(16):
        io_dict[f'adder_out_{k}'] = m.Out(m.Bits[8])
    io_dict['sign_out'] = m.Out(m.Bits[16])
    io_dict['clk'] = m.BitIn
    io_dict['rst'] = m.BitIn

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
        pi_ctl = [random.randint(0, (1 << CFG['pi_ctl_width']) - 1) for _ in range(4)]
        new_bits = [random.randint(0, 1) for _ in range(16)]
        test_cases.append([pi_ctl, new_bits])

    # initialize
    t.zero_inputs()
    t.poke(dut.rst, 1)
    cycle(2)
    t.poke(dut.rst, 0)
    for j in range(1 + CFG['num_chunks']):
        cycle()

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

    # get dependencies for simulation
    ext_srcs = get_deps_fpga_emu(impl_file = THIS_DIR / 'test_analog_core.sv')
    print(ext_srcs)

    # waveform dumping options
    defines = {}
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
        ext_srcs=ext_srcs,
        inc_dirs=[
            get_svreal_header().parent,
            get_msdsl_header().parent,
            get_dir('inc/fpga')
        ],
        ext_model_file=True,
        disp_type='realtime',
        dump_waveforms=False,
        defines=defines,
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

        # print measured and expected
        print(f'Test case #{k}: pi_ctl={pi_ctl}, all_bits={new_bits}')
        print(f'[measured] sgn: {sgn_meas}, mag: {mag_meas}')
        print(f'[expected] sgn: {sgn_expct}, mag: {mag_expct}, analog_sample: {analog_sample}')

        # check results
        for sm, mm, se, me in zip(sgn_meas, mag_meas, sgn_expct, mag_expct):
            check_adc_result(sm, mm, se, me)

    # declare success
    print('Success!')
