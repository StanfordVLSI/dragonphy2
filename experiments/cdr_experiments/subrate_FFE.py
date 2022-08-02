from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
from matplotlib import ticker, cm
import numpy as np
from copy import copy, deepcopy
from scipy import linalg, stats, special
from dragonphy import *
from rich.progress import Progress
from pptree import print_tree
from corner_sampling import find_zf_taps, find_subsampled_taps

THIS_DIR = Path(__file__).resolve().parent
sparam_file_list = ["Case4_FM_13SI_20_T_D13_L6.s4p",
                    "peters_01_0605_B1_thru.s4p",  
                    "peters_01_0605_B12_thru.s4p",  
                    "peters_01_0605_T20_thru.s4p",
                    "TEC_Whisper42p8in_Meg6_THRU_C8C9.s4p",
                    "TEC_Whisper42p8in_Nelco6_THRU_C8C9.s4p"]

f_sig = 16e9
channel_length = 30
select_channel = True
phase_steps_check = False
ffe_length = 10
num_bits = 8.4
channel_list = [0,1,2,3,4,5]
num_of_precursors = 4
std=4e-3

err_length = 30
num_of_samples = 40

debug_DLE = True

list_of_target_curs_pos = [4,8,8,8,12,3]
list_of_mm_lock_position = [15e-12,15e-12,12e-12,12e-12,3e-12, 15e-12]
list_of_eq_mm_lock_position = list_of_mm_lock_position# [15e-12,15e-12,25e-12,15e-12,15e-12, 15e-12]


for ii in channel_list:
    file = sparam_file_list[ii]
    target_curs_pos = list_of_target_curs_pos[ii]
    mm_lock_pos = list_of_mm_lock_position[ii]

    file_name = str(get_file(f'data/channel_sparam/{file}'))
    t, imp = s4p_to_impulse(str(file_name), 0.1e-12, 20e-9, zs=50, zl=50)

    cursor_position = np.argmax(imp)

    shift_delay = -t[cursor_position] + (num_of_precursors)*1.0/(f_sig/16)
    chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=200000, s4p=file_name, zs=50, zl=50)
    time, pulse = chan.get_pulse_resp(f_sig=f_sig/16, resp_depth=200, t_delay=shift_delay + mm_lock_pos)

    sr_zf_taps = find_zf_taps(pulse, 10, target_curs_pos)


    shift_delay = -t[cursor_position] + (num_of_precursors)*1.0/(f_sig)
    time, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay=shift_delay + mm_lock_pos)

    zf_taps = find_zf_taps(pulse, 10, target_curs_pos)

    bits = np.zeros((3000,))
    bits[::4]  = -1
    bits[1::4] = -1
    bits[2::4] =  1
    bits[3::4] =  1


    plt.plot(np.convolve(bits, pulse))
    
    bits[::2]  = -1
    bits[1::2] =  1

    plt.plot(np.convolve(bits, pulse))

    plt.show()




