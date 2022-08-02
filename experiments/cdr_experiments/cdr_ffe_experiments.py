from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
from matplotlib import ticker, cm
import numpy as np
from scipy import linalg, stats
from dragonphy import *
from rich.progress import Progress


def heaviside(x):
    return 1.0 if x > 0 else 0.0

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
ub_std = 19e-3
phase_step = 0.1e-12

debug_DLE = True
plot_amplified_noise = False

find_optimal_ffe_point = True


list_of_target_curs_pos = [3,7,9,8,9,4]
#list_of_target_curs_pos = [50,50,50,50,50,50]
#list_of_target_curs_pos = [4,15,15,15,15,15]

list_of_mm_lock_position = [15e-12,15e-12,12e-12,12e-12,3e-12, 15e-12]
list_of_ub_stds = [8e-3, 44.5e-3, 18.5e-3, 2e-3, 24.5e-3, 8.5e-3]
list_of_eq_mm_lock_position = list_of_mm_lock_position# [15e-12,15e-12,25e-12,15e-12,15e-12, 15e-12]

tone = np.zeros((400,))
tone[::2] = 1
tone[1::2] = -1


if find_optimal_ffe_point:
    for ii in channel_list:
        file = sparam_file_list[ii]
        #print(file)
        mm_lock_pos = list_of_mm_lock_position[ii]

        file_name = str(get_file(f'data/channel_sparam/{file}'))
        t, imp = s4p_to_impulse(str(file_name), 0.1e-12, 20e-9, zs=50, zl=50)

        cursor_position = np.argmax(imp)
        shift_delay = -t[cursor_position] + (num_of_precursors)*1.0/(f_sig)
        #Load the S4P into a channel model
        chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=200000, s4p=file_name, zs=50, zl=50)

        time, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay=shift_delay + mm_lock_pos)

        chan_mat = linalg.convolution_matrix(pulse, ffe_length)
        best_val = 1
        best_pos = 0
        for jj in range(ffe_length):
            imp = np.zeros((200 + ffe_length -1,1))
            imp[jj] = 1
            zf_taps = np.reshape(np.linalg.pinv(chan_mat) @ imp, (ffe_length,))
            eq_pulse = np.convolve(pulse,zf_taps)
            eq_pulse = eq_pulse / eq_pulse[jj]
            eq_pulse[jj] = 0

            mean_sqr_error = np.sum(np.dot(eq_pulse, eq_pulse))

            if best_val > mean_sqr_error:
                best_val = mean_sqr_error
                best_pos = jj


print(list_of_target_curs_pos)

for ii in channel_list:
    ub_std = list_of_ub_stds[ii]
    file = sparam_file_list[ii]
    target_curs_pos = list_of_target_curs_pos[ii]
    mm_lock_pos = list_of_mm_lock_position[ii]

    file_name = str(get_file(f'data/channel_sparam/{file}'))
    t, imp = s4p_to_impulse(str(file_name), 0.1e-12, 20e-9, zs=50, zl=50)

    cursor_position = np.argmax(imp)
    shift_delay = -t[cursor_position] + (num_of_precursors)*1.0/(f_sig)
    #Load the S4P into a channel model
    chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=200000, s4p=file_name, zs=50, zl=50)

    time, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay=shift_delay + mm_lock_pos)
    time_1ps, pulse_1ps = chan.get_pulse_resp(f_sig, resp_depth=200, t_delay=shift_delay + mm_lock_pos + phase_step)


    chan_mat = linalg.convolution_matrix(pulse, ffe_length)
    imp = np.zeros((200 + ffe_length -1,1))
    imp[target_curs_pos] = 1
    zf_taps = np.reshape(np.linalg.pinv(chan_mat) @ imp, (ffe_length,))
    print(np.amax(np.abs(zf_taps)))
    #zf_taps = zf_taps / np.sum(np.abs(zf_taps))

    h_vec = np.convolve(pulse,zf_taps)
    a_vec = np.convolve(pulse - pulse_1ps, zf_taps)



    # The coupling between noise and phase makes this a little hard to think about - maybe do it stepwise?

    if debug_DLE:
    #    plt.plot(np.convolve(tone, pulse))
    #    plt.show()
        plt.stem(zf_taps)
        plt.show()
        plt.stem(pulse)
        plt.show()
        plt.plot(h_vec)
        plt.show()
        plt.plot(a_vec/phase_step)
        plt.show()
        continue



   