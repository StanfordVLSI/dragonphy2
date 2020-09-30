from pathlib import Path
import matplotlib.pyplot as plt

from dragonphy import *

THIS_DIR = Path(__file__).resolve().parent
S4P_DIR = get_dir('data/channel_sparam')

def test_all_impulses():
    for file_name in S4P_DIR.glob('*.s4p'):
        t, imp = s4p_to_impulse(str(file_name), 0.1e-12, 20e-9, zs=50, zl=50)
        plt.plot(t*1e9, imp, label=file_name.stem)

    plt.legend(prop={'size': 8})
    plt.title('All Impulse Responses')
    plt.xlabel('Time (ns)')
    plt.ylabel('Value')
    plt.savefig(THIS_DIR / 'all_imp.eps')
    plt.cla()
    plt.clf()

def test_all_steps():
    for file_name in S4P_DIR.glob('*.s4p'):
        t, imp = s4p_to_step(str(file_name), 0.1e-12, 20e-9, zs=50, zl=50)
        plt.plot(t*1e9, imp, label=file_name.stem)

    plt.legend(prop={'size': 8})
    plt.title('All Step Responses')
    plt.xlabel('Time (ns)')
    plt.ylabel('Value')
    plt.savefig(THIS_DIR / 'all_step.eps')
    plt.cla()
    plt.clf()

def test_all_pulses():
    for file_name in S4P_DIR.glob('*.s4p'):
        chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=200000,
                       s4p=file_name, zs=50, zl=50)
        _, pulse = chan.get_pulse_resp(f_sig=16e9, resp_depth=10000, t_delay=0)
        plt.plot(pulse, '-o', label=file_name.stem, markersize=2)

    plt.legend(prop={'size': 8})
    plt.title('All Pulse Responses')
    plt.xlabel('Index')
    plt.ylabel('Value')
    plt.savefig(THIS_DIR / 'all_pulse.eps')
    plt.cla()
    plt.clf()
