# Generic imports
from pathlib import Path
from math import log2, ceil
import numpy as np

# FPGA-specific imports
from msdsl import MixedSignalModel, VerilogGenerator, sum_op, clamp_op, to_uint, to_sint
from msdsl.expr.extras import if_
from msdsl.expr.format import SIntFormat
from msdsl.function import PlaceholderFunction

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

        # Random number generator seeds (defaults generated with random.org)
        m.add_digital_param('jitter_seed', width=32, default=46428)
        m.add_digital_param('noise_seed', width=32, default=8518)

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

        # Noise controls
        m.add_analog_input('jitter_rms')
        m.add_analog_input('noise_rms')

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

        # Sample the pi_ctl code
        m.add_digital_state('pi_ctl_sample', width=system_values['pi_ctl_width'])
        m.set_next_cycle(m.pi_ctl_sample, m.pi_ctl, clk=m.clk, rst=m.rst, ce=m.sample_ctl)

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
        t_samp_pre = m.bind_name(
            't_samp_pre',
            ((m.slice_offset*(1<<system_values['pi_ctl_width'])) + m.pi_ctl_sample)
            / ((2.0**system_values['pi_ctl_width'])*system_values['freq_rx'])
        )

        # Add jitter to the sampling time
        t_samp_jitter = m.set_gaussian_noise('t_samp_jitter', std=m.jitter_rms, clk=m.clk, rst=m.rst,
                                             lfsr_init=m.jitter_seed)
        t_samp = m.bind_name('t_samp', t_samp_pre + t_samp_jitter)

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

            # evaluate the function (the last three inputs are used for updating the function contents)
            f_eval.append(m.set_from_sync_func(f'f_eval_{k}', chan_func, t_eval, clk=m.clk, rst=m.rst,
                                               wdata=wdata, waddr=waddr, we=we))

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
        sample_value_pre = m.add_analog_state('analog_sample_pre', range_=5*system_values['vref_rx'])
        m.set_next_cycle(
            sample_value_pre,
            if_(m.incr_sum, sample_value_pre + pulse_resp_sum, pulse_resp_sum),
            clk=m.clk,
            rst=m.rst
        )

        # add noise to the sample value
        sample_noise = m.set_gaussian_noise('sample_noise', std=m.noise_rms, clk=m.clk, rst=m.rst,
                                            lfsr_init=m.noise_seed)
        sample_value = m.bind_name('sample_value', sample_value_pre + sample_noise)

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
        return ['dt', 'func_order', 'func_numel', 'chunk_width', 'num_chunks',
                'slices_per_bank', 'num_banks', 'pi_ctl_width', 'vref_rx',
                'vref_tx', 'n_adc', 'freq_tx', 'freq_rx', 'func_widths',
                'func_exps', 'func_domain']
