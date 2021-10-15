from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np
from scipy import linalg
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


f_sig = 26e9
channel_length = 30
select_channel = True
phase_steps_check = False
ffe_length = 10
num_bits = 8.4
channel_list = [1]
num_of_precursors = 4

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
    shift_delay = -t[cursor_position] + (num_of_precursors)*1.0/(f_sig)
    #Load the S4P into a channel model
    chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=200000, s4p=file_name, zs=50, zl=50)

    time, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay=shift_delay + mm_lock_pos)

    chan_mat = linalg.convolution_matrix(pulse, ffe_length)
    imp = np.zeros((199 + ffe_length,1))
    imp[target_curs_pos] = 1
    zf_taps = np.reshape(np.linalg.pinv(chan_mat) @ imp, (ffe_length,))

    if debug_DLE:
        plt.stem(zf_taps)
        plt.show()
        plt.plot(pulse)
        plt.show()
        plt.plot(np.convolve(pulse, zf_taps))
        plt.show()
        exit()
    bits = np.random.randint(2, size=(int(10**num_bits),))*2 - 1
    codes = chan.compute_output(bits, resp_depth=200, f_sig=f_sig, t_delay=shift_delay + mm_lock_pos)
    codes_plus_noise = codes + np.random.randn(len(codes))*1.8e-2
    eq_codes = np.convolve(codes_plus_noise, zf_taps)

    eq_codes = eq_codes[target_curs_pos:int(10**num_bits) + target_curs_pos]
    est_bits = np.where(eq_codes>0, 1, -1)

    est_codes = chan.compute_output(est_bits, resp_depth=200, f_sig=f_sig, t_delay=shift_delay + mm_lock_pos)

    error_sig = codes-est_codes
    b_err = (bits - est_bits)/2
    err_loc = np.where(np.abs(b_err) == 1)[0]
    total_errors = len(err_loc)

    distance_between_errors = err_loc[1:] - err_loc[:-1]
    first_skip = True

    if total_errors < 1:
        print('No Errors Found')
        continue


    dict_of_errors = {}
    dict_of_error_pol = {}
    curr_error     = "p"
    curr_err_loc   = err_loc[0]
    curr_error_polarity = b_err[err_loc[0]]

    for ii, dist_btwn_err in enumerate(distance_between_errors):
        print(dist_btwn_err, err_loc[ii], b_err[err_loc[ii]], b_err[err_loc[ii]+dist_btwn_err])

        if dist_btwn_err > 15:
            print("Storing:", curr_error, curr_err_loc)
            if curr_error not in dict_of_errors:
                dict_of_errors[curr_error] = []
                dict_of_error_pol[curr_error] = []
            dict_of_errors[curr_error] += [curr_err_loc]
            dict_of_error_pol[curr_error] += [curr_error_polarity]

            curr_err_loc = err_loc[ii] + dist_btwn_err
            curr_error = "p"
            curr_error_polarity = b_err[err_loc[ii]+dist_btwn_err]
            print()
        else:
            new_tag = str(dist_btwn_err-1) if dist_btwn_err > 1 else ""
            if b_err[err_loc[ii]+dist_btwn_err] == curr_error_polarity:
                new_tag += 'p'
            else:
                new_tag += 'n'
            curr_error += new_tag

    if distance_between_errors[-1] > 10:
        dict_of_errors['p'] += [err_loc[-1]]

    running_total = 0
    print(f'Error Rate: {total_errors/int(10**num_bits)}')


    for err_typ in dict_of_errors:
        average_bit_patterns = np.zeros((30,))
        for idx, pol in zip(dict_of_errors[err_typ],dict_of_error_pol[err_typ]):
            plt.plot(error_sig[idx-5+num_of_precursors:idx+num_of_precursors+30])
            plt.plot(b_err[idx-5:idx+30])
            average_bit_patterns = average_bit_patterns + bits[idx-25:idx+5]*pol
        plt.title(err_typ)
        plt.show()

        plt.plot(average_bit_patterns/len(dict_of_errors[err_typ]))
        plt.show()

        for idx in dict_of_errors[err_typ]:
            plt.plot(eq_codes[idx-5+num_of_precursors:idx+num_of_precursors+30])
        plt.title(err_typ)
        plt.show()

        num_of_errors = len(list(filter(lambda x: (x== 'p') or (x == 'n'), err_typ)))
        running_total += len(dict_of_errors[err_typ])*num_of_errors
        print(f'% of {err_typ}: {len(dict_of_errors[err_typ])*num_of_errors/total_errors * 100} %')

    print(running_total, total_errors)






