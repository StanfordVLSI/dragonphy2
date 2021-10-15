from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np
from scipy import linalg
from dragonphy import *
from rich.progress import Progress

system_config = Configuration('system', path_head='../../config')
ffe_config = system_config['generic']['ffe']
ffe_config['parameters']['length'] = 12

sparam_file_list = ["Case4_FM_13SI_20_T_D13_L6.s4p",
                    "peters_01_0605_B1_thru.s4p",  
                    "peters_01_0605_B12_thru.s4p",  
                    "peters_01_0605_T20_thru.s4p",
                    "TEC_Whisper42p8in_Meg6_THRU_C8C9.s4p",
                    "TEC_Whisper42p8in_Nelco6_THRU_C8C9.s4p"]

file_name = str(get_file(f'data/channel_sparam/{sparam_file_list[0]}'))
f_sig = 16e9
alpha = 0.8e-12;
resp_depth=50
ffe_length=10
delay_adjust =7.32e-12
num_of_precursors=2
ffe_cursor_pos = 3

t, imp = s4p_to_impulse(str(file_name), 0.1e-12, 20e-9, zs=50, zl=50)
cursor_position = np.argmax(imp)

t_max = t[cursor_position] - delay_adjust
shift_delay = -t_max + (num_of_precursors)/f_sig

#Load the S4P into a channel model
chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=800000,
                   s4p=file_name, zs=50, zl=50)

#Trim leading zeros from the channel model
t2, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=resp_depth, t_delay=shift_delay)
im_idx = np.argmax(pulse)


chan_mat = linalg.convolution_matrix(pulse, ffe_length)
imp = np.zeros((resp_depth+ffe_length-1,1))
imp[ffe_cursor_pos] = 1
zf_taps = np.reshape(np.linalg.pinv(chan_mat) @ imp, (ffe_length,)) 


#Create an upsampled f_sig pulse response:

hr_pulse = chan.compute_output(np.ones((100,)) ,f_sig=f_sig*100, resp_depth=resp_depth*100, t_delay=shift_delay)

#Create matching sampling times
hr_t = shift_delay + np.linspace(0, resp_depth/f_sig+1/f_sig, resp_depth*100 + 99)
hr_t = hr_t - hr_t[0] - 1/f_sig

#Create High Resolution Slope
a_v = (hr_pulse[1:] - hr_pulse[:-1])/(hr_t[1:]-hr_t[:-1])

#Low Resolution for Comparison Purposes
lr_t, lr_pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=resp_depth, t_delay=shift_delay)
lr_t = lr_t - lr_t[0]

#Down-sample Slope
lr_a_v = a_v[100::100]

print("sum of derivative taps: ", np.sum(lr_a_v/np.max(np.abs(lr_a_v))))
print(np.sum(a_v))

#Plot to validate
fig, axs = plt.subplots(2)
axs[1].plot((hr_t[:-1] + hr_t[1:])/2, a_v/np.max(np.abs(a_v)))
axs[0].plot(hr_t, hr_pulse/np.max(hr_pulse))
axs[0].stem(lr_t, lr_pulse/np.max(lr_pulse))
axs[1].stem(hr_t[100::100], lr_a_v/np.max(np.abs(a_v)))
plt.show()

eq_lr_pulse = np.convolve(lr_pulse, zf_taps)[:50]

eq_hr_pulse = np.zeros((ffe_length*100,))
eq_hr_pulse[::100] = zf_taps
eq_hr_pulse = np.convolve(eq_hr_pulse, hr_pulse)[:resp_depth*100+99]

eq_a_v = np.zeros((ffe_length*100,))
eq_a_v[::100] = zf_taps
eq_a_v = np.convolve(eq_a_v, a_v)[50:resp_depth*100+99+49]
eq_lr_a_v = eq_a_v[100::100]

plt.plot(eq_hr_pulse)
plt.show()
plt.plot(eq_a_v)
plt.show()

#Equalized Channel
fig, axs = plt.subplots(2)

axs[0].plot(hr_t, hr_pulse/np.max(hr_pulse))
axs[0].plot(hr_t, eq_hr_pulse/np.max(eq_hr_pulse))
axs[0].stem(lr_t, lr_pulse/np.max(lr_pulse))
axs[0].stem(lr_t, eq_lr_pulse/np.max(eq_lr_pulse))


axs[1].plot((hr_t[:-1] + hr_t[1:])/2, a_v/np.max(np.abs(a_v)))
axs[1].plot((hr_t[:-1] + hr_t[1:])/2, eq_a_v/np.max(np.abs(eq_a_v)))
axs[1].stem(hr_t[100::100], lr_a_v/np.max(np.abs(lr_a_v)))
axs[1].stem(hr_t[100::100], eq_lr_a_v/np.max(np.abs(eq_lr_a_v)))
plt.show()

plt.plot(hr_t, hr_pulse/np.max(hr_pulse))
plt.stem(lr_t, lr_pulse/np.max(lr_pulse))
plt.title("Channel Response (16 Gb/s)")
plt.xlabel("time (s)")
plt.ylabel("A.U")
plt.show()
plt.plot(hr_t, eq_hr_pulse/np.max(eq_hr_pulse))
plt.stem(lr_t, eq_lr_pulse/np.max(eq_lr_pulse))
plt.title("Equalized Channel Response (16 Gb/s)")
plt.xlabel("time (s)")
plt.ylabel("A.U")
plt.show()
exit()

#Autocorrelation

hr_r_chan = np.convolve(hr_pulse, hr_pulse[::-1])
plt.plot(hr_r_chan)
plt.show()

r_chan = np.convolve(lr_pulse, lr_pulse[::-1])
plt.stem(r_chan)
plt.show()

r_a_v = np.convolve(lr_a_v, lr_a_v[::-1])
plt.stem(r_a_v)
plt.show()

hr_r_a_v = np.convolve(a_v, a_v[::-1])
plt.plot(hr_r_a_v)
plt.show()

white_jitter = np.random.normal(size=(10000000,))
jitter 		 = np.convolve(white_jitter, np.exp(-0.25*np.linspace(0,40,41)))
chan_white_jitter  = np.convolve(white_jitter, lr_a_v/np.max(np.abs(lr_a_v)))
chan_jitter  = np.convolve(jitter, lr_a_v/np.max(np.abs(lr_a_v)))

plt.psd(jitter)
plt.psd(white_jitter)
plt.psd(chan_white_jitter)
plt.psd(chan_jitter)
plt.show()


chan_mat = linalg.convolution_matrix(lr_a_v, ffe_length+10)
imp = np.zeros((resp_depth+ffe_length+10-1,1))
imp[ffe_cursor_pos] = 1
zf_taps = np.reshape(np.linalg.pinv(chan_mat) @ imp, (ffe_length+10,)) 

plt.plot(np.convolve(zf_taps, lr_a_v))
plt.show()
plt.psd(jitter)
plt.psd(chan_jitter)
plt.psd(np.convolve(chan_jitter, zf_taps/np.max(np.abs(zf_taps))))
plt.show()

plt.plot(zf_taps)
plt.show()
