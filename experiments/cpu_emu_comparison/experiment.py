#!/usr/bin/env python3

from argparse import ArgumentParser
from pathlib import Path
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

parser = ArgumentParser()
parser.add_argument('--fast_jtag', action='store_true', help='Use hierarchical I/O rather than true JTAG commands for reading and writing registers.  Useful for test development.')
parser.add_argument('--dump_waveforms', action='store_true', help='Dump waveforms for debugging purposes.  Useful for debugging, but should be disabled when gathering experimental data.')
args = parser.parse_args()

deps = get_deps_cpu_sim(
    impl_file=THIS_DIR / 'test.sv',
    override={
        'snh': THIS_DIR / 'snh.sv',
        'V2T_clock_gen_S2D': THIS_DIR / 'V2T_clock_gen_S2D.sv',
        'stochastic_adc_PR': THIS_DIR / 'stochastic_adc_PR.sv',
        'phase_interpolator': THIS_DIR / 'phase_interpolator.sv',
        'input_divider': THIS_DIR / 'input_divider.sv',
        'output_buffer': THIS_DIR / 'output_buffer.sv',
        'mdll_r1_top': 'chip_stubs'
    }
)
print(deps)

defines = {}
if args.fast_jtag:
    defines['FAST_JTAG'] = True

DragonTester(
    ext_srcs=deps,
    directory=BUILD_DIR,
    defines=defines,
    dump_waveforms=args.dump_waveforms
).run()
