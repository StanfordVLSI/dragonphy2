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

@pytest.mark.wip
def test_sim():
    deps = get_deps_cpu_sim_new(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        top_module='test',
        inc_dirs=[get_mlingua_dir() / 'samples', get_dir('inc/new_cpu')],
        defines={'DAVE_TIMEUNIT': '1fs', 'NCVLOG': None},
        simulator=SIMULATOR,
        flags=['-unbuffered'],
        dump_waveforms=True
	).run()

    y = np.loadtxt(BUILD_DIR / 'ti_adc.txt', dtype=int, delimiter=',')
    y = y.flatten()

    plot_data(y)
#    check_data(x, y)

def plot_data(y):
    plt.plot(y[:100])
    plt.xlabel('Sample')
    plt.ylabel('ADC Code')
    plt.show()
    #plt.savefig(BUILD_DIR / 'ac.eps')
    #plt.cla()
    #plt.clf()

# def check_data(x, y, inl_limit=5, offset_limit=2.5, gain_bnds=(250, 290)):
#     # compute linear regression
#     regr = linear_model.LinearRegression()
#     regr.fit(x[:, np.newaxis], y)
#
#     # INL
#     y_fit = regr.predict(x[:, np.newaxis])
#     inl = np.max(np.abs(y - y_fit))
#     assert inl <= inl_limit, f'INL out of spec: {inl}.'
#     print(f'INL OK: {inl}')
#
#     # offset
#     offset = regr.intercept_
#     assert -offset_limit <= offset <= offset_limit, f'Offset out of spec: {offset}.'
#     print(f'Offset OK: {offset}')
#
#     # gain
#     gain = regr.coef_[0]
#     assert min(gain_bnds) <= gain <= max(gain_bnds), f'Gain out of spec: {gain} LSB/Volt.'
#     print(f'Gain OK: {gain} LSB/Volt.')
