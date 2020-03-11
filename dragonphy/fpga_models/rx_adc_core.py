from pathlib import Path
from argparse import ArgumentParser

from msdsl import MixedSignalModel, VerilogGenerator, to_sint, min_op, max_op
from msdsl.expr.extras import if_

def clamp(a, min_val, max_val):
    return min_op([max_op([a, min_val]), max_val])

def main():
    print('Running model generator...')

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
    m = MixedSignalModel(Path(__file__).stem, dt=a.dt)
    m.add_analog_input('in_')
    m.add_digital_output('out', width=a.n, signed=True)
    m.add_digital_input('clk_val')
    m.add_digital_input('emu_clk')
    m.add_digital_input('emu_rst')
    m.add_digital_output('emu_stall')

    # determine when sampling should happen
    m.add_digital_state('prev_clk_val')
    m.set_next_cycle(m.prev_clk_val, m.clk_val, clk=m.emu_clk, rst=m.emu_rst)

    # determine when the emulator should stall
    m.set_this_cycle(m.emu_stall, m.clk_val & (~m.prev_clk_val))

    # sample channel value at the right time
    m.add_analog_state('samp_val', range_=30)
    m.set_next_cycle(m.samp_val, if_(m.emu_stall, m.in_, m.samp_val), clk=m.emu_clk, rst=m.emu_rst)

    # define ADC behavior using combinational logic acting on the sampled value
    expr = ((m.samp_val-a.vn)/(a.vp-a.vn) * ((2**a.n)-1)) - (2**(a.n-1))
    clamped = clamp(expr, -(2**(a.n-1)), (2**(a.n-1))-1)
    m.set_this_cycle(m.out, to_sint(clamped, width=a.n))

    # determine the output filename
    filename = Path(a.output).resolve() / f'{m.module_name}.sv'
    print(f'Model will be written to: {filename}')

    # generate the model
    m.compile_to_file(VerilogGenerator(), filename)

if __name__ == '__main__':
    main()
