from pathlib import Path
from argparse import ArgumentParser

from msdsl import MixedSignalModel, VerilogGenerator, sum_op
from msdsl.expr.extras import if_

from dragonphy import Filter
from dragonphy.files import get_file

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

    # parse arguments
    a = parser.parse_args()

    # define model pinout
    m = MixedSignalModel(Path(__file__).stem, dt=a.dt)
    m.add_digital_input('in_')
    m.add_analog_output('out')
    m.add_digital_input('clk')

    # define model behavior
    m.set_next_cycle(m.out, if_(m.in_, a.vp, a.vn), clk=m.clk, rst="1'b0")

    # determine the output filename
    filename = Path(a.output).resolve() / f'{m.module_name}.sv'
    print(f'Model will be written to: {filename}')

    # generate the model
    m.compile_to_file(VerilogGenerator(), filename)

if __name__ == '__main__':
    main()