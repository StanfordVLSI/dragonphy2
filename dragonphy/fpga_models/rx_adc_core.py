from pathlib import Path
from msdsl import MixedSignalModel, VerilogGenerator, to_sint, clamp_op
from msdsl.expr.expr import array

class RXAdcCore:
    def __init__(self, filename=None, **system_values):
        module_name = Path(filename).stem
        build_dir   = Path(filename).parent

        #This is a wonky way of validating this.. :(
        assert (all([req_val in system_values for req_val in self.required_values()])), \
            f'Cannot build {module_name}, Missing parameter in config file'

        m = MixedSignalModel(module_name, dt=system_values['dt'], build_dir=build_dir)
        # main I/O: input, output, and clock
        m.add_analog_input('in_')
        m.add_digital_output('out', width=system_values['n'], signed=True)
        m.add_digital_input('clk_val')
        # timestep control: DT request and response
        m.add_analog_output('dt_req')
        m.add_analog_input('emu_dt')
        # emulator clock and reset
        m.add_digital_input('emu_clk')
        m.add_digital_input('emu_rst')
        # additional input: maximum timestep
        # TODO: clean this up
        m.add_analog_input('dt_req_max')

        # determine when sampling should happen
        m.add_digital_state('clk_val_prev')
        m.set_next_cycle(m.clk_val_prev, m.clk_val, clk=m.emu_clk, rst=m.emu_rst)

        # detect a rising edge on the clock
        m.bind_name('pos_edge', m.clk_val & (~m.clk_val_prev))

        # delay the positive edge signal
        m.add_digital_state('pos_edge_prev', init=0)
        m.set_next_cycle(m.pos_edge_prev, m.pos_edge, clk=m.emu_clk, rst=m.emu_rst)

        # sample channel value at the right time
        vp, vn, n = system_values['vp'], system_values['vn'], system_values['n']
        expr = ((m.in_ - vn) / (vp - vn) * ((2 ** n) - 1)) - (2 ** (n - 1))
        expr = clamp_op(expr, -(2 ** (n - 1)), (2 ** (n - 1)) - 1)
        expr = to_sint(expr, width=n)
        m.set_next_cycle(m.out, expr, clk=m.emu_clk, rst=m.emu_rst, ce=m.pos_edge_prev)

        # stall if needed
        dt_req_array = array(
            [m.dt_req_max, 0.0],
            m.pos_edge_prev,
            real_range_hint=m.emu_dt.format_.range_,
            width=m.emu_dt.format_.width,
            exponent=m.emu_dt.format_.exponent
        )
        m.set_this_cycle(m.dt_req, dt_req_array)

        # generate the model
        m.compile_to_file(VerilogGenerator())

        self.generated_files = [filename]

    @staticmethod
    def required_values():
        return ['dt', 'vp', 'vn', 'n']