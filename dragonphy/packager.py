from pathlib import Path

class Packager():
	def __init__(self, package_name='constant', parameter_dict={}, path="."):
		self.name = package_name + '_pack'
		self.parameters = parameter_dict
		self.package = []
		self.filename = "{}.sv".format(self.name)
		self.path_head = path
	def create_package(self, new_parameters={}, path_head=""):
		self.add_parameters(new_parameters)
		self.generate_package()
		self.save_package()

	@property
	def path(self):
		return str(Path(self.path_head + '/' + self.name + '.sv'))

	def add_parameters(self, new_parameters={}):
		self.parameters.update(new_parameters)

	def package_wrapper(self, lines=[]):
		package_definition_open = "package {};".format(self.name)
		package_definition_close = "endpackage"

		new_lines = [package_definition_open]
		for line in lines:
			new_lines += ['\t' + line]
		new_lines += [package_definition_close]

		return new_lines

	def generate_parameter_list(self,lines=[]):
		new_lines = lines

		for parameter in self.parameters:
			new_lines += [self.design_param_definition(parameter, self.parameters[parameter])]

		return new_lines

	def design_param_definition(self, parameter_name, parameter_default):
		return "localparam integer {} = {};".format(parameter_name, parameter_default)

	def generate_package(self):
		self.package = self.package_wrapper(self.generate_parameter_list())

	def save_package(self):
		cwd = Path(self.path_head)
		cwd.mkdir(exist_ok=True)

		with open(Path(self.path_head + '/' + self.filename).resolve(), 'w') as f:
			for line in self.package:
				f.write(line +'\n')