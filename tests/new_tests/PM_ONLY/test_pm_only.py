# general imports
import os
import pytest
from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'
if 'FPGA_SERVER' in os.environ:
    SIMULATOR = 'vivado'
else:
    SIMULATOR = 'ncsim'

CLK_ASYNC_FREQ = 501e6
CLK_REF_FREQ = 4e9
N_PM = 20
T_TOL = 1e-12

@pytest.mark.parametrize((), [pytest.param(marks=pytest.mark.slow) if SIMULATOR=='vivado' else ()])
def test_sim():
    def qwrap(s):
        return f'"{s}"'
    defines = {
        'PM_TXT': qwrap(BUILD_DIR / 'pm.txt'),
        'DELAY_TXT': qwrap(BUILD_DIR / 'delay.txt'),
        'CLK_ASYNC_FREQ': CLK_ASYNC_FREQ,
        'CLK_REF_FREQ': CLK_REF_FREQ,
        'N_TESTS': 100,
        'DAVE_TIMEUNIT': '1fs',
        'NCVLOG': None
    }

    deps = get_deps_cpu_sim_new(impl_file=THIS_DIR / 'test.sv')
    deps.insert(0, Directory.path() + '/build/all/adapt_fir/ffe_gpack.sv')
    deps.insert(0, Directory.path() + '/build/all/adapt_fir/cmp_gpack.sv')
    deps.insert(0, Directory.path() + '/build/all/adapt_fir/mlsd_gpack.sv')
    deps.insert(0, Directory.path() + '/build/all/adapt_fir/constant_gpack.sv')
    deps.insert(0, Directory.path() + '/vlog/new_pack/dsp_pack.sv')
    print(deps)

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        top_module='test',
        inc_dirs=[get_mlingua_dir() / 'samples', get_dir('inc/new_cpu')],
        defines=defines,
        simulator=SIMULATOR
    ).run()

    delay = np.loadtxt(BUILD_DIR / 'delay.txt', dtype=float)

    # get PM estimate of delay
    pm = np.loadtxt(BUILD_DIR / 'pm.txt', dtype=float)
    pm *= (1.0/CLK_ASYNC_FREQ)/(2**(N_PM+1))

    # plot results
    plot_data(delay=delay, pm=pm)

    # check the results
    check_data(delay=delay, pm=pm)

def plot_data(delay, pm):
    plt.plot(delay*1e12, pm*1e12, '*')
    plt.plot(delay*1e12, ((1/CLK_REF_FREQ)-pm)*1e12, '*')
    plt.xlabel('True Delay (ps)')
    plt.ylabel('Phase Monitor Estimate (ps)')
    plt.legend(['Test', 'Tref-Test'])

    plt.tight_layout()
    plt.savefig(BUILD_DIR / 'pm.eps')

    plt.cla()
    plt.clf()

def check_data(delay, pm):
    for t_true, t_est in zip(delay, pm):
        # there is a 180 degree ambiguity in the measurement
        delta_1 = abs(t_true - t_est)
        delta_2 = abs(t_true - ((1/CLK_REF_FREQ) - t_est))
        delta = min(delta_1, delta_2)
        print(delta_1, delta_2)

        assert delta <= T_TOL, \
            f'Phase measurement error of {delta*1e12} ps is out of spec.'
