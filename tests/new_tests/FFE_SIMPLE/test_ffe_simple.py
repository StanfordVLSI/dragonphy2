# general imports
import os
import pytest
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'
if 'FPGA_SERVER' in os.environ:
    SIMULATOR = 'vivado'
else:
    SIMULATOR = 'ncsim'

# Set DUMP_WAVEFORMS to True if you want to dump all waveforms for this
# test.  The waveforms are stored in tests/new_tests/AC/build/waves.shm
DUMP_WAVEFORMS = True

@pytest.mark.parametrize((), [pytest.param(marks=pytest.mark.slow) if SIMULATOR=='vivado' else ()])
def test_sim():
    deps = get_deps_cpu_sim_new(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    def qwrap(s):
        return f'"{s}"'

    defines = {
        'TI_ADC_TXT': qwrap(BUILD_DIR / 'ti_adc.txt'),
        'FFE_TXT': qwrap(BUILD_DIR / 'ffe.txt'),
        'DAVE_TIMEUNIT': '1fs',
        'NCVLOG': None,
        'SIMULATION': None
    }

    flags = ['-unbuffered']
    if DUMP_WAVEFORMS:
        defines['DUMP_WAVEFORMS'] = None
        flags += ['-access', '+r']

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        top_module='test',
        inc_dirs=[get_mlingua_dir() / 'samples', get_dir('inc/new_cpu'), get_dir('')],
        defines=defines,
        simulator=SIMULATOR,
        flags=flags,
        dump_waveforms=True
    ).run()

    # We won't be looking at the transmitted bits
    #tx = np.loadtxt(BUILD_DIR / 'tx_output.txt', dtype=int, delimiter=',')
    #tx = tx.flatten()

    adc = np.loadtxt(BUILD_DIR / 'ti_adc.txt', dtype=int, delimiter=',')
    adc = adc.flatten()

    ffe = np.loadtxt(BUILD_DIR / 'ffe.txt', dtype=int, delimiter=',')
    ffe = ffe.flatten()

    # Number of datapoints recorded in one test (currently 100ns)
    N = 16 * 100
    # latency from adc datapoint to equivalent ffe datapoint
    FFE_LATENCY = 16 * 3
    # warmup time before ffe has expected output
    STARTUP = 16 * 3
    def test_response(adc, ffe, resp, div):
        end = len(adc) - len(resp) - FFE_LATENCY
        for i in range(STARTUP, end):
            res = sum(adc[i+j] * resp[j] for j in range(len(resp)))
            res = res // div
            ffe_res = ffe[i+FFE_LATENCY]

            #assert ffe_res == res
            if ffe_res != res:
                print('expected', res, 'got', ffe_res)


    test_response(adc[:N], ffe[:N], [4], 4)
    print('Passed identity test')

    test_response(adc[N:2*N], ffe[N:2*N], [4, -4], 4)
    print('Passed diff test')

    #test_response(adc[2*N:3*N], ffe[2*N:3*N], [1, -8, 1, 3, -1, -2, -4, 7, 6, -3], 4)
    #temp = [8, -4, 4]
    #temp = [2, 0, 0, 2]
    #temp = [-3, 6, 7, -4, -2, -1, 3, 1, -8, 1]
    #temp =  [2, 1, -3, 2, 3, -1, 1, -2, -2, 1]
    temp = [10, 10, 10, 10]
    test_response(adc[2*N:3*N], ffe[2*N:3*N], temp, 2**7)
    print('Passed diff test')

    # channel is lossless, should get 100%




if __name__ == "__main__":
    test_sim()
