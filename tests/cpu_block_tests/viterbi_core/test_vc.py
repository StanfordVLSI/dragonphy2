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

    est_channel = [2**(5-ii) for ii in range(5)] + [0]*25
    rse_val = np.convolve([0,0,-1,1,0,0,1,0,1,0], est_channel)[:32] * 2 + np.random.randint(-4, 4, 32)

    print(rse_val)
    write_vc_inputs(BUILD_DIR / 'vc_inputs.txt',
        est_channel, rse_val
    )

    DragonTester(
        ext_srcs=deps,
        dump_waveforms=True,
        simulator='xcelium',
        directory=BUILD_DIR,
        defines={}
    ).run()

    state_vals = read_vc_outputs(BUILD_DIR / 'vc_outputs.txt')
    print(rse_val)


def write_vc_inputs(filename, 
    est_channel, rse_val):
    with open(filename, 'w') as f:

        for val in est_channel:
            print(f'{val}', file=f)

        for val in rse_val:
            print(f'{val}', file=f)


    return 

def read_vc_outputs(filename):
    state_vals = []


    with open(filename, 'r') as f:
        for ii in range(2):
            state_vals.append(int(f.readline()))

    return state_vals


if __name__ == "__main__":
    print('hi')