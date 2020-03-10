from pathlib import Path
from argparse import ArgumentParser

from msdsl import MixedSignalModel, VerilogGenerator, sum_op
from msdsl.expr.extras import if_

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
    # TODO: make it possible to change this impulse response
    impulse = [0.0, 0.0, 0.3296799539643607, 0.2209910819184177, 0.14813475220501948, 0.0992976939175467,
               0.06656123475804272, 0.0446173299472002, 0.029907890664194543, 0.02004785864685175,
               0.013438481531073656, 0.009008083558558384, 0.006038298985665742, 0.004047592854048414,
               0.0027131826282592577, 0.0018187007042778426, 0.001219111539816573, 0.0008171949034924244,
               0.0005477821253291318, 0.00036718933946812394, 0.0002461343749360688, 0.00016498880553809898,
               0.00011059530372366366, 7.413424908337173e-05, 4.969367325838328e-05, 3.331066534623951e-05,
               2.2328806728369044e-05, 1.4967446754081228e-05, 1.0032979597231711e-05, 6.725307345490989e-06,
               4.508108329433344e-06, 3.021875382919408e-06, 2.025623645792503e-06, 1.35781613549851e-06,
               9.10171374455295e-07, 6.101061176251945e-07, 4.089663608531456e-07, 2.7413834983410843e-07,
               1.8376043128093375e-07, 1.2317830075576445e-07, 8.256888423319585e-08, 5.534757828030723e-08,
               3.7100591220816686e-08, 2.486927001508728e-08, 1.6670370221386052e-08, 1.1174483334230648e-08,
               7.490480183025973e-09, 5.021019021115014e-09, 3.3656897013796373e-09, 2.2560892755704754e-09]

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