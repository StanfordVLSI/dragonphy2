from pathlib import Path
from argparse import ArgumentParser
from msdsl import MixedSignalModel, VerilogGenerator
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
    parser.add_argument('--tlo', type=float, default=0.5e-9)
    parser.add_argument('--thi', type=float, default=0.5e-9)
    parser.add_argument('--tdel', type=float, default=0.5e-9)

    # parse arguments
    a = parser.parse_args()

    # define model pinout
    build_dir = Path(a.output).resolve()
    m = MixedSignalModel(module_name, dt=a.dt, build_dir=build_dir)
    m.add_digital_input('emu_rst')
    m.add_digital_input('emu_clk')
    m.add_analog_input('emu_dt')
    m.add_analog_output('dt_req', init=a.tdel)
    m.add_digital_output('clk_val')
    m.add_digital_input('clk_i')
    m.add_digital_output('clk_o')

    # determine the next requested timestep, advancing to the next half period
    # if the timestep was granted, otherwise subtracting the actual timestep
    # from the requested timestep
    dt_req_imm = if_(m.dt_req == m.emu_dt,
                     if_(m.clk_val,
                         a.tlo,
                         a.thi),
                     m.dt_req - m.emu_dt)
    m.set_next_cycle(m.dt_req, dt_req_imm, clk=m.emu_clk, rst=m.emu_rst)

    # update the clock value
    clk_val_imm = if_(m.dt_req == m.emu_dt,
                      ~m.clk_val,
                      m.clk_val)
    m.set_next_cycle(m.clk_val, clk_val_imm, clk=m.emu_clk, rst=m.emu_rst)

    # pass through clock input to clock output
    m.set_this_cycle(m.clk_o, m.clk_i)

    # generate the model
    m.compile_to_file(VerilogGenerator())

if __name__ == '__main__':
    main()
