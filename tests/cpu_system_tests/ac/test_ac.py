# general imports
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'
SIMULATOR = 'ncsim'

def test_sim(dump_waveforms):
    deps = get_deps_cpu_sim(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    def qwrap(s):
        return f'"{s}"'

    defines = {
        'TI_ADC_TXT': qwrap(BUILD_DIR / 'ti_adc.txt')
    }

    flags = ['-unbuffered']
    if dump_waveforms:
        defines['DUMP_WAVEFORMS'] = None
        flags += ['-access', '+r']

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        defines=defines,
        dump_waveforms=dump_waveforms
    ).run()

    y = np.loadtxt(BUILD_DIR / 'ti_adc.txt', dtype=int, delimiter=',')
    y = y.flatten()

    plot_data(y)
    check_data(y)

def plot_data(y):
    plt.plot(y[:100])
    plt.xlabel('Sample')
    plt.ylabel('ADC Code')
    plt.savefig(BUILD_DIR / 'ac.eps')
    plt.cla()
    plt.clf()

def check_data(y, enob_limit=4.5, npts=1000, Fs=16e9, Fstim=1.023e9):
    # gather results
    enob_result = enob(y[:npts], Fs=Fs, Fstim=Fstim)
    print(f'ENOB: {enob_result}')

    # print results
    assert enob_result >= enob_limit, 'ENOB is too low.'

if __name__ == "__main__":
    test_sim()
