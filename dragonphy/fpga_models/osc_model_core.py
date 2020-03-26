from pathlib import Path
from argparse import ArgumentParser
from copy import deepcopy
from msdsl import MixedSignalModel, VerilogGenerator
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
    parser.add_argument('--tdel', type=float, default=0.5e-9)

    # parse arguments
    a = parser.parse_args()

    # define model pinout
    build_dir = Path(a.output).resolve()
    m = MixedSignalModel(module_name, dt=a.dt, build_dir=build_dir)
    m.add_real_param('t_lo', default=0.5e-9)
    m.add_real_param('t_hi', default=0.5e-9)
    m.add_digital_input('emu_rst')
    m.add_digital_input('emu_clk')
    m.add_analog_input('emu_dt')
    m.add_analog_output('dt_req', init=a.tdel)
    m.add_digital_output('clk_val')
    m.add_digital_input('clk_i')
    m.add_digital_output('clk_o')

    # determine if the request was granted
    m.bind_name('req_grant', m.dt_req == m.emu_dt)

    # update the clock value
    m.add_digital_state('prev_clk_val')
    m.set_next_cycle(m.prev_clk_val, m.clk_val, clk=m.emu_clk, rst=m.emu_rst)
    m.set_this_cycle(m.clk_val, if_(m.req_grant, ~m.prev_clk_val, m.prev_clk_val))

    # determine arguments for formating time steps
    # TODO: clean this up
    dt_fmt_kwargs = dict(
        range_=m.emu_dt.format_.range_,
        width=m.emu_dt.format_.width,
        exponent=m.emu_dt.format_.exponent
    )
    array_fmt_kwargs = deepcopy(dt_fmt_kwargs)
    array_fmt_kwargs['real_range_hint'] = m.emu_dt.format_.range_
    del array_fmt_kwargs['range_']

    # determine the next period
    dt_req_next_array = array([m.t_hi, m.t_lo], m.prev_clk_val, **array_fmt_kwargs)
    m.bind_name('dt_req_next', dt_req_next_array, **dt_fmt_kwargs)

    # increment the time request
    m.bind_name('dt_req_incr', m.dt_req - m.emu_dt, **dt_fmt_kwargs)

    # determine the next period
    dt_req_imm_array = array([m.dt_req_incr, m.dt_req_next], m.req_grant, **array_fmt_kwargs)
    m.bind_name('dt_req_imm', dt_req_imm_array, **dt_fmt_kwargs)
    m.set_next_cycle(m.dt_req, m.dt_req_imm, clk=m.emu_clk, rst=m.emu_rst)

    # pass through clock input to clock output
    m.set_this_cycle(m.clk_o, m.clk_i)

    # generate the model
    m.compile_to_file(VerilogGenerator())

if __name__ == '__main__':
    main()
