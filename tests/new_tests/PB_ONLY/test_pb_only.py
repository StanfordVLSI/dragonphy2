# general imports
import os
import pytest
from sklearn import linear_model
from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np
# AHA imports
import fault
import magma as m

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'
if 'FPGA_SERVER' in os.environ:
    SIMULATOR = 'vivado'
else:
    SIMULATOR = 'ncsim'

CLK_REF_FREQ = 4e9
N_BLENDER = 4

PH_ERR_TOL   = 1e-12
FREQ_ERR_TOL = 5e4
DUTY_ERR_TOL = 0.01
GAIN_ERR_TOL = 0.01

class Results:
    def __init__(self, tester, dut):
        self.tester = tester
        self.dut = dut
        self.ph = []
        self.freq = []
        self.duty = []

    def log(self):
        self.ph.append(self.tester.get_value(self.dut.delay_out))
        self.freq.append(self.tester.get_value(self.dut.freq_out))
        self.duty.append(self.tester.get_value(self.dut.duty_out))

    def convert_values(self):
        self.ph = 1e-12*np.array([elem.value for elem in self.ph], dtype=float)
        self.freq = 1e9*np.array([elem.value for elem in self.freq], dtype=float)
        self.duty = np.array([elem.value for elem in self.duty], dtype=float)

@pytest.mark.parametrize((), [pytest.param(marks=pytest.mark.slow) if SIMULATOR=='vivado' else ()])
def test_sim():
    # declare circuit
    class dut(m.Circuit):
        name = 'test'
        io = m.IO(
            thm_sel_bld=m.In(m.Bits[2**N_BLENDER]),
            delay0=fault.RealIn,
            delay1=fault.RealIn,
            delay_out=fault.RealOut,
            freq_out = fault.RealOut,
            duty_out = fault.RealOut
        )

    # create tester
    t = fault.Tester(dut)

    mixers = []
    for val in range((2**(N_BLENDER))+1):
        mixer = Results(t, dut)
        mixers.append(mixer)
        t.print('Testing thm_sel_bld=%0b\n', (1<<val)-1)
        t.poke(dut.thm_sel_bld, (1 << val)-1)
        for k in list(range(-60, 0))+list(range(1,60))+list(range(60,0,-1))+list(range(-1,-60,-1)):
            t.poke(dut.delay0, 60e-12)
            t.poke(dut.delay1, (60+k)*1e-12)
            t.delay(20e-9)
            mixer.log()

    # delay at the end to make sure that the last point is recorded OK
    t.delay(20e-9)

    # gather dependencies
    deps = get_deps_cpu_sim_new(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    t.compile_and_run(
        target='system-verilog',
        simulator=SIMULATOR,
        ext_srcs=deps,
        ext_model_file=True,
        disp_type='realtime',
        defines = {
            'CLK_REF_FREQ': CLK_REF_FREQ,
            'DAVE_TIMEUNIT': '1fs',
            'NCVLOG': None
        },
        parameters = {
            'Nblender': N_BLENDER
        },
        flags=['-sv', '-unbuffered'],
        directory=BUILD_DIR,
        num_cycles=1e12
    )

    # gather list of times
    test_del = []
    for k in list(range(-60, 0))+list(range(1,60))+list(range(60,0,-1))+list(range(-1,-60,-1)):
        test_del.append(k*1e-12)
    test_del = np.array(test_del, dtype=float)

    # convert values and unwrap phase
    for mixer in mixers:
        mixer.convert_values()
        scale_factor = 2*np.pi*CLK_REF_FREQ
        mixer.ph *= scale_factor
        mixer.ph = np.unwrap(mixer.ph)
        mixer.ph /= scale_factor

    # plot results
    plot_data(test_del, mixers)

    # check the results
    for k, mixer in enumerate(mixers):
        print(f'Checking behavior for value {k}...')
        check_data(test_del, mixer, wgt=k/(2**N_BLENDER))

def plot_data(test_del, mixers):
    leg = []
    for k, mixer in enumerate(mixers):
        plt.plot(test_del*1e12, mixer.ph*1e12, '*')
        leg.append(f'val={k}')
    plt.xlabel('Relative Delay (ps)')
    plt.ylabel('Phase Blender Output (ps)')
    plt.legend(leg)
    plt.tight_layout()
    plt.savefig(BUILD_DIR / 'pb_ph.eps')
    plt.cla()
    plt.clf()

    for k, mixer in enumerate(mixers):
        plt.plot(test_del*1e12, mixer.freq/1e9, '*')
    plt.xlabel('Relative Delay (ps)')
    plt.ylabel('Phase Blender Output (GHz)')
    plt.legend(leg)
    plt.tight_layout()
    plt.savefig(BUILD_DIR / 'pb_freq.eps')
    plt.cla()
    plt.clf()

    for k, mixer in enumerate(mixers):
        plt.plot(test_del*1e12, mixer.duty, '*')
    plt.xlabel('Relative Delay (ps)')
    plt.ylabel('Phase Blender Output (Duty Cycle)')
    plt.legend(leg)
    plt.tight_layout()
    plt.savefig(BUILD_DIR / 'pb_duty.eps')
    plt.cla()
    plt.clf()

def check_data(test_del, mixer, wgt):
    # frequency should be flat
    freq_err = np.max(np.abs(mixer.freq - CLK_REF_FREQ))
    assert freq_err <= FREQ_ERR_TOL, \
        f'Frequency error out of spec: {freq_err/1e9} GHz.'

    # duty cycle should be flat
    duty_err = np.max(np.abs(mixer.duty - 0.5))
    assert duty_err <= DUTY_ERR_TOL, \
        f'Duty cycle error out of spec: {duty_err*100} %'

    # transfer curve should have a certain shape
    regr = linear_model.LinearRegression()
    regr.fit(test_del[:, np.newaxis], mixer.ph)
    ph_fit = regr.predict(test_del[:, np.newaxis])
    ph_err = np.max(np.abs(mixer.ph - ph_fit))
    assert ph_err <= PH_ERR_TOL, \
        f'Nonlinearity out of spec: {ph_err*1e12} ps'

    # gain
    gain = regr.coef_[0]
    assert wgt-GAIN_ERR_TOL <= gain <= wgt+GAIN_ERR_TOL,\
        f'Gain out of spec: {gain} ps/ps.'
