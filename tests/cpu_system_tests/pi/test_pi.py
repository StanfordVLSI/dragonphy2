# general imports
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from sklearn import linear_model

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

# testing parameters
T_PER = 1/4e9
INL_LIM = 10e-12
GAIN_MIN = 0.8e-12
GAIN_MAX = 1.1e-12
MONOTONIC_LIM = -0.01e-12
RES_LIM = 2e-12

def test_sim(dump_waveforms):
    deps = get_deps_cpu_sim(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    def qwrap(s):
        return f'"{s}"'
    defines = {
        'PI_CTL_TXT': qwrap(BUILD_DIR / 'pi_ctl.txt'),
        'DELAY_TXT': qwrap(BUILD_DIR / 'delay.txt')
    }

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        defines=defines,
        dump_waveforms=dump_waveforms
    ).run()

    # read data from file
    pi_ctl = np.loadtxt(BUILD_DIR / 'pi_ctl.txt', dtype=int, delimiter=',')
    delay = np.loadtxt(BUILD_DIR / 'delay.txt', dtype=float, delimiter=',')

    # sort each column increasing order of pi_ctl codes
    for k in range(delay.shape[1]):
        idx_arr = pi_ctl[:, k].argsort()
        pi_ctl[:, k] = pi_ctl[idx_arr, k]
        delay[:, k] = delay[idx_arr, k]

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
    print(f'INL: {inl*1e12:0.3f} ps.')

    # gain
    gain = regr.coef_[0]
    print(f'Gain: {gain*1e12:0.3f} ps/LSB')

    # monotonicity
    min_delta = np.min(np.diff(y))
    print(f'Min delta is {min_delta*1e12:0.3f} ps.')

    # resolution
    max_delta = np.max(np.diff(y))
    print(f'Max delta is {max_delta*1e12:0.3f} ps.')

    # check INL
    assert inl <= INL_LIM, \
        f'INL out of spec.  Worst-case code: {np.argmax(np.abs(y - y_fit))}.'

    # check gain
    assert GAIN_MIN <= gain <= GAIN_MAX, f'Gain out of spec.'
    
    # check monotonicity
    if min_delta < MONOTONIC_LIM:
        deltas = np.diff(y)
        worst = np.argmin(deltas)
        print('PI is not monotonic.')
        print(f'Worst-case code is {worst} with delta {deltas[worst]*1e12:0.3f} ps.')
        raise Exception(f'Assertion failed.')

    # check resolution
    if max_delta > RES_LIM:
        deltas = np.diff(y)
        worst = np.argmax(deltas)
        print('PI resolution is low.')
        print(f'Worst-case code is {worst} with delta {deltas[worst]*1e12:0.3f} ps.')
        raise Exception(f'Assertion failed.')
    print(f'Resolution check OK with max change {np.max(np.diff(y))*1e12:0.3f} ps.')
