from pathlib import Path
from argparse import ArgumentParser

from msdsl import MixedSignalModel, VerilogGenerator, to_sint, clamp_op
from msdsl.expr.extras import if_

from dragonphy import Directory

class RXAdcCore:
    def __init__(self, filename=None, **system_values):
        module_name = Path(filename).stem
        build_dir   = Path(filename).parent

        #This is a wonky way of validating this.. :(
        assert (all([req_val in system_values for req_val in self.required_values()])), f'Cannot build {module_name}, Missing parameter in config file'

        m = MixedSignalModel(module_name, dt=system_values['dt'], build_dir=build_dir)
        m.add_analog_input('in_')
        m.add_digital_output('out', width=system_values['n'], signed=True)
        m.add_digital_input('clk_val')
        m.add_digital_input('emu_clk')
        m.add_digital_input('emu_rst')
        m.add_digital_output('emu_stall')

         # determine when sampling should happen
        m.add_digital_state('prev_clk_val')
        m.set_next_cycle(m.prev_clk_val, m.clk_val, clk=m.emu_clk, rst=m.emu_rst)

        # determine when the emulator should stall
        m.set_this_cycle(m.emu_stall, m.clk_val & (~m.prev_clk_val))

        # sample channel value at the right time
        m.add_analog_state('samp_val', range_=m.in_.format_.range_, width=m.in_.format_.width,
                           exponent=m.in_.format_.exponent)
        m.set_next_cycle(m.samp_val, if_(m.emu_stall, m.in_, m.samp_val), clk=m.emu_clk, rst=m.emu_rst)

        # define ADC behavior using combinational logic acting on the sampled value
        expr = ((m.samp_val-system_values['vn'])/(system_values['vp']-system_values['vn']) * ((2**system_values['n'])-1)) - (2**(system_values['n']-1))

        clamped = clamp_op(expr, -(2**(system_values['n']-1)), (2**(system_values['n']-1))-1)
        m.set_this_cycle(m.out, to_sint(clamped, width=system_values['n']))

        # generate the model
        m.compile_to_file(VerilogGenerator())

    @staticmethod
    def required_values():
        return ['dt', 'vp', 'vn', 'n']
