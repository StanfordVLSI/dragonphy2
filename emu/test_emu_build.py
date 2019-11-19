import json
from dragonphy import *
from svreal import get_svreal_header

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
    print('Attemping to build bitstream for emulator.')

    src_cfg = AnasymodSourceConfig()

    # Select board
    prj_cfg['PROJECT']['board_name'] = board_name 
    with open(get_file('emu/prj_config.json'), 'w') as f:
        f.write(json.dumps(prj_cfg))

    # Verilog Sources
    tb = get_file('verif/tb.sv')
    deps = get_deps(tb, view_order=['fpga'])
    file_list = [tb] + deps
    src_cfg.add_verilog_sources(file_list)

    # Simulation source
    src_cfg.add_verilog_sources([get_file('emu/sim_ctrl.sv')], fileset='sim')

    # Verilog Headers
    header_file_list = [get_file('inc/signals/fpga/signals.sv')] + [get_svreal_header()]
    src_cfg.add_verilog_headers(header_file_list)

    # Verilog defines
    src_cfg.add_defines({'SIMULATION_MODE_MSDSL': None, 'DT_MSDSL': 50e-9}, fileset='sim')

    # Write source config
    src_cfg.write_to_file(get_file('emu/source.config'))

if __name__ == '__main__':
    test_emu_build('ARTY_A7')
