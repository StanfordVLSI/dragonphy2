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
        'TI_ADC_TXT': qwrap(BUILD_DIR / 'ti_adc.txt')
    }

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        defines=defines,
        dump_waveforms=dump_waveforms
    ).run()

    tx = np.loadtxt(BUILD_DIR / 'tx_output.txt', dtype=int, delimiter=',')
    tx = tx.flatten()

    adc = np.loadtxt(BUILD_DIR / 'ti_adc.txt', dtype=int, delimiter=',')
    adc = adc.flatten()

    # what fraction of bits are correct when latency is 'shift'?
    def test_shift(shift):
        correct = 0
        N = len(tx) - shift
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

if __name__ == "__main__":
    test_sim()
