from pathlib import Path
from argparse import ArgumentParser

from msdsl import MixedSignalModel, VerilogGenerator, to_sint, clamp_op
from msdsl.expr.expr import array
from msdsl.expr.extras import if_

def main():
    module_name = Path(__file__).stem
    print(f'Running model generator for {module_name}...')

    # parse command line arguments
    parser = ArgumentParser()

    # generic arguments
    parser.add_argument('-o', '--output', type=str, default='.')
    parser.add_argument('--dt', type=float, default=0.1e-6)

    # model-specific arguments
    parser.add_argument('--vp', type=float, default=+1.0)
    parser.add_argument('--vn', type=float, default=-1.0)
    parser.add_argument('--n', type=int, default=8)

    # parse arguments
    a = parser.parse_args()

    # define model pinout
    build_dir = Path(a.output).resolve()
    m = MixedSignalModel(module_name, dt=a.dt, build_dir=build_dir)
    # main I/O: input, output, and clock
    m.add_analog_input('in_')
    m.add_digital_input('in_valid')
    m.add_digital_output('out', width=a.n, signed=True)
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
    m.add_digital_state('should_stall')
    m.add_digital_state('armed')

    # combo logic signals
    m.bind_name('pos_edge_active', m.armed & m.clk_val)
    m.bind_name('should_samp', m.pos_edge_active & m.in_valid)

    # update states
    m.set_next_cycle(m.should_stall, m.pos_edge_active & (~m.in_valid), clk=m.emu_clk, rst=m.emu_rst)
    m.set_next_cycle(m.armed, if_(~m.clk_val, 1, if_(m.should_samp, 0, m.armed)),
                     clk=m.emu_clk, rst=m.emu_rst)

    # sample channel value at the right time
    expr = ((m.in_-a.vn)/(a.vp-a.vn) * ((2**a.n)-1)) - (2**(a.n-1))
    expr = clamp_op(expr, -(2**(a.n-1)), (2**(a.n-1))-1)
    expr = to_sint(expr, width=a.n)
    m.set_next_cycle(m.out, expr, clk=m.emu_clk, rst=m.emu_rst, ce=m.should_samp)

    # stall if needed
    dt_req_array = array(
        [m.dt_req_max, 0.0],
        m.should_stall,
        real_range_hint=m.emu_dt.format_.range_,
        width=m.emu_dt.format_.width,
        exponent=m.emu_dt.format_.exponent
    )
    m.set_this_cycle(m.dt_req, dt_req_array)

    # generate the model
    m.compile_to_file(VerilogGenerator())

if __name__ == '__main__':
    main()
