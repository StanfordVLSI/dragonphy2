from pathlib import Path
import random

import magma, fault

class Tester:
	def __init__(self, top_module='test', testbench=None, libraries=None,
				 packages=None, flags=None, files=None, simulator='ncsim',
				 directory='', overload_seed=False, seed=None):
		# set values for arguments that default to a list
		# see: https://stackoverflow.com/questions/1132941/least-astonishment-and-the-mutable-default-argument
		testbench = testbench if testbench is not None else []
		libraries = libraries if libraries is not None else []
		packages = packages if packages is not None else []
		flags = flags if flags is not None else []
		files = files if files is not None else []

		# save settings
		self.directory = directory
		self.top_module = top_module
		self.testbench = [Path(tb).resolve() for tb in testbench]
		self.libraries = [Path(library).resolve() for library in libraries]
		self.packages = [Path(package).resolve() for package in packages]
		self.files = [Path(file).resolve() for file in files]
		self.flags = flags
		self.simulator = simulator
		self.seed = seed

		# generate a random seed if needed
		if overload_seed and (self.seed is None):
			self.generate_new_seed()

	def generate_new_seed(self):
		self.seed = random.getrandbits(32)

	def run(self):
		# generate list of extra flags (beyond those requested by the user)
		# TODO: make this work for simulators other than ncsim
		extra_flags = []
		extra_flags += ['-clean']
		if self.seed is not None:
			extra_flags += ['-seed', self.seed]
		for file_ in self.files:
			extra_flags += ['-f', file_]

		# run tester
		tester = fault.Tester(magma.DeclareCircuit(self.top_module))
		tester.compile_and_run(
			target='system-verilog',
			simulator=self.simulator,
			top_module=self.top_module,
			ext_srcs=self.packages + self.testbench,
			ext_libs=self.libraries,
			flags=self.flags + extra_flags,
			ext_test_bench=True,
			disp_type='realtime'
		)