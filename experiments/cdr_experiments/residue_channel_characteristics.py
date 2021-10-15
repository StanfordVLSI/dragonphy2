from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np
from scipy import linalg
from dragonphy import *


THIS_DIR = Path(__file__).resolve().parent
sparam_file_list = ["Case4_FM_13SI_20_T_D13_L6.s4p",
                    "peters_01_0605_B1_thru.s4p",  
                    "peters_01_0605_B12_thru.s4p",  
                    "peters_01_0605_T20_thru.s4p",
                    "TEC_Whisper42p8in_Meg6_THRU_C8C9.s4p",
                    "TEC_Whisper42p8in_Nelco6_THRU_C8C9.s4p"]

#sparam_file_list = [sparam_file_list[2], sparam_file_list[4]]

f_sig = 16e9
step_size = 1e-12
channel_length = 30
select_channel = True
phase_steps_check = False
ffe_length = 10
num_bits = 5
debug_list = [2, 4]
num_of_precursors = 4

#target_curs_pos = 8
list_of_target_curs_pos = [3,6,12,9,12,3]
list_of_mm_lock_position = [15e-12,15e-12,12e-12,15e-12,3e-12, 15e-12]
list_of_eq_mm_lock_position = list_of_mm_lock_position# [15e-12,15e-12,25e-12,15e-12,15e-12, 15e-12]

phase_steps = [0.5e-12, 1e-12, 1.5e-12, 2e-12, 2.5e-12, 3e-12, 3.5e-12, 4e-12, 4.5e-12, 5e-12, 5.5e-12, 6e-12]

if phase_steps_check:
    for step_size in phase_steps:
        for channel_target in debug_list:
            file = sparam_file_list[channel_target]
            mm_lock_pos = list_of_mm_lock_position[channel_target]
            target_curs_pos = list_of_target_curs_pos[channel_target]

            file_name = str(get_file(f'data/channel_sparam/{file}'))
            t, imp = s4p_to_impulse(str(file_name), 0.1e-12, 20e-9, zs=50, zl=50)

            cursor_position = np.argmax(imp)
            shift_delay = -t[cursor_position] + (num_of_precursors)*1.0/(f_sig)
            #Load the S4P into a channel model
            chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=200000,
                               s4p=file_name, zs=50, zl=50)
            
            time_0ps, pulse_0ps = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay=shift_delay + mm_lock_pos)
            time_1ps, pulse_1ps = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay=shift_delay + mm_lock_pos + step_size)

            chan_mat = linalg.convolution_matrix(pulse_0ps, ffe_length)
            imp = np.zeros((199 + ffe_length,1))
            imp[target_curs_pos] = 1
            zf_taps = np.reshape(np.linalg.pinv(chan_mat) @ imp, (ffe_length,))

            plt.plot(np.convolve(zf_taps,pulse_0ps))
            plt.show()


            mm_pd_taps = np.pad(pulse_1ps, [(0,2)], mode='constant', constant_values=0)  - np.pad(pulse_1ps, [(2,0)], mode='constant', constant_values=0)
            mm_pd_gain = np.abs(mm_pd_taps[num_of_precursors+1])

            equalized_pulse_1ps = np.convolve(pulse_1ps, zf_taps)
            eq_mm_pd_taps = np.pad(equalized_pulse_1ps, [(0,2)], mode='constant', constant_values=0)  - np.pad(equalized_pulse_1ps, [(2,0)], mode='constant', constant_values=0)
            eq_mm_pd_gain = np.abs(eq_mm_pd_taps[target_curs_pos+1]) 

            difference = pulse_1ps - pulse_0ps
            residue_pd_taps = np.pad(difference, [(0,2)], mode='constant', constant_values=0)  - np.pad(difference, [(2,0)], mode='constant', constant_values=0)# - np.pad(difference, [(3,0)], mode='constant', constant_values=0)
            residue_gain = np.abs(residue_pd_taps[num_of_precursors+1])

            print(f'{file} : {step_size}')
            print(f'MM Gain: {mm_pd_gain/step_size}')
            print(f'EQ MM Gain: {eq_mm_pd_gain/step_size}')
            print(f'RES MM Gain: {residue_gain/step_size}')
            print()


