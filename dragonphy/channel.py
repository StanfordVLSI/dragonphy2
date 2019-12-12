import numpy as np
import matplotlib.pyplot as plt 

class Filter:
    def __init__(self, sampl_rate=1):
        self.sampl_rate = sampl_rate

    def __getitem__(self, ind):
        return self.impulse_response[ind]

    def __call__(self, symbols):
        #Needs further analysis - do I need to drop leading and lagging samples?
        return np.convolve(symbols, self.impulse_response, mode='full')

    def length(self):
        return len(self.impulse_response)

class Channel(Filter):
    def __init__(self, channel_type='perfect', resp_depth=10, cursor_pos=2, sampl_rate=1, **kwargs):
        super().__init__(sampl_rate)
        self.resp_depth       = resp_depth
        self.cursor_pos       = cursor_pos
        self.impulse_response = self.channel_generator[channel_type](self, resp_depth=self.resp_depth, **kwargs)
        self.pulse_response = []
        self.reset_cursor()
        self.real_time        = (np.array(range(self.length()))-self.cursor_pos)*1.0/sampl_rate

    def __call__(self, symbols):
        return super().__call__(symbols)*1.0/self.sampl_rate
        
    def normalize_area(self, unnormalized_array):
        scale = 1/np.sum(unnormalized_array)*self.sampl_rate
        return scale*unnormalized_array

    def normalize_energy(self, unnormalized_array):
        scale = 1/np.sqrt(np.sum(np.square(unnormalized_array))*1.0/self.sampl_rate)
        return scale*unnormalized_array

    def normalize_none(self, unnormalized_array):
        return unnormalized_array

    def reset_cursor(self):
        self.cursor_pos = list(self.impulse_response).index(max(self.impulse_response))

    def calculate_time(self):
        return (np.array(range(self.length()))-self.cursor_pos)*1.0/self.sampl_rate

    def perfect_channel(self, resp_depth=10, **kwargs):
        return np.identity(resp_depth)[self.cursor_pos]

    # From: The Physics of Transmission Lines at High and Very High Frequencies
    # Continuous Model: h(t) = 1/(pi*k) * 1/(1+(t/k)^2)
    def dielectric2_channel(self, resp_depth=10, normal='area', **kwargs):
        try:
            tau = kwargs['tau']
        except KeyError as e:
            print("Dielectric2 Effect Channel: {} not specified, defaulting to {}=2".format('tau','tau'))
            tau = 2
        
        sample_per = 1.0/self.sampl_rate
        
        self.cursor_pos = int(resp_depth/2)

        func_scale = 1.0/(np.pi*tau)
        nT_over_tau = np.divide(range(-self.cursor_pos, resp_depth-self.cursor_pos), np.repeat(sample_per/tau, resp_depth))
        
        unscaled_array = 1.0/(1.0 + nT_over_tau**2)
        return self.normal_select[normal](self, unscaled_array)

    # From: Ryan Boesch Thesis
    # Continuous Channel Model: h(t) = 1/(pi*k) * (1+t/k)/(1+(t/k)^2)
    # Continuous Pulse Response: p(t) = rect(t/T) * h(t)
    def dielectric1_pulse_channel(self, resp_depth=10, normal='area', **kwargs):
        try:
            tau = kwargs['tau']
        except KeyError as e:
            print("Dielectric1 Pulse Response Effect Channel: {} not specified, defaulting to {}=2".format('tau','tau'))
            tau = 2
        
        sample_per = 1.0/self.sampl_rate
       
        func_scale = 1.0/(np.pi*tau)

        T = sample_per
        delta = T/100.
        t = np.arange(-1./delta, resp_depth/delta, delta)
        rect = np.where(np.abs(t) < T/2, 1., 0.)

        t = np.arange(-1./delta, resp_depth/delta, delta)
        t_over_k = np.divide(t, tau)
        h = func_scale * np.divide((1. + t_over_k), (1. + t_over_k ** 2))
        h = np.clip(h, 0, None)

        plt.plot(rect)
        plt.plot(h)
        plt.show()

        p = np.convolve(rect, h)


        argmax_p = np.argmax(p)
        print(argmax_p)
        
        start_n = argmax_p % int(T/delta)
        p_n = p[start_n::int(T/delta)] 

        print(f'Length = {len(p_n)}')

        start_nonzero = next((i for i, x in enumerate(p_n) if x), None) - 1

        plt.plot(p)
        plt.stem(start_n + np.arange(0, int(T/delta) * len(p_n), int(T/delta)), p_n)
        plt.show()
        p_n_crop = p_n[start_nonzero:start_nonzero + resp_depth]

        return self.normal_select[normal](self, p_n_crop)
    # From: Ryan Boesch Thesis
    # Continuous Channel Model: h(t) = 1/(pi*k) * (1+t/k)/(1+(t/k)^2)
    def dielectric1_channel(self, resp_depth=10, normal='area', **kwargs):
        try:
            tau = kwargs['tau']
        except KeyError as e:
            print("Dielectric1 Effect Channel: {} not specified, defaulting to {}=2".format('tau','tau'))
            tau = 2
        
        sample_per = 1.0/self.sampl_rate
       
        func_scale = 1.0/(np.pi*tau)

        # Find argmax of continuous time function
        sample_points_cont = np.linspace(-1./tau, -1./tau + sample_per * resp_depth, resp_depth * 10000)
        nT_over_tau_cont = np.multiply(sample_points_cont, np.repeat(sample_per/tau, resp_depth * 10000))
        unscaled_array_cont = np.clip((1.0 + nT_over_tau_cont)/(1.0 + nT_over_tau_cont**2), 0, None)
    
        argmax_val = np.argmax(unscaled_array_cont)
        print(argmax_val)
        
        # Now calculate discrete time signal with argmax
        argmax_mod = argmax_val % sample_per

        sample_points = np.linspace(-1./tau + argmax_mod, -1./tau + argmax_mod + sample_per * resp_depth, resp_depth)
        nT_over_tau = np.multiply(sample_points, np.repeat(sample_per/tau, resp_depth))
        
        unscaled_array = np.pad(np.clip((1.0 + nT_over_tau)/(1.0 + nT_over_tau**2), 0, None), (self.cursor_pos, 0), 'constant', constant_values=(0,0))[0:resp_depth]
        return self.normal_select[normal](self, unscaled_array)

    # From: The Physics of Transmission Lines at High and Very High Frequencies
    # Continuous Model:     h(t) = sqrt(tau)/(2*t*sqrt(pi*t)) * e^(-tau/4t)
    # Discrete Model:       h(n) = sqrt(beta/pi) * e^(-beta/n)/n^(3/2)
    def skineffect_channel(self, resp_depth=10, normal='area', **kwargs):
        try: 
            tau = kwargs['tau']
        except KeyError as e:
            print("Skin Effect Channel: {} not specified, defaulting to {}=2".format('tau','tau'))
            tau = 2

        sampl_per = 1.0/self.sampl_rate
        # Let beta be tau/(4*T)
        beta = tau/(4*sampl_per)

        # func_scale = np.sqrt(beta/np.pi)
        expon_val = np.repeat(np.exp(-beta), resp_depth-1)
        one_over_n = np.divide(np.ones((resp_depth-1,)), range(1,resp_depth))
        expon_arr = np.power(expon_val, one_over_n)
        n_to_3_o_2 = np.power(range(1,resp_depth), 3.0/2.0)

        # Shift is equivalent to convolving with a delayed impulse response. Delay by 1 more for n=0 (cannot divide by 0).
        unscaled_array = np.pad(np.divide(expon_arr,n_to_3_o_2),(self.cursor_pos,0),'constant', constant_values=(0,0))[0:resp_depth]
        return self.normal_select[normal](self, unscaled_array)

    # Combined skineffect and dielectric effect channel model
    def combined_channel(self, resp_depth=10, normal='area', **kwargs):
        try:
            tau_skin = kwargs['tau1']
            tau_diel = kwargs['tau2']
        except KeyError as e:
            print("Skin Effect Channel: {} not specified, defaulting to {}=2".format('tau1', 'tau1'))
            print("Dielectric Channel: {} not specified, defaulting to {}=2".format('tau2', 'tau2'))
            tau_skin = 2
            tau_diel = 2

        diel_resp = self.dielectric1_channel(resp_depth/2, normal, tau_diel)
        skin_resp = self.skineffect_channel(resp_depth/2, normal, tau_skin)

        unscaled_array = np.convolve(diel_resp, skin_resp)
        return self.normal_select[normal](self, unscaled_array)


    def exponential_channel(self, resp_depth=10, normal='area', **kwargs):
        try: 
            tau = kwargs['tau']
        except KeyError:
            print("Exponential Channel: {} not specified, defaulting to {}=2".format('tau','tau'))
            tau = 2
        expon_val = np.exp(-1.0/(tau*self.sampl_rate))
        expon_val_sqrd = np.exp(-2.0/(tau*self.sampl_rate))
        expon_normal_select = { 'area' : self.sampl_rate*(1-expon_val), 'energy' :  np.sqrt(self.sampl_rate*(1-expon_val_sqrd))}

        return expon_normal_select[normal]*np.pad(np.power(np.repeat(expon_val, resp_depth-self.cursor_pos), range(resp_depth-self.cursor_pos)),(self.cursor_pos,0),'constant', constant_values=(0,0))

    def modify_channel(self, channel_type, normal='area', resp_depth_ext=10, **kwargs):
        modifier_response = self.channel_generator[channel_type](self, resp_depth=resp_depth_ext, normal=normal, **kwargs)
        self.resp_depth=self.resp_depth+resp_depth_ext
        self.impulse_response = self.normal_select[normal](self, np.convolve(self.impulse_response, modifier_response, mode='full')*1.0/self.sampl_rate)
        self.reset_cursor()
        self.real_time        = self.calculate_time()

    def calculate_channel_area(self):
        return np.sum(self.impulse_response)*1.0/self.sampl_rate

    def calculate_channel_energy(self):
        return np.sum(np.square(self.impulse_response))*1.0/self.sampl_rate

    def calculate_settled_step_response(self):
        return np.sum(self.impulse_response)*1.0/self.sampl_rate


    channel_generator = { 'perfect' : perfect_channel, 'exponent' : exponential_channel, 'skineffect' : skineffect_channel, 'dielectric2' : dielectric2_channel, \
                         'dielectric1' : dielectric1_channel, 'combined' : combined_channel, 'dielectric1_pulse' : dielectric1_pulse_channel}
    normal_select     = { 'area' : normalize_area, 'energy' : normalize_energy, 'none': normalize_none}

# Used for testing 
if __name__ == "__main__":
    c1 = Channel(channel_type='skineffect', sampl_rate=5, resp_depth=10)
    c2 = Channel(channel_type='dielectric1', tau=0.87, sampl_rate=1, resp_depth=125)
    c3 = Channel(channel_type='dielectric2', sampl_rate=5, resp_depth=125)
    c4 = Channel(channel_type='dielectric1_pulse', tau=0.87, sampl_rate=1., resp_depth=100)

    plt.plot(c1.impulse_response)
    plt.show()

    plt.stem(c2.impulse_response)
    plt.show()

    plt.stem(c4.impulse_response)
    plt.show()

    plt.plot(c3.impulse_response)
    plt.show()
