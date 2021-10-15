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
slice_point = 130000
cdr_adjust  =12e-12
alpha = 15e-12
dc_bal_gain = 1e-13 
beta  = 1/3000
gamma = 0
N_samples = 160000
ffe_length = 10
target_curs_pos = 8
freq_slope = 0.0001

t, imp = s4p_to_impulse(str(file_name), 0.1e-12, 20e-9, zs=50, zl=50)
cursor_position = np.argmax(imp)

#Load the S4P into a channel model
chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=800000,
                   s4p=file_name, zs=50, zl=50)


num_of_precursors = 2
shift_delay = -t[cursor_position] + (num_of_precursors)*1.0/(f_sig)

values = [1,0,0]

num_chan_vals = 100


time, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay=shift_delay + np.mod(cdr_adjust, 1/f_sig))
#pulse_r = chan.compute_output(values, resp_depth=num_chan_vals, f_sig=f_sig, t_delay=shift_delay + np.mod(12e-12, 1/f_sig))
select  = np.where(np.abs(pulse)/np.max(np.abs(pulse)) > 0.005, 1, 0)
print(f"Number Of Channel Taps: {np.sum(select)}")
#select = np.zeros((200,))
#select[:num_chan_vals] = 1

NB = 20
#Generate Random Data and put it into a parallel bank structure
data = np.random.randint(2, size=(N_samples,))*2 - 1
noise = (2*np.random.random(size=(N_samples,))-1) * 1/2**NB 

show_plot=False

iter_codes = []
cdr_history = []
cdr_est_history = []
phase_est_history = [cdr_adjust]
dc_bals           = []
freq_est_history  = []
total_phase_history  = []


phase_est = 0
freq_est  = 0

time, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay=shift_delay + np.mod(cdr_adjust, 1/f_sig))
chan_mat = linalg.convolution_matrix(pulse, ffe_length)
imp = np.zeros((200 + ffe_length - 1,1))
imp[target_curs_pos] = 1
zf_taps = np.reshape(np.linalg.pinv(chan_mat) @ imp, (ffe_length,))

eq_ch = chan.compute_output(zf_taps, resp_depth=200, f_sig=f_sig, t_delay=shift_delay + np.mod(cdr_adjust, 1/f_sig))
prev_eq_res = np.sum(np.square(eq_ch)) - np.square(eq_ch[6])

fig, axes = plt.subplots(3)
axes[0].stem(zf_taps)
axes[1].stem(eq_ch)
axes[2].stem(pulse)
plt.show()  
dc_bal = 0.0
dc_bal_L = 0.0
total_ffe_adjusts = 0
with Progress() as progress:
    cdr_task = progress.add_task("[red]CDR: ", total=N_samples-200)
    for ii in range(200,N_samples):

        datum = data[ii-200:ii+2]

        if len(datum) < 202:
            continue
        codes     = chan.compute_output(datum, resp_depth=200, f_sig=f_sig, t_delay=shift_delay + np.mod(cdr_adjust, 1/f_sig))
        opt_codes = chan.compute_output(datum, resp_depth=200, f_sig=f_sig, t_delay=shift_delay + np.mod(12e-12, 1/f_sig), select=select)#:num_chan_vals+1+200]
    
        try:
            codes = codes[:202] + noise[ii-200:ii+2]
        except ValueError:
            codes = codes[:201] + noise[ii-200:ii+2] 

        residual = codes[200] - opt_codes[200]

        est_bits = np.convolve(zf_taps, codes)
        sign_data = np.where(est_bits > 0, 1, -1)

        dc_bal += sign_data[200]# - sign_data[199]
        all_cdr_est = residual*(sign_data[200])# -sign_data[199])# - sign_data[198]) 
        #pi_corr     -= (idv_cdr_est - avg_cdr_est)*0.05e-12
        freq_input = heaviside(ii - 40000)* 1/f_sig * (ii-40000) * freq_slope - heaviside(ii - 80000) * 1/f_sig * (ii - 80000) * freq_slope * 2
        phase_input = heaviside(ii - 20000)*5e-12 
        total_phase_input = phase_input + freq_input 

        phase_est += residual*alpha
        freq_est  += phase_est_history[-1]*beta

        cdr_adjust = phase_est + freq_est + total_phase_input - dc_bal * dc_bal_gain

        cdr_est_history += [all_cdr_est]
        phase_est_history += [phase_est]
        freq_est_history  += [freq_est]
        total_phase_history += [total_phase_input]
        cdr_history += [cdr_adjust]
        iter_codes  += [codes[200]]
        dc_bals += [dc_bal * dc_bal_gain]

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


np.savetxt("residual_cdr_1.csv", np.array(cdr_history), delimiter=",")


#plt.plot(np.mod(cdr_history,1/f_sig), label="Sampling Position Error")
plt.plot(dc_bals)
plt.plot(cdr_history)
#plt.plot(np.mod(total_phase_history,1/f_sig), label="Input Phase")
#plt.plot(np.array(dc_bals) * ave * alpha * 50)
#plt.plot(total_phase_history)
plt.title("Residual MM-CDR Traces")
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

