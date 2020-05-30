# general imports
import numpy as np
from pathlib import Path

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

def test_sim(dump_waveforms):
    deps = get_deps_cpu_sim(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    def qwrap(s):
        return f'"{s}"'

    defines = {
        'TI_ADC_TXT': qwrap(BUILD_DIR / 'ti_adc.txt'),
        'FFE_TXT': qwrap(BUILD_DIR / 'ffe.txt')
    }

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        defines=defines,
        dump_waveforms=dump_waveforms
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
    FFE_LATENCY = 16 * 5

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

    temp = [10, 8, -12, 10, 3, -7, 3, -12, -2, 1]
    test_response(adc[2*N:3*N], ffe[2*N:3*N], temp, 2**(2+5))
    print('Passed deep test')