import numpy as np
import matplotlib.pyplot as plt

class Wiener():
	def __init__(self, step_size=2, num_taps=5, debug=False):
		self.step_size 		= step_size
		self.num_taps		= num_taps
		self.filter_in 		= np.zeros(num_taps)
		self.weights 		= np.zeros(num_taps)
		self.error 			= np.inf
		self.total_error 	= []
		self.debug 			= debug

	def update_initial_weights(self, new_weights):
		self.weights = new_weights

	def find_weights(self, ideal_in, curr_filter_in):
		# update filter inputs
		append_in = np.append(self.filter_in, curr_filter_in)
		self.filter_in = append_in[1:self.num_taps + 1]	

		if self.debug:
			print(f'Filter input: {self.filter_in}')

		# R = E[u(n)u^H(n)]
		R = np.outer(self.filter_in, np.conj(self.filter_in))
		if self.debug:
			print(f'R: {R}')	
		
		# p = E[u(n)d*(n)] 
		p = np.conj(ideal_in)*self.filter_in
		if self.debug:
			print(f'p: {p}')

		next_weights = self.weights +  self.step_size*(p - np.multiply(R, self.weights))
		self.weights = next_weights

		return next_weights

	def find_weights_error(self, ideal_in, curr_filter_in):
		# update filter inputs
		append_in = np.append(self.filter_in, curr_filter_in)
		self.filter_in = append_in[1:self.num_taps + 1]	
		if self.debug:
			print(f'Input: {self.filter_in}')	

		self.error = ideal_in - np.dot(self.weights, self.filter_in)
		self.total_error.append(self.error)
		if self.debug:
			print(f'Error: {self.error}')
			print(f'W[n]: {self.weights}')

		next_weights = self.weights + self.step_size*self.error*(self.filter_in)
		self.weights = next_weights
		if self.debug:
			print(f'W[n+1]: {next_weights}')

		return next_weights
			
	def plot_total_error(self):
		plt.plot(self.total_error)
		plt.show()

	def clear_total_error(self):
		self.total_error = []

# Used for testing 
if __name__ == "__main__":
	w = Wiener()
		
