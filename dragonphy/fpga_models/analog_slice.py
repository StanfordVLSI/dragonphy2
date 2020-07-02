# Generic imports
from pathlib import Path
from math import log2, ceil
import numpy as np

# FPGA-specific imports
from msdsl import MixedSignalModel, VerilogGenerator, sum_op, clamp_op, to_uint, to_sint
from msdsl.expr.extras import if_
from msdsl.expr.format import SIntFormat

# DragonPHY imports
from dragonphy import Filter, get_file

class AnalogSlice:
    def __init__(self, filename=None, **system_values):
        # set a fixed random seed for repeatability
        np.random.seed(0)

        module_name = Path(filename).stem
        build_dir   = Path(filename).parent

        #This is a wonky way of validating this.. :(
        assert (all([req_val in system_values for req_val in self.required_values()])), \
            f'Cannot build {module_name}, Missing parameter in config file'

        m = MixedSignalModel(module_name, dt=system_values['dt'], build_dir=build_dir)

        # Chunk of bits from the history; corresponding delay is bit_idx/freq_tx delay
        m.add_digital_input('chunk', width=system_values['chunk_width'])
        m.add_digital_input('chunk_idx', width=int(ceil(log2(system_values['num_chunks']))))

        # Control code for the corresponding PI slice
        m.add_digital_input('pi_ctl', width=system_values['pi_ctl_width'])

        # Indicates sequencing of ADC slice within a bank (typically a static value)
        m.add_digital_input('slice_offset', width=int(ceil(log2(system_values['slices_per_bank']))))

        # Control codes that affect states in the slice
        m.add_digital_input('sample_ctl')
        m.add_digital_input('incr_sum')
        m.add_digital_input('write_output')

        # ADC sign and magnitude
        m.add_digital_output('out_sgn')
        m.add_digital_output('out_mag', width=system_values['n_adc'])

        # Emulator clock and reset
        m.add_digital_input('clk')
        m.add_digital_input('rst')

        # Sample the pi_ctl code
        m.add_digital_state('pi_ctl_sample', width=system_values['pi_ctl_width'])
        m.set_next_cycle(m.pi_ctl_sample, m.pi_ctl, clk=m.clk, rst=m.rst, ce=m.sample_ctl)

        # read in the channel data
        chan = Filter.from_file(get_file('build/chip_src/adapt_fir/chan.npy'))

        # create a function
        domain = [chan.t_vec[0], chan.t_vec[-1]]
        chan_func = m.make_function(chan.interp, domain=domain, order=system_values['func_order'],
                                    numel=system_values['func_numel'])
        self.check_func_error(chan_func)

        # compute weights to apply to pulse responses
        weights = []
        for k in range(system_values['chunk_width']):
            weights.append(
                m.add_analog_state(
                    f'weights_{k}',
                    range_=system_values['vref_tx']
                )
            )
            m.set_next_cycle(weights[-1], if_(m.chunk[k], system_values['vref_tx'], -system_values['vref_tx']),
                             clk=m.clk, rst=m.rst)

        # Compute the evaluation time for this slice
        t_samp = m.bind_name(
            't_samp',
            ((m.slice_offset*(1<<system_values['pi_ctl_width'])) + m.pi_ctl_sample)
            / ((2.0**system_values['pi_ctl_width'])*system_values['freq_rx'])
        )

        # Evaluate the step response function.  Note that the number of evaluation times is the
        # number of chunks plus one.
        f_eval = []
        for k in range(system_values['chunk_width']+1):
            # compute change time as an integer multiple of the TX period
            chg_idx = m.bind_name(
                f'chg_idx_{k}', (
                    system_values['slices_per_bank']*system_values['num_banks']
                    - (m.chunk_idx+1)*system_values['chunk_width']
                    + k
                )
            )

            # scale by TX period
            t_chg = m.bind_name(f't_chg_{k}', chg_idx/system_values['freq_tx'])

            # compute the kth evaluation time
            t_eval = m.bind_name(f't_eval_{k}', t_samp - t_chg)

            # evaluate the function
            f_eval.append(m.set_from_sync_func(f'f_eval_{k}', chan_func, t_eval, clk=m.clk, rst=m.rst))

        # Compute the pulse responses for each bit
        pulse_resp = []
        for k in range(system_values['chunk_width']):
            pulse_resp.append(
                m.bind_name(
                    f'pulse_resp_{k}',
                    weights[k]*(f_eval[k] - f_eval[k+1])
                )
            )

        # sum up all of the pulse responses
        pulse_resp_sum = m.bind_name('pulse_resp_sum', sum_op(pulse_resp))

        # update the overall sample value
        sample_value = m.add_analog_state('analog_sample', range_=5*system_values['vref_rx'])
        m.set_next_cycle(
            sample_value,
            if_(m.incr_sum, sample_value + pulse_resp_sum, pulse_resp_sum),
            clk=m.clk,
            rst=m.rst
        )

        # determine out_sgn (note that the definition is opposite of the typical
        # meaning; "0" means negative)
        out_sgn = if_(sample_value < 0, 0, 1)
        m.set_next_cycle(m.out_sgn, out_sgn, clk=m.clk, rst=m.rst, ce=m.write_output)

        # determine out_mag
        vref_rx, n_adc = system_values['vref_rx'], system_values['n_adc']
        abs_val = m.bind_name('abs_val', if_(sample_value < 0, -1.0*sample_value, sample_value))
        code_real_unclamped = m.bind_name('code_real_unclamped', (abs_val / vref_rx) * ((2**(n_adc-1))-1))
        code_real = m.bind_name('code_real', clamp_op(code_real_unclamped, 0, (2**(n_adc-1))-1))

        # TODO: clean this up -- since real ranges are not intervals, we need to tell MSDSL
        # that the range of the signed integer is smaller
        code_sint = to_sint(code_real, width=n_adc+1)
        code_sint.format_ = SIntFormat(width=n_adc+1, min_val=0, max_val=(2**(n_adc-1))-1)
        code_sint = m.bind_name('code_sint', code_sint)

        code_uint = m.bind_name('code_uint', to_uint(code_sint, width=n_adc))
        m.set_next_cycle(m.out_mag, code_uint, clk=m.clk, rst=m.rst, ce=m.write_output)

        # generate the model
        m.compile_to_file(VerilogGenerator())

        self.generated_files = [filename]

    @staticmethod
    def check_func_error(f):
        samp = np.random.uniform(f.domain[0], f.domain[1], 1000)
        approx = f.eval_on(samp)
        exact = f.func(samp)
        err = np.max(np.abs(exact-approx))
        print(f'Worst-case error: {err}')

    @staticmethod
    def required_values():
        return ['dt', 'func_order', 'func_numel', 'chunk_width', 'num_chunks',
                'slices_per_bank', 'num_banks', 'pi_ctl_width', 'vref_rx',
                'vref_tx', 'n_adc', 'freq_tx', 'freq_rx']