max_gain = {}
ii = 0
for (target_curs_pos, mm_lock_pos, eq_mm_lock_pos, file) in zip(list_of_target_curs_pos, list_of_mm_lock_position, list_of_eq_mm_lock_position, sparam_file_list):
    if not ii in debug_list:
        ii += 1
        continue
    ii += 1

    file_name = str(get_file(f'data/channel_sparam/{file}'))
    t, imp = s4p_to_impulse(str(file_name), 0.1e-12, 20e-9, zs=50, zl=50)

    cursor_position = np.argmax(imp)
    shift_delay = -t[cursor_position] + (num_of_precursors)*1.0/(f_sig)
    #Load the S4P into a channel model
    chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=200000,
                       s4p=file_name, zs=50, zl=50)
    
    time_0ps, pulse_0ps = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay=shift_delay + mm_lock_pos)
    time_1ps, pulse_1ps = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay=shift_delay + mm_lock_pos + step_size)

    plt.stem(pulse_0ps[:12])
    plt.show()

    chan_mat = linalg.convolution_matrix(pulse_0ps, ffe_length)
    imp = np.zeros((199 + ffe_length,1))
    imp[target_curs_pos] = 1
    zf_taps = np.reshape(np.linalg.pinv(chan_mat) @ imp, (ffe_length,))

    plt.plot(np.convolve(zf_taps,pulse_0ps))
    plt.plot(np.convolve(zf_taps,pulse_1ps))
    plt.show()

    offset_mm_pd_taps = np.pad(pulse_0ps, [(0,2)], mode='constant', constant_values=0)  - np.pad(pulse_0ps, [(2,0)], mode='constant', constant_values=0)
    mm_pd_taps = np.pad(pulse_1ps, [(0,2)], mode='constant', constant_values=0)  - np.pad(pulse_1ps, [(2,0)], mode='constant', constant_values=0)
    mm_pd_gain = mm_pd_taps[num_of_precursors+1] - offset_mm_pd_taps[num_of_precursors+1]
    mm_pd_taps[num_of_precursors+1] = 0

    equalized_pulse_1ps = np.convolve(pulse_1ps, zf_taps)
    equalized_pulse_0ps = np.convolve(pulse_0ps, zf_taps)
    offset_eq_mm_pd_taps = np.pad(equalized_pulse_0ps, [(0,2)], mode='constant', constant_values=0)  - np.pad(equalized_pulse_0ps, [(2,0)], mode='constant', constant_values=0)

    eq_mm_pd_taps = np.pad(equalized_pulse_1ps, [(0,2)], mode='constant', constant_values=0)  - np.pad(equalized_pulse_1ps, [(2,0)], mode='constant', constant_values=0)
    eq_mm_pd_gain = eq_mm_pd_taps[target_curs_pos+1] - offset_eq_mm_pd_taps[num_of_precursors+1]
    eq_mm_pd_taps[target_curs_pos+1] = 0

    difference = pulse_1ps - pulse_0ps
    residue_pd_taps = np.pad(difference, [(0,2)], mode='constant', constant_values=0)  - np.pad(difference, [(2,0)], mode='constant', constant_values=0)# - np.pad(difference, [(3,0)], mode='constant', constant_values=0)
    residue_gain = np.abs(residue_pd_taps[num_of_precursors+1])
    residue_pd_taps[num_of_precursors+1] = 0

    fig, axes = plt.subplots(3,1)

    axes[0].plot(residue_pd_taps)
    axes[1].plot(mm_pd_taps)
    axes[2].plot(eq_mm_pd_taps)
    plt.show()


    bits = np.random.randint(2, size=(10**num_bits,))*2 - 1
    residue_noise = np.convolve(difference, bits)
    mm_pd_noise   = np.convolve(mm_pd_taps, bits)
    eq_mm_pd_noise = np.convolve(eq_mm_pd_taps, bits)

    mm_pd_std = np.sqrt(np.dot(mm_pd_noise, mm_pd_noise.T)/10**num_bits)
    eq_mm_pd_std = np.sqrt(np.dot(eq_mm_pd_noise, eq_mm_pd_noise.T)/10**num_bits)
    residue_pd_std = np.sqrt(np.dot(residue_noise, residue_noise.T)/10**num_bits)


    auto_mm = np.convolve(mm_pd_taps, mm_pd_taps[::-1])/mm_pd_gain**2
    auto_eq_mm = np.convolve(eq_mm_pd_taps[:202], eq_mm_pd_taps[:202][::-1])/eq_mm_pd_gain**2
    auto_res_mm = np.convolve(residue_pd_taps, residue_pd_taps[::-1])/residue_gain**2

#    plt.plot(auto_mm)
#    plt.plot(auto_eq_mm)
#    plt.plot(auto_res_mm)
#    plt.show()

    psd_mm = np.fft.fft(auto_mm)/len(auto_mm)
    psd_eq_mm = np.fft.fft(auto_eq_mm)/len(auto_eq_mm)
    psd_res_mm = np.fft.fft(auto_res_mm)/len(auto_res_mm)

    freq_mm = np.linspace(0, f_sig, len(auto_mm))
    freq_eq_mm = np.linspace(0, f_sig, len(auto_eq_mm))
    freq_res_mm = np.linspace(0, f_sig, len(auto_res_mm))

    select  = np.where(np.abs(pulse_0ps)/np.max(np.abs(pulse_0ps)) > 0.005, False, True)
    plt.plot(pulse_0ps)

    if select_channel:
        pulse_0ps[select] = 0
        channel_length = 200 - np.sum(select)
    else:
        pulse_0ps[channel_length:] = 0
    plt.stem(pulse_0ps)
    plt.show()
    difference = (pulse_1ps-pulse_0ps)
    mm_out   = np.pad(difference, [(0,2)], mode='constant', constant_values=0) - np.pad(difference, [(2,0)], mode='constant', constant_values=0)
    mm_out[num_of_precursors+1] = 0

    auto_imp_res = np.convolve(mm_out, mm_out[::-1])/residue_gain**2
    psd_res_mm_imp = np.fft.fft(auto_imp_res)/len(auto_imp_res)


    bits = np.random.randint(2, size=(10**num_bits,))*2 - 1
    noise = np.convolve(mm_out, bits)
    std_noise = np.sqrt(np.dot(noise, noise.T)/10**num_bits)

    plt.plot(freq_mm, 10*np.log10(np.abs(psd_mm)), label='MM PSD')
    plt.plot(freq_eq_mm, 10*np.log10(np.abs(psd_eq_mm)), label='EQ MM PSD')
    plt.plot(freq_res_mm, 10*np.log10(np.abs(psd_res_mm)), label='RESIDUE MM PSD')
    plt.plot(freq_res_mm,10*np.log10(np.abs(psd_res_mm_imp)), label='IMPERFECT RESIDUE MM PSD')
    plt.legend()
    plt.show()

    #plt.plot(np.convolve(mm_pd_taps/np.max(np.abs(mm_pd_taps)), np.ones((100000,)))[:300])
    #plt.plot(np.convolve(eq_mm_pd_taps/np.max(np.abs(eq_mm_pd_taps)), np.ones((100000,)))[:300])
    #plt.plot(np.convolve(residue_pd_taps/np.max(np.abs(residue_pd_taps)), np.ones((100000,)))[:300])
    #plt.show()
    print(f'{file}:\nResidue Gain: {residue_gain} @ {step_size*1e12} ps step')
    print(f'MM Gain @ Step: {mm_pd_gain} @ {step_size*1e12} ps step')
    print(f'EQ MM Gain @ Step: {eq_mm_pd_gain} @ {step_size*1e12} ps step')
    print(f'EQ / UNEQ Gain: {eq_mm_pd_gain}')
    print(f'Residue Phase Noise: {residue_pd_std} | SNR:  {20*np.log10(residue_gain/residue_pd_std)}')
    print(f'MM Phase Noise: {mm_pd_std}  | SNR: {20*np.log10(mm_pd_gain/mm_pd_std)}')
    print(f'EQ MM Phase Noise: {eq_mm_pd_std} | SNR:  {20*np.log10(eq_mm_pd_gain/eq_mm_pd_std)}')
    print(f'PD + Remainder Noise: {std_noise} | SNR: {20*np.log10(residue_gain/std_noise)}, Channel Est Length: {channel_length}')

    #plt.hist(noise, bins=100)
    #a_mm_out[1] = 0
    #a_mm_out[0] = 0

    plt.stem(zf_taps)
    plt.show()

    #bits = np.random.randint(2, size=(10**num_bits,))*2 - 1
    #noise = np.convolve(a_mm_out, bits)
    #std_noise = np.sqrt(np.dot(noise, noise.T)/10**num_bits)
    #print(f'Phase Dependent Noise: {std_noise} (without precursors) {20*np.log10(gain/np.square(std_noise))}')
    #plt.hist(noise, bins=100)
    #plt.show()


    #plt.hist(noise, bins=100)
    #mm_out[1] = 0
    #mm_out[0] = 0

    #bits = np.random.randint(2, size=(10**num_bits,))*2 - 1
    #noise = np.convolve(mm_out, bits)
    #std_noise = np.sqrt(np.dot(noise, noise.T)/10**num_bits)
    #print(f'Phase Dependent Noise: {std_noise} (without precursors) {20*np.log10(gain/np.square(std_noise))}')
    #plt.hist(noise, bins=100)
    #plt.show()
    print()
#    max_gain[file] = np.zeros((125,))
#    for ii in range(1,125):
#        time, pulse_nps = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay= shift_delay + np.mod(ii*1e-12, 1/f_sig))
#        difference = pulse_nps-pulse_0ps
#        mm_out     = np.pad(difference, [(0,1)], mode='constant', constant_values=0) - np.pad(difference, [(1,0)], mode='constant', constant_values=0) 
#        max_gain[file][ii-1] = np.max(mm_out) / ii

#for file in sparam_file_list:
#    plt.plot(max_gain[file], label=file)

#plt.legend()
#plt.show()