from dragonphy import *

def test_loopback():
    srcs = []
    srcs += get_views(signals='beh')
    srcs += get_files('stim/loopback_stim.sv')

    libs = get_views(
        loopback='all',
        tx='all',
        clk_gen='beh',
        prbs21='all',
        chan='all',
        tb='all',
        rx='all',
        rx_cmp='all'
    )

    run_sim(srcs=srcs, libs=libs, cwd=get_dir('tests/build_loopback'),
            top='stim', inc_dirs=get_dirs('src/signals/beh/'))

if __name__ == '__main__':
    test_loopback()
