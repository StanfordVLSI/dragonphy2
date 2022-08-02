from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np
from scipy import linalg
from dragonphy import *
from rich.progress import Progress

THIS_DIR = Path(__file__).resolve().parent

system_config = Configuration('system', path_head='../../config')
ffe_config = system_config['generic']['ffe']
ffe_config['parameters']['length'] = 12

sparam_file_list = ["Case4_FM_13SI_20_T_D13_L6.s4p",
                    "peters_01_0605_B1_thru.s4p",  
                    "peters_01_0605_B12_thru.s4p",  
                    "peters_01_0605_T20_thru.s4p",
                    "TEC_Whisper42p8in_Meg6_THRU_C8C9.s4p",
                    "TEC_Whisper42p8in_Nelco6_THRU_C8C9.s4p"]


plot_response = True

file_name = str(get_file(f'data/channel_sparam/{sparam_file_list[0]}'))
f_sig = 16e9
alpha = 0.8e-12;
resp_depth=50
ffe_length=10
delay_adjust =7.32e-12
num_of_precursors=2
ffe_cursor_pos = 2

t, imp = s4p_to_impulse(str(file_name), 0.1e-12, 20e-9, zs=50, zl=50)
cursor_position = np.argmax(imp)

t_max = t[cursor_position] - delay_adjust
shift_delay = -t_max + (num_of_precursors)/f_sig

#Load the S4P into a channel model
chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=800000,
                   s4p=file_name, zs=50, zl=50)

#Trim leading zeros from the channel model
t2, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=resp_depth, t_delay=shift_delay)
print(shift_delay)
plt.stem(t2[0:10],pulse[0:10])
plt.show()
im_idx = np.argmax(pulse)


#Calculate FFE Taps
#ffe = FFEHelper(ffe_config, chan, step_size=0.1, t_max=t_max, sampl_rate=f_sig, cursor_pos=im_idx, iterations=500000, blind=False, quant=False)

plt.plot(pulse)
plt.show()

chan_mat = linalg.convolution_matrix(pulse, ffe_length)
imp = np.zeros((resp_depth+ffe_length-1,1))
imp[ffe_cursor_pos] = 1
zf_taps = np.reshape(np.linalg.pinv(chan_mat) @ imp, (ffe_length,)) 
print(len(pulse)) 
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

#Plot to validate
if plot_response:
	fig, axs = plt.subplots(2)
	axs[1].plot((hr_t[:-1] + hr_t[1:])/2, a_v/np.max(np.abs(a_v)))
	axs[0].plot(hr_t, hr_pulse/np.max(hr_pulse))
	axs[0].stem(lr_t, lr_pulse/np.max(lr_pulse))
	axs[1].stem(hr_t[100::100], lr_a_v/np.max(np.abs(a_v)))
	plt.show()



pre_curs  = lr_pulse[num_of_precursors-1]
post_curs = lr_pulse[num_of_precursors+1]
pre_slope = lr_a_v[num_of_precursors-1]
post_slope = lr_a_v[num_of_precursors+1]

#N is the number of samples to see (1+alpha*A_0) go to a small value (0.01)
A_0 = post_slope - pre_slope
H_0 = post_curs - pre_curs

N = int(np.ceil(np.log(0.01)/np.log((1 + alpha*A_0))))

#clr_pulse = chan.compute_output(ffe.weights, f_sig=f_sig, resp_depth=200, t_delay=shift_delay)
#clr_a_v   = np.convolve(lr_a_v, ffe.weights)

clr_pulse = chan.compute_output(zf_taps, f_sig=f_sig, resp_depth=200, t_delay=shift_delay)
clr_a_v   = np.convolve(lr_a_v, zf_taps)



pre_curs_ffe = clr_pulse[ffe_cursor_pos-1]
post_curs_ffe = clr_pulse[ffe_cursor_pos+1]
pre_slope_ffe = clr_a_v[ffe_cursor_pos-1]
post_slope_ffe = clr_a_v[ffe_cursor_pos+1]
A_0_ffe = post_slope_ffe - pre_slope_ffe
H_0_ffe = post_curs_ffe  - pre_curs_ffe

plt.plot(clr_pulse)
plt.plot(lr_pulse)
plt.show()

plt.plot(clr_a_v)
plt.plot(lr_a_v)
plt.show()

print(A_0, A_0_ffe, A_0_ffe/A_0)
print(H_0, H_0_ffe)
print(alpha*A_0_ffe, alpha*A_0)
print(N)

#plt.plot(ffe.weights)
plt.plot(zf_taps)
plt.show()

unfolded_c = np.zeros((len(lr_pulse)+2,))
unfolded_c[2:-2] = lr_pulse[2:] - lr_pulse[:-2]
unfolded_c[:2]  = lr_pulse[:2]
unfolded_c[len(lr_pulse):] = -lr_pulse[len(lr_pulse)-2:]


unfolded_c_ffe = np.zeros((len(clr_pulse)+2,))
unfolded_c_ffe[2:-2] = clr_pulse[2:] - clr_pulse[:-2]
unfolded_c_ffe[:2] = clr_pulse[:2]
unfolded_c_ffe[len(clr_pulse):] = -clr_pulse[len(clr_pulse)-2:]

plt.stem(unfolded_c_ffe, linefmt='b-', markerfmt='bo')
plt.stem(unfolded_c, linefmt='r-', markerfmt='ro')
plt.show()

c = np.zeros((len(lr_pulse)-num_of_precursors,))
c_ffe = np.zeros((len(clr_pulse)-ffe_cursor_pos,))


c[:num_of_precursors+1] = unfolded_c[num_of_precursors+2:2*num_of_precursors+3] + (1 + alpha*A_0)*np.flip(unfolded_c[:num_of_precursors+1])
c[num_of_precursors+1:] = unfolded_c[2*num_of_precursors+3:]

c_ffe[:ffe_cursor_pos+1] = unfolded_c_ffe[ffe_cursor_pos+2:2*ffe_cursor_pos+3] + np.flip(unfolded_c_ffe[:ffe_cursor_pos+1])
c_ffe[ffe_cursor_pos+1:] = unfolded_c_ffe[2*ffe_cursor_pos+3:]

plt.plot(c_ffe)
plt.plot(c)
plt.show()

l2_c = np.dot(c,c)
l2_c_ffe = np.dot(c_ffe, c_ffe)

print(f'Root of Folded C: {np.sqrt(l2_c)}')
print(f'Root of Folded C: {np.sqrt(l2_c_ffe)}')


#Generate Random Data and put it into a parallel bank structure
N_bits = 100
data = np.random.randint(2, size=(N_bits,))*2 - 1
codes = chan.compute_output(data, resp_depth=200, f_sig=f_sig, t_delay=shift_delay)
plt.plot(codes)
plt.show()
#est_bit = np.where(np.convolve(codes, ffe.weights) > 0, 1, -1)
est_bit = np.where(np.convolve(codes, zf_taps) > 0, 1, -1)
est_bit = np.where(codes > 0, 1, -1)

plt.plot(est_bit[2:len(data)+2])
plt.plot(data)
plt.show()

#plt.plot(np.convolve(codes, ffe.weights))
plt.plot(np.convolve(codes, zf_taps)[ffe_cursor_pos:])
plt.plot(data)
plt.show()

Be = (N_bits - np.dot(est_bit[2:len(data)+2], data))/N_bits/2
#Be = (N_bits - np.dot(est_bit[2:len(data)+2], data))/N_bits
print(Be)
Be = Be if Be < 0.5 else np.abs(0.5 - Be)



#######
print(np.sqrt(alpha/2/np.abs(A_0)*l2_c))
print(np.sqrt(alpha*np.abs(A_0/A_0_ffe)/2/np.abs(A_0_ffe)*l2_c_ffe))
print("------")
print(np.sqrt(alpha/2/np.abs(A_0_ffe)/(1 + A_0_ffe*alpha/2)*l2_c_ffe))
print(np.sqrt(alpha/2/np.abs(A_0_ffe)/(1 + A_0_ffe*alpha/2)*(l2_c_ffe + 0.5*(alpha*A_0_ffe)**2)))
print("------")
print(np.sqrt(1/2/np.abs(A_0_ffe)*l2_c_ffe))

print(-2*alpha*A_0_ffe*clr_pulse[ffe_cursor_pos]*clr_pulse[ffe_cursor_pos+2])
print(-2*alpha*A_0_ffe*clr_pulse[ffe_cursor_pos+1]*clr_pulse[ffe_cursor_pos+3])
print((alpha*A_0)**2 * (clr_pulse[ffe_cursor_pos]**2 + clr_pulse[ffe_cursor_pos+3]**2))
print(clr_pulse[ffe_cursor_pos], clr_pulse[ffe_cursor_pos+1], clr_pulse[ffe_cursor_pos+2])
print(np.abs(A_0/A_0_ffe))
