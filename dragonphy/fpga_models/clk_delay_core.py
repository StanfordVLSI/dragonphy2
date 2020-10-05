from pathlib import Path
from math import log2, ceil
from itertools import count
import numpy as np

from msdsl import MixedSignalModel, VerilogGenerator
from msdsl.expr.expr import array
from msdsl.expr.extras import if_

class ClkDelayCore:
    def __init__(self, filename=None, **system_values):
        # set a fixed random seed for repeatability
        np.random.seed(1)

        module_name = Path(filename).stem
        build_dir   = Path(filename).parent

        #This is a wonky way of validating this.. :(
        assert (all([req_val in system_values for req_val in self.required_values()])), \
            f'Cannot build {module_name}, Missing parameter in config file'

        # instantiate model
        m = MixedSignalModel(module_name, dt=system_values['dt'], build_dir=build_dir)

        # main I/O: delay code and gain
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

        # jitter control
        m.add_digital_input('jitter_seed', width=32)
        m.add_analog_input('jitter_rms')

        # compute the delay (with no jitter)
        m.bind_name('delay_amt_pre', m.code * (system_values['t_per'] / (2.0 ** system_values['n_bits'])))

        # add jitter to the delay amount (which might possibly yield a negative value)
        m.set_gaussian_noise('t_jitter', std=m.jitter_rms, clk=m.emu_clk,
                             rst=m.emu_rst, lfsr_init=m.jitter_seed)
        m.bind_name('delay_amt_noisy', m.delay_amt_pre + m.t_jitter)

        # make the delay amount non-negative
        m.bind_name('delay_amt', if_(m.delay_amt_noisy >= 0.0, m.delay_amt_noisy, 0.0))

        # determine when the clock value has changed
        m.add_digital_state('clk_i_val_prev')
        m.set_next_cycle(m.clk_i_val_prev, m.clk_i_val, clk=m.emu_clk, rst=m.emu_rst)
        m.bind_name('clk_edge', m.clk_i_val ^ m.clk_i_val_prev)

        # create pointer that advances each time there is a clock edge
        depth = system_values['depth']
        dbits = int(ceil(log2(depth)))
        m.add_digital_state('addr', width=dbits)
        m.add_digital_state('next_addr', width=dbits)
        m.set_this_cycle(m.next_addr, if_(m.addr == (depth-1), 0, m.addr+1))
        m.set_next_cycle(m.addr, m.next_addr, clk=m.emu_clk, rst=m.emu_rst, ce=m.clk_edge)

        # convenience function for formatting DT signals
        def add_dt_state(*args, range_=m.emu_dt.format_.range_, width=m.emu_dt.format_.width,
                         exponent=m.emu_dt.format_.exponent, **kwargs):
            return m.add_analog_state(*args, range_=range_, width=width, exponent=exponent, **kwargs)

        # convenience function for formatting DT signals
        def dt_array(*args, real_range_hint=m.emu_dt.format_.range_, width=m.emu_dt.format_.width,
                     exponent=m.emu_dt.format_.exponent, **kwargs):
            return array(*args, real_range_hint=real_range_hint, width=width, exponent=exponent,
                         **kwargs)

        # instantiate delay "units" that each keep track of one edge

        dt_req = []
        req_data = []
        req_grant = []
        req_valid = []

        for k in range(depth):
            # should load data if there is a clock edge and this slice is selected
            load_data = m.bind_name(f'load_data_{k}', m.clk_edge & (k == m.addr))

            # handle update of dt_req
            dt_req.append(add_dt_state(f'dt_req_{k}'))
            m.set_next_cycle(
                dt_req[-1],
                if_(load_data, m.delay_amt, dt_req[-1] - m.emu_dt),
                clk=m.emu_clk,
                rst=m.emu_rst
            )

            # handle update of req_data
            req_data.append(m.add_digital_state(f'req_data_{k}'))
            m.set_next_cycle(req_data[-1], m.clk_i_val, ce=load_data,
                             clk=m.emu_clk, rst=m.emu_rst)

            # handle update of req_grant
            req_grant.append(m.bind_name(f'req_grant_{k}', dt_req[-1] == m.emu_dt))

            # handle update of req_valid
            req_valid.append(m.add_digital_state(f'req_valid_{k}'))
            m.set_next_cycle(req_valid[-1], (req_valid[-1] & (~req_grant[-1])) | load_data,
                             clk=m.emu_clk, rst=m.emu_rst)

        # replace dt_req with dt_req_max for invalid requests

        dt_req_mux = []
        for k in range(depth):
            dt_req_mux.append(
                m.bind_name(
                    f'dt_req_mux_{k}',
                    dt_array(
                        [m.dt_req_max, dt_req[k]],
                        req_valid[k],
                    )
                )
            )

        # convenience function to find the minimum DT request using a tree structure

        counter = count()
        def tree_min(data):
            # check cases
            if len(data) == 0:
                raise Exception("This shouldn't happen...")
            elif len(data) == 1:
                return data[0]
            else:
                val0 = tree_min(data[:len(data)//2])
                val1 = tree_min(data[len(data)//2:])
                return m.bind_name(
                    f'dt_intern_{next(counter)}',
                    dt_array(
                        [val0, val1],
                        val1 < val0,
                    )
                )

        # set the "dt_req" output to the minimum time request (where invalid requests
        # are replaced with "dt_req_max"

        m.set_this_cycle(m.dt_req, tree_min(dt_req_mux))

        # determine if the output should be set or cleared

        set_out = req_grant[0] & req_valid[0] & req_data[0]
        clr_out = req_grant[0] & req_valid[0] & (~req_data[0])

        for k in range(1, depth):
            set_out = set_out | (req_grant[k] & req_valid[k] & req_data[k])
            clr_out = clr_out | (req_grant[k] & req_valid[k] & (~req_data[k]))

        m.bind_name('set_out', set_out)
        m.bind_name('clr_out', clr_out)

        # set output, clear output, or keep it the same

        m.add_digital_state('clk_o_val_prev')
        m.set_next_cycle(m.clk_o_val_prev, m.clk_o_val, clk=m.emu_clk, rst=m.emu_rst)
        m.set_this_cycle(m.clk_o_val, (m.clk_o_val_prev & (~m.clr_out)) | (m.set_out))

        # generate the model
        m.compile_to_file(VerilogGenerator())

        self.generated_files = [filename]

    @staticmethod
    def required_values():
        return ['dt', 'n_bits', 't_per', 'depth']