import os
from pathlib import Path

from anasymod.analysis import Analysis
from dragonphy import *
from dragonphy.git_util import get_git_hash_short

THIS_DIR = Path(__file__).resolve().parent
SIMULATOR = 'vivado'

def test_emu_build(board_name):
    # Write project config
    prj = AnasymodProjectConfig()
    prj.set_board_name(board_name)
    prj.write_to_file(THIS_DIR / 'prj.yaml')

    # Build up a configuration of source files for the project
    src_cfg = AnasymodSourceConfig()

    # JTAG-related
    src_cfg.add_verilog_sources([get_file('vlog/chip_src/jtag/jtag_intf.sv')])
    src_cfg.add_edif_files([os.environ['TAP_CORE_LOC']], fileset='fpga')
    src_cfg.add_verilog_sources([get_file('vlog/fpga_models/tap_core.sv')], fileset='fpga')
    src_cfg.add_verilog_sources([get_file('vlog/fpga_models/DW_tap.sv')], fileset='fpga')
    src_cfg.add_verilog_sources([os.environ['DW_TAP']], fileset='sim')

    # Verilog Sources
    src_cfg.add_verilog_sources(get_deps_fpga_emu('dragonphy_top'))
    src_cfg.add_verilog_sources([THIS_DIR / 'sim_ctrl.sv'], fileset='sim')

    # Verilog Headers
    header_file_list = [get_file('inc/fpga/iotype.sv')]
    src_cfg.add_verilog_headers(header_file_list)

    # Verilog Defines
    src_cfg.add_defines({'VIVADO': None})

    git_hash_short = get_git_hash_short()
    GIT_HASH = f"28'h{git_hash_short:07x}"
    src_cfg.add_defines({'GIT_HASH': GIT_HASH}, fileset='sim')

    # Write source config
    # TODO: interact directly with anasymod library rather than through config files
    src_cfg.write_to_file(THIS_DIR / 'source.yaml')

    # "models" directory has to exist
    (THIS_DIR / 'build' / 'models').mkdir(exist_ok=True, parents=True)

def test_emu_sim():
    # create analysis object
    ana = Analysis(input=os.path.dirname(__file__), simulator_name='vivado')
    ana.set_target(target_name='sim')

    # run simulation
    ana.simulate()

def test_emu_prog():
    # create analysis object
    ana = Analysis(input=os.path.dirname(__file__))
    ana.set_target(target_name='fpga')

    # build bitstream if needed
    ana.build()

    # # start interactive control
    ctrl = ana.launch(debug=True)

    def cycle():
        ctrl.set_param(name='tck', value=1)
        ctrl.set_param(name='tck', value=0)

    def do_reset():
        # initialize signals
        ctrl.set_param(name='tdi', value=0)
        ctrl.set_param(name='tck', value=0)
        ctrl.set_param(name='tms', value=1)
        ctrl.set_param(name='trst_n', value=0)
        cycle()

        # de-assert reset
        ctrl.set_param(name='trst_n', value=1)
        cycle()

        # go to the IDLE state
        ctrl.set_param(name='tms', value=1)
        cycle()
        for _ in range(10):
            cycle()
        ctrl.set_param(name='tms', value=0)
        cycle()

    def shift_ir(inst_in, length):
        # Move to Select-DR-Scan state
        ctrl.set_param(name='tms', value=1)
        cycle()

        # Move to Select-IR-Scan state
        ctrl.set_param(name='tms', value=1)
        cycle()

        # Move to Capture IR state
        ctrl.set_param(name='tms', value=0)
        cycle()

        # Move to Shift-IR state
        ctrl.set_param(name='tms', value=0)
        cycle()

        # Remain in Shift-IR state and shift in inst_in.
        # Observe the TDO signal to read the x_inst_out
        for i in range(length-1):
            ctrl.set_param(name='tdi', value=(inst_in >> i) & 1)
            cycle()

        # Shift in the last bit and switch to Exit1-IR state
        ctrl.set_param(name='tdi', value=(inst_in >> (length-1)) & 1)
        ctrl.set_param(name='tms', value=1)
        cycle()

        # Move to Update-IR state
        ctrl.set_param(name='tms', value=1)
        cycle()

        # Move to Run-Test/Idle state
        ctrl.set_param(name='tms', value=0)
        cycle()
        cycle()

    def shift_dr(data_in, length):
        # Move to Select-DR-Scan state
        ctrl.set_param(name='tms', value=1)
        cycle()

        # Move to Capture-DR state
        ctrl.set_param(name='tms', value=0)
        cycle()

        # Move to Shift-DR state
        ctrl.set_param(name='tms', value=0)
        cycle()

        # Remain in Shift-DR state and shift in data_in.
        # Observe the TDO signal to read the data_out
        data_out = 0
        for i in range(length-1):
            ctrl.set_param(name='tdi', value=(data_in >> i) & 1)
            ctrl.refresh_param('vio_0_i')
            data_out |= (int(ctrl.get_param('tdo')) << i)
            cycle()

        # Shift in the last bit and switch to Exit1-DR state
        ctrl.set_param(name='tdi', value=(data_in >> (length-1)) & 1)
        data_out |= (int(ctrl.get_param('tdo')) << (length-1))
        ctrl.set_param(name='tms', value=1)
        cycle()

        # Move to Update-DR state
        ctrl.set_param(name='tms', value=1)
        cycle()

        # Move to Run-Test/Idle state
        ctrl.set_param(name='tms', value=0)
        cycle()
        cycle()

        # Return the output data
        return data_out

    def read_id ():
        shift_ir(1, 5)
        return shift_dr(0, 32)

    # reset emulator
    ctrl.set_reset(1)
    ctrl.set_reset(0)

    # release external reset
    ctrl.set_param(name='rstb', value=1)

    # release JTAG reset
    do_reset()

    # read ID
    jtag_id = read_id()

    # check results
    print('Checking the results...')
    print(f'Got ID: {jtag_id}')

    if jtag_id != 497598771:
        raise Exception('ID mismatch')
    else:
        print('OK!')