import json
from dragonphy import *
from svreal import get_svreal_header

prj_cfg = {
  "PROJECT": {
    "board_name": "ZC702",
    "plugins": [],
    "emu_clk_freq": 20e6
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
    fpga_top = get_file('verif/fpga_top.sv')
    deps = get_deps(fpga_top, view_order=['fpga'])
    file_list = [fpga_top] + deps
    src_cfg.add_verilog_sources(file_list)

    # Verilog Headers
    header_file_list = [get_file('inc/signals/fpga/signals.sv')] + [get_svreal_header()]
    src_cfg.add_verilog_headers(header_file_list)

    # Write source config
    src_cfg.write_to_file(get_file('emu/source.config'))

if __name__ == '__main__':
    test_emu_build('ARTY_A7')
