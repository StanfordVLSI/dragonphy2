# Generic imports
from pathlib import Path
import numpy as np

# FPGA-specific imports
from msdsl import MixedSignalModel, VerilogGenerator, sum_op
from msdsl.expr.signals import AnalogState
from msdsl.expr.extras import if_
from msdsl.function import PlaceholderFunction

# DragonPHY imports
from dragonphy import Filter, get_file

class ChannelCore:
    def __init__(self, filename=None, **system_values):
        # set a fixed random seed for repeatability
        np.random.seed(0)

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

        # Create "placeholder function" that can be updated
        # at runtime with the channel function
        chan_func = PlaceholderFunction(
                domain=system_values['func_domain'],
                order=system_values['func_order'],
                numel=system_values['func_numel'],
                coeff_widths=system_values['func_widths'],
                coeff_exps=system_values['func_exps']
        )

        # Check the function on a representative test case
        chan = Filter.from_file(get_file('build/chip_src/adapt_fir/chan.npy'))
        self.check_func_error(chan_func, chan.interp)

        # Add digital inputs that will be used to reconfigure
        # the function at runtime
        wdata = []
        for k in range(chan_func.order+1):
            wdata += [m.add_digital_input(f'wdata{k}', signed=True, width=chan_func.coeff_widths[k])]
        waddr = m.add_digital_input('waddr', width=chan_func.addr_bits)
        we = m.add_digital_input('we')

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
            step_sig = m.set_from_sync_func(f'step_{k}', chan_func, time_mux[k+1], clk=m.clk, rst=m.rst,
                                            wdata=wdata, waddr=waddr, we=we)
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
    def check_func_error(placeholder, func):
        # calculate coeffients
        coeffs = placeholder.get_coeffs(func)

        # determine test points
        samp = np.random.uniform(placeholder.domain[0],
                                 placeholder.domain[1],
                                 1000)

        # evaluate the function at those test points using
        # the calculated coefficients
        approx = placeholder.eval_on(samp, coeffs)

        # determine the values the function should have at
        # the test points
        exact = func(samp)

        # calculate the error
        err = np.max(np.abs(exact-approx))

        # display the error
        print(f'Worst-case error: {err}')

    @staticmethod
    def required_values():
        return ['dt', 'func_order', 'func_numel', 'num_terms',
                'func_domain', 'func_widths', 'func_exps']
