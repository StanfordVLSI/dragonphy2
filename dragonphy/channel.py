import numpy as np
import matplotlib.pyplot as plt

from scipy.interpolate import interp1d
from math import floor

class Filter:
    def __init__(self, t_vec, v_vec):
        # save time / voltage points of step response
        self.t_vec = t_vec
        self.v_vec = v_vec

    def get_step_resp(self, f_sig=1e9, resp_depth=50):
        # truncate the response depth if needed
        if self.t_vec[-1] < (resp_depth-1)/f_sig:
            resp_depth = int(floor(self.t_vec[-1]*f_sig)) + 1

        # compute times at which step reponse should be evaluated
        t_step = np.linspace(0, (resp_depth-1)/f_sig, resp_depth)

        # compute interpolated step response
        v_step = interp1d(self.t_vec, self.v_vec, bounds_error=False,
                          fill_value=(self.v_vec[0], self.v_vec[-1]))(t_step)

        return t_step, v_step

    def get_pulse_resp(self, f_sig=1e9, resp_depth=50):
        # compute interpolated step response
        t_step, v_step = self.get_step_resp(f_sig=f_sig, resp_depth=resp_depth+1)

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

class Channel(Filter):
    def __init__(self, channel_type='perfect', sampl_rate=1e9, resp_depth=50, **kwargs):
        # determine vector of time points
        t_vec = np.linspace(0, (resp_depth-1)/sampl_rate, resp_depth)

        if channel_type == 'step':
            v_vec = step_channel(t_vec=t_vec, **kwargs)
        elif channel_type == 'exponent':
            v_vec = exponential_channel(t_vec=t_vec, **kwargs)
        elif channel_type == 'arctan':
            v_vec = arctan_channel(t_vec=t_vec, **kwargs)
        else:
            raise Exception(f'Unknown channel type: {channel_type}')

        # call the super constructor
        super().__init__(t_vec=t_vec, v_vec=v_vec)

def step_channel(t_vec, t_delay=2e-9):
    return np.heaviside(t_vec - t_delay, 0)

def exponential_channel(t_vec, t_delay=2e-9, tau=2.0e-9):
    return (1-np.exp(-(t_vec-t_delay)/tau))*np.heaviside(t_vec-t_delay, 0)

# Adapted from: The Physics of Transmission Lines at High and Very High Frequencies
# Impulse response is h(t) = 1/(pi*k) * 1/(1+(t/k)^2)
# Therefore the step response is proportional to arctan(t/k)
def arctan_channel(t_vec, t_delay=2e-9, tau=2.0e-9):
    return (2.0/np.pi)*np.arctan((t_vec-t_delay)/tau)*np.heaviside(t_vec-t_delay, 0)

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


# # From: The Physics of Transmission Lines at High and Very High Frequencies
# # Continuous Model:     h(t) = sqrt(tau)/(2*t*sqrt(pi*t)) * e^(-tau/4t)
# # Discrete Model:       h(n) = sqrt(beta/pi) * e^(-beta/n)/n^(3/2)
# def skineffect_channel(self, resp_depth=10, normal='area', **kwargs):
#     try:
#         tau = kwargs['tau']
#     except KeyError:
#         print("Skin Effect Channel: {} not specified, defaulting to {}=2".format('tau', 'tau'))
#         tau = 2
#
#     sampl_per = 1.0 / self.sampl_rate
#     # Let beta be tau/(4*T)
#     beta = tau / (4 * sampl_per)
#
#     # func_scale = np.sqrt(beta/np.pi)
#     expon_val = np.repeat(np.exp(-beta), resp_depth - 1)
#     one_over_n = np.divide(np.ones((resp_depth - 1,)), range(1, resp_depth))
#     expon_arr = np.power(expon_val, one_over_n)
#     n_to_3_o_2 = np.power(range(1, resp_depth), 3.0 / 2.0)
#
#     # Shift is equivalent to convolving with a delayed impulse response. Delay by 1 more for n=0 (cannot divide by 0).
#     unscaled_array = np.pad(np.divide(expon_arr, n_to_3_o_2), (self.cursor_pos, 0), 'constant',
#                             constant_values=(0, 0))[0:resp_depth]
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
