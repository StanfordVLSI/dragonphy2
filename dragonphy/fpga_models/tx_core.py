from pathlib import Path
from argparse import ArgumentParser

from msdsl import MixedSignalModel, VerilogGenerator, sum_op
from msdsl.expr.extras import if_

from dragonphy import Filter
from dragonphy.files import get_file

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

    # parse arguments
    a = parser.parse_args()

    # define model pinout
    build_dir = Path(a.output).resolve()
    m = MixedSignalModel(module_name, dt=a.dt, build_dir=build_dir)
    m.add_digital_input('in_')
    m.add_analog_output('out')
    m.add_digital_input('clk')

    # define model behavior
    m.set_next_cycle(m.out, if_(m.in_, a.vp, a.vn), clk=m.clk, rst="1'b0")

    # generate the model
    m.compile_to_file(VerilogGenerator())

if __name__ == '__main__':
    main()