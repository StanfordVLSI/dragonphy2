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


file_name = str(get_file(f'data/channel_sparam/{sparam_file_list[1]}'))
f_sig = 16e9
f_clk = 10e9 + 1e5
slice_point = 100000
cdr_adjust  = 200e-12
alpha = 0.5e-12 
beta  = 1/3000
gamma = 0
N_samples = 120000
ffe_length = 10
target_curs_pos = 8
freq_slope = 0.001

t, imp = s4p_to_impulse(str(file_name), 0.1e-12, 20e-9, zs=50, zl=50)
cursor_position = np.argmax(imp)

#Load the S4P into a channel model
chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=800000,
                   s4p=file_name, zs=50, zl=50)


num_of_precursors = 2
shift_delay = -t[cursor_position] + (num_of_precursors)*1.0/(f_sig)
NB = 6
#Generate Random Data and put it into a parallel bank structure
data = np.random.randint(2, size=(N_samples,))*2 - 1
noise = (np.random.random(size=(N_samples,))*2 - 1) * 1/(2**NB)


show_plot=False

iter_codes = []
cdr_history = []
cdr_est_history = []
ave_cdr_history = [cdr_adjust]
phase_est_history = [cdr_adjust]
freq_est_history  = []
total_phase_history  = []


phase_est = 0
freq_est  = 0

time, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay=shift_delay + np.mod(cdr_adjust, 1/f_sig))
chan_mat = linalg.convolution_matrix(pulse, ffe_length)
imp = np.zeros((209,1))
imp[target_curs_pos] = 1
zf_taps = np.reshape(np.linalg.pinv(chan_mat) @ imp, (ffe_length,))
filt_noise = np.convolve(zf_taps, noise)
fig, axes = plt.subplots(2,1)
axes[0].hist(noise)
axes[1].hist(filt_noise)
print(np.sqrt(np.dot(filt_noise.T, filt_noise)/len(filt_noise))/np.sqrt(np.dot(noise.T, noise)/len(noise)))
plt.show()

eq_ch = chan.compute_output(zf_taps, resp_depth=200, f_sig=f_sig, t_delay=shift_delay + np.mod(cdr_adjust, 1/f_sig))
prev_eq_res = np.sum(np.square(eq_ch)) - np.square(eq_ch[6])

fig, axes = plt.subplots(3)
axes[0].stem(zf_taps)
axes[1].stem(eq_ch)
axes[2].stem(pulse)
plt.show()  

total_ffe_adjusts = 0
with Progress() as progress:
    cdr_task = progress.add_task("[red]CDR: ", total=N_samples-200)
    for ii in range(200,N_samples):
        datum = data[ii-200:ii+2]

        codes = chan.compute_output(datum, resp_depth=200, f_sig=f_sig, t_delay=shift_delay + np.mod(cdr_adjust, 1/f_sig))

        #plt.plot(codes)
        try:
            codes = codes[:202] + noise[ii-200:ii+2]
        except ValueError:
            codes = codes[:201] + noise[ii-200:ii+2]
        #plt.plot(codes)
        #plt.show()
        est_bits = np.convolve(zf_taps, codes)
        #est_bits = codes
        sign_data = np.where(est_bits > 0, 1, -1)


        #all_cdr_est = np.multiply(sign_data[2:], codes[1:-1]) - np.multiply(sign_data[:-2], codes[1:-1])
        all_cdr_est = est_bits[200]*(sign_data[201]-sign_data[199])

        #pi_corr     -= (idv_cdr_est - avg_cdr_est)*0.05e-12
        freq_input = heaviside(ii - 40000)* 1/f_sig * (ii-40000) * freq_slope - heaviside(ii - 80000) * 1/f_sig * (ii - 80000) * freq_slope * 2
        phase_input = heaviside(ii - 20000)*5e-12 
        total_phase_input = phase_input + freq_input 

        phase_est += all_cdr_est*alpha
        freq_est  += phase_est_history[-1]*beta
        cdr_adjust  = phase_est + freq_est + total_phase_input

        cdr_est_history += [all_cdr_est]
        phase_est_history += [phase_est]
        freq_est_history  += [freq_est]
        total_phase_history += [total_phase_input]
        cdr_history += [cdr_adjust]
        iter_codes  += [codes[200]]
        ave_cdr_history += [ave_cdr_history[-1]*0.99 + 0.01*cdr_adjust]

        progress.update(cdr_task, advance=1)

        #eq_ch = chan.compute_output(zf_taps, resp_depth=200, f_sig=f_sig, t_delay=shift_delay + np.mod(cdr_adjust, 1/f_sig))
        #eq_res = np.sum(np.square(eq_ch)) - np.square(eq_ch[6])
        #if prev_eq_res > eq_res:
        #    time, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay=shift_delay + np.mod(cdr_adjust, 1/f_sig))
        #    chan_mat = linalg.convolution_matrix(pulse, ffe_length)
        #    imp = np.zeros((209,1))
        #    imp[target_curs_pos] = 1
        #    zf_taps = np.reshape(np.linalg.pinv(chan_mat) @ imp, (ffe_length,))
        #    eq_ch = chan.compute_output(zf_taps, resp_depth=200, f_sig=f_sig, t_delay=shift_delay + np.mod(cdr_adjust, 1/f_sig))
        #    prev_eq_res = np.sum(np.square(eq_ch)) - np.square(eq_ch[6])
#
        #    total_ffe_adjusts += 1

np.savetxt("mm_cdr.csv", np.array(cdr_history), delimiter=",")

#print(total_ffe_adjusts/N_samples)

plt.plot(np.mod(cdr_history,1/f_sig), label="Sampling Position Error")
#plt.plot(cdr_history)
#plt.plot(ave_cdr_history)
#plt.plot(np.mod(total_phase_history,1/f_sig), label="Input Phase")
plt.title("Equalized MM-CDR Traces")
plt.xlabel("Cycles (62.5 ps per Cycle)")
plt.ylabel("Sampling Position (ps)")
plt.legend()
plt.show()

cdr_slice = np.mod(cdr_history[slice_point:], 1/f_sig)
cdr_mean = np.mean(cdr_slice)
zeroed_cdr = cdr_slice - cdr_mean
cdr_std    = np.sqrt(np.dot(zeroed_cdr.T, zeroed_cdr)/len(zeroed_cdr))

print(f"Mean: {cdr_mean}")
print(f"Standard Deviation: {cdr_std}")

plt.hist(cdr_slice - cdr_mean,bins=60)
plt.show()
