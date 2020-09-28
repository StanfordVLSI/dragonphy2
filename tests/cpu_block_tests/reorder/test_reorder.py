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
        'OUT_TXT': qwrap(BUILD_DIR / 'out.txt'),
        'REP_TXT': qwrap(BUILD_DIR / 'rep.txt')
    }

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        defines=defines,
        dump_waveforms=dump_waveforms
    ).run()

    # check the main ADC slices
    meas = np.loadtxt(BUILD_DIR / 'out.txt', dtype=int, delimiter=',')
    meas = meas.flatten()
    expct = np.arange(-128, 128)
    assert (meas == expct).all(), 'Data mismatch for main ADC slices'

    # check the replica ADC slices
    meas = np.loadtxt(BUILD_DIR / 'rep.txt', dtype=int, delimiter=',')
    meas = meas.flatten()
    expct = np.array([+12, -34]*16)
    assert (meas == expct).all(), 'Data mismatch for replica ADC slices'
