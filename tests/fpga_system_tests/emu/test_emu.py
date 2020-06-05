import os
import serial
from pathlib import Path

from anasymod.analysis import Analysis
from dragonphy import *
from dragonphy.git_util import get_git_hash_short

THIS_DIR = Path(__file__).resolve().parent
SIMULATOR = 'vivado'

def test_1(board_name):
    # Write project config
    prj = AnasymodProjectConfig()
    prj.set_board_name(board_name)
    prj.write_to_file(THIS_DIR / 'prj.yaml')

    # Build up a configuration of source files for the project
    src_cfg = AnasymodSourceConfig()

    # JTAG-related
    src_cfg.add_verilog_sources([get_file('vlog/chip_src/jtag/jtag_intf.sv')])
    src_cfg.add_edif_files([os.environ['TAP_CORE_LOC']], fileset='fpga')
    src_cfg.add_verilog_sources([get_file('vlog/fpga_models/jtag/tap_core.sv')], fileset='fpga')
    src_cfg.add_verilog_sources([get_file('vlog/fpga_models/jtag/DW_tap.sv')], fileset='fpga')
    src_cfg.add_verilog_sources([os.environ['DW_TAP']], fileset='sim')

    # Verilog Sources
    src_cfg.add_verilog_sources(get_deps_fpga_emu('dragonphy_top'))
    src_cfg.add_verilog_sources([THIS_DIR / 'sim_ctrl.sv'], fileset='sim')

    # Verilog Headers
    header_file_list = [get_file('inc/fpga/iotype.sv')]
    src_cfg.add_verilog_headers(header_file_list)

    # Verilog Defines
    src_cfg.add_defines({'VIVADO': None})
    src_cfg.add_defines({'GIT_HASH': str(get_git_hash_short())}, fileset='sim')

    # Firmware
    src_cfg.add_firmware_files([THIS_DIR / 'main.c'])

    # Write source config
    # TODO: interact directly with anasymod library rather than through config files
    src_cfg.write_to_file(THIS_DIR / 'source.yaml')

    # "models" directory has to exist
    (THIS_DIR / 'build' / 'models').mkdir(exist_ok=True, parents=True)

def test_2():
    # run simulation
    ana = Analysis(input=str(THIS_DIR), simulator_name='vivado')
    ana.set_target(target_name='sim')
    ana.simulate()

def test_3():
    # build bitstream
    ana = Analysis(input=str(THIS_DIR))
    ana.set_target(target_name='fpga')
    ana.build()

def test_4():
    # build ELF
    ana = Analysis(input=str(THIS_DIR))
    ana.set_target(target_name='fpga')
    ana.build_firmware()

def test_5():
    # download program
    ana = Analysis(input=str(THIS_DIR))
    ana.set_target(target_name='fpga')
    ana.program_firmware()

def test_6(ser_port):
    # connect to the CPU
    print('Connecting to the CPU...')
    ser = serial.Serial(
        port=ser_port,
        baudrate=115200
    )

    # read the ID
    print('Sending the ID command...')
    ser.write('ID\n'.encode('utf-8'))
    print('Reading the response...')
    out = ser.readline()

    # quit the program
    print('Quitting the program...')
    ser.write('EXIT\n'.encode('utf-8'))

    # check results
    print('Checking the results...')
    val = int(out.strip())
    print(f'Got ID: {val}')

    if val != 497598771:
        raise Exception('ID mismatch')
    else:
        print('OK!')