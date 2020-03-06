from dragonphy import *
from common import adapt_fir

def test_probes():
    build_dir  = 'tests/build_probes'

    # Adapts the fir weights and returns the package files needed
    config = 'test_loopback_config'
    packages = adapt_fir(build_dir, config)

    src = get_file('stim/loopback_stim.sv')
    inc = get_file('inc/signals/beh/signals.sv')
    libs = get_deps(src, view_order=['beh', 'syn'])
    run_sim(srcs=[src, inc] + packages, libs=libs, cwd=get_dir(build_dir),
            top='stim', inc_dirs=get_dirs('inc/signals/beh'),
            probes=['stim'])

if __name__ == '__main__':
    test_probes()
