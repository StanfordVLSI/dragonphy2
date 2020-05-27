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
    '''
    deps = get_deps_cpu_sim_new(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    def qwrap(s):
        return f'"{s}"'

    defines = {
        'TI_ADC_TXT': qwrap(BUILD_DIR / 'ti_adc.txt'),
        'TI_ADC_TXT_2': qwrap(BUILD_DIR / 'ti_adc2.txt'),
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
    '''
    y = np.loadtxt(BUILD_DIR / 'ti_adc.txt', dtype=int, delimiter=',')
    y = y.flatten()

    plot_data(y)
    enob1 = check_data(y)

    y2 = np.loadtxt(BUILD_DIR / 'ti_adc2.txt', dtype=int, delimiter=',')
    y2 = y2.flatten()

    plot_data(y2)
    enob2 = check_data(y2)

    delta = enob2 - enob1
    assert delta > 0.3, f'ENOB improvement only {delta}, expected ~0.5'

def plot_data(y):
    plt.plot(y[:100])
    plt.xlabel('Sample')
    plt.ylabel('ADC Code')
    plt.savefig(BUILD_DIR / 'ac.eps')
    plt.cla()
    plt.clf()

def check_data(y, enob_limit=4.5, npts=1000, Fs=16e9, Fstim=1.023e9):
    # gather results
    # ADC_BITS is used only for quantizing remapped values
    ADC_BITS = 8
    y_remap = remap(y, Fs, Fstim, ADC_BITS)
    enob_result = enob(y_remap[:npts], Fs=Fs, Fstim=Fstim)
    print(f'ENOB: {enob_result}')

    # print results
    assert enob_result >= enob_limit, 'ENOB is too low.'
    return enob_result

if __name__ == "__main__":
    test_sim()
