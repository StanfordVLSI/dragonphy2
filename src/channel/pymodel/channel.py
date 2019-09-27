import numpy as np

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
		self.cursor_pos   	  = cursor_pos
		self.impulse_response = self.channel_generator[channel_type](self, resp_depth=self.resp_depth, **kwargs)
		self.reset_cursor()
		self.real_time 		  = (np.array(range(self.length()))-self.cursor_pos)*1.0/sampl_rate

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

	def perfect_channel(self, **kwargs):
		return np.identity(self.resp_depth)[self.cursor_pos]

	def skineffect_channel(self, resp_depth=10, normal='area', **kwargs):
		try: 
			tau = kwargs['tau']
		except KeyError as e:
			print("Skin Effect Channel: {} not specified, defaulting to {}=2".format('tau','tau'))
			tau = 2

        # From: The Physics of Transmission Lines at High and Very High Frequencies
        # Continuous Model:     h(t) = sqrt(tau)/(2*t*sqrt(pi*t)) * e^(-tau/4t)
        # Discrete Model:       h(n) = sqrt(beta/pi) * e^(-beta/n)/n^(3/2)

		sampl_per = 1.0/self.sampl_rate

        # Let beta be tau/(4*T)
		beta = tau/(4*sampl_per)
		eps  = 1E-3

        # func_scale = np.sqrt(beta/np.pi)
		expon_val = np.repeat(np.exp(-beta), resp_depth-1)
		one_over_n = np.divide(np.ones((resp_depth-1,)), range(1,resp_depth))
		expon_arr = np.power(expon_val, one_over_n)
		n_to_3_o_2 = np.power(range(1,resp_depth), 3.0/2.0)
		unscaled_array = np.pad(np.divide(expon_arr,n_to_3_o_2),(self.cursor_pos,0),'constant', constant_values=(0,0))
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


	channel_generator = { 'perfect' : perfect_channel, 'exponent' : exponential_channel, 'skineffect' : skineffect_channel}
	normal_select     = { 'area' : normalize_area, 'energy' : normalize_energy, 'none': normalize_none}
