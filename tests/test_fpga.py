from dragonphy import *
from svreal import get_svreal_header

def test_fpga():
    src = get_file('stim/fpga_stim.sv')
    inc = get_file('inc/signals/fpga/signals.sv')
    libs = get_deps(src, view_order=['fpga_verif', 'fpga'])
    defs = [('EMU', 'stim.fpga_top_i.emu')]
    run_sim(srcs=[src, inc], libs=libs, cwd=get_dir('tests/build_fpga'),
            top='stim', inc_dirs=[get_svreal_header().parent]+get_dirs('inc/signals/fpga'),
            defs=defs)

if __name__ == '__main__':
    test_fpga()
