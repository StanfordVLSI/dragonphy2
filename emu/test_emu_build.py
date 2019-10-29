from dragonphy import *
from svreal import get_svreal_header

def test_emu_build():
    print('Attemping to build bitstream for emulator.')

    # build list of files needed to build the bitstream
    fpga_top = get_file('verif/fpga_top.sv')
    deps = get_deps(fpga_top, view_order=['fpga'])
    header_file_list = [get_file('inc/signals/fpga/signals.sv')] + [get_svreal_header()]
    file_list = [fpga_top] + deps + header_file_list

    # start TCL interpreter
    tcl = VivadoTCL(cwd=get_dir('emu'), debug=True)
    tcl.set_var('file_list', file_list)
    tcl.set_var('header_file_list', header_file_list)
    tcl.source(get_file('emu/build.tcl'))

if __name__ == '__main__':
    test_emu_build()
