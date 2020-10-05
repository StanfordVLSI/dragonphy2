import random
import magma
import fault

from dragonphy.files import get_mlingua_dir, get_dir

class DragonTester:
	def __init__(self, top_module='test', ext_test_bench=True, disp_type='realtime',
				 simulator='ncsim', overload_seed=False, seed=None, clean=True,
				 flags=None, target='system-verilog', dump_waveforms=False,
				 timescale='1fs/1fs', unbuffered=True, inc_dirs=None,
				 defines=None, num_cycles=1e12, **kwargs):
		# set defaults
		if inc_dirs is None:
			inc_dirs = []
		if defines is None:
			defines = {}

		# adjust inc_dirs
		if get_dir('inc/cpu') not in inc_dirs:
			inc_dirs = [get_dir('inc/cpu')] + inc_dirs
		if get_mlingua_dir() / 'samples' not in inc_dirs:
			inc_dirs = [get_mlingua_dir() / 'samples'] + inc_dirs

		# adjust defines
		defines['DAVE_TIMEUNIT'] = '1fs'
		if simulator == 'vcs':
			defines['VCS'] = None
		else:
			defines['NCVLOG'] = None
		defines['SIMULATION'] = None
		if (simulator == 'ncsim') and dump_waveforms:
			defines['DUMP_WAVEFORMS'] = True

		# save kwargs
		kwargs['top_module'] = top_module
		kwargs['ext_test_bench'] = ext_test_bench
		kwargs['disp_type'] = disp_type
		kwargs['simulator'] = simulator
		kwargs['target'] = target
		kwargs['timescale'] = timescale
		kwargs['inc_dirs'] = inc_dirs
		kwargs['defines'] = defines
		kwargs['num_cycles'] = num_cycles
		if (simulator == 'ncsim') and dump_waveforms:
			kwargs['dump_waveforms'] = False  # this is handled specially, see below...
		else:
			kwargs['dump_waveforms'] = dump_waveforms
		self.kwargs = kwargs

		# save dump_waveforms argument -- this is treated as a special case because the
		# handling is simulator-dependent
		self.dump_waveforms = dump_waveforms

		# save flags argument -- this is treated as a special case because the
		# flags that should be passed are simulator-dependent.
		flags = flags if flags is not None else []
		self.flags = flags

		# save custom arguments
		self.clean = clean
		self.seed = seed
		self.unbuffered = unbuffered

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
				flags += ['-seed', str(self.seed)]
			if self.unbuffered:
				flags += ['-unbuffered']
			if self.dump_waveforms:
				flags += ['-access', '+r']
			# need "-sv" flag because not all files
			# in DaVE have a ".sv" extension
			flags += ['-sv']
		elif self.kwargs['simulator'] == 'vcs':
			flags += ['-lca']
			if self.seed is not None:
				flags += [f'+ntb_random_seed={self.seed}']

		# run the simulation
		tester.compile_and_run(**self.kwargs, flags=flags)
