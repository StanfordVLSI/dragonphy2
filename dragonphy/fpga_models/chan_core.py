from pathlib import Path
from argparse import ArgumentParser
from msdsl import MixedSignalModel, VerilogGenerator, to_sint, min_op, max_op

def clamp(a, min_val, max_val):
    return min_op([max_op([a, min_val]), max_val])

def main():
    print('Running model generator...')

    # parse command line arguments
    parser = ArgumentParser()

    # generic arguments
    parser.add_argument('-o', '--output', type=str, default='.')
    parser.add_argument('--dt', type=float, default=0.1e-6)

    # parse arguments
    a = parser.parse_args()

    # define model pinout
    m = MixedSignalModel(Path(__file__).stem, dt=a.dt)
    m.add_analog_input('in_')
    m.add_analog_output('out')
    m.add_analog_input('dt')
    m.add_digital_input('clk')
    m.add_digital_input('rst')

    # define model behavior
    m.set_this_cycle(m.out, m.in_)

    # determine the output filename
    filename = Path(a.output).resolve() / f'{m.module_name}.sv'
    print(f'Model will be written to: {filename}')

    # generate the model
    m.compile_to_file(VerilogGenerator(), filename)

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