# general imports
import numpy as np
import matplotlib.pyplot as plt
from sklearn import linear_model
from pathlib import Path

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

def test_sim():
    def qwrap(s):
        return f'"{s}"'

    defines = {
        'DELAY_TXT': qwrap(BUILD_DIR / 'delay.txt'),
        'ADDER_TXT': qwrap(BUILD_DIR / 'adder.txt')
    }

    deps = get_deps_cpu_sim(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        defines=defines
    ).run()

    x = np.loadtxt(BUILD_DIR / 'delay.txt', dtype=float)
    y = np.loadtxt(BUILD_DIR / 'adder.txt', dtype=int, delimiter=',')
    y = y.flatten()

    # make sure that length of y is an integer multiple of length of x
    assert len(y) % len(x) == 0, \
        'Number of ADC codes must be an integer multiple of the number of input samples.'

    # repeat input as necessary
    num_repeat = len(y) // len(x)
    x = np.repeat(x, num_repeat)

    assert len(x) == len(y), \
        'Lengths of x and y should match at this point.'

    plot_data(x, y)
    check_data(x, y)

def plot_data(x, y):
    plt.plot(1e12*x, y, '*')
    plt.xlabel('Delay (ps)')
    plt.ylabel('Adder output')

    plt.savefig(BUILD_DIR / 'tdc.eps')

    plt.cla()
    plt.clf()

def check_data(x, y, inl_limit=5, offset_limit=5, gain_bnds=(0.23, 0.28)):
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
    gain = regr.coef_[0] * 1e-12
    assert min(gain_bnds) <= gain <= max(gain_bnds), f'Gain out of spec: {gain} LSB/ps.'
    print(f'Gain OK: {gain} LSB/ps.')