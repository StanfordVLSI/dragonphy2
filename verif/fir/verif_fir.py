from dragonphy import *
import numpy as np
import matplotlib.pyplot as plt

def write_file(parameters, codes, weights):
	f = open("adapt_params.txt", "w+")
	f.write('code_len\n' + str(parameters[0]) + '\n')
	f.write('num_taps\n' + str(parameters[1]) + '\n')
	f.write('mu\n' + str(parameters[2]) + '\n')
	f.write('codes\n' + ",".join([str(c) for c in codes]) + '\n')
	f.write('weights\n' + ",".join([str(w) for w in weights]) + '\n')

def plot_adapt_input(codes, chan_out, n, plt_mode='normal'):
	if plt_mode == 'stem':
		plt.stem(codes[:n], markerfmt='C0o', basefmt='C0-')
		plt.stem(chan_out[:n], markerfmt='C1o', basefmt='C1-')
	else:
		plt.plot(codes[:n], 'o-')
		plt.plot(chan_out[:n], 'o-')
	plt.show()

# Used for testing 
if __name__ == "__main__":

	# Number of iterations of Wiener Steepest Descent
	iterations  = 1000
	# Number of taps for FIR
	M = 10
	# mu: step size
	u = .1

	ideal_codes = np.random.randint(2, size=iterations)
	print(f'Ideal Code Sequence: {ideal_codes}')

	chan = Channel(channel_type='skineffect', sampl_rate=1)
	
	chan_out = np.convolve(chan.impulse_response, ideal_codes, mode='same')
	print(f'Channel output: {chan_out}')

	plot_adapt_input(ideal_codes, chan_out, 100)
	
	adapt = Wiener(step_size = u, num_taps = M)
	print(f'------------------------------------------')
	for i in range(iterations):
		adapt.find_weights_error(ideal_codes[i], chan_out[i])	
		
	adapt.plot_total_error()

	print(f'------------------------------------------')
	print(f'Filter input: {adapt.filter_in}')
	print(f'Weights: {adapt.weights}')
	write_file([iterations, M, u], ideal_codes, adapt.weights)	
