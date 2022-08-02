from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np
from scipy import linalg
from dragonphy import *
from rich.progress import Progress


class BankIterator:
    def __init__(self, bank):
        self._values = bank.values
        self._width  = bank.width
        self._max_idx = bank.max_idx
        self._idx  = 0

    def __next__(self):
        if self._idx < self._max_idx:
            result = self._values[self._idx*self._width:(self._idx+1)*self._width]
            self._idx += 1
            return result
        raise StopIteration

class Bank:
    def __init__(self, values=None, width=None ):
        self.values     = values if any(values) else 0 
        self.width      = width if width else 1
        self.max_idx    = np.floor(len(values)/self.width)
        self._idx = 0
    def __getitem__(self, idx):
        if idx >= self.max_idx:
            return None
        else:
            return self.values[idx*self.width:(idx+1)*self.width]
    def __iter__(self):
        return BankIterator(self)

class TimedMultiChannelWrapper:
    def __init__(self, channel_types=None, sampl_rate=None, resp_depth=None, f_sig=None, parameters=None, t_delays=None):
        self.channel_types = channel_types if channel_types else ['s4p']
        self.sampl_rate   = sampl_rate   if sampl_rate   else 1e9
        self.resp_depth   = resp_depth   if resp_depth   else 50
        self.f_sig         = f_sig         if f_sig         else 1e8
        self.parameters    = parameters    if parameters    else [{}]
        self.t_delays      = t_delays      if t_delays      else [0]

        self._chan_ = {}
        ii = 0
        for (channel_type, params) in zip(channel_types, parameters):
            self._chan_[ii] = Channel(channel_type=channel_type, sampl_rate=sampl_rate, resp_depth=resp_depth, **params)
            ii += 1

    def compute_output(self, symbols, f_sig=None, resp_depth=None, t_delays=None):
        f_sig      = f_sig      if f_sig      else self.f_sig
        resp_depth = resp_depth if resp_depth else self.resp_depth
        t_delays   = t_delays   if t_delays   else self.t_delays

        interleave_factor = len(self._chan_)

        code_section = self._chan_[0].compute_output(symbols, f_sig=f_sig, resp_depth=resp_depth, t_delay=t_delays[0])
        
        codes = np.zeros((len(code_section),))
        codes[0::interleave_factor] = code_section[0::interleave_factor]
        for ii in range(interleave_factor):
            chan = self._chan_[ii]
            t_delay = t_delays[ii]
            code_section = chan.compute_output(symbols, f_sig=f_sig, resp_depth=resp_depth, t_delay=t_delay)
            codes[ii::interleave_factor] = code_section[ii::interleave_factor]

        return codes

    def update_timing(self, t_delays):
        self.t_delays = t_delays

class TrianglePhaseOffset:
    def __init__(self, period=1e-6, f_sig=16e9, f_clk=16e9+1e4, num_chan=16):
        self.f_sig = f_sig
        self.f_clk = f_clk
        self.norm_per = period*f_sig
        self.num_chan = num_chan
        self.adjustment = num_chan*(f_sig - f_clk)/f_sig/f_sig
        self.state = 0
    def next_phase(self):
        return_val = 0
        if self.state < 0.5*self.norm_per:
            return_val = self.adjustment
        else:
            return_val = -self.adjustment

        self.state += 1
        self.state = np.mod(self.state, self.norm_per)
        return return_val

class ExponentialMovingAverage:
    def __init__(self, beta=0.5):
        self.beta = beta
        self.val  = 0
        self.hist = []

    def __iadd__(self, new_value):
        self.val = (1-beta)*self.val + beta*new_value
        self.hist += [self.val]

    def get_history(self):
        return self.hist

class PhaseInterpolator:
    def __init__(self, nbits=8, gain=1, center_delay=0, f_sig=16e9, pi_curve=None):
        self.nbits        = nbits
        self.f_sig        = f_sig
        self.gain         = gain
        self.center_delay = center_delay
        self.mod_delay    = 0
        self.pi_curve     = pi_curve if pi_curve else None

    def __iadd__(self, value):
        self.mod_delay += value 
        return self
    def __call__(self, code):
        interp_val = self.center_delay + np.mod(self.mod_delay + self.gain*code,1/self.f_sig)
        if self.pi_curve:
            return self.pi_curve(interp_val)[0]
        else:
            return interp_val

class ModBitProximityTable:
    def __init__(self, nbits=8, full_scale=1):
        self.nbits      = nbits
        self.full_scale = full_scale
        self.lsb        = full_scale/(2**nbits)
        self.table      = np.linspace(0, full_scale, 2**nbits)

    def __prox__(self, value):
        return np.mod(round(value/self.lsb), 2**self.nbits)

    def __getitem__(self, idx):
        return self.table[self.__prox__(idx)]

    def __setitem__(self, idx, new_value):
        self.table[self.__prox__(idx)] = new_value

class LimitedMovementTable(ModBitProximityTable):
    def __init__(self, nbits=8, full_scale=1):
        super().__init__(nbits=nbits, full_scale=full_scale)

    def __setitem__(self, idx, new_value):
        act_idx = self.__prox__(idx)

        ul_idx = 511 if act_idx == 511 else act_idx + 1
        ll_idx = 0 if act_idx == 0 else act_idx - 1
        
        new_value = new_value if new_value < self.table[ul_idx] else self.table[ul_idx]
        new_value = new_value if new_value > self.table[ll_idx] else self.table[ll_idx]

        self.table[act_idx] = new_value

class SJKPICurve:
    def __init__(self, f_sig=16e9, n_spikes=16, amplitude=0.5, duty_cycle=0.5):
        self.a = amplitude
        self.b = duty_cycle
        self.t = 1/f_sig/n_spikes

    def __call__(self, arr):
        a = self.a
        b = self.b
        t = self.t
        arr_m = np.mod(arr, t)
        return arr +  np.where(arr_m < b*t, -a*arr_m + a/(b*t)*arr_m**2, a*(1+b)/(1-b)*(arr_m-b*t) - a/((1-b)*t) * (arr_m**2 - (b*t)**2))

THIS_DIR = Path(__file__).resolve().parent
sparam_file_list = ["Case4_FM_13SI_20_T_D13_L6.s4p",
                    "peters_01_0605_B1_thru.s4p",  
                    "peters_01_0605_B12_thru.s4p",  
                    "peters_01_0605_T20_thru.s4p",
                    "TEC_Whisper42p8in_Meg6_THRU_C8C9.s4p",
                    "TEC_Whisper42p8in_Nelco6_THRU_C8C9.s4p"]


file_name = str(get_file(f'data/channel_sparam/{sparam_file_list[0]}'))
f_sig = 10e9
f_clk = 10e9 + 1e5
max_num_pi = 4
slice_point = 5000
cdr_adjust  = 44e-12
N_samples = 30000
ffe_length = 10
#Load the S4P into a channel model
chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=800000,
                   s4p=file_name, zs=50, zl=50)

#Trim leading zeros from the channel model
t2, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay=0)

cursor_position = np.argmax(pulse)
num_of_precursors = 2
shift_delay = -t2[cursor_position] + num_of_precursors*1.0/(f_sig) #+ 13.5e-12
print(shift_delay)
#Create multichannel wrapper
multi_channel = TimedMultiChannelWrapper(
    channel_types= ['s4p', 's4p', 's4p', 's4p'],
    sampl_rate   = 10e12,
    resp_depth   = 800000,
    f_sig        = f_sig,
    parameters   = [{'s4p' : file_name, 'zs' : 50, 'zl': 50}, 
                    {'s4p' : file_name, 'zs' : 50, 'zl': 50},
                    {'s4p' : file_name, 'zs' : 50, 'zl': 50},
                    {'s4p' : file_name, 'zs' : 50, 'zl': 50}],
    t_delays     = [shift_delay, shift_delay, shift_delay, shift_delay]
)

