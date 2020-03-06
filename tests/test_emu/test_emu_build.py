from dragonphy import *

def test_emu_build(board_name='ZC702'):
    # Write project config
    prj = AnasymodProjectConfig()
    prj.set_board_name(board_name)
    prj.write_to_file(get_file('emu/prj.yaml'))

    # Adapts the fir weights and returns the package files needed
    config = 'test_loopback_config'
    build_dir = str(get_dir('emu/pack_dir'))
    packages = adapt_fir(build_dir, config)
    packages = get_files_arr(packages)

    # Build up a configuration of source files for the project
    src_cfg = AnasymodSourceConfig()

    # Verilog Sources
    tb = get_file('verif/tb.sv')
    deps = get_deps(tb, view_order=['fpga', 'syn'])
    file_list = packages + deps + [tb]
    src_cfg.add_verilog_sources(file_list)

    # Simulation source
    src_cfg.add_verilog_sources([get_file('emu/sim_ctrl.sv')], fileset='sim')

    # Verilog Headers
    header_file_list = [get_file('inc/signals/fpga/signals.sv')] 
    src_cfg.add_verilog_headers(header_file_list)

    # Write source config
    # TODO: interact directly with anasymod library rather
    # than through config files
    src_cfg.write_to_file(get_file('emu/source.yaml'))

    # Create empty models folder
    # TODO: fix this
    get_file('emu/build/models').mkdir(exist_ok=True, parents=True)

if __name__ == '__main__':
    test_emu_build('ARTY_A7')
