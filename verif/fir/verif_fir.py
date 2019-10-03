from dragonphy import *
from pathlib import Path

import subprocess
import numpy as np
import matplotlib.pyplot as plt
import yaml

def write_files(parameters, codes, weights, path="."):
	with open(path + '/' + "adapt_coeff.txt", "w+") as f:
		f.write('num_taps: ' + str(parameters[1]) + '\n')
		f.write('weights:\n' + "\n".join([str(w) for w in weights]) + '\n')
	with open(path + '/' +  "adapt_codes.txt", "w+") as f:
		f.write('code_len: ' + str(parameters[0]) + '\n')
		f.write('codes:\n' + "\n".join([str(c) for c in codes]) + '\n')

	#f.write('mu: ' + str(parameters[2]) + '\n')

	#This is the most compatible way of writing for verilog - given its a fairly low level language

def deconvolve(weights, chan):
	plt.plot(chan(weights))
	plt.show()

def plot_adapt_input(codes, chan_out, n, plt_mode='normal'):
	if plt_mode == 'stem':
		plt.stem(codes[:n], markerfmt='C0o', basefmt='C0-')
		plt.stem(chan_out[:n], markerfmt='C1o', basefmt='C1-')
	else:
		plt.plot(codes[:n], 'o-')
		plt.plot(chan_out[:n], 'o-')
	plt.show()

def perform_wiener(ideal_input, chan, chan_out, M = 11, u = 0.1, build_dir='.'):

	adapt = Wiener(step_size = u, num_taps = M, cursor_pos=pos)
	for i in range(iterations-2):
		adapt.find_weights_pulse(ideal_codes[i-pos], chan_out[i])	
	
#	pulse_weights = adapt.weights	
#	for i in range(iterations-2):
#		adapt.find_weights_error(ideal_codes[i-pos], chan_out[i])	
#	
#	pulse2_weights = adapt.find_weights_pulse2()

#	print(pulse_weights)
#	print(adapt.weights)
	
	#plt.plot(adapt.weights)
	#plt.show()

	#print(f'Filter input: {adapt.filter_in}')
	print(f'Adapted Weights: {adapt.weights}')
	write_files([iterations, M, u], chan_out, adapt.weights, 'verif/fir/build_fir')	
	
	#deconvolve(adapt.weights, chan)

	#plt.plot(chan(np.reshape(pulse_weights, len(pulse_weights))))
	#plt.plot(chan(pulse2_weights[-1]))
	#plt.show()


# Used for testing 
if __name__ == "__main__":

	build_dir = 'verif/fir/build_fir'
	pack_dir  = 'verif/fir/pack'

	system_config = Configuration('system')
	test_config   = system_config['test']

	#Associate the correct build directory to the python collateral
	test_config['parameters']['ideal_code_filename'] = build_dir + '/' + test_config['parameters']['ideal_code_filename'] 
	test_config['parameters']['adapt_code_filename'] = build_dir + '/' + test_config['parameters']['adapt_code_filename']
	test_config['parameters']['adapt_coef_filename'] = build_dir + '/' + test_config['parameters']['adapt_coef_filename'] 

	# Get config parameters from system.yml file
	ffe_config = system_config['generic']['ffe']

	# Number of iterations of Wiener Steepest Descent
	iterations  = 200000
	system_config['test']['parameters']['num_of_codes'] = iterations

	# Cursor position with the most energy 
	pos = 2

	ideal_codes = np.random.randint(2, size=iterations)*2 - 1
	
	chan = Channel(channel_type='skineffect', normal='area', tau=2, sampl_rate=5, cursor_pos=pos, resp_depth=125)
	chan_out = chan(ideal_codes)

	#plot_adapt_input(ideal_codes, chan_out, 100)

	if ffe_config["adaptation"]["type"] == "wiener":
		perform_wiener(ideal_codes, chan, chan_out, ffe_config['parameters']["length"], \
			ffe_config["adaptation"]["args"]["mu"], build_dir=build_dir)
	else: 
		print(f'Do Nothing')
	
	#Create Package Generator Object 
	generic_packager   = Packager(package_name='constant', parameter_dict=system_config['generic']['parameters'], path=pack_dir)
	testbench_packager = Packager(package_name='test',     parameter_dict=test_config['parameters'], path=pack_dir)
	ffe_packager	   = Packager(package_name='ffe',      parameter_dict=ffe_config['parameters'], path=pack_dir)

	#Create package file from parameters specified in system.yaml under generic
	generic_packager.create_package()
	testbench_packager.create_package()
	ffe_packager.create_package()

	#Create TestBench Object
	tester   = Tester(
						testbench = 'verif/fir/test.sv',
						libraries = ['src/fir/syn/ffe.sv'],
						packages  = [generic_packager.path, testbench_packager.path, ffe_packager.path],
						flags 	  = ['-sv'],
						build_dir = build_dir,
						overload_seed=True
					)

	#Execute TestBench Object
	tester.run()
	
