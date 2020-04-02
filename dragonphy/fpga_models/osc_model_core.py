from pathlib import Path
from argparse import ArgumentParser
from copy import deepcopy
from msdsl import MixedSignalModel, VerilogGenerator
from msdsl.expr.expr import array
from msdsl.expr.extras import if_

class OscModelCore:
    def __init__(self,  filename=None, **system_values):
        module_name = Path(filename).stem
        build_dir   = Path(filename).parent

        print(f'Running model generator for {module_name}...')
        assert (all([req_val in system_values for req_val in self.required_values()])), f'Cannot build {module_name}, Missing parameter in config file'


        m = MixedSignalModel(module_name, dt=system_values['dt'], build_dir=build_dir)
        m.add_digital_input('emu_rst')
        m.add_digital_input('emu_clk')
        m.add_analog_input('emu_dt')
        m.add_analog_output('dt_req', init=system_values['tlo'])
        m.add_digital_output('clk_val')
        m.add_digital_input('clk_i')
        m.add_digital_output('clk_o')

        # determine the next requested timestep, advancing to the next half period
        # if the timestep was granted, otherwise subtracting the actual timestep
        # from the requested timestep
        dt_req_imm = if_(m.dt_req == m.emu_dt,
                         if_(m.clk_val,
                             system_values['tlo'],
                             system_values['thi']),
                         m.dt_req - m.emu_dt)
        m.set_next_cycle(m.dt_req, dt_req_imm, clk=m.emu_clk, rst=m.emu_rst)

        # update the clock value
        clk_val_imm = if_(m.dt_req == m.emu_dt,
                          ~m.clk_val,
                          m.clk_val)
        m.set_next_cycle(m.clk_val, clk_val_imm, clk=m.emu_clk, rst=m.emu_rst)

        # pass through clock input to clock output
        m.set_this_cycle(m.clk_o, m.clk_i)

        # generate the model
        m.compile_to_file(VerilogGenerator())

        self.generated_files = [filename]


    @staticmethod
    def required_values():
        return ['dt', 'tlo', 'thi']

