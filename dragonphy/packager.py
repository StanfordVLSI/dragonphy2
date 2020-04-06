import numpy as np
import shutil
from pathlib import Path
from numbers import Integral, Real

class Packager():
    def __init__(self, package_name='constant', parameters=None, dir='.'):
        # set defaults
        parameters = parameters if parameters is not None else {}

        # save settings
        self.package_name = package_name
        self.parameters = parameters
        self.path = Path(dir).resolve() / f'{self.package_name}.sv'

        # initialize the package contents (list of strings; each is one line)
        self.package = []

    def create_package(self, new_parameters=None):
        self.add_parameters(new_parameters)
        self.generate_package()
        self.save_package()

    def generate_package(self):
        self.package = self.package_wrapper(self.generate_parameter_list())

    def save_package(self, nl='\n'):
        self.path.parent.mkdir(exist_ok=True, parents=True)
        with open(self.path, 'w') as f:
            for line in self.package:
                f.write(line + nl)

    def add_parameters(self, new_parameters=None):
        if new_parameters is not None:
            self.parameters.update(new_parameters)

    def package_wrapper(self, lines=None):
        new_lines = []
        new_lines += [f"package {self.package_name};"]
        if lines is not None:
            for line in lines:
                new_lines += ['    ' + line]
        new_lines += ["endpackage"]

        return new_lines

<<<<<<< HEAD
    def design_param_definition(self, parameter_name, parameter_default):
        if isinstance(parameter_default, str):
            parameter_type    = 'string'
            parameter_default = "\"" + parameter_default + "\""
        elif isinstance(parameter_default, int):
            parameter_type    = 'integer'
        else:
            print(f'Cannot determine type for {parameter_name} (default: {parameter_default})')
            exit()

        return "localparam {} {} = {};".format(parameter_type, parameter_name, parameter_default)
=======
    def generate_parameter_list(self):
        retval = []
        for name, value in self.parameters.items():
            retval += [self.design_param_definition(name, value)]
        return retval
>>>>>>> master

    def design_param_definition(self, parameter_name, parameter_default):
        if isinstance(parameter_default, (list, tuple, np.ndarray)):
            # array of values (only handles 1D arrays for now)
            type = self.get_sv_type_array(parameter_default)
            param_decl = f'{type} {parameter_name} [{len(parameter_default)}]'
            param_val = ', '.join(self.format_sv_val(val, type)
                                  for val in parameter_default)
            param_val = f"'{{{param_val}}}"
        else:
            # single value
            type = self.get_sv_type(parameter_default)
            param_decl = f'{type} {parameter_name}'
            param_val = self.format_sv_val(parameter_default, type)

        return f'localparam {param_decl} = {param_val};'

    @classmethod
    def get_sv_type_array(cls, vals):
        sv_types = [cls.get_sv_type(elem) for elem in vals]
        if any(elem == 'string' for elem in sv_types):
            assert all(elem == 'string' for elem in sv_types)
            return 'string'
        elif any(elem == 'real' for elem in sv_types):
            assert all(elem in {'real', 'integer'} for elem in sv_types)
            return 'real'
        else:
            assert all(elem == 'integer' for elem in sv_types)
            return 'integer'

    @staticmethod
    def get_sv_type(val):
        if isinstance(val, str):
            return 'string'
        elif isinstance(val, Integral):
            return 'integer'
        elif isinstance(val, Real):
            return 'real'
        else:
            raise Exception(f'Unknown data type: {type(val)}')

    @staticmethod
    def format_sv_val(val, type):
        if type=='string':
            return f'"{val}"'
        else:
            return f'{val}'

    @staticmethod
    def delete_pack_dir(path='.'):
        cwd = Path(path)
        shutil.rmtree(cwd) 
