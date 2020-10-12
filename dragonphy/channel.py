from math import floor

import numpy as np

from scipy.interpolate import interp1d
from scipy.special import erfc

import matplotlib.pyplot as plt

from .sparams import s4p_to_step

def calculate_channel_loss(channel):
    one_zero_pattern = np.tile([-1,1], (10*channel.resp_depth))
    result = np.ptp(channel.compute_output(one_zero_pattern)[2*channel.resp_depth:-2*channel.resp_depth])
    return np.log10(result)*20

class Filter:
    def __init__(self, t_vec, v_vec):
        # save time / voltage points of step response
        self.t_vec = t_vec
        self.v_vec = v_vec
        self.interp = interp1d(t_vec, v_vec, bounds_error=False,
                               fill_value=(v_vec[0], v_vec[-1]))

    def get_step_resp(self, f_sig=1e9, resp_depth=50, t_delay=0):
        # truncate the response depth if needed
        if self.t_vec[-1] < (resp_depth-1)/f_sig:
            resp_depth = int(floor(self.t_vec[-1]*f_sig)) + 1
        # compute times at which step reponse should be evaluated
        t_step = np.linspace(0, (resp_depth-1)/f_sig, resp_depth) - t_delay
        # compute interpolated step response
        v_step = self.interp(t_step)

        return t_step, v_step

    def get_pulse_resp(self, f_sig=1e9, resp_depth=50, t_delay=0):
        # compute interpolated step response
        t_step, v_step = self.get_step_resp(f_sig=f_sig, resp_depth=resp_depth+1, t_delay=t_delay)

        # take first difference to get pulse response
        v_pulse = np.diff(v_step)

        # return result (remembering the throw away the extra time point at the end)
        return t_step[:-1], v_pulse

    def compute_output(self, symbols, f_sig=1e9, resp_depth=50):
        # get the pulse response
        _, v_pulse = self.get_pulse_resp(f_sig=f_sig, resp_depth=resp_depth)

        # convolve pulse response with symbols
        # TODO: should samples at the beginning and end be dropped?
        return np.convolve(symbols, v_pulse, mode='full')

    def to_file(self, file):
        arr = np.column_stack((self.t_vec, self.v_vec))
        np.save(file, arr)

    @classmethod
    def from_file(cls, file):
        arr = np.load(file)
        return cls(t_vec=arr[:, 0], v_vec=arr[:, 1])


class Channel(Filter):
    def __init__(self, channel_type='s4p', sampl_rate=1e9, resp_depth=50, **kwargs):
        # determine vector of time points

        if channel_type == 's4p':
            s4p = str(kwargs['s4p'])
            dt = 1/sampl_rate
            T = (resp_depth-1)*dt
            zs = kwargs.get('zs', 50)
            zl = kwargs.get('zl', 50)
            t_vec, v_vec = s4p_to_step(s4p, dt=dt, T=T, zs=zs, zl=zl)
        else:
            t_vec = np.linspace(0, (resp_depth - 1) / sampl_rate, resp_depth)

            if channel_type == 'step':
                self.chan_func = step_channel
            elif channel_type == 'exponent':
                self.chan_func = exponential_channel
            elif channel_type == 'arctan':
                self.chan_func = arctan_channel
            elif channel_type == 'skineffect':
                self.chan_func = skineffect_channel
            elif channel_type == 'boesch':
                self.chan_func = boesch_channel
            else:
                raise Exception(f'Unknown channel type: {channel_type}')

            v_vec = self.chan_func(t_vec=t_vec, **kwargs)

        # call the super constructor
        super().__init__(t_vec=t_vec, v_vec=v_vec)

    def compute_output(self, symbols, f_sig=1e9, resp_depth=50):
        return super().compute_output(symbols, f_sig=f_sig, resp_depth=resp_depth)


class DelayChannel(Channel):
    def __init__(self, channel_type='step', sampl_rate=1e9, resp_depth=50, t_delay=2e-9, **kwargs):
        self.sampl_rate = sampl_rate
        self.resp_depth = resp_depth
        self.kwargs     = kwargs
        super().__init__(channel_type=channel_type, sampl_rate=sampl_rate, resp_depth=resp_depth, t_delay=t_delay, **kwargs)

    def adjust_delay(self, t_delay):
        t_vec = np.linspace(0, (self.resp_depth-1)/self.sampl_rate, self.resp_depth)
        v_vec = self.chan_func(t_vec=self.t_vec, t_delay=t_delay, **self.kwargs)
        self.interp = interp1d(t_vec, v_vec, bounds_error=False,
                               fill_value=(v_vec[0], v_vec[-1]))

        self.t_vec = t_vec
        self.v_vec = v_vec

    def get_step_resp(self, f_sig=1e9, resp_depth=None, t_delay=0):
        resp_depth = self.resp_depth if resp_depth is None else resp_depth
        return super().get_step_resp(f_sig=f_sig, resp_depth=resp_depth, t_delay=t_delay)

    def get_pulse_resp(self, f_sig=1e9, resp_depth=None, t_delay=0):
        resp_depth = self.resp_depth if resp_depth is None else resp_depth
        return super().get_pulse_resp(f_sig=f_sig, resp_depth=resp_depth, t_delay=t_delay)

    def compute_output(self, symbols, f_sig=1e9, resp_depth=None):
        resp_depth = self.resp_depth if resp_depth is None else resp_depth 
        return super().compute_output(symbols, f_sig=f_sig, resp_depth=resp_depth)


def step_channel(t_vec, t_delay=2e-9):
    return np.heaviside(t_vec - t_delay, 0)

def exponential_channel(t_vec, t_delay=2e-9, tau=2.0e-9):
    return (1-np.exp(-(t_vec-t_delay)/tau))*np.heaviside(t_vec-t_delay, 0)

# Adapted from: The Physics of Transmission Lines at High and Very High Frequencies
# Impulse response is h(t) = 1/(pi*k) * 1/(1+(t/k)^2)
# Therefore the step response is proportional to arctan(t/k)
def arctan_channel(t_vec, t_delay=2e-9, tau=2.0e-9):
    return (1.0/np.pi)*(np.arctan((t_vec-t_delay)/tau) + (np.pi/2.0))

# Adapted from: High-speed Signal Propagation: Advanced Black Magic
# Step Response is s(t) = u(t) * erfc(1/2 * sqrt(tau/ t))
# Need to low bound the time value to avoid issues with imaginary erfc and nan
def skineffect_channel(t_vec, t_delay=2e-9, tau=2.0e-9):
    delayed_t_vec = t_vec - t_delay
    bound_delayed_t_vec = np.clip(delayed_t_vec, tau/100, None)

    return erfc(1/2*np.sqrt(np.divide(tau,(bound_delayed_t_vec))))*np.heaviside(bound_delayed_t_vec, 0)

#Adapted from: Ryan Boesch's Thesis
#Step Response is s(t) = (2*arctan(t/k) + log(k^2 + t^2))/(2*pi)
def boesch_channel(t_vec, t_delay=2e-9, tau=2.0e-9):
    delayed_t_vec = t_vec-t_delay
    bd_t_vec = np.clip(delayed_t_vec, tau/100, None)

    return 2*np.pi + (np.log(tau**2 + bd_t_vec**2) + 2.0*np.arctan(bd_t_vec/tau))/(2*np.pi)

# # From: Ryan Boesch Thesis
# # Continuous Model: h(t) = 1/(pi*k) * (1+t/k)/(1+(t/k)^2)
# def dielectric1_channel(self, t_vec, t_delay=2e-9, tau=2.5e-9):
#     try:
#         tau = kwargs['tau']
#     except KeyError:
#         print('Dielectric Effect Channel: tau not specified, defaulting to tau=2')
#         tau = 2
#
#     sample_per = 1.0 / self.sampl_rate
#
#     nT_over_tau = np.divide(range(-int(1 / tau) - 1, resp_depth - int(1 / tau) - 1),
#                             np.repeat(sample_per / tau, resp_depth))
#
#     unscaled_array = np.pad(np.clip((1.0 + nT_over_tau) / (1.0 + nT_over_tau ** 2), 0, None), (self.cursor_pos, 0),
#                             'constant', constant_values=(0, 0))[0:resp_depth]
#     return self.normal_select[normal](self, unscaled_array)

# # Combined skineffect and dielectric effect channel model
# def combined_channel(self, resp_depth=10, normal='area', **kwargs):
#     try:
#         tau_skin = kwargs['tau1']
#     except KeyError:
#         tau_skin = 2
#         print(f'Skin Effect Channel: tau1 not specified, defaulting to tau1={tau_skin}')
#     try:
#         tau_diel = kwargs['tau2']
#     except KeyError:
#         tau_diel = 2
#         print(f'Dielectric Channel: tau2 not specified, defaulting to tau2={tau_diel}')
#
#     diel_resp = self.dielectric1_channel(resp_depth / 2, normal, tau_diel)
#     skin_resp = self.skineffect_channel(resp_depth / 2, normal, tau_skin)
#
#     unscaled_array = np.convolve(diel_resp, skin_resp)
#     return self.normal_select[normal](self, unscaled_array)

# Used for testing 
if __name__ == "__main__":
    for channel_type in ['step', 'exponent', 'arctan']:
        chan = Channel(channel_type=channel_type)
        t_pulse, v_pulse = chan.get_pulse_resp()
        print(v_pulse)
        plt.plot(t_pulse, v_pulse)
        plt.show()
