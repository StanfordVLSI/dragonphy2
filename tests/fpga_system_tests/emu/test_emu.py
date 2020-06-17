import os
import serial
import time
import json
import re
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
    src_cfg.add_edif_files([os.environ['TAP_CORE_LOC']], fileset='fpga')
    src_cfg.add_verilog_sources([get_file('vlog/fpga_models/jtag/tap_core.sv')], fileset='fpga')
    src_cfg.add_verilog_sources([get_file('vlog/fpga_models/jtag/DW_tap.sv')], fileset='fpga')
    src_cfg.add_verilog_sources([os.environ['DW_TAP']], fileset='sim')
    src_cfg.add_verilog_sources([get_file('vlog/pack/const_pack.sv')], fileset='sim')
    src_cfg.add_verilog_sources([get_file('build/cpu_models/jtag/jtag_reg_pack.sv')], fileset='sim')

    # Verilog Sources
    deps = get_deps_fpga_emu(impl_file=(THIS_DIR / 'tb.sv'))
    deps = [dep for dep in deps if Path(dep).stem != 'tb']  # anasymod already includes tb.sv
    src_cfg.add_verilog_sources(deps)
    src_cfg.add_verilog_sources([THIS_DIR / 'sim_ctrl.sv'], fileset='sim')

    # Verilog Headers
    header_file_list = [get_file('inc/fpga/iotype.sv')]
    src_cfg.add_verilog_headers(header_file_list)

    # Verilog Defines
    src_cfg.add_defines({'VIVADO': None})
    src_cfg.add_defines({'DT_EXPONENT': -46})  # TODO: move to DT_SCALE
    src_cfg.add_defines({'GIT_HASH': str(get_git_hash_short())}, fileset='sim')
    src_cfg.add_defines({'LONG_WIDTH_REAL': 32})

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
    ana.simulate(convert_waveform=False)

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
    jtag_inst_width = 5
    sc_bus_width = 32
    sc_addr_width = 14

    tc_bus_width = 32
    tc_addr_width = 14

    sc_op_width = 2
    tc_op_width = 2

    sc_cfg_data = 8
    sc_cfg_inst = 9
    sc_cfg_addr = 10
    tc_cfg_data = 12
    tc_cfg_inst = 13
    tc_cfg_addr = 14

    read = 1
    write = 2

    reg_list = json.load(open(get_file('build/all/jtag/reg_list.json'), 'r'))
    reg_dict = {elem['name']: elem['addresses'] for elem in reg_list}
    arr_pat = re.compile(r'([a-zA-Z_0-9]+)+\[(\d+)\]')
    def get_reg_addr(name):
        m = arr_pat.match(name)
        if m:
            name = m.groups()[0]
            index = int(m.groups()[1])
            return reg_dict[name][index]
        else:
            return reg_dict[name]

    # connect to the CPU
    print('Connecting to the CPU...')
    ser = serial.Serial(
        port=ser_port,
        baudrate=115200
    )

    # functions
    def do_reset():
        ser.write('RESET\n'.encode('utf-8'))

    def do_init():
        ser.write('INIT\n'.encode('utf-8'))

    def set_emu_rst(val):
        ser.write(f'SET_EMU_RST {val}\n'.encode('utf-8'))

    def set_rstb(val):
        ser.write(f'SET_RSTB {val}\n'.encode('utf-8'))

    def set_sleep(val):
        ser.write(f'SET_SLEEP {val}\n'.encode('utf-8'))

    def shift_ir(val, width):
        ser.write(f'SIR {val} {width}\n'.encode('utf-8'))

    def shift_dr(val, width):
        ser.write(f'SDR {val} {width}\n'.encode('utf-8'))
        return int(ser.readline().strip())

    def write_tc_reg(name, val):
        # specify address
        shift_ir(tc_cfg_addr, jtag_inst_width)
        shift_dr(get_reg_addr(name), tc_addr_width)

        # send data
        shift_ir(tc_cfg_data, jtag_inst_width)
        shift_dr(val, tc_bus_width)

        # specify "WRITE" operation
        shift_ir(tc_cfg_inst, jtag_inst_width)
        shift_dr(write, tc_op_width)

    def write_sc_reg(name, val):
        # specify address
        shift_ir(sc_cfg_addr, jtag_inst_width)
        shift_dr(get_reg_addr(name), sc_addr_width)

        # send data
        shift_ir(sc_cfg_data, jtag_inst_width)
        shift_dr(val, sc_bus_width)

        # specify "WRITE" operation
        shift_ir(sc_cfg_inst, jtag_inst_width)
        shift_dr(write, sc_op_width)

    def read_tc_reg(name):
        # specify address
        shift_ir(tc_cfg_addr, jtag_inst_width)
        shift_dr(get_reg_addr(name), tc_addr_width)

        # specify "READ" operation
        shift_ir(tc_cfg_inst, jtag_inst_width)
        shift_dr(read, tc_op_width)

        # get data
        shift_ir(tc_cfg_data, jtag_inst_width)
        return shift_dr(0, tc_bus_width)

    def read_sc_reg(name):
        # specify address
        shift_ir(sc_cfg_addr, jtag_inst_width)
        shift_dr(get_reg_addr(name), sc_addr_width)

        # specify "READ" operation
        shift_ir(sc_cfg_inst, jtag_inst_width)
        shift_dr(read, sc_op_width)

        # get data
        shift_ir(sc_cfg_data, jtag_inst_width)
        return shift_dr(0, sc_bus_width)

    # Initialize
    do_init()

    # Clear emulator reset
    set_emu_rst(0)

    # Reset JTAG
    print('Reset JTAG')
    do_reset()

    # Release other reset signals
    print('Release other reset signals')
    set_rstb(1)

    # Soft reset
    print('Soft reset')
    write_tc_reg('int_rstb', 1)
    write_tc_reg('en_inbuf', 1)
    write_tc_reg('en_gf', 1)
    write_tc_reg('en_v2t', 1)

    # read the ID
    print('Reading ID...')
    shift_ir(1, 5)
    id_result = shift_dr(0, 32)
    print(f'ID: {id_result}')

    # Set PFD offset
    print('Set PFD offset')
    for k in range(16):
        write_tc_reg(f'ext_pfd_offset[{k}]', 0)

    # Configure PRBS checker
    print('Configure the PRBS checker')
    write_tc_reg('sel_prbs_mux', 0) # "0" is ADC, "3" is BIST

    # Release the PRBS checker from reset
    print('Release the PRBS checker from reset')
    write_tc_reg('prbs_rstb', 1)

    # Configure the CDR offsets
    print('Configure the CDR offsets')
    write_tc_reg('ext_pi_ctl_offset[0]', 0)
    write_tc_reg('ext_pi_ctl_offset[1]', 128)
    write_tc_reg('ext_pi_ctl_offset[2]', 256)
    write_tc_reg('ext_pi_ctl_offset[3]', 384)
    write_tc_reg('en_ext_max_sel_mux', 1)

    # Configure the retimer
    print('Configuring the retimer...')
    write_tc_reg('retimer_mux_ctrl_1', 0xffff)
    write_tc_reg('retimer_mux_ctrl_2', 0xffff)

    # Configure the CDR
    print('Configuring the CDR...')
    write_tc_reg('Kp', 15)
    write_tc_reg('Ki', 0)
    write_tc_reg('invert', 1)
    write_tc_reg('en_freq_est', 0)
    write_tc_reg('en_ext_pi_ctl', 0)

    # Re-initialize ordering
    print('Re-initialize ADC ordering')
    write_tc_reg('en_v2t', 0)
    write_tc_reg('en_v2t', 1)

    # Wait for CDR to lock
    print('Wait for PRBS checker to lock')
    time.sleep(1.0)

    # Run PRBS test
    print('Run PRBS test')
    write_tc_reg('prbs_checker_mode', 2)
    time.sleep(1.0)

    # Read out PRBS test results
    print('Read out PRBS test results')
    write_tc_reg('prbs_checker_mode', 3)

    err_bits = 0
    err_bits |= read_sc_reg('prbs_err_bits_upper')
    err_bits <<= 32
    err_bits |= read_sc_reg('prbs_err_bits_lower')
    print(f'err_bits: {err_bits}')

    total_bits = 0
    total_bits |= read_sc_reg('prbs_total_bits_upper')
    total_bits <<= 32
    total_bits |= read_sc_reg('prbs_total_bits_lower')
    print(f'total_bits: {total_bits}')

    # check results
    print('Checking the results...')
    assert id_result == 497598771, 'ID mismatch'
    assert err_bits == 0, 'Bit error detected'
    assert total_bits > 100000, 'Not enough bits detected'

    # finish test
    print('OK!')
