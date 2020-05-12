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
    '''
    deps = get_deps_cpu_sim_new(impl_file=THIS_DIR / 'test.sv')
    print(deps)


    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        top_module='test',
        inc_dirs=[get_mlingua_dir() / 'samples', get_dir('inc/new_cpu')],
        defines={'DAVE_TIMEUNIT': '1fs', 'NCVLOG': None},
        simulator=SIMULATOR,
        dump_waveforms = True
    ).run()
'''
    # grab results

    with open(BUILD_DIR / 'tx_output.txt') as f:
        tx = f.read()
    with open(BUILD_DIR / 'ti_adc.txt') as f:
        adc = f.read()

    tx = [int(x) for x in tx.split()]
    adc = [int(x.replace(',', '')) for x in adc.split()]
    adc = [a - 0.5*b for a,b in zip(adc[:-1], adc[1:])] + [0]

    print(tx[:100])
    print(adc[:100])


    def test_shift(shift):
        correct = 0
        N = len(tx) - shift
        for i in range(N):
            correct += (tx[i] ^ (adc[i+shift]<0))
        return correct / N

    results = [test_shift(x) for x in range(2000)]
    print(results)
    print('BEST AND WORST', max(results), min(results))
    shift = results.index(max(results))
    for i in range(30):
        pairs = zip(tx[16*i:16*(i+1)], adc[16*i+shift:16*(i+1)+shift])
        print('\t'.join([str(t)+' '+str(a)+' ' for t,a in pairs]))

    def check(t, a):
        b = a > 0
        if (t,b) == (0, 0):
            return 0
        elif (t, b) == (1, 1):
            return 1
        elif (t, b) == (0, 1):
            return 2
        elif (t,b) == (1, 0):
            return 3


    for i in range(30):
        pairs = zip(tx[16*i:16*(i+1)], adc[16*i+shift:16*(i+1)+shift])
        print('\t'.join([str(check(t, a)) for t,a in pairs]))

    print('done')
    
if __name__ == '__main__':
    test_sim()
