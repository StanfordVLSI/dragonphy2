from dragonphy import *

def test_loopback():
    src = get_file('stim/loopback_stim.sv')
    inc = get_file('inc/signals/beh/signals.sv')
    libs = get_deps(src, view_order=['beh'])
    run_sim(srcs=[src, inc], libs=libs, cwd=get_dir('tests/build_loopback'),
            top='stim', inc_dirs=get_dirs('inc/signals/beh'))

if __name__ == '__main__':
    test_loopback()
