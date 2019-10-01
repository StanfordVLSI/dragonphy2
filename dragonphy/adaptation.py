import numpy as np

class Wiener():
	def __init__(self, step_size=2, num_taps=5):
		self.step_size 	= step_size
		self.num_taps	= num_taps
		self.filter_in 	= np.zeros(num_taps)
		self.weights 	= np.zeros(num_taps)

	def update_initial_weights(new_weights):
		self.weights = new_weights

	def find_weights(ideal_in, curr_filter_in):
		# update filter inputs
		self.filter_in.append(curr_filter_in)
		self.filter_in = self.filter_in[0:self.num_taps]	

		# R = E[u(n)u^H(n)]
		R = np.outer(self.filter_in, np.conj(self.filter_in))
		
		# p = E[u(n)d*(n)] 
		p = np.conj(ideal_in)*self.filter_in

		next_weights = self.weights - self.step_size*(p - np.multiply(R, self.weights)
		self.weights = next_weights

		return next_weights

# Used for testing 
if __name__ == "__main__":
	w = Wiener()
		
