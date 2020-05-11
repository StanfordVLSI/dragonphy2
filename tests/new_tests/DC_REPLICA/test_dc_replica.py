# general imports
import os
import pytest
import numpy as np
import matplotlib.pyplot as plt
from sklearn import linear_model
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
# test.  The waveforms are stored in tests/new_tests/DC_REPLICA/build/waves.shm
DUMP_WAVEFORMS = False

@pytest.mark.parametrize((), [pytest.param(marks=pytest.mark.slow) if SIMULATOR=='vivado' else ()])
def test_sim():
    deps = get_deps_cpu_sim_new(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    def qwrap(s):
        return f'"{s}"'

    defines = {
        'TI_ADC_TXT': qwrap(BUILD_DIR / 'ti_adc.txt'),
        'RX_INPUT_TXT': qwrap(BUILD_DIR / 'rx_input.txt'),
        'WIDTH_TXT': qwrap(BUILD_DIR / 'width.txt'),
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
        inc_dirs=[get_mlingua_dir() / 'samples', get_dir('inc/new_cpu')],
        defines=defines,
        simulator=SIMULATOR,
        flags=flags
    ).run()

    x = np.loadtxt(BUILD_DIR / 'rx_input.txt', dtype=float)

    y = np.loadtxt(BUILD_DIR / 'ti_adc.txt', dtype=int, delimiter=',')
    y = y.flatten()

    widths = np.loadtxt(BUILD_DIR / 'width.txt', dtype=float, delimiter=',')
    widths = widths.flatten()

    # make sure that length of y is an integer multiple of length of x
    assert len(y) % len(x) == 0, \
        'Number of ADC codes must be an integer multiple of the number of input samples.'

    # repeat input as necessary
    num_repeat = len(y) // len(x)
    x = np.repeat(x, num_repeat)

    assert len(x) == len(y), \
        'Lengths of x and y should match at this point.'

    plot_data(x, y, widths)
    check_data(x, y)

def plot_data(x, y, widths):
    plt.plot(x, y, '*')
    plt.xlabel('Differential input voltage')
    plt.ylabel('ADC Code')
    plt.savefig(BUILD_DIR / 'dc.eps')
    plt.cla()
    plt.clf()

    plt.plot(x, widths*1e12, '*')
    plt.xlabel('Differential input voltage')
    plt.ylabel('PFD Out Width (ps)')
    plt.savefig(BUILD_DIR / 'widths.eps')
    plt.cla()
    plt.clf()

def check_data(x, y, inl_limit=5, offset_limit=2.5, gain_bnds=(260, 300)):
    # compute linear regression
    regr = linear_model.LinearRegression()
    regr.fit(x[:, np.newaxis], y)

    # INL
    y_fit = regr.predict(x[:, np.newaxis])
    inl = np.max(np.abs(y - y_fit))
    assert inl <= inl_limit, f'INL out of spec: {inl}.'
    print(f'INL OK: {inl}')

    # offset
    offset = regr.intercept_
    assert -offset_limit <= offset <= offset_limit, f'Offset out of spec: {offset}.'
    print(f'Offset OK: {offset}')

    # gain
    gain = regr.coef_[0]
    assert min(gain_bnds) <= gain <= max(gain_bnds), f'Gain out of spec: {gain} LSB/Volt.'
    print(f'Gain OK: {gain} LSB/Volt.')