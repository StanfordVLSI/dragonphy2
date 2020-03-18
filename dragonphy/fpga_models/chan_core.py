# Generic imports
from pathlib import Path
from argparse import ArgumentParser
import numpy as np

# FPGA-specific imports
from msdsl import MixedSignalModel, VerilogGenerator

# DragonPHY imports
from dragonphy import Filter, get_file

def check_error(f):
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
    parser.add_argument('--order', type=int, default=2)
    parser.add_argument('--numel', type=int, default=32)

    # parse arguments
    a = parser.parse_args()

    # define model pinout
    build_dir = Path(a.output).resolve()
    m = MixedSignalModel(module_name, dt=a.dt, build_dir=build_dir)
    m.add_analog_input('in_')
    m.add_analog_output('out')
    m.add_analog_input('dt')
    m.add_digital_input('clk')
    m.add_digital_input('rst')

    # read in the channel data
    chan = Filter.from_file(get_file('build/adapt_fir/chan.npy'))

    # create a function
    domain = [chan.t_vec[0], chan.t_vec[-1]]
    chan_func = m.make_function(chan.interp, domain=domain, order=a.order, numel=a.numel,
                                verif_per_seg=10)

    # check error
    check_error(chan_func)

    # apply function (albeit to
    m.set_from_sync_func('unused_sig', chan_func, m.dt, clk=m.clk, rst=m.rst)

    # define model behavior
    m.set_this_cycle(m.out, m.in_)

    # generate the model
    m.compile_to_file(VerilogGenerator())

if __name__ == '__main__':
    main()

# // update memory
# always @(data_ana_i.value) begin
#     // shift back memory
#     for (int i=(mem_len-2); i>=0; i=i-1) begin
#         t_mem[i+1]=t_mem[i];
#         v_mem[i+1]=v_mem[i];
#     end
#
#     // add new values at index 0
#     t_mem[0] = $realtime;
#     v_mem[0] = data_ana_i.value;
# end
#
# // function to evaluate the step response at specific times
# import step_resp_pack::*;
# function real eval_at(input real t);
#     integer idx;
#     real weight;
#     idx = $floor(t/step_dt);
#     if (idx < 0) begin
#         eval_at = v_step[0];
#     end else if (idx >= (step_len-1)) begin
#         eval_at = v_step[step_len-1];
#     end else begin
#         weight = (t/step_dt) - idx;
#         eval_at = (1-weight)*v_step[idx] + weight*v_step[idx+1];
#     end
# endfunction
#
# // update the output of the transmitter
# real tmp;
# always @(data_ana_o.req) begin
#     // calculate output
#     tmp = 0;
#     for (int i=0; i<(mem_len-1); i=i+1) begin
#         if (i==0) begin
#             tmp += v_mem[i]*eval_at($realtime-t_mem[i]);
#         end else begin
#             tmp += v_mem[i]*(eval_at($realtime-t_mem[i])-eval_at($realtime-t_mem[i-1]));
#         end
#     end
#
#     // assign to the output
#     data_ana_o.value = tmp;
#
#     // acknowledge request
#     ->>data_ana_o.ack;
# end