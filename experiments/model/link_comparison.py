import numpy as np
import math
from pathlib import Path
from math import exp, ceil, log2
from scipy import linalg

import matplotlib.pyplot as plt

from scipy.interpolate import interp1d
from dragonphy import *


real_channels = ["Case4_FM_13SI_20_T_D13_L6.s4p",
"peters_01_0605_B1_thru.s4p",  
                    "peters_01_0605_B12_thru.s4p",  
                    "peters_01_0605_T20_thru.s4p",
                    "TEC_Whisper42p8in_Meg6_THRU_C8C9.s4p",
                    "TEC_Whisper42p8in_Nelco6_THRU_C8C9.s4p"]
def slicer(x):
    if x > 2/3:
        return 1
    elif x > 0:
        return 1/3
    elif x > -2/3:
        return -1/3
    else:
        return -1

def get_real_channel_step(s4p_file, f_sig=16e9, mm_lock_pos=12.5e-12, numel=2048, domain=[0, 4e-9]):
    file_name = str(get_file(f'data/channel_sparam/{s4p_file}'))

    step_size = domain[1]/(numel-1)

    t, imp = s4p_to_impulse(str(file_name), step_size/100.0, 10*domain[1],  zs=50, zl=50)

    cur_pos = np.argmax(imp)

    t_delay = -t[cur_pos] + 2*1/f_sig + mm_lock_pos

    t2, step = s4p_to_step(str(file_name), step_size, 10*domain[1], zs=50, zl=50)

    interp = interp1d(t2, step, bounds_error=False, fill_value=(step[0], step[-1]))
    
    t_step = np.linspace(0, domain[1], numel) - t_delay
    v_step = interp(t_step)

    return v_step

def read_array(f):
    arr_text = ""

    while True:
        line = f.readline()
        if line == '':
            return 1, []

        arr_text += " " + line.strip()
        if ']' in line:
            break

    arr = np.array([float(val) for val in arr_text[2:-1].split()])
    return arr

def get_real_channel_pulse(s4p_file, f_sig=16e9, mm_lock_pos=12.5e-12, numel=2048, domain=[0,4e-9], osr=False):
    file_name = str(get_file(f'data/channel_sparam/{s4p_file}'))
    
    step_size = domain[1]/(numel-1)
    t, imp = s4p_to_impulse(str(file_name), step_size/100.0, 10*domain[1],  zs=50, zl=50)
    cur_pos = np.argmax(imp)
    t_delay = -t[cur_pos] + 2*1/f_sig + mm_lock_pos

    t, pulse = Channel(channel_type='s4p', sampl_rate=24e12, resp_depth=200000, s4p=file_name, zs=50, zl=50).get_pulse_resp(f_sig=f_sig, resp_depth=35, t_delay=t_delay)
    if osr:
        t_osr, p_osr = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=200000, s4p=file_name, zs=50, zl=50).get_pulse_resp(f_sig=f_sig*64, resp_depth=35*64, t_delay=t_delay)
        return pulse, p_osr

    return pulse

def find_nearest_arg(array,value):
    idx = np.searchsorted(array, value, side="left")
    if idx > 0 and (idx == len(array) or math.fabs(value - array[idx-1]) < math.fabs(value - array[idx])):
        return idx-1
    else:
        return idx

pvals = [0, 1, 2, 3, 4, 5, 6, 7, 8]
N_samples = 10000000
ffe_lengths = [16,16,16,32,16,16]
channel_shift = [2.5e-12, 2.5e-12, 2.5e-12, 2.5e-12, 2.5e-12, 2.5e-12]
number_of_dfe_taps =[1, 1, 1, 1, 1, 1]

run_init = False
run_sim = True
sigmas = [1.8e-3, 3.5e-3, 7.5e-3, 3e-3, 6.5e-3, 1.7e-3]
for jj, sparam_file in enumerate(real_channels):
    sigma = sigmas[jj]
    if run_init:
        ffe_length = ffe_lengths[jj]
        pulse, pulse_osr = get_real_channel_pulse(sparam_file, f_sig=16e9, mm_lock_pos=12.5e-12+channel_shift[jj], numel=2048, domain=[0,4e-9], osr=True)
        fig, ax = plt.subplots()
        ff = np.fft.fftshift(np.fft.fftfreq(len(pulse_osr), d=1/(64*16e9)))
        Fw = np.fft.fftshift(np.fft.fft(pulse_osr))
        plt.plot(ff, 20*np.log10(np.abs(Fw)))
        plt.title(f'{sparam_file}')
        plt.xlim([0, 16e9])
        plt.ylim([-100, 0])
        idx = find_nearest_arg(ff, 8e9)
        plt.vlines(ff[idx], -100, 0)
        plt.hlines(20*np.log10(np.abs(Fw[idx])), 0, 16e9)
        plt.text(ff[idx], 20*np.log10(np.abs(Fw[idx])), f'{20*np.log10(np.abs(Fw[idx])):.2f} dB, {ff[idx]/1e9:0.2f} GHz', horizontalalignment='center', verticalalignment='bottom')
        fig.savefig(f'plots/{sparam_file}_fft.png')

        best_err = -1;
        best_zf_taps = 0
        best_mm_lock_pos = 0
        best_pv = 0
        for pv in pvals:
            best_err_by_shift = []
            for mm_lock_pos in list(np.linspace(0, 60e-12, 80, endpoint=False)):
                pulse = get_real_channel_pulse(sparam_file, f_sig=16e9, mm_lock_pos=mm_lock_pos+channel_shift[jj], numel=2048, domain=[0,4e-9], osr=False)

                data = np.random.randint(0, 4, size=N_samples)*2-3
                chan_mat = linalg.convolution_matrix(pulse, ffe_length)

                for ii in range(1,ffe_length-1):
                    total_length = len(pulse) + ffe_length - 1
                    imp = np.zeros((len(pulse) + ffe_length - 1, 1))
                    imp[ii] = 1

                    shape_mat = np.zeros((ffe_length, ffe_length))
                    for kk in range(ffe_length):
                        shape_mat[kk, kk] = 1
                        
                    for kk in range(ffe_length-1):
                        for nn in range(number_of_dfe_taps[jj]):
                            if kk+1 + nn < ffe_length:
                                shape_mat[kk+1 + nn, kk] = (pv/10)/(nn+1)
                    

                    target_mat = shape_mat @ chan_mat.T @ np.linalg.pinv(chan_mat @ chan_mat.T + sigma**2 * np.eye(total_length)) 

                    zf_taps = np.reshape(target_mat @ imp, (ffe_length,))

                    new_eql_pulse = np.convolve(zf_taps, pulse)[0:ffe_length]
                    main_tap = new_eql_pulse[ii]
                    new_eql_pulse[ii] = new_eql_pulse[ii] - 1
                    for nn in range(number_of_dfe_taps[jj]):
                        if ii+1+nn < ffe_length:
                            new_eql_pulse[ii+1+nn] = new_eql_pulse[ii+1+nn] - (pv/10)/(nn+1)
                    ener_err = np.sqrt(np.sum(np.square(new_eql_pulse)))/main_tap**2
                    abs_err = np.sum(np.abs(new_eql_pulse))/main_tap

                    print(f'{ii}: {abs_err} {ener_err}')
                    if (abs_err < best_err) or (best_err < 0):
                        best_ii = ii
                        best_zf_taps = zf_taps
                        best_err = abs_err
                        best_mm_lock_pos = mm_lock_pos + channel_shift[jj]
                        best_pv = pv

                best_err_by_shift.append(best_err)
        pulse = get_real_channel_pulse(sparam_file, f_sig=16e9, mm_lock_pos=best_mm_lock_pos, numel=2048, domain=[0,4e-9])

        fig, ax = plt.subplots()
        plt.stem(best_zf_taps)
        plt.title(f'{sparam_file} {best_mm_lock_pos}')
        fig.savefig(f'plots/{sparam_file}_ffe_taps.png')
        best_eql_pulse = np.convolve(best_zf_taps, pulse)
        fig, ax = plt.subplots()
        plt.stem(best_eql_pulse)
        fig.savefig(f'plots/{sparam_file}_eq_pulse_pre_dfe.png')
        for nn in range(number_of_dfe_taps[jj]):
            best_eql_pulse[best_ii+nn+1] = best_eql_pulse[best_ii+nn+1] - (best_pv/10)/(nn+1)
        fig, ax = plt.subplots()
        plt.stem(best_eql_pulse)
        fig.savefig(f'plots/{sparam_file}_eq_pulse.png')
        fig, ax = plt.subplots()
        plt.stem(pulse)
        fig.savefig(f'plots/{sparam_file}_pulse.png')
        fig, ax = plt.subplots()
        plt.plot(np.linspace(0, 60e-12, 80, endpoint=False) + channel_shift[jj], best_err_by_shift)
        fig.savefig(f'plots/{sparam_file}_err.png')

        rx_input = np.convolve(pulse, data)
        ffe_output = np.convolve(best_zf_taps, rx_input)
        ffe_output = ffe_output[best_ii+1:]

            
        dfe_output = np.zeros(len(ffe_output))
        for ii in range(0, number_of_dfe_taps[jj]):
            dfe_output[ii] = ffe_output[ii]

        for ii in range(0, len(ffe_output)-number_of_dfe_taps[jj]):
            dfe_output[ii+number_of_dfe_taps[jj]] = ffe_output[ii+number_of_dfe_taps[jj]]
            for nn in range(number_of_dfe_taps[jj]):
                dfe_output[ii+number_of_dfe_taps[jj]] = dfe_output[ii+number_of_dfe_taps[jj]] - (best_pv/10)/(nn+1)*slicer(dfe_output[ii+number_of_dfe_taps[jj]-nn-1])

        fig, ax = plt.subplots()
        plt.hist(ffe_output, bins=100)
        fig.savefig(f'plots/{sparam_file}_ffe_output.png')

        fig, ax = plt.subplots()
        plt.hist(dfe_output, bins=100)
        plt.title(f'{sparam_file} {best_pv}')
        fig.savefig(f'plots/{sparam_file}_dfe_output.png')

        with open(f'plots/config_{sparam_file}.txt', 'w') as f:
            print(f'{ffe_length}', file=f)
            print(f'{best_ii}', file=f)
            print(f'{best_pv}', file=f)
            print(f'{best_mm_lock_pos}', file=f)
            print(f'{number_of_dfe_taps[jj]}', file=f)
            print(f'{channel_shift[jj]}', file=f)
            print(f'{pulse}', file=f)
            print(f'{best_zf_taps}', file=f)

    if run_sim:
        with open(f'plots/config_{sparam_file}.txt', 'r') as f:
            ffe_length = int(f.readline())
            best_ii = int(f.readline())
            best_pv = int(f.readline())
            best_mm_lock_pos = float(f.readline())
            number_of_dfe_taps = int(f.readline())
            channel_shift = float(f.readline())
            pulse = read_array(f)
            best_zf_taps = read_array(f)

        data = (np.random.randint(0, 4, size=N_samples)*2-3)/3
        rx_input = np.convolve(pulse, data)
        rx_input = rx_input[2:]
        noise = np.random.normal(0, sigma, len(rx_input))
        rx_input = rx_input + noise
        ffe_output = np.convolve(best_zf_taps, rx_input)
        ffe_output = ffe_output[best_ii+1:]


        dfe_output = np.zeros(len(ffe_output))
        for ii in range(0, number_of_dfe_taps):
            dfe_output[ii] = ffe_output[ii]

        for ii in range(0, len(ffe_output)-number_of_dfe_taps):
            dfe_output[ii+number_of_dfe_taps] = ffe_output[ii+number_of_dfe_taps]
            for nn in range(number_of_dfe_taps):
                dfe_output[ii+number_of_dfe_taps] = dfe_output[ii+number_of_dfe_taps] - (best_pv/10)/(nn+1)*slicer(dfe_output[ii+number_of_dfe_taps-nn-1])

        received_data = [slicer(val) for val in dfe_output]

        error_count = np.sum(np.abs(data[3:N_samples-1] - received_data[0:N_samples-4]))

        print(f'Error rate: {error_count/(N_samples-4)}')
