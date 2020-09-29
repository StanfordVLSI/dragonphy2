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

def test_all_impulses(): 
    THIS_DIR = Path(__file__).resolve().parent
   
    sparam_file_list = ["peters_01_0605_B12_thru.s4p",
                        "peters_01_0605_B1_thru.s4p",  
                        "peters_01_0605_T20_thru.s4p",
                        "TEC_Whisper42p8in_Meg6_THRU_C8C9.s4p",
                        "TEC_Whisper42p8in_Nelco6_THRU_C8C9.s4p"]


    for sparam_file in sparam_file_list:
        file_name = str(get_file(f'data/channel_sparam/{sparam_file}'))
        t, imp = s4p_to_impulse(file_name, 0.1e-12, 20e-9, zs=50, zl=50)
        plt.plot(t*1e9, imp, label=sparam_file.split('.')[0])

    plt.legend()
    plt.savefig(THIS_DIR / 'all_imp.eps')
    plt.cla()
    plt.clf()

