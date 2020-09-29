from pathlib import Path
import matplotlib.pyplot as plt

from dragonphy import *

def test_sparams():
    THIS_DIR = Path(__file__).resolve().parent
    file_name = str(get_file('data/channel_sparam/peters_01_0605_B12_thru.s4p'))

    t, imp = s4p_to_impulse(file_name, 0.1e-12, 20e-9, zs=50, zl=50)
    plt.plot(t*1e9, imp)
    plt.title('Impulse Response')
    plt.xlabel('Time (ns)')
    plt.ylabel('Value')
    plt.savefig(THIS_DIR / 'imp.eps')
    plt.cla()
    plt.clf()

    t, step = s4p_to_step(file_name, 0.1e-12, 20e-9, zs=50, zl=50)
    plt.plot(t*1e9, step)
    plt.title('Step Response')
    plt.xlabel('Time (ns)')
    plt.ylabel('Value')
    plt.savefig(THIS_DIR / 'step.eps')
    plt.cla()
    plt.clf()
