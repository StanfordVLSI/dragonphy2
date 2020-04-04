from pathlib import Path
from msdsl import MixedSignalModel, VerilogGenerator, min_op
from msdsl.expr.expr import array, concatenate
from msdsl.expr.extras import if_

class ClkDelayCore:
    def __init__(self, filename=None, **system_values):
        module_name = Path(filename).stem
        build_dir   = Path(filename).parent

        #This is a wonky way of validating this.. :(
        assert (all([req_val in system_values for req_val in self.required_values()])), \
            f'Cannot build {module_name}, Missing parameter in config file'

        m = MixedSignalModel(module_name, dt=system_values['dt'], build_dir=build_dir)
        # main I/O: delay code, clock in/out values
        m.add_digital_input('code', width=system_values['n_bits'])
        m.add_digital_input('clk_i_val')
        m.add_digital_output('clk_o_val')
        # timestep control: DT request and response
        m.add_analog_output('dt_req')
        m.add_analog_input('emu_dt')
        # emulator clock and reset
        m.add_digital_input('emu_clk')
        m.add_digital_input('emu_rst')
        # additional input: maximum timestep
        # TODO: clean this up
        m.add_analog_input('dt_req_max')

        # compute the delay
        m.bind_name('delay_amt', m.code*(system_values['t_per']/(2.0**system_values['n_bits'])))

        # determine when the clock value has changed
        m.add_digital_state('clk_i_val_prev')
        m.set_next_cycle(m.clk_i_val_prev, m.clk_i_val, clk=m.emu_clk, rst=m.emu_rst)
        m.bind_name('clk_pos_edge', m.clk_i_val & (~m.clk_i_val_prev))
        m.bind_name('clk_neg_edge', (~m.clk_i_val) & m.clk_i_val_prev)

        # determine formatting of emu_dt signal
        emu_dt_kwargs = dict(
            range_=m.emu_dt.format_.range_,
            width=m.emu_dt.format_.width,
            exponent=m.emu_dt.format_.exponent
        )

        # determine the timestep until the next positive and negative edge
        m.add_analog_state('dt_req_pos', **emu_dt_kwargs)
        m.add_analog_state('dt_req_neg', **emu_dt_kwargs)
        m.set_next_cycle(m.dt_req_pos, if_(m.clk_pos_edge, m.delay_amt, m.dt_req_pos - m.emu_dt),
                         clk=m.emu_clk, rst=m.emu_rst)
        m.set_next_cycle(m.dt_req_neg, if_(m.clk_neg_edge, m.delay_amt, m.dt_req_neg - m.emu_dt),
                         clk=m.emu_clk, rst=m.emu_rst)

        # determine if timestep requests have been met
        m.bind_name('dt_req_pos_grant', m.dt_req_pos == m.emu_dt)
        m.bind_name('dt_req_neg_grant', m.dt_req_neg == m.emu_dt)

        # compute the minimum of the positive and negative timestep requests, which
        # is the timestep request that will be made if both are valid
        m.bind_name('dt_req_min', min_op([m.dt_req_pos, m.dt_req_neg]), **emu_dt_kwargs)

        # determine if the timestep request are valid
        m.add_digital_state('dt_req_pos_valid', init=0)
        m.add_digital_state('dt_req_neg_valid', init=0)
        m.set_next_cycle(m.dt_req_pos_valid, if_(m.clk_pos_edge, 1, if_(m.dt_req_pos_grant, 0, m.dt_req_pos_valid)),
                         clk=m.emu_clk, rst=m.emu_rst)
        m.set_next_cycle(m.dt_req_neg_valid, if_(m.clk_neg_edge, 1, if_(m.dt_req_neg_grant, 0, m.dt_req_neg_valid)),
                         clk=m.emu_clk, rst=m.emu_rst)

        # make the timestep request
        dt_req_array = array(
            [m.dt_req_max, m.dt_req_neg, m.dt_req_pos, m.dt_req_min],
            concatenate([m.dt_req_pos_valid, m.dt_req_neg_valid]),
            real_range_hint=m.emu_dt.format_.range_,
            width=m.emu_dt.format_.width,
            exponent=m.emu_dt.format_.exponent
        )
        m.set_this_cycle(m.dt_req, dt_req_array)

        # set the output value to "1" if the rising edge DT request has been granted (if it's valid),
        # set the output value to "0" if the falling edge DT request has been granted (if it's valid),
        # otherwise k
        m.add_digital_state('clk_o_val_prev')
        m.set_next_cycle(m.clk_o_val_prev, m.clk_o_val, clk=m.emu_clk, rst=m.emu_rst)
        m.set_this_cycle(m.clk_o_val, if_(m.dt_req_pos_valid & m.dt_req_pos_grant, 1,
                                          if_(m.dt_req_neg_valid & m.dt_req_neg_grant, 0, m.clk_o_val_prev)))

        # generate the model
        m.compile_to_file(VerilogGenerator())

        self.generated_files = [filename]

    @staticmethod
    def required_values():
        return ['dt', 'n_bits', 't_per']