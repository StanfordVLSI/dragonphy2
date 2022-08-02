from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
from matplotlib import ticker, cm
import numpy as np
from scipy import linalg, stats
from dragonphy import *
from rich.progress import Progress

def damped_cosine_impulse(amplitude, decay, freq, sampling_rate, length):
    w_0 = freq * 2 * np.pi / sampling_rate
    alp = decay / sampling_rate
    amp = amplitude

    y = np.zeros((length+2,))
    x = np.zeros((length+2,))

    x[2] = 1

    for ii in range(2, length+2):
        y[ii] = y[ii-1] * 2 * np.exp(-alp)*np.cos(w_0) - y[ii-2] * np.exp(-2*alp) + amp*x[ii-1] * np.exp(-alp)*np.sin(w_0)

    return y[2:]

THIS_DIR = Path(__file__).resolve().parent
sparam_file_list = ["Case4_FM_13SI_20_T_D13_L6.s4p",
                    "peters_01_0605_B1_thru.s4p",  
                    "peters_01_0605_B12_thru.s4p",  
                    "peters_01_0605_T20_thru.s4p",
                    "TEC_Whisper42p8in_Meg6_THRU_C8C9.s4p",
                    "TEC_Whisper42p8in_Nelco6_THRU_C8C9.s4p"]

dmpd_cos = damped_cosine_impulse(11.72, np.log(11.72/1.24)*1e9, 1.1e9, 16e9, 100)

f_sig = 16e9
channel_length = 30
ffe_length = 10
num_bits = 8.4
num_of_precursors = 4


list_of_target_curs_pos = [4,10,8,8,12,3]
list_of_mm_lock_position = [15e-12,15e-12,12e-12,12e-12,3e-12, 15e-12]

channel_list = [0,1,2,3,4,5]

for ii in channel_list:
    file = sparam_file_list[ii]
    target_curs_pos = list_of_target_curs_pos[ii]
    mm_lock_pos = list_of_mm_lock_position[ii]

    file_name = str(get_file(f'data/channel_sparam/{file}'))
    t, imp = s4p_to_impulse(str(file_name), 0.1e-12, 20e-9, zs=50, zl=50)

    cursor_position = np.argmax(imp)
    shift_delay = -t[cursor_position] + (num_of_precursors)*1.0/(f_sig)
    #Load the S4P into a channel model
    chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=600000, s4p=file_name, zs=50, zl=50)
    time, pulse = chan.get_pulse_resp(f_sig=16e9, resp_depth=200, t_delay=shift_delay+mm_lock_pos)

    #start_time = time[0]
    #end_time = time[-1] * 6.05/6

    #upsampled_time = np.linspace(start_time,end_time,6099) - 50/(16e11)
    #pulse = np.convolve(pulse/100, np.ones((100,)))
    #time, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=600, t_delay=shift_delay + mm_lock_pos)

    #chan_mat = linalg.convolution_matrix(pulse, ffe_length)
    #imp = np.zeros((600 -1 + ffe_length,1))
    #imp[target_curs_pos] = 1
    #zf_taps = np.reshape(np.linalg.pinv(chan_mat) @ imp, (ffe_length,))

    #F_zf_taps = np.fft.fft(zf_taps)
    F_pulse    = np.fft.fft(pulse)
    #F_eq_pulse = np.fft.fft(np.convolve(pulse,zf_taps))
    #plt.plot(upsampled_time,pulse)
    #plt.show()
    #freq_zf = np.linspace(0, f_sig, 100)
    freq_pulse = np.linspace(0, f_sig, 200)
    #freq_eq_pulse = np.linspace(0, f_sig, 699)

    #plt.plot(freq_zf, 20*np.log10(np.abs(F_zf_taps)))
    #plt.plot(freq_pulse,20*np.log10(np.abs(F_pulse)))
    #plt.plot(freq_eq_pulse, 20*np.log10(np.abs(F_eq_pulse)))
    #plt.xscale('log')
    #plt.show()


    spectrum = F_pulse
    log_spectrum = np.log(np.abs(spectrum)) #+ 1j*np.unwrap(np.angle(spectrum))
    #ceps = np.fft.ifft(log_spectrum).real
    #plt.plot(freq_pulse, np.unwrap(np.angle(F_pulse)))
    #plt.xscale('log')
    #plt.show()


    #plt.plot(ceps)
    #plt.show()

    tx_filt = np.array([1,0, 0, -3e-2, 0, 2.24e-4])
    tx_filt = tx_filt/np.sum(np.abs(tx_filt))
    tx_length = len(tx_filt)

    eq_pulse = np.convolve(pulse,tx_filt)[:200]

    chan_mat = linalg.convolution_matrix(eq_pulse, ffe_length)
    imp = np.zeros((200 + ffe_length -1,1))
    imp[target_curs_pos] = 1
    zf_eq_taps = np.reshape(np.linalg.pinv(chan_mat) @ imp, (ffe_length,))

    chan_mat = linalg.convolution_matrix(pulse, ffe_length)
    imp = np.zeros((200 + ffe_length -1,1))
    imp[target_curs_pos] = 1
    zf_taps = np.reshape(np.linalg.pinv(chan_mat) @ imp, (ffe_length,))

    print(np.sum(np.abs(zf_taps)))
    print(np.sqrt(np.sum(np.square(zf_taps))))
    continue

    plt.stem(zf_taps)
    plt.show()
    plt.plot(pulse)
    plt.plot(eq_pulse)
    plt.show()
    plt.plot(np.convolve(pulse, zf_taps))
    plt.show()

    plt.plot(np.append(tx_filt, np.zeros((ffe_length-tx_length,))))
    plt.show()

    F_tx_filt = np.fft.fft(np.append(tx_filt, np.zeros((ffe_length-tx_length,))))
    F_zf_taps = np.fft.fft(zf_taps)

    F_deconv = np.divide(F_zf_taps,F_tx_filt)

    zf_deconv_taps = np.fft.ifft(F_deconv).real
    plt.plot(zf_eq_taps)
    plt.plot(zf_deconv_taps)
    plt.plot(zf_taps)
    plt.show()

    print(np.sum(np.square(zf_deconv_taps)))
    print(np.sum(np.square(zf_taps)))
    print(np.sum(np.square(zf_eq_taps)))

    plt.plot(zf_taps - np.convolve(zf_deconv_taps, tx_filt)[:ffe_length])
    plt.show()
