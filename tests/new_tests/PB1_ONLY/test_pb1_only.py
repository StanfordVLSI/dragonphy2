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
            en_mixer=m.BitIn,
            delay0=fault.RealIn,
            delay1=fault.RealIn,
            delay_out=fault.RealOut,
            freq_out = fault.RealOut,
            duty_out = fault.RealOut
        )

    # create tester
    t = fault.Tester(dut)

    test_del = []

    mixer_on = Results(tester=t, dut=dut)
    for k in range(-124, 125):
        t.print('Testing delay %0.3f ps\n', k)

        t.poke(dut.delay0, 125e-12)
        t.poke(dut.delay1, (125+k)*1e-12)

        t.poke(dut.en_mixer, 1)
        t.delay(20e-9)
        mixer_on.log()

        test_del.append(k*1e-12)

    mixer_off = Results(tester=t, dut=dut)
    for k in range(-124, 125):
        t.print('Testing delay %0.3f ps\n', k)

        t.poke(dut.delay0, 125e-12)
        t.poke(dut.delay1, (125+k)*1e-12)

        t.poke(dut.en_mixer, 0)
        t.delay(20e-9)
        mixer_off.log()

    # delay at end to make sure we record the last point
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
        flags=['-sv'],
        directory=BUILD_DIR,
        num_cycles=1e12
    )

    test_del = np.array(test_del, dtype=float)
    mixer_off.convert_values()
    mixer_on.convert_values()

    # plot results
    plot_data(test_del, mixer_on, mixer_off)

    # check the results
    print('Checking behavior with mixer off...')
    check_data(test_del, mixer_off, wgt=0.0)

    print('Checking behavior with mixer on...')
    check_data(test_del, mixer_on, wgt=0.5)

def plot_data(test_del, mixer_on, mixer_off):
    plt.plot(test_del*1e12, mixer_on.ph*1e12, '*')
    plt.plot(test_del*1e12, mixer_off.ph*1e12, '*')
    plt.xlabel('Relative Delay (ps)')
    plt.ylabel('Phase Blender Output (ps)')
    plt.legend(['Blender Enabled', 'Blender Disabled'])
    plt.tight_layout()
    plt.savefig(BUILD_DIR / 'pb1_ph.eps')
    plt.cla()
    plt.clf()

    plt.plot(test_del*1e12, mixer_on.freq/1e9, '*')
    plt.plot(test_del*1e12, mixer_off.freq/1e9, '*')
    plt.xlabel('Relative Delay (ps)')
    plt.ylabel('Phase Blender Output (GHz)')
    plt.legend(['Blender Enabled', 'Blender Disabled'])
    plt.tight_layout()
    plt.savefig(BUILD_DIR / 'pb1_freq.eps')
    plt.cla()
    plt.clf()

    plt.plot(test_del*1e12, mixer_on.duty, '*')
    plt.plot(test_del*1e12, mixer_off.duty, '*')
    plt.xlabel('Relative Delay (ps)')
    plt.ylabel('Phase Blender Output (Duty Cycle)')
    plt.legend(['Blender Enabled', 'Blender Disabled'])
    plt.tight_layout()
    plt.savefig(BUILD_DIR / 'pb1_duty.eps')
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
