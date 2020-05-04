# general imports
import os
import pytest
import numpy as np

from pathlib import Path

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'
if 'FPGA_SERVER' in os.environ:
    SIMULATOR = 'vivado'
else:
    SIMULATOR = 'ncsim'

@pytest.mark.parametrize((), [pytest.param(marks=pytest.mark.slow) if SIMULATOR=='vivado' else ()])
def test_sim():
    def qwrap(s):
        return f'"{s}"'
    defines = {
        'W_INP_TXT': qwrap(BUILD_DIR / 'w_inp.txt'),
        'W_OUT_TXT': qwrap(BUILD_DIR / 'w_out.txt'),
        'W_INC_TXT': qwrap(BUILD_DIR / 'w_inc.txt'),
        'W_PLS_TXT': qwrap(BUILD_DIR / 'w_pls.txt'),
        'DAVE_TIMEUNIT': '1fs',
        'NCVLOG': None
    }
    deps = get_deps_cpu_sim_new(impl_file=THIS_DIR / 'test.sv')
    print(deps)



    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        top_module='test',
        inc_dirs=[get_mlingua_dir() / 'samples', get_dir('inc/new_cpu')],
        defines=defines,
        simulator=SIMULATOR,
        flags=['-unbuffered']
#        dump_waveforms=True
    ).run()

    iw     = np.loadtxt(BUILD_DIR / 'w_inp.txt', dtype=float)
    ow     = np.loadtxt(BUILD_DIR / 'w_out.txt', dtype=float)
    inc    = np.loadtxt(BUILD_DIR / 'w_inc.txt', dtype=float)
    ow_pls = np.loadtxt(BUILD_DIR / 'w_pls.txt', dtype=float)



    # make sure that length of y is an integer multiple of length of x
    assert len(iw) == len(ow), \
        'Number of ADC codes must be an integer multiple of the number of input samples.'

    print(iw)
    print(ow)
    print(inc)
    print(ow_pls)

def convert_to_dictionary(array):
    new_dict = {}
    return array


def check_weights(iw, ow, inc, ow_pls):
    return 

if __name__ == "__main__":
    test_sim()
