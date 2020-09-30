#!/usr/bin/env python3

# general imports
from argparse import ArgumentParser
from pathlib import Path

# DragonPHY-specific
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

parser = ArgumentParser()
parser.add_argument('--dump_waveforms', action='store_true', help='Dump waveforms for debugging purposes.')
parser.add_argument('--chan_tau', default=100e-12, type=float, help='Time constant of the channel in seconds')
parser.add_argument('--chan_dly', default=15e-12, type=float, help='Delay of the channel in seconds.')
parser.add_argument('--etol', default=None, type=float, help='Error tolerance for modeling.')
args = parser.parse_args()

# read dependencies from a pickle file if desired
deps = get_deps_cpu_sim(impl_file=THIS_DIR / 'test.sv')

defines = {
    'CHAN_TAU': args.chan_tau,
    'CHAN_DLY': args.chan_dly
}

DragonTester(
    ext_srcs=deps,
    directory=BUILD_DIR,
    defines=defines,
    dump_waveforms=args.dump_waveforms
).run()