#Create Offset Widget
dynamic_offset = TrianglePhaseOffset(period=5e-6, f_sig=f_sig, f_clk=f_clk, num_chan=16)


#Generate Random Data and put it into a parallel bank structure
data = np.random.randint(2, size=(N_samples,))*2 - 1
_codes = chan.compute_output(data, resp_depth=200, f_sig=f_sig, t_delay=shift_delay)

data_bank      = Bank(values=data, width=16)

show_plot=False

#Store enough data for the convolution to be correct, Store iteratively calculated codes
data_buffer = np.array([])
iter_codes = []
cdr_history = []
pi_history  = []
phase_interp = {}
idv_corr = {}

target_curs_pos = 2
pi_corr     = np.zeros((4,))
#pi_corr     = np.random.randn(4,)*10e-12

gain_mismatch = [1,1,1,1]#[1, 1.05, 0.95, 0.85]
duty = [0,0,0,0]
n_spikes = [0,0,0,0]


for ii in range(max_num_pi):
    duty[ii] = np.random.rand(1)*0.4 + 0.2
    n_spikes[ii] = np.random.randint(10) + 10
    #phase_interp[ii] = PhaseInterpolator(nbits         = 8, 
    #                                      gain         = gain_mismatch[ii],
    #                                      center_delay = shift_delay, 
    #                                      f_sig=f_sig, 
    #                                      pi_curve=SJKPICurve(f_sig=f_sig, n_spikes=n_spikes[ii], amplitude=0.5, duty_cycle=duty[ii])
    #)
    phase_interp[ii] = PhaseInterpolator(nbits         = 16, 
                                          gain         = gain_mismatch[ii],
                                          center_delay = shift_delay, 
                                          f_sig=f_sig, 
                                          pi_curve=None
    )
    idv_corr[ii] = LimitedMovementTable(nbits=9, full_scale=1/f_sig)

#plt.ion()
fig        = plt.figure()
ax         = fig.add_subplot(111)

if show_plot:
    for pi_idx in range(max_num_pi):
        time, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=32, t_delay=shift_delay + np.mod(gain_mismatch[pi_idx]*(cdr_adjust+pi_corr[pi_idx]),1/f_sig))
        ax.plot(time, pulse)
    plt.pause(0.001)

time, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay=shift_delay + np.mod(cdr_adjust, 1/f_sig))

chan_mat = linalg.convolution_matrix(pulse, ffe_length)
imp = np.zeros((209,1))
imp[target_curs_pos] = 1
zf_taps = np.reshape(np.linalg.pinv(chan_mat) @ imp, (ffe_length,))
eq_ch = multi_channel.compute_output(zf_taps, resp_depth=30)
prev_eq_res = np.sum(np.square(eq_ch)) - np.square(eq_ch[6])

fig, axes = plt.subplots(3)
axes[0].stem(zf_taps)
axes[1].stem(eq_ch)
axes[2].stem(pulse)
plt.show()  

ii = 0
with Progress() as progress:
    cdr_task = progress.add_task("[red]CDR: ", total=data_bank.max_idx)
    for datum in data_bank:
        ii = ii + 1
        len_db = len(data_buffer)

        #multi_channel.update_timing([phase_interp[ii](idv_corr[ii][cdr_adjust] + pi_corr[ii]) for ii in range(max_num_pi)])
        multi_channel.update_timing([phase_interp[ii](cdr_adjust + pi_corr[ii]) for ii in range(max_num_pi)])
        #multi_channel.update_timing([(cdr_adjust + pi_corr[ii]) for ii in range(max_num_pi)])

        data_buffer = np.concatenate((data_buffer, datum)) if len_db < 200 else np.concatenate((data_buffer[16:],datum))

        eq_ch = multi_channel.compute_output(zf_taps, resp_depth=30)

        eq_res = np.sum(np.square(eq_ch)) - np.square(eq_ch[6])
        if eq_res > prev_eq_res * 1.1:
            chan_mat = linalg.convolution_matrix(pulse, ffe_length)
            zf_taps = np.reshape(np.linalg.pinv(chan_mat) @ imp, (ffe_length,))
            eq_ch = multi_channel.compute_output(zf_taps, resp_depth=30)
            plt.plot(eq_ch)
            plt.show()
            prev_eq_res = np.sum(np.square(eq_ch)) - np.square(eq_ch[6])        

        codes = multi_channel.compute_output(data_buffer, resp_depth=200)
        est_bits = np.convolve(zf_taps, codes)
        #est_bits = codes
        est_bits = est_bits[len_db:-199] if len_db < 200 else est_bits[len_db-16:-199]

        #codes = codes[len_db:-199] if len_db < 200 else codes[len_db-16: -199]
        #est_bits = est_bits[len_db+target_curs_pos-2:-199-ffe_length+1+target_curs_pos-2] if len_db < 200 else est_bits[len_db-16+target_curs_pos-2:-199-ffe_length+1+target_curs_pos-2]
        sign_data = np.where(est_bits > 0, 1, -1)
        #if len_db > 200:
        #    sign_data = data_buffer[len_db-16-3:-3]
        #plt.plot(sign_data)
        #plt.plot(data_buffer[len_db-2:])
        #plt.plot(codes)
        #plt.show()

        #all_cdr_est = np.multiply(sign_data[2:], codes[1:-1]) - np.multiply(sign_data[:-2], codes[1:-1])
        all_cdr_est = np.multiply(sign_data[2:], est_bits[1:-1]) - np.multiply(sign_data[:-2], est_bits[1:-1])
        
        #Calculate Average and Individual CDR Estimates
        avg_cdr_est = np.sum(all_cdr_est)
        idv_cdr_est = np.array([np.sum(all_cdr_est[pi_idx::4]) for pi_idx in range(max_num_pi)])

        #pi_corr     -= (idv_cdr_est - avg_cdr_est)*0.05e-12
        cdr_adjust  += avg_cdr_est*0.1e-12 * 0.21

        cdr_history += [cdr_adjust]
        pi_history  += [pi_corr.copy()]
        iter_codes  += list(codes)

        for pi_idx in range(max_num_pi):
            phase_interp[pi_idx] += 0#dynamic_offset.next_phase()
            idv_corr[pi_idx][cdr_adjust] = idv_corr[pi_idx][cdr_adjust] - (idv_cdr_est[pi_idx] - avg_cdr_est)*0.1e-12


        progress.update(cdr_task, advance=1)
        if (np.mod(ii, 97) == 0) and show_plot:
            ax.clear()
            for pi_idx in range(max_num_pi):
                time, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=32, t_delay=phase_interp[pi_idx](cdr_adjust + pi_corr[pi_idx]))
                ax.plot(time, pulse)
            plt.pause(0.00001)

pi_history     = np.array(pi_history)
t1, pulse1     = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay=shift_delay)

plt.ioff()
plt.stem(t1, pulse1)
for pi_idx in range(max_num_pi):
    t2, pulse2 = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay=phase_interp[pi_idx](cdr_adjust + pi_corr[pi_idx]))
    plt.plot(t2, pulse2)
plt.show()

plt.plot(np.mod(cdr_history,1/f_sig))
plt.show()

for pi_idx in range(max_num_pi):
    plt.plot(idv_corr[pi_idx].table)
plt.show()


cdr_slice = cdr_history[slice_point:]
cdr_mean = np.mean(cdr_slice)
zeroed_cdr = cdr_slice - cdr_mean
cdr_std    = np.sqrt(np.dot(zeroed_cdr.T, zeroed_cdr)/len(zeroed_cdr))

print(cdr_mean)
print(cdr_std)

plt.hist(cdr_slice - cdr_mean,bins=60)
plt.show()
