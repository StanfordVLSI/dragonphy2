import os, pytest
from time import sleep
from pathlib import Path
from argparse import ArgumentParser

import msdsl, svreal
from anasymod.analysis import Analysis
from dragonphy import *

THIS_DIR = Path(__file__).resolve().parent
SIMULATOR = 'xrun' if 'FPGA_SERVER' not in os.environ else 'vivado'

def test_emu_build(board_name='ZC702'):
    # Write project config
    prj = AnasymodProjectConfig()
    prj.set_board_name(board_name)
    prj.write_to_file(THIS_DIR / 'prj.yaml')

    # Build up a configuration of source files for the project
    src_cfg = AnasymodSourceConfig()

    # Verilog Sources
    src_cfg.add_verilog_sources(get_deps_fpga_emu('tb'))
    src_cfg.add_verilog_sources([THIS_DIR / 'sim_ctrl.sv'], fileset='sim')

    # Verilog Headers
    header_file_list = [get_file('inc/fpga/signals.sv')]
    src_cfg.add_verilog_headers(header_file_list)

    # Write source config
    # TODO: interact directly with anasymod library rather than through config files
    src_cfg.write_to_file(THIS_DIR / 'source.yaml')

    # Create empty models folder
    # TODO: fix this
    (THIS_DIR / 'build' / 'models').mkdir(exist_ok=True, parents=True)

def test_emu_sim():
    # create analysis object
    ana = Analysis(input=os.path.dirname(__file__),
                   simulator_name=SIMULATOR)
    # setup project's filesets
    ana.setup_filesets()
    # run the simulation
    ana.simulate()

@pytest.mark.skipif(
    'FPGA_SERVER' not in os.environ,
    reason='The FPGA_SERVER environment variable must be set to run this test.'
)
def test_emu_prog(bitstream=True):
    # create analysis object
    ana = Analysis(input=os.path.dirname(__file__))
    ana.setup_filesets()
    ana.set_target(target_name='fpga')

    # build bitstream if needed
    if bitstream:
        ana.build()

    # start interactive control
    ctrl = ana.launch(debug=True)

    # reset emulator
    ctrl.set_reset(1)
    ctrl.set_param(name='tm_stall', value=0x3FFFFFF)
    sleep(0.1)
    ctrl.set_reset(0)
    sleep(0.1)

    # reset everything else
    ctrl.set_param(name='rx_rstb', value=0b0)
    ctrl.set_param(name='prbs_rst', value=0b1)
    ctrl.set_param(name='lb_mode', value=0b00)
    sleep(0.1)

    # align the loopback tester
    ctrl.set_param(name='rx_rstb', value=0b1)
    ctrl.set_param(name='prbs_rst', value=0b0)
    ctrl.set_param(name='lb_mode', value=0b01)
    sleep(1)

    # run the loopback test
    ctrl.set_param(name='lb_mode', value=0b10)
    sleep(10)

    # halt the emulation
    ctrl.set_param(name='tm_stall', value='0000000')
    sleep(0.1)

    # get results
    print(f'Reading results from VIO.')
    ctrl.refresh_param('vio_0_i')
    lb_latency = int(ctrl.get_param('lb_latency'))
    lb_correct_bits = int(ctrl.get_param('lb_correct_bits'))
    lb_total_bits = int(ctrl.get_param('lb_total_bits'))

    # print results
    print(f'Loopback latency: {lb_latency} cycles.')
    print(f'Loopback correct bits: {lb_correct_bits}.')
    print(f'Loopback total bits: {lb_total_bits}.')

    # check results
    assert (lb_total_bits >= 50e6), 'Not enough total bits transmitted.'
    assert (lb_total_bits == lb_correct_bits), 'Bit error detected.'

if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('--board_name', type=str, default='ARTY_A7')
    parser.add_argument('--build', action='store_true')
    parser.add_argument('--sim', action='store_true')
    parser.add_argument('--prog', action='store_true')
    parser.add_argument('--bitstream', action='store_true')
    args = parser.parse_args()

    if args.build:
        test_emu_build(args.board_name)
    if args.sim:
        test_emu_sim()
    if args.prog:
        test_emu_prog(args.bitstream)
