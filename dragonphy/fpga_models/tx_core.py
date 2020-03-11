import yaml
from pathlib import Path
from argparse import ArgumentParser

from msdsl import MixedSignalModel, VerilogGenerator, sum_op
from msdsl.expr.extras import if_

from dragonphy.files import get_file

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
    m.add_digital_input('in_')
    m.add_analog_output('out')
    m.add_digital_input('clk')

    # impulse response
    with open(get_file('build/adapt_fir/pulse_resp.yml'), 'r') as f:
        impulse = yaml.safe_load(f)['pulse_resp']

    # save a history of inputs
    i_hist = m.make_history(m.in_, len(impulse), clk=m.clk, rst="1'b0")

    # write output values
    o_expr = sum_op([if_(elem, +weight, -weight)
                     for elem, weight in zip(i_hist, impulse)])
    m.set_this_cycle(m.out, o_expr)

    # determine the output filename
    filename = Path(a.output).resolve() / f'{m.module_name}.sv'
    print(f'Model will be written to: {filename}')

    # generate the model
    m.compile_to_file(VerilogGenerator(), filename)

if __name__ == '__main__':
    main()