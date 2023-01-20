from pathlib import Path
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

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

    write_eie_inputs(BUILD_DIR / 'eie_inputs.txt', channel_shift, nrz_mode, channel, trellis_patterns)

    defines = {}

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        defines=defines
    ).run()

    injection_error_seqs = read_eie_outputs(BUILD_DIR / 'eie_outputs.txt')
    gold_model_error_seqs = ErrorInjectionEngine(3, 4, 3, 0, channel, trellis_patterns)
    assert check_injection_error_seqs(gold_model_error_seqs, injection_error_seqs) == 0 

def write_eie_inputs(filename, channel_shift, nrz_mode, channel, trellis_patterns):
    with open(filename, 'w') as f:
        print(f'{channel_shift}', file=f)
        print(f'{nrz_mode}', file=f)
        for val in channel:
            print(f'{val}', file=f)
        for arr in trellis_patterns:
            for val in arr:
                print(f'{val}', file=f)

def read_eie_outputs(filename):
    with open(filename, 'r') as f:
        lines = f.readlines()
        injection_error_seqs = []
        for line in lines:
            line = line.strip()
            line = line.replace('{', '').replace('}', '')
            injection_error_seqs.append([int(x) for x in line.split(',')][::-1])
    return injection_error_seqs

def check_injection_error_seqs(gold_model_error_seqs, injection_error_seqs):

    difference = 0
    for ii in range(len(injection_error_seqs)):
        for jj in range(len(injection_error_seqs[ii])):
            difference += abs(injection_error_seqs[ii][jj] - gold_model_error_seqs[ii][jj])

    return difference


if __name__ == "__main__":
    a = ErrorInjectionEngine(3, 4, 3, 0, [0, 125, 250, 125, 65, 32, 16], [[+1,  0,  0,  0], [+1, -1,  0,  0], [+1,  0,  0, -1], [+1, -1, +1, -1]])
    b = read_eie_outputs(BUILD_DIR / 'eie_outputs.txt')
    assert(check_injection_error_seqs(a, b) == 0)