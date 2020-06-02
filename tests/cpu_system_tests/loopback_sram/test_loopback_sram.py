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
        'SRAM_OUT_TXT': qwrap(BUILD_DIR / 'sram_out.txt')
    }

    # NOTE This times out after 10us, after reading 1312*16
    # bits back from SRAM.
    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        defines=defines,
        dump_waveforms=dump_waveforms
    ).run()

    tx = np.loadtxt(BUILD_DIR / 'tx_output.txt', dtype=int, delimiter=',')
    tx = tx.flatten()

    # reading file is a little strange because sram captures
    # 8 sets of data per cycle and we only care about first 16
    # The last 2 are "x" so we can't use default np loader
    NUM_ADC = 16
    adc_txt = open(BUILD_DIR / 'sram_out.txt').readlines()
    adc2 = [line.strip().split(',') for line in adc_txt]
    adc3 = [line[:NUM_ADC] for line in adc2]
    adc = np.array(adc3, dtype=int)
    adc = adc.flatten()

    # what fraction of bits are correct when latency is 'shift'?
    def test_shift(shift):
        correct = 0
        N = min(len(tx), len(adc)) - shift
        for i in range(N):
            correct += (tx[i] ^ (adc[i+shift]<0))
        return correct / N

    # test various latencies and see which is best
    results = [test_shift(x) for x in range(200)]
    result = max(results)
    shift = results.index(result)

    print(f'Recovered bit percentage {100*result}%')
    print(f'Latency {shift} cycles')

    # channel is lossless, should get 100%
    assert result == 1.0
