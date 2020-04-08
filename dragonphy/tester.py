import random
import magma
import fault

class DragonTester:
	def __init__(self, top_module, ext_test_bench=True, disp_type='realtime',
				 simulator='ncsim', overload_seed=False, seed=None, clean=True,
				 flags=None, target='system-verilog', **kwargs):
		# save kwargs
		kwargs['top_module'] = top_module
		kwargs['ext_test_bench'] = ext_test_bench
		kwargs['disp_type'] = disp_type
		kwargs['simulator'] = simulator
		kwargs['target'] = target
		self.kwargs = kwargs

		# save flags argument -- this is treated as a special case because the
		# flags that should be passed are simulator dependent.
		flags = flags if flags is not None else []
		self.flags = flags

		# save custom arguments
		self.clean = clean
		self.seed = seed

		# generate a random seed if needed
		if overload_seed and (self.seed is None):
			self.generate_new_seed()

	def generate_new_seed(self):
		self.seed = random.getrandbits(32)

	def run(self):
		# declare magma circuit to represent the testbench
		class DUT(magma.Circuit):
			name = self.kwargs['top_module']
			io = magma.IO()

		# instantiate the tester
		tester = fault.Tester(DUT)

		# update flags for ncsim
		flags = self.flags
		if self.kwargs['simulator'] == 'ncsim':
			if self.clean:
				flags += ['-clean']
			if self.seed is not None:
				flags += ['-seed', self.seed]
			# need "-sv" flag because not all files
			# in DaVE have a ".sv" extension
			flags += ['-sv']

		# run the simulation
		tester.compile_and_run(**self.kwargs, flags=flags)