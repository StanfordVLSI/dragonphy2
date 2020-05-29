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
        'TI_ADC_TXT': qwrap(BUILD_DIR / 'ti_adc.txt'),
        'DAVE_TIMEUNIT': '1fs',
        'NCVLOG': None,
        'SIMULATION': None
    }

    flags = ['-unbuffered']
    if dump_waveforms:
        defines['DUMP_WAVEFORMS'] = None
        flags += ['-access', '+r']

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        top_module='test',
        inc_dirs=[get_mlingua_dir() / 'samples', get_dir('inc/cpu')],
        defines=defines,
        simulator=SIMULATOR,
        flags=flags
    ).run()

    y = np.loadtxt(BUILD_DIR / 'ti_adc.txt', dtype=int, delimiter=',')
    y0 = y[:, 0]
    y1 = y[:, 1]

    plot_data(y0, y1)

    print('Checking replica 0...')
    check_data(y0)

    print('Checking replica 1...')
    check_data(y1)

def plot_data(y0, y1):
    plt.plot(y0[:100])
    plt.plot(y1[:100])
    plt.xlabel('Sample')
    plt.ylabel('ADC Code')
    plt.legend(['y0', 'y1'])
    plt.savefig(BUILD_DIR / 'ac.eps')
    plt.cla()
    plt.clf()

def check_data(y, enob_limit=5.0, npts=1000, Fs=1e9, Fstim=12.3e6):
    # gather results
    enob_result = enob(y[:npts], Fs=Fs, Fstim=Fstim)
    print(f'ENOB: {enob_result}')

    # print results
    assert enob_result >= enob_limit, 'ENOB is too low.'
