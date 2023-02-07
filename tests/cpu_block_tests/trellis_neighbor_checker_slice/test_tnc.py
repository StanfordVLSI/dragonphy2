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

    for ies in injection_error_seqs:
        est_error = ies + np.random.randint(-10,10,size=3)
        null_energy = np.sum(np.square(est_error))

        gold_model_flag, lwe = TrellisNeighborCheckerSlice(3, 4, injection_error_seqs, est_error, null_energy)


        write_tnc_inputs(BUILD_DIR / 'tnc_inputs.txt', injection_error_seqs, est_error, null_energy)

        DragonTester(
            ext_srcs=deps,
            directory=BUILD_DIR,
            defines={}
        ).run()

        actual_flag = read_tnc_outputs(BUILD_DIR / 'tnc_outputs.txt')

        assert check_best_flag_idx(gold_model_flag, actual_flag) == 0

def write_tnc_inputs(filename, injection_error_seqs, est_error, null_energy):
    with open(filename, 'w') as f:
        for arr in injection_error_seqs:
            for val in arr:
                print(f'{val}', file=f)
        for val in est_error:
            print(f'{val}', file=f)
        print(f'{null_energy}', file=f)


def read_tnc_outputs(filename):
    actual_flag = 0
    with open(filename, 'r') as f:
        actual_flag = int(f.readline())
    return actual_flag

def check_best_flag_idx(gold_model_flag, flag):
    return abs(gold_model_flag - flag)


if __name__ == "__main__":
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
    est_error = injection_error_seqs[3] + np.random.randint(-10,10,size=3)
    null_energy = np.sum(np.square(est_error))

    gold_model_flag, lwe = TrellisNeighborCheckerSlice(3, 4, injection_error_seqs, est_error, null_energy)

    assert(check_best_flag_idx(gold_model_flag, 4) == 0)