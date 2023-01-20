from pathlib import Path
from dragonphy import *
import numpy as np
import os

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

Path(BUILD_DIR).mkdir(parents=True, exist_ok=True)


def test_sim():
    deps = get_deps_cpu_sim(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    def qwrap(s):
        return f'"{s}"'

    channel_shift = 3
    nrz_mode      = 0
    channel       = [0, 125, 250, 125, 65, 32]
    trellis_patterns = [
                            [+1,  0,  0,  0],
                            [+1, -1,  0,  0],
                            [+1,  0,  0, -1],
                            [+1, -1, +1, -1]
    ]

    injection_error_seqs = ErrorInjectionEngine(3, 4, channel_shift, nrz_mode, channel, trellis_patterns)

    est_errors = np.random.randint(-10, 10, size=32)
    for ii, val in enumerate(injection_error_seqs[0]):
        est_errors[ii + 16] += val
        est_errors[ii + 16 + 2] += val

    gold_model_flags = TrellisNeighborChecker(16, 3, 4, channel, trellis_patterns, nrz_mode, est_errors, cp=2)

    write_tnc_inputs(BUILD_DIR / 'tnc_inputs.txt', channel, trellis_patterns, est_errors)

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        defines={}
    ).run()

    actual_flag = read_tnc_outputs(BUILD_DIR / 'tnc_outputs.txt')
    print(actual_flag)
    print(gold_model_flags)
    assert check_flags(gold_model_flags, actual_flag) == 0

def write_tnc_inputs(filename, channel, trellis_patterns, est_errors):
    with open(filename, 'w') as f:
        for val in channel:
            print(f'{val}', file=f)
        for arr in trellis_patterns:
            for val in arr:
                print(f'{val}', file=f)
        for val in est_errors:
            print(f'{val}', file=f)

def read_tnc_outputs(filename):
    actual_flag = []
    with open(filename, 'r') as f:
        for line in f.readlines():
            actual_flag += [int(line)]
    return actual_flag

def check_flags(gold_model_flags, flags):
    difference = 0
    for gfl, fl in zip(gold_model_flags, flags):
        difference += abs(gfl - fl)
    return difference


if __name__ == "__main__":
    seq_length    = 3
    channel_shift = 3
    nrz_mode      = 0
    channel       = [25, 125, 250, 125, 65, 32]
    trellis_patterns = [
                            [+1,  0,  0,  0],
                            [+1, -1,  0,  0],
                            [+1,  0,  0, -1],
                            [+1, -1, +1, -1]
    ]

    injection_error_seqs = ErrorInjectionEngine(seq_length, 4, channel_shift, nrz_mode, channel, trellis_patterns)

    est_errors = np.random.randint(-10, 10, size=32)
    for ii, val in enumerate(injection_error_seqs[2]):
        est_errors[ii + 16] += val

    print(est_errors[16 - seq_length: 32 - seq_length])

    gold_model_flags = TrellisNeighborChecker(16, seq_length, 4, channel, trellis_patterns, nrz_mode, est_errors, cp=2)

    print(gold_model_flags)
    for flag in gold_model_flags:
        if flag > 0:
            print(injection_error_seqs[flag-1])