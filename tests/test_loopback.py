from dragonphy import *

def test_loopback():
    src = get_file('stim/loopback_stim.sv')
    libs = get_deps(src, view_order=['beh'])
    run_sim(srcs=[src], libs=libs, cwd=get_dir('tests/build_loopback'),
            top='stim', inc_dirs=get_dirs('inc/signals/beh'))

if __name__ == '__main__':
    test_loopback()
