from dragonphy import *

def test_emu_build():
    print('Attemping to build bitstream for emulator.')

    # build list of files needed to build the bitstream
    fpga_top = get_file('verif/fpga_top.sv')
    deps = get_deps(fpga_top, view_order=['fpga', 'syn'])
    file_list = [fpga_top] + deps + [get_file('inc/signals/fpga/signals.sv')]

    # start TCL interpreter
    tcl = VivadoTCL(cwd=get_dir('emu'), debug=True)
    tcl.set_var('file_list', file_list)
    tcl.source(get_file('emu/build.tcl'))

if __name__ == '__main__':
    test_emu_build()
