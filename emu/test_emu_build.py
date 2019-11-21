import json
from dragonphy import *
from svreal import get_svreal_header
from common import adapt_fir

prj_cfg = {
  "PROJECT": {
    "board_name": "ZC702",
    "plugins": [],
    "emu_clk_freq": 20e6,
    "dt": 50e-9
  },
  "TARGET": {
    "fpga": {
    }
  }
}

def test_emu_build(board_name='ZC702'):
    # Select board
    # TODO: interact directly with anasymod library rather
    # than through config files
    prj_cfg['PROJECT']['board_name'] = board_name 
    with open(get_file('emu/prj_config.json'), 'w') as f:
        f.write(json.dumps(prj_cfg))

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
    header_file_list = [get_file('inc/signals/fpga/signals.sv')] + [get_svreal_header()]
    src_cfg.add_verilog_headers(header_file_list)

    # Verilog defines for simulation
    # TODO: clean up naming / interface (SIMULATION_MODE should be set automatically
    # when running a simulation, DT_MSDSL is essentially obsolete because adaptive
    # timestepping is used now, etc.)
    src_cfg.add_defines({'SIMULATION_MODE_MSDSL': None, 'DT_MSDSL': 50e-9}, fileset='sim')

    # Write source config
    # TODO: interact directly with anasymod library rather
    # than through config files
    src_cfg.write_to_file(get_file('emu/source.config'))

if __name__ == '__main__':
    test_emu_build('ARTY_A7')
