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

    # model-specific arguments
    parser.add_argument('--vp', type=float, default=+1.0)
    parser.add_argument('--vn', type=float, default=-1.0)
    parser.add_argument('--n', type=int, default=8)

    # parse arguments
    a = parser.parse_args()

    # define model pinout
    m = MixedSignalModel('rx_adc_core', dt=a.dt)
    m.add_analog_input('in_')
    m.add_digital_output('out', width=a.n, signed=True)
    m.add_digital_input('clk')
    m.add_digital_input('rst')

    # define model behavior
    # compute expression for ADC output as an unclamped, real number
    expr = ((m.in_-a.vn)/(a.vp-a.vn) * ((2**a.n)-1)) - (2**(a.n-1))

    # clamp to ADC range
    clamped = clamp(expr, -(2**(a.n-1)), (2**(a.n-1))-1)

    # assign expression to output
    m.set_next_cycle(m.out, to_sint(clamped, width=a.n), clk=m.clk, rst=m.rst)

    # determine the output filename
    filename = Path(a.output).resolve() / f'{m.module_name}.sv'
    print(f'Model will be written to: {filename}')

    # generate the model
    m.compile_to_file(VerilogGenerator(), filename)

if __name__ == '__main__':
    main()
