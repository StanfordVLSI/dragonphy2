import matplotlib.pyplot as plt
import numpy.matlib
import numpy as np
from pathlib import Path
from scipy import linalg, stats
from dragonphy import *

THIS_DIR = Path(__file__).resolve().parent
sparam_file_list = ["Case4_FM_13SI_20_T_D13_L6.s4p",
                    "peters_01_0605_B1_thru.s4p",  
                    "peters_01_0605_B12_thru.s4p",  
                    "peters_01_0605_T20_thru.s4p",
                    "TEC_Whisper42p8in_Meg6_THRU_C8C9.s4p",
                    "TEC_Whisper42p8in_Nelco6_THRU_C8C9.s4p"]

def sample_noise_with_random_iteration(err_descript, zf_taps, ffe_length, std, frame_length, rand_start=False):
    center_idx = int(frame_length/2 + ffe_length/2)
    zf_taps_mat = linalg.convolution_matrix(zf_taps, frame_length + ffe_length)
    cov_mat = np.dot(zf_taps_mat, zf_taps_mat.T)[ffe_length:ffe_length+frame_length,ffe_length:ffe_length+frame_length]
    rv = stats.multivariate_normal(np.zeros((frame_length,)).T, cov_mat*std**2, allow_singular=True)

    random_error = rv.rvs(size=(1,))

    for err in err_descript:
        random_error[err[0] + center_idx - ffe_length] = err[1]*(np.random.exponential(scale=0.1, size=(1,)) + 1)



    dx_scale = 0.0001
    dx_mat = np.eye(frame_length) * dx_scale

    allowable_choices = [ii for ii in range(frame_length) if ii not in [err[0]+center_idx - ffe_length for err in err_descript]]

    for jj in range(100):
        idxs = np.random.choice(allowable_choices, 10)

        for idx in idxs:
            dx = dx_mat[:, idx]

            df_1 = rv.logpdf(random_error + dx) - rv.logpdf(random_error - dx)
            df_2 = rv.logpdf(random_error + dx*100 + dx ) - rv.logpdf(random_error + dx*100 - dx)

            var = 2 * (100.0) / (df_1 - df_2) * dx_scale**2
            x0  = var * df_1/2 - random_error[idx]

            random_error[idx] = np.random.normal(loc=x0, scale=np.sqrt(var), size=(1,))
            while np.abs(random_error[idx]) > 0.99:
                random_error[idx] = np.random.uniform(low=-0.5, high=0.5, size=(1,))

    return random_error

def sample_noise_from_quadrant(err_descript, zf_taps, ffe_length, std, frame_length, err_pol=-1, lsb=0.05, rand_start=False):
    rand_shift = 0# np.random.randint(low=-5, high=5)

    center_idx = int(frame_length/2) + rand_shift
    frame_err_pattern = np.zeros((frame_length,))
    for err in err_descript:
        frame_err_pattern[err[0] + center_idx] = err[1]

    zf_taps_mat = linalg.convolution_matrix(zf_taps, frame_length + ffe_length)
    cov_mat = np.dot(zf_taps_mat, zf_taps_mat.T)*std**2

    values = []

    err_pattern = frame_err_pattern


    l_idx = center_idx
    r_idx = center_idx
    stds = [std]
    inc_flag = True
    ii = 0
    jj = 0

    final_rv = stats.multivariate_normal(np.zeros(10), cov_mat[center_idx-4:center_idx+6, center_idx-4:center_idx+6], allow_singular=False)

    while ii < frame_length:
        #print(cov_mat[l_idx:r_idx+1, l_idx:r_idx+1])
        #current_rv = stats.multivariate_normal(np.zeros(r_idx-l_idx + 1), cov_mat[l_idx:r_idx+1, l_idx:r_idx+1], allow_singular=True)
        e_idx = r_idx if inc_flag else l_idx

        if err_pattern[e_idx] == 0:
            possible_next_values = np.arange(-1+lsb*std/2,1-lsb*std/2,lsb*std)
        else:
            possible_next_values = err_pol*np.arange(1+lsb*std,3,lsb*std) * err_pattern[e_idx]

        if len(values) < 10:
            current_rv = stats.multivariate_normal(np.zeros(len(values)+1), cov_mat[l_idx:r_idx+1, l_idx:r_idx+1], allow_singular=False)

            pos = np.zeros((len(possible_next_values),len(values)+1))

            if inc_flag:
                pos = np.matlib.repmat(np.array(values+[0.0]), len(possible_next_values),1)
                pos[:,-1] = possible_next_values
            else:
                pos = np.matlib.repmat(np.array([0.0] + values), len(possible_next_values),1)
                pos[:,0] = possible_next_values
        else:
            current_rv = final_rv

            pos = np.zeros((len(possible_next_values),10))

            if inc_flag:
                pos = np.matlib.repmat(np.array(values[-9:]+[0.0]), len(possible_next_values),1)
                pos[:,-1] = possible_next_values
            else:
                pos = np.matlib.repmat(np.array([0.0] + values[:9]), len(possible_next_values),1)
                pos[:,0] = possible_next_values

        #log_probs = current_rv.logpdf(pos)
        #if np.sum(np.where(log_probs > -70, 0, 1))/len(log_probs) > 0.5:
#
        #    values = []
        #    norm_consts = []
        #    err_pattern = frame_err_pattern
#
        #    l_idx = center_idx
        #    r_idx = center_idx
#
        #    inc_flag = True
        #    ii = 0
        #    std = std * 1.00005
        #    lsb = lsb / 1.00005
        #    jj += 1
#
        #    stds += [std]
        #    if jj > 100:
        #        print(std)
#
        #    continue


        probabilities = current_rv.pdf(pos)
        probabilities = probabilities/np.sum(probabilities)

        next_val_idx = np.random.choice(np.arange(len(probabilities)), 1, p=probabilities)
        next_value   = possible_next_values[next_val_idx] +  np.random.uniform(low=-lsb*std/2, high=lsb*std/2, size=(1,))

        values = values + [next_value[0]] if inc_flag else [next_value[0]] + values


        if inc_flag:
            if l_idx == 0:
                inc_flag = True
            else:
                l_idx -= 1
                inc_flag = False

        else:
            if r_idx == frame_length - 1:
                inc_flag = False
            else:
                r_idx += 1
                inc_flag=True



        ii += 1
        jj += 1


    #print(f'Ratio Of Useful Cycles: {ii/1.0/jj}')

    values = np.array(values)

    for ii in range(25):
        for jj in range(5,frame_length-5):
            if err_pattern[jj] == 0:
                possible_next_values = np.arange(-1+lsb*std/2,1-lsb*std/2,lsb*std)
            else:
                possible_next_values = err_pol*np.arange(1+lsb*std,3,lsb*std) * err_pattern[jj]
            pos = np.matlib.repmat(np.concatenate((values[jj-5:jj], [0], values[jj+1:jj+5])), len(possible_next_values),1)
            pos[:,5] = possible_next_values


            probabilities = final_rv.pdf(pos)
            probabilities = probabilities/np.sum(probabilities)

            next_val_idx = np.random.choice(np.arange(len(probabilities)), 1, p=probabilities)
            values[jj]   = possible_next_values[next_val_idx] +  np.random.uniform(low=-lsb*std/2, high=lsb*std/2, size=(1,))

    return np.array(values), err_pattern*2.0, stds, rand_shift


def find_reasonable_noise_coeff(std, zf_taps, max_val=1, num_of_std=5):
    return max_val/(np.sqrt(np.sum(np.square(zf_taps))) * std) / num_of_std

def find_zf_taps(pulse, ffe_length, target_curs_pos, gausian_noise=0):
    chan_mat = linalg.convolution_matrix(pulse, ffe_length)
    cov_mat  = np.dot(chan_mat, chan_mat.T)

    imp = np.zeros((len(pulse) + ffe_length - 1, 1))
    imp[target_curs_pos] = 1

    inv_mat = np.dot(chan_mat.T, np.linalg.pinv(cov_mat + np.eye(len(pulse)+ffe_length-1) * gausian_noise**2))
    zf_taps = np.reshape(inv_mat @ imp, (ffe_length,))

    return zf_taps

def find_subsampled_taps(pulse, ffe_length, target_curs_pos, ratio):
    mod_pulse = pulse[::ratio]

    chan_mat = linalg.convolution_matrix(mod_pulse, ffe_length)
    cov_mat  = np.dot(chan_mat, chan_mat.T)

    imp = np.zeros((len(mod_pulse) + ffe_length -1, 1))
    imp[target_curs_pos] = 1

    inv_mat = np.dot(chan_mat.T, np.linalg.pinv(cov_mat + np.eye(len(mod_pulse)+ffe_length-1) * gausian_noise**2))
    zf_taps = np.reshape(inv_mat @ imp, (ffe_length,))

    return zf_taps

if __name__ == "__main__":
    f_sig = 26e9
    channel_length = 30
    select_channel = True
    phase_steps_check = False
    ffe_length = 10
    num_bits = 8.4
    channel_list = [0]
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
        shift_delay = -t[cursor_position] + (num_of_precursors)*1.0/(f_sig)
        #Load the S4P into a channel model
        chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=200000, s4p=file_name, zs=50, zl=50)

        time, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay=shift_delay + mm_lock_pos)
        
        chan_mat = linalg.convolution_matrix(pulse, ffe_length)
        cov_mat = np.dot(chan_mat, chan_mat.T)

        imp = np.zeros((200 + ffe_length -1,1))
        imp[target_curs_pos] = 1

        inv_mat = np.dot(chan_mat.T, np.linalg.pinv(cov_mat))

        zf_taps = np.reshape(inv_mat @ imp, (ffe_length,))

        #np.sqrt(np.sum(np.square(zf_taps)))
        #continue


        gen_err = np.zeros((num_of_samples - ffe_length,))
        wc_err  = np.zeros((num_of_samples,))


        #fig1, axes = plt.subplots(2)
        outlier_std = 0
        curr_std = find_reasonable_noise_coeff(std, zf_taps, num_of_std=2.6) * std
        print(f'Noise Std: {curr_std}')
        for jj in range(70):
            #random_error = sample_noise_with_random_iteration([(0,1), (1,-1)], zf_taps, ffe_length, std, 50)
            random_error, act_err, _std, shft = sample_noise_from_quadrant([(0,1), (3,-1)], zf_taps, ffe_length, curr_std, num_of_samples)
            plt.plot(_std)
            #plt.plot(nc)
            #plt.show()

            #axes[0].plot(random_error[int(ffe_length/2):-int(ffe_length/2)])
            #gen_err += random_error
            
            #axes[1].plot(np.convolve(pulse, random_error)[num_of_precursors+int(ffe_length/2):num_of_precursors+num_of_samples-int(ffe_length/2)])

            meas_std = np.sqrt(np.sum(np.square(np.convolve(pulse, random_error)[num_of_precursors:num_of_precursors+num_of_samples])/num_of_samples))


            if meas_std > outlier_std:
                outlier_std = meas_std
                wc_err = random_error

            gen_err += np.convolve(pulse, random_error)[num_of_precursors+int(ffe_length/2):num_of_precursors+num_of_samples-int(ffe_length/2)]/250
        #axes[0].set_title('Post-FFE Noise')
        #axes[1].set_title('Pre-FFE Noise')
        plt.title('Standard Deviation (Noise Power) over time')
        plt.show()
        print(f'worst std: {outlier_std}')

        fig2, axes = plt.subplots(2)
        axes[0].plot(wc_err)
        axes[1].plot(np.convolve(pulse, wc_err)[num_of_precursors:num_of_precursors+num_of_samples])
        plt.show()
        print()

        plt.plot(gen_err)
        plt.show()








