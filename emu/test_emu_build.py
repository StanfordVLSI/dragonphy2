from dragonphy import *
from svreal import get_svreal_header

def test_emu_build():
    print('Attemping to build bitstream for emulator.')

    src_cfg = AnasymodSourceConfig()

    # Verilog Sources
    fpga_top = get_file('verif/fpga_top.sv')
    deps = get_deps(fpga_top, view_order=['fpga'])
    file_list = [fpga_top] + deps
    src_cfg.add_verilog_sources(file_list)

    # Verilog Headers
    header_file_list = [get_file('inc/signals/fpga/signals.sv')] + [get_svreal_header()]
    src_cfg.add_verilog_headers(header_file_list)

    # XCI files
    xci_files = [get_file('emu/clk_wiz_0/clk_wiz_0.xci'),
                 get_file('emu/vio_0/vio_0.xci')]
    src_cfg.add_xci_files(xci_files)

    # XDC files
    xdc_files = [get_file('emu/custom.xdc')]
    src_cfg.add_xdc_files(xdc_files)

    # Write source config
    src_cfg.write_to_file(get_file('emu/source.config'))

if __name__ == '__main__':
    test_emu_build()
