# Generic imports
from pathlib import Path
import numpy as np

# FPGA-specific imports
from msdsl import MixedSignalModel, VerilogGenerator, sum_op
from msdsl.expr.signals import AnalogState
from msdsl.expr.extras import if_

# DragonPHY imports
from dragonphy import Filter, get_file

class ChannelCore:
    def __init__(self, filename=None, **system_values):
        module_name = Path(filename).stem
        build_dir   = Path(filename).parent

        #This is a wonky way of validating this.. :(
        assert (all([req_val in system_values for req_val in self.required_values()])), \
            f'Cannot build {module_name}, Missing parameter in config file'

        m = MixedSignalModel(module_name, dt=system_values['dt'], build_dir=build_dir)
        m.add_analog_input('in_')
        m.add_analog_output('out')
        m.add_analog_input('dt_sig')
        m.add_digital_input('clk')
        m.add_digital_input('cke')
        m.add_digital_input('rst')

        view = system_values['view']

        # read in the channel data
        chan = Filter.from_file(get_file('build/chip_src/adapt_fir/chan.npy'))

        # create a function
        domain = [chan.t_vec[0], chan.t_vec[-1]]
        chan_func = m.make_function(chan.interp, domain=domain, order=system_values['func_order'],
                                    numel=system_values['func_numel'], verif_per_seg=10)
        self.check_func_error(chan_func)

        # create a history of past inputs
        cke_d = m.add_digital_state('cke_d')
        m.set_next_cycle(cke_d, m.cke, clk=m.clk, rst=m.rst)
        value_hist = m.make_history(m.in_, system_values['num_terms']+1, clk=m.clk, rst=m.rst, ce=cke_d)

        # create a history times in the past when the input changed
        time_incr = []
        time_mux = []
        for k in range(system_values['num_terms']+1):
            if k == 0:
                time_incr.append(m.dt_sig)
                time_mux.append(None)
            else:
                # create the signal
                mem_sig = AnalogState(name=f'time_mem_{k}', range_=m.dt_sig.format_.range_,
                                      width=m.dt_sig.format_.width, exponent=m.dt_sig.format_.exponent,
                                      init=0.0)
                m.add_signal(mem_sig)

                # increment time by dt_sig (this is the output from the current tap)
                incr_sig = m.bind_name(f'time_incr_{k}', mem_sig + m.dt_sig)
                time_incr.append(incr_sig)

                # mux input of DFF between current and previous memory value
                mux_sig = m.bind_name(f'time_mux_{k}', if_(m.cke_d, time_incr[k-1], time_incr[k]))
                time_mux.append(mux_sig)

                # delayed assignment
                m.set_next_cycle(signal=mem_sig, expr=mux_sig, clk=m.clk, rst=m.rst)

        # evaluate step response function
        step = []
        for k in range(system_values['num_terms']):
            step_sig = m.set_from_sync_func(f'step_{k}', chan_func, time_mux[k+1], clk=m.clk, rst=m.rst)
            step.append(step_sig)

        # compute the products to be summed
        prod = []
        for k in range(system_values['num_terms']):
            if k==0:
                prod_sig = m.bind_name(f'prod_{k}', value_hist[k+1]*step[k])
            else:
                prod_sig = m.bind_name(f'prod_{k}', value_hist[k+1]*(step[k]-step[k-1]))
            prod.append(prod_sig)

        # define model behavior
        m.set_this_cycle(m.out, sum_op(prod))

        # generate the model
        m.compile_to_file(VerilogGenerator())

        self.generated_files = [filename]

    @staticmethod
    def check_func_error(f):
        samp = np.random.uniform(f.domain[0], f.domain[1], 1000)
        approx = f.eval_on(samp)
        exact = f.func(samp)
        err = np.sqrt(np.mean((exact-approx)**2))
        print(f'RMS error: {err}')

    @staticmethod
    def required_values():
        return ['dt', 'func_order', 'func_numel', 'num_terms']

