# Generic imports
from pathlib import Path
from argparse import ArgumentParser
import numpy as np

# FPGA-specific imports
from msdsl import MixedSignalModel, VerilogGenerator, sum_op
from msdsl.expr.signals import AnalogState
from msdsl.expr.extras import if_

# DragonPHY imports
from dragonphy import Filter, get_file

def check_func_error(f):
    samp = np.random.uniform(f.domain[0], f.domain[1], 1000)
    approx = f.eval_on(samp)
    exact = f.func(samp)
    err = np.sqrt(np.mean((exact-approx)**2))
    print(f'RMS error: {err}')

def main():
    module_name = Path(__file__).stem
    print(f'Running model generator for {module_name}...')

    # parse command line arguments
    parser = ArgumentParser()

    # generic arguments
    parser.add_argument('-o', '--output', type=str, default='.')
    parser.add_argument('--dt', type=float, default=0.1e-6)
    parser.add_argument('--func_order', type=int, default=1)
    parser.add_argument('--func_numel', type=int, default=512)
    parser.add_argument('--num_terms', type=int, default=25)

    # parse arguments
    a = parser.parse_args()

    # define model pinout
    build_dir = Path(a.output).resolve()
    m = MixedSignalModel(module_name, dt=a.dt, build_dir=build_dir)
    m.add_analog_input('in_')
    m.add_analog_output('out')
    m.add_digital_output('out_valid')
    m.add_analog_input('dt_sig')
    m.add_digital_input('clk')
    m.add_digital_input('cke')
    m.add_digital_input('rst')

    # read in the channel data
    chan = Filter.from_file(get_file('build/adapt_fir/chan.npy'))

    # create a function
    domain = [chan.t_vec[0], chan.t_vec[-1]]
    chan_func = m.make_function(chan.interp, domain=domain, order=a.func_order,
                                numel=a.func_numel, verif_per_seg=10)
    check_func_error(chan_func)

    # create a history of past inputs
    cke_d = m.add_digital_state('cke_d')
    m.set_next_cycle(cke_d, m.cke, clk=m.clk, rst=m.rst)
    value_hist = m.make_history(m.in_, a.num_terms+1, clk=m.clk, rst=m.rst, ce=cke_d)

    # create a history times in the past when the input changed
    time_incr = []
    time_mux = []
    for k in range(a.num_terms+1):
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
    for k in range(a.num_terms):
        step_sig = m.set_from_sync_func(f'step_{k}', chan_func, time_mux[k+1], clk=m.clk, rst=m.rst)
        step.append(step_sig)

    # compute the products to be summed
    prod = []
    for k in range(a.num_terms):
        if k==0:
            prod_sig = m.bind_name(f'prod_{k}', value_hist[k+1]*step[k])
        else:
            prod_sig = m.bind_name(f'prod_{k}', value_hist[k+1]*(step[k]-step[k-1]))
        prod.append(prod_sig)

    # set output (only valid if the current timestep is zero)
    m.set_this_cycle(m.out, sum_op(prod))
    m.set_this_cycle(m.out_valid, m.dt_sig == 0)

    # generate the model
    m.compile_to_file(VerilogGenerator())

if __name__ == '__main__':
    main()