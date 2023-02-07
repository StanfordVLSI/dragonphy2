from pathlib import Path
import numpy as np

from msdsl import MixedSignalModel, VerilogGenerator
from msdsl.expr.extras import if_

from dragonphy import get_dragonphy_real_type

class TXCore:
    def __init__(self, filename=None, **system_values):
        # set a fixed random seed for repeatability
        np.random.seed(4)

        module_name = Path(filename).stem
        build_dir = Path(filename).parent

        #This is a wonky way of validating this.. :(
        assert (all([req_val in system_values for req_val in self.required_values()])), \
            f'Cannot build {module_name}, Missing parameter in config file'

        m = MixedSignalModel(module_name, dt=system_values['dt'], build_dir=build_dir,
                             real_type=get_dragonphy_real_type())

        # Imagining verilog syntax in_[1:0], with in_[1] being high-order
        m.add_digital_input('in_', width=2)
        m.add_analog_output('out')
        m.add_digital_input('cke')
        m.add_digital_input('clk')
        m.add_digital_input('rst')

        # save previous value of cke
        m.add_digital_state('cke_prev', init=0)
        m.set_next_cycle(m.cke_prev, m.cke, clk=m.clk, rst=m.rst)

        # detect positive edge of cke
        m.add_digital_signal('cke_posedge')
        m.set_this_cycle(m.cke_posedge, m.cke & (~m.cke_prev))

        # define model behavior
        vp3, vn3 = system_values['vp3'], system_values['vn3']
        vp1, vn1 = system_values['vp1'], system_values['vn1']
        m.set_next_cycle(m.out,
            if_(m.in_[1], if_(m.in_[0], vp3, vp1), if_(m.in_[0], vn1, vn3)),
            clk=m.clk, rst=m.rst, ce=m.cke_posedge)

        # generate the model
        m.compile_to_file(VerilogGenerator())

        self.generated_files = [filename]

    @staticmethod
    def required_values():
        return ['dt', 'bits_per_symbol', 'vp3', 'vp1', 'vn1', 'vn3']
