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

    num_of_test_cycles = 5

    seq_length = 3
    num_of_trellis_patterns = 4
    trellis_pattern_depth = 4

    channel_shift = 3
    nrz_mode      = 0
    channel_est       = [0, 125, 250, 125, 65, 32]
    channel_est       = channel_est + (30 -len(channel_est))*[0]
    trellis_patterns = [
                            [+1,  0,  0,  0],
                            [+1, -1,  0,  0],
                            [+1,  0,  0, -1],
                            [+1, -1, +1, -1] 
    ]

    
    error_checker_i = ErrorCheckerPipeline(16, seq_length, num_of_trellis_patterns, trellis_pattern_depth, 1)
    injection_error_seqs = ErrorInjectionEngine(seq_length, 4, channel_shift, nrz_mode, channel_est, trellis_patterns)

    gold_model_results = []

    res_errors_in = np.random.randint(-10, 10, size=(16,num_of_test_cycles), dtype=np.int32)
    res_errors_in[3:3+seq_length,1] += injection_error_seqs[3]

    syms_in = np.zeros((16, num_of_test_cycles), dtype=np.int32)

    for ii in range(num_of_test_cycles):
        syms_in[:,ii] = np.random.randint(0, 4, size=(16,))
        result = error_checker_i.at_posedge_clock(syms_in[:,ii], res_errors_in[:,ii], channel_est, channel_shift, trellis_patterns)
        gold_model_results += [result]

    write_error_pipeline_inputs(BUILD_DIR / 'ep_inputs.txt', num_of_test_cycles, syms_in, res_errors_in, channel_est, channel_shift, trellis_patterns)

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        defines={}
    ).run()

    actual_results = read_error_pipeline_outputs(BUILD_DIR / 'ep_outputs.txt', num_of_test_cycles)
    assert check_outputs(gold_model_results, actual_results) == 0

def write_error_pipeline_inputs(filename, num_of_test_cycles, syms_in, res_errors_in, channel, channel_shift, trellis_patterns):
    def print_array_to_file(arr, file):
        print('{' + ' '.join([str(val) for val in arr]) + '}', file=file)
    
    with open(filename, 'w') as f:
        print_array_to_file(channel, f)
        print(f'{channel_shift}', file=f)
        for arr in trellis_patterns:
            print_array_to_file(arr, f)
            
        for ii in range(num_of_test_cycles):
            print_array_to_file(syms_in[:,ii], f)
            print_array_to_file(res_errors_in[:,ii], f)


def read_error_pipeline_outputs(filename, num_of_test_cycles):
    def read_iteration(line):
        return int(line.split()[1].strip()[:-1])

    def read_array(line):
        new_arr = line.strip()[1:-1].strip().split()
        return np.array([int(val) for val in new_arr])

    actual_results = []

    with open(filename, 'r') as f:
        for ii in range(num_of_test_cycles):
            read_iteration(f.readline())
            actual_results += [(read_array(f.readline()), 
            read_array(f.readline()),
            read_array(f.readline()),
            read_array(f.readline()))]

    return actual_results

def check_outputs(gold_model_results, actual_results):
    difference = 0
    for gfl, fl in zip(gold_model_results, actual_results):
        for arr1, arr2 in zip(gfl, fl):
            print(arr1, arr2)
            difference += np.sum(np.abs(arr1-arr2))
        print()
    return difference


if __name__ == "__main__":
    seq_length = 3
    num_of_trellis_patterns = 4
    trellis_pattern_depth = 4

    error_checker_i = ErrorCheckerPipeline(16, seq_length, num_of_trellis_patterns, trellis_pattern_depth, 3)

    channel_est   = [25, 125, 250, 125, 65, 32]
    channel_shift = 3
    trellis_patterns = [
                        [+1,  0,  0,  0],
                        [+1, -1,  0,  0],
                        [+1,  0,  0, -1],
                        [+1, -1, +1, -1]
    ]

    injection_error_seqs = ErrorInjectionEngine(seq_length, 4, channel_shift, 0, channel_est, trellis_patterns)

    syms_in = np.random.randint(0, 4, size=(16,)) #np.array([{0:-3, 1:-1, 2:1, 3:3}[val] for val in np.random.randint(0, 4, size=(16,))])

    res_errors_in = np.random.randint(-5, 5, size=16)
    result = error_checker_i.at_posedge_clock(syms_in, res_errors_in, channel_est, channel_shift, trellis_patterns)
    print(result)

    syms_in = np.random.randint(0, 4, size=(16,)) #np.array([{0:-3, 1:-1, 2:1, 3:3}[val] for val in np.random.randint(0, 4, size=(16,))])
    res_errors_in = np.random.randint(-5, 5, size=16)
    res_errors_in[3:3+seq_length] += injection_error_seqs[0]

    result = error_checker_i.at_posedge_clock(syms_in, res_errors_in, channel_est, channel_shift, trellis_patterns)
    print(result)

    syms_in = np.random.randint(0, 4, size=(16,))#np.array([{0:-3, 1:-1, 2:1, 3:3}[val] for val in np.random.randint(0, 4, size=(16,))])
    res_errors_in = np.random.randint(-5, 5, size=16)

    result = error_checker_i.at_posedge_clock(syms_in, res_errors_in, channel_est, channel_shift, trellis_patterns)
    print(result)

    syms_in = np.random.randint(0, 4, size=(16,))#np.array([{0:-3, 1:-1, 2:1, 3:3}[val] for val in np.random.randint(0, 4, size=(16,))])
    res_errors_in = np.random.randint(-5, 5, size=16)

    result = error_checker_i.at_posedge_clock(syms_in, res_errors_in, channel_est, channel_shift, trellis_patterns)
    print(result)