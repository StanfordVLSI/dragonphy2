from pathlib import Path
import subprocess

class Tester:
	def __init__(self, testbench, libraries=[], packages=[], flags=[], sim='xrun', build_dir='', overload_seed=False, seed=None):
		self.build_dir = build_dir
		self.testbench = Path(testbench).resolve()
		self.libraries = [Path(library).resolve() for library in libraries]
		self.packages  = [Path(package).resolve() for package in packages]
		self.flags 	   = flags
		self.sim	   = sim
		self.args 	   = []
		self.cwd 	   = Path(self.build_dir)
		self.returncode = None

		if overload_seed and not seed:
			with open('/dev/urandom', 'rb') as f:
				self.seed = int.from_bytes(f.read(4), byteorder='big')
		elif overload_seed:
			self.seed = seed

		self.generate_arguments()

	def generate_new_seed(self):
		with open('/dev/urandom', 'rb') as f:
			self.seed = int.from_bytes(f.read(4), byteorder='big')


	def execute(self):
		self.generate_arguments()
		self.cwd.mkdir(exist_ok=True)
		print('\u001b[32;1mCOMMAND\u001b[0m: ' + " ".join(self.args))
		self.returncode = subprocess.run(self.args, cwd=self.cwd).returncode

	def generate_arguments(self):
		self.args = []

		self.args += [f'{self.sim}']
		if self.seed:
			self.args += ['-seed', f'{self.seed}']
		for flag in self.flags:
			self.args += [f'{flag}']
		self.args += ['-top', f'test']
		for package in self.packages:
			self.args += [f'{package}']
		self.args += [f'{self.testbench}']
		for library in self.libraries:
			self.args += ['-v', f'{library}']

	def check(self):
		assert self.returncode == 0
		print('\u001b[32:1mBUILD SUCCESFUL\u001b[0m')

	def run(self):
		self.execute()
		self.check()
