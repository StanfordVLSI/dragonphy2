# general imports
import numpy as np
import matplotlib.pyplot as plt
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
        'TI_ADC_TXT_2': qwrap(BUILD_DIR / 'ti_adc2.txt')
    }
    
    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        defines=defines,
        dump_waveforms=dump_waveforms
    ).run()

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
