from pathlib import Path
from argparse import ArgumentParser

from msdsl import MixedSignalModel, VerilogGenerator, sum_op
from msdsl.expr.extras import if_

from dragonphy import Filter, Directory
from dragonphy.files import get_file

class TXCore:
    def __init__(self, filename=None, **system_values):
        module_name = Path(filename).stem
        build_dir = Path(filename).parent

        #This is a wonky way of validating this.. :(
        assert (all([req_val in system_values for req_val in self.required_values()])), f'Cannot build {module_name}, Missing parameter in config file'

        m = MixedSignalModel(module_name, dt=system_values['dt'], build_dir=build_dir)

        m.add_digital_input('in_')
        m.add_analog_output('out')
        m.add_digital_input('clk')

        # define model behavior
        m.set_next_cycle(m.out, if_(m.in_, system_values['vp'], system_values['vn']), clk=m.clk, rst="1'b0")

        # generate the model
        m.compile_to_file(VerilogGenerator())

    @staticmethod
    def required_values():
        return ['dt', 'vp', 'vn']
