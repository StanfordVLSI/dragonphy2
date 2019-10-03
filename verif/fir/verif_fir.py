from dragonphy import *
from pathlib import Path

import subprocess
import numpy as np
import matplotlib.pyplot as plt
import yaml

def test_ffe():
    # testbench location
    tb = 'verif/fir/test.sv'

    # library locations
    libs = []
    libs.append('src/fir/syn/ffe.sv')

    # package locations
    packs = []
    packs.append('verif/fir/pack/constant_pack.sv')

    # resolve paths
    tb = Path(tb).resolve()
    packs = [Path(pack).resolve() for pack in packs]
    libs = [Path(lib).resolve() for lib in libs]


    # construct the command
    args = []
    args += ['xrun']
    args += [f'{tb}']
    for pack in packs:
    	args += [f'{pack}']
    for lib in libs:
        args += ['-v', f'{lib}']

    # set up build dir     
    cwd = Path('verif/fir/build_fir')
    cwd.mkdir(exist_ok=True)

    # run the simulation
    result = subprocess.run(args, cwd=cwd)
    assert result.returncode == 0

def get_configs():
	f = open("config/system.yml", "r")
	system_info = yaml.load(f)
	return system_info["generic"]["ffe"]
 
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

def perform_wiener(ideal_input, chan, chan_out, M = 11, u = 0.1):

	adapt = Wiener(step_size = u, num_taps = M, cursor_pos=pos)
	for i in range(iterations-2):
		adapt.find_weights_pulse(ideal_codes[i-pos], chan_out[i])	
	
	pulse_weights = adapt.weights	
	for i in range(iterations-2):
		adapt.find_weights_error(ideal_codes[i-pos], chan_out[i])	
	
	pulse2_weights = adapt.find_weights_pulse2()

	print(pulse_weights)
	print(adapt.weights)
	print(pulse2_weights[-1])
	
	#plt.plot(adapt.weights)
	#plt.show()

	print(f'Filter input: {adapt.filter_in}')
	print(f'Weights: {adapt.weights}')
	write_files([iterations, M, u], chan_out, adapt.weights, 'verif/fir')	
	
	#deconvolve(adapt.weights, chan)

	#plt.plot(chan(np.reshape(pulse_weights, len(pulse_weights))))
	#plt.plot(chan(pulse2_weights[-1]))
	#plt.show()


# Used for testing 
if __name__ == "__main__":
	# Get config parameters from system.yml file
	ffe_configs = get_configs() 

	# Number of iterations of Wiener Steepest Descent
	iterations  = 200000
	# Cursor position with the most energy 
	pos = 2

	ideal_codes = np.random.randint(2, size=iterations)*2 - 1
	print(f'Ideal Code Sequence: {ideal_codes}')

	chan = Channel(channel_type='skineffect', normal='area', tau=2, sampl_rate=5, cursor_pos=pos, resp_depth=125)
	
	chan_out = chan(ideal_codes)
	print(f'Channel output: {chan_out}')

	#plot_adapt_input(ideal_codes, chan_out, 100)

	print(ffe_configs)

	if ffe_configs["adaptation"]["type"] == "wiener":
		perform_wiener(ideal_codes, chan, chan_out, ffe_configs["length"], \
			ffe_configs["adaptation"]["args"]["mu"])
	else: 
		print(f'Do Nothing')
	
	Packager(parameter_dict=Configuration('system')['generic']['parameters'], path='verif/fir/pack').create_package()
	test_ffe()
	
