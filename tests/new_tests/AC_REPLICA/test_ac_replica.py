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
# test.  The waveforms are stored in tests/new_tests/AC_REPLICA/build/waves.shm
DUMP_WAVEFORMS = False

@pytest.mark.parametrize((), [pytest.param(marks=pytest.mark.slow) if SIMULATOR=='vivado' else ()])
def test_sim():
    deps = get_deps_cpu_sim_new(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    def qwrap(s):
        return f'"{s}"'

    defines = {
        'TI_ADC_TXT': qwrap(BUILD_DIR / 'ti_adc.txt'),
        'DAVE_TIMEUNIT': '1fs',
        'NCVLOG': None
    }

    flags = ['-unbuffered']
    if DUMP_WAVEFORMS:
        defines['DUMP_WAVEFORMS'] = None
        flags += ['-access', '+r']

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        top_module='test',
        inc_dirs=[get_mlingua_dir() / 'samples', get_dir('inc/new_cpu')],
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
