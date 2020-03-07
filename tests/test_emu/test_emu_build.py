from pathlib import Path
import msdsl, svreal
from dragonphy import *

THIS_DIR = Path(__file__).resolve().parent

def test_emu_build(board_name='ZC702'):
    # Write project config
    prj = AnasymodProjectConfig()
    prj.set_board_name(board_name)
    prj.write_to_file(THIS_DIR / 'prj.yaml')

    # Adapts the fir weights and returns the package files needed
    config = 'test_loopback_config'
    build_dir = str(THIS_DIR / 'pack_dir')
    packages = adapt_fir(build_dir, config)
    packages = get_files_arr(packages)

    # Build up a configuration of source files for the project
    src_cfg = AnasymodSourceConfig()

    # Verilog Sources
    tb = get_file('verif/tb.sv')
    deps = get_deps(
        'tb',
        view_order=['tb', 'fpga_models', 'chip_src'],
        includes=[get_dir('inc/fpga_models'), svreal.get_svreal_header().parent, msdsl.get_msdsl_header().parent],
        defines={'DT_WIDTH': 27, 'DT_EXPONENT': -46},
        skip={'svreal', 'assign_real', 'comp_real', 'add_sub_real', 'ite_real', 'dff_real', 'mul_real'}
    )
    file_list = packages + deps
    src_cfg.add_verilog_sources(file_list)

    # Simulation source
    src_cfg.add_verilog_sources([THIS_DIR / 'sim_ctrl.sv'], fileset='sim')

    # Verilog Headers
    header_file_list = [get_file('inc/fpga_models/signals.sv')] 
    src_cfg.add_verilog_headers(header_file_list)

    # Write source config
    # TODO: interact directly with anasymod library rather
    # than through config files
    src_cfg.write_to_file(THIS_DIR / 'source.yaml')

    # Create empty models folder
    # TODO: fix this
    (THIS_DIR / 'build' / 'models').mkdir(exist_ok=True, parents=True)

if __name__ == '__main__':
    test_emu_build('ARTY_A7')
