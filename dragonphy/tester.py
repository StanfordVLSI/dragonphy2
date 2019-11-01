from pathlib import Path
import subprocess

class Tester:
	def __init__(self, top = 'test', testbench=[], libraries=[], packages=[], flags=[], files=[], input_tcl=None, sim='xrun', build_dir='', overload_seed=False, seed=None, wave=False):
		self.build_dir = build_dir
		self.top 	   = top
		self.testbench = [Path(tb).resolve() for tb in testbench]
		self.libraries = [Path(library).resolve() for library in libraries]
		self.packages  = [Path(package).resolve() for package in packages]
		self.files 	   = [Path(file).resolve() for file in files]
		self.wave = wave
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

		self.cwd.mkdir(exist_ok=True)

		if not input_tcl:
			self.generate_input_tcl()
		else:
			self.input_tcl = input_tcl

		self.generate_arguments()


	def generate_new_seed(self):
		with open('/dev/urandom', 'rb') as f:
			self.seed = int.from_bytes(f.read(4), byteorder='big')

	def generate_input_tcl(self):
		input_path = Path(self.build_dir + '/hdl.tcl').resolve()
		with open(input_path, 'w') as f:
			if self.wave:
				f.write(f'database -open waves.shm -into waves.shm -default\n')
				f.write(f'probe -create {self.top} -depth 9\n')
				f.write(f'probe -create {self.top} -depth 9 -all -memories\n')
			f.write(f'run\n')
			f.write(f'exit\n')
		self.input_tcl = input_path

	def execute(self):
		self.generate_arguments()
		self.cwd.mkdir(exist_ok=True)
		print('\u001b[32;1mCOMMAND\u001b[0m: ' + " ".join(self.args))
		self.returncode = subprocess.run(self.args, cwd=self.cwd).returncode

	def generate_arguments(self):
		self.args = []

		self.args += [f'{self.sim}', '-clean']
		if self.seed:
			self.args += ['-seed', f'{self.seed}']
		for flag in self.flags:
			self.args += [f'{flag}']
		self.args += ['-top', f'{self.top}']
		for package in self.packages:
			self.args += [f'{package}']
		for tb in self.testbench:
			self.args += [f'{tb}']

		for library in self.libraries:
			self.args += ['-v', f'{library}']
		for file in self.files:
			self.args += ['-f', f'{file}']

		#Access is required for the probe to work
		self.args += ['-input', f'{self.input_tcl}', '-access', 'r']

	def check(self):
		assert self.returncode == 0
		print('\u001b[32:1mBUILD SUCCESFUL\u001b[0m')

	def run(self):
		self.execute()
		self.check()
