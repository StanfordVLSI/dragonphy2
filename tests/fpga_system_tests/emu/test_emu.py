import os
import serial
import time
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

    # connect to the CPU
    print('Connecting to the CPU...')
    ser = serial.Serial(
        port=ser_port,
        baudrate=115200
    )

    # functions
    def set_rstb(val):
        ser.write(f'SET_RSTB {val}\n'.encode('utf-8'))

    def shift_ir(val, width):
        ser.write(f'SIR {val} {width}\n'.encode('utf-8'))

    def shift_dr(val, width):
        ser.write(f'SDR {val} {width}\n'.encode('utf-8'))
        return int(ser.readline().strip())

    def write_tc_reg(addr, val):
        # specify address
        shift_ir(tc_cfg_addr, jtag_inst_width)
        shift_dr(addr, tc_addr_width)

        # send data
        shift_ir(tc_cfg_data, jtag_inst_width)
        shift_dr(val, tc_bus_width)

        # specify "WRITE" operation
        shift_ir(tc_cfg_inst, jtag_inst_width)
        shift_dr(write, tc_op_width)

    def write_sc_reg(addr, val):
        # specify address
        shift_ir(sc_cfg_addr, jtag_inst_width)
        shift_dr(addr, sc_addr_width)

        # send data
        shift_ir(sc_cfg_data, jtag_inst_width)
        shift_dr(val, sc_bus_width)

        # specify "WRITE" operation
        shift_ir(sc_cfg_inst, jtag_inst_width)
        shift_dr(write, sc_op_width)

    def read_tc_reg(addr):
        # specify address
        shift_ir(tc_cfg_addr, jtag_inst_width)
        shift_dr(addr, tc_addr_width)

        # specify "READ" operation
        shift_ir(tc_cfg_inst, jtag_inst_width)
        shift_dr(read, tc_op_width)

        # get data
        shift_ir(tc_cfg_data, jtag_inst_width)
        return shift_dr(0, tc_bus_width)

    def read_sc_reg(addr):
        # specify address
        shift_ir(sc_cfg_addr, jtag_inst_width)
        shift_dr(addr, sc_addr_width)

        # specify "READ" operation
        shift_ir(sc_cfg_inst, jtag_inst_width)
        shift_dr(read, sc_op_width)

        # get data
        shift_ir(sc_cfg_data, jtag_inst_width)
        return shift_dr(0, sc_bus_width)

    # reset sequence
    int_rstb = 4516
    en_inbuf = 4396
    en_gf = 4304
    en_v2t = 4284

    set_rstb(0)
    set_rstb(1)
    write_tc_reg(int_rstb, 1)
    write_tc_reg(en_inbuf, 1)
    write_tc_reg(en_gf, 1)
    write_tc_reg(en_v2t, 1)

    # read the ID
    print('Reading ID...')
    shift_ir(1, 5)
    id_result = shift_dr(0, 32)
    print(f'ID: {id_result}')

    # read the ID
    print('Read/write test of TC register...')
    pd_offset_ext = 4236
    write_tc_reg(pd_offset_ext, 0xCAFE)
    tc_result = read_tc_reg(pd_offset_ext)
    print(f'TC reg: {tc_result}')

    # run PRBS test
    prbs_rstb = 4528
    prbs_gen_rstb = 4532
    prbs_gen_cke = 4116
    sel_prbs_mux = 4568
    prbs_checker_mode = 4112

    write_tc_reg(prbs_rstb, 1)
    write_tc_reg(prbs_gen_rstb, 1)
    write_tc_reg(prbs_gen_cke, 1)
    write_tc_reg(sel_prbs_mux, 0b11)
    write_tc_reg(prbs_checker_mode, 0)
    write_tc_reg(prbs_checker_mode, 2)
    time.sleep(1)
    write_tc_reg(prbs_checker_mode, 3)

    prbs_err_bits_upper = 4096
    prbs_err_bits_lower = 4100

    err_bits = 0
    err_bits |= read_sc_reg(prbs_err_bits_upper)
    err_bits <<= 32
    err_bits |= read_sc_reg(prbs_err_bits_lower)
    print(f'err_bits: {err_bits}')

    prbs_total_bits_upper = 4104
    prbs_total_bits_lower = 4108

    total_bits = 0
    total_bits |= read_sc_reg(prbs_total_bits_upper)
    total_bits <<= 32
    total_bits |= read_sc_reg(prbs_total_bits_lower)
    print(f'total_bits: {total_bits}')

    # check results
    print('Checking the results...')
    assert id_result == 497598771, 'ID mismatch'
    assert tc_result == 0xCAFE, 'TC reg mismatch'
    assert err_bits == 0, 'Bit error detected'
    assert total_bits > 3000000, 'Not enough bits detected'

    # finish test
    print('OK!')