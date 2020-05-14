# general imports
import os
import pytest
from pathlib import Path

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'
if 'FPGA_SERVER' in os.environ:
    SIMULATOR = 'vivado'
else:
    SIMULATOR = 'ncsim'

#@pytest.mark.wip
def test_sim():
    deps = get_deps_cpu_sim_new(impl_file=THIS_DIR / 'test.sv')
    print(deps)


    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        top_module='test',
        inc_dirs=[get_mlingua_dir() / 'samples', get_dir('inc/new_cpu')],
        defines={'DAVE_TIMEUNIT': '1fs', 'NCVLOG': None, 'SIMULATION':None},
        simulator=SIMULATOR,
        dump_waveforms = True
    ).run()

    # grab results
    with open(BUILD_DIR / 'tx_output.txt') as f:
        tx = f.read()
    with open(BUILD_DIR / 'ti_adc.txt') as f:
        adc = f.read()

    tx = [int(x) for x in tx.split()]
    adc = [int(x.replace(',', '')) for x in adc.split()]

    # what fraction of bits are correct when latency is 'shift'?
    def test_shift(shift):
        correct = 0
        N = len(tx) - shift
        for i in range(N):
            correct += (tx[i] ^ (adc[i+shift]<0))
        return correct / N

    # test various latencies and see which is best
    results = [test_shift(x) for x in range(100)]
    result = max(results)
    shift = results.index(result)

    print(f'Recovered bit percentage {100*result}%')
    print(f'Latency {shift} cycles')

    # TODO there is still lots of error because there is no FFE
    assert result > 0.6

if __name__ == '__main__':
    test_sim()
