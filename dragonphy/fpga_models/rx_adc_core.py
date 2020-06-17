from pathlib import Path
from msdsl import MixedSignalModel, VerilogGenerator, to_sint, clamp_op, to_uint
from msdsl.expr.expr import array
from msdsl.expr.extras import if_
from msdsl.expr.format import SIntFormat

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
        m.add_digital_output('out_sgn')
        m.add_digital_output('out_mag', width=system_values['n'])
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

        # determine out_sgn (note that the definition is opposite of the typical
        # meaning; "0" means negative)
        out_sgn = if_(m.in_ < 0, 0, 1)
        m.set_next_cycle(m.out_sgn, out_sgn, clk=m.emu_clk, rst=m.emu_rst, ce=m.pos_edge_prev)

        # determine out_mag
        vref, n = system_values['vref'], system_values['n']
        abs_val = if_(m.in_ < 0, -1.0*m.in_, m.in_)
        code_real_unclamped = (abs_val / vref) * ((2**(n-1))-1)
        code_real = clamp_op(code_real_unclamped, 0, (2**(n-1))-1)
        code_sint = to_sint(code_real, width=n+1)

        # TODO: clean this up -- since real ranges are not intervals,
        # we need to tell MSDSL that the range of the signed integer is
        # smaller
        code_sint.format_ = SIntFormat(width=n+1, min_val=0, max_val=(2**(n-1))-1)

        code_uint = to_uint(code_sint, width=n)
        m.set_next_cycle(m.out_mag, code_uint, clk=m.emu_clk, rst=m.emu_rst, ce=m.pos_edge_prev)

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
        return ['dt', 'vref', 'n']