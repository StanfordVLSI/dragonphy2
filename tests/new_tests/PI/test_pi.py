# general imports
import os
import numpy as np
import matplotlib.pyplot as plt
import pytest
from pathlib import Path
from sklearn import linear_model

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'
if 'FPGA_SERVER' in os.environ:
    SIMULATOR = 'vivado'
else:
    SIMULATOR = 'ncsim'

# testing parameters
T_PER = 1/4e9
INL_LIM = 10e-12
OFFSET_NOM = 233e-12
OFFSET_DEV = 500e-12
GAIN_MIN = 0.3e-12
GAIN_MAX = 1.9e-12
MONOTONIC_LIM = -0.01e-12
RES_LIM = 3.5e-12

@pytest.mark.parametrize((), [pytest.param(marks=pytest.mark.slow) if SIMULATOR=='vivado' else ()])
def test_sim():
    deps = get_deps_cpu_sim_new(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    def qwrap(s):
        return f'"{s}"'
    defines = {
        'PI_CTL_TXT': qwrap(BUILD_DIR / 'pi_ctl.txt'),
        'DELAY_TXT': qwrap(BUILD_DIR / 'delay.txt'),
        'DAVE_TIMEUNIT': '1fs',
        'NCVLOG': None
    }

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        top_module='test',
        inc_dirs=[get_mlingua_dir() / 'samples', get_dir('inc/new_cpu')],
        defines=defines,
        simulator=SIMULATOR,
        flags=['-unbuffered']
    ).run()

    pi_ctl = np.loadtxt(BUILD_DIR / 'pi_ctl.txt', dtype=int, delimiter=',')
    delay = np.loadtxt(BUILD_DIR / 'delay.txt', dtype=float, delimiter=',')

    # unwrap phase
    delay_unwrapped = np.zeros(delay.shape, dtype=float)
    for k in range(delay.shape[1]):
        # get original delay values
        delay_unwrapped[:, k] = delay[:, k]
        # convert to phase
        scale_factor = 2*np.pi/T_PER
        delay_unwrapped[:, k] *= scale_factor
        # unwrap with built-in function
        delay_unwrapped[:, k] = np.unwrap(delay_unwrapped[:, k])
        # convert back to time
        delay_unwrapped[:, k] /= scale_factor

    # plot results
    plot_data(pi_ctl, delay_unwrapped)

    # check each PI
    for k in range(pi_ctl.shape[1]):
        print(f'Checking PI #{k}...')
        check_pi(pi_ctl[:, k], delay_unwrapped[:, k])
        if k != (pi_ctl.shape[1]-1):
            print('')

def plot_data(pi_ctl, delay):
    fig = plt.figure(figsize=(10, 9))
    Nout = pi_ctl.shape[1]

    for k in range(Nout):
        ax = fig.add_subplot(Nout, 1, k+1)
        ax.plot(pi_ctl[:, k], 1e12*delay[:, k], '*')
        ax.set_title(f'PI Output #{k}')
        ax.set_xlabel('PI Code')
        ax.set_ylabel('Delay (ps)')

    fig.subplots_adjust(hspace=0.5)
    plt.tight_layout()

    plt.savefig(BUILD_DIR / 'pi.eps')

def check_pi(x, y):
    # create linear regression
    regr = linear_model.LinearRegression()
    regr.fit(x[:, np.newaxis], y)
    y_fit = regr.predict(x[:, np.newaxis])

    # INL
    inl = np.max(np.abs(y - y_fit))
    if inl > INL_LIM:
        print(f'INL out of spec: {inl*1e12:0.3f} ps.')
        print(f'Worst-case code: {np.argmax(np.abs(y - y_fit))}.')
        raise Exception(f'Assertion failed.')
    print(f'INL OK: {inl*1e12:0.3f} ps')

    # calculate offset
    offset = regr.intercept_
    offset %= T_PER

    # calculate offset error from nominal and wrap to +/- 0.5*T_PER
    offset_error = offset - OFFSET_NOM
    offset_error = ((offset_error + 0.5*T_PER)%T_PER) - 0.5*T_PER

    # check offset
    assert -OFFSET_DEV <= offset_error <= +OFFSET_DEV, \
        f'Offset out of spec: {offset*1e12:0.3f} ps'
    print(f'Offset OK: {offset*1e12:0.3f} ps')

    # gain
    gain = regr.coef_[0]
    assert GAIN_MIN <= gain <= GAIN_MAX, \
        f'Gain out of spec: {gain*1e12:0.3f} ps/LSB'
    print(f'Gain OK: {gain*1e12:0.3f} ps/LSB')

    # monotonicity check
    deltas = np.diff(y)
    if np.any(deltas < MONOTONIC_LIM):
        worst = np.argmin(deltas)
        print('PI is not monotonic.')
        print(f'Worst-case code is {worst} with delta {deltas[worst]*1e12:0.3f} ps.')
        raise Exception(f'Assertion failed.')
    print(f'Monotonicity check OK with min change {np.min(deltas)*1e12:0.3f} ps.')

    # Resolution
    # apply bounds checking
    if np.any(deltas > RES_LIM):
        worst = np.argmax(deltas)
        print('PI resolution is low.')
        print(f'Worst-case code is {worst} with delta {deltas[worst]*1e12:0.3f} ps.')
        raise Exception(f'Assertion failed.')
    print(f'Resolution check OK with max change {np.max(deltas)*1e12:0.3f} ps.')
