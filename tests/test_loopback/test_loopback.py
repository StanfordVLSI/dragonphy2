import os
from pathlib import Path
from dragonphy import *

THIS_DIR = Path(__file__).resolve().parent
SIMULATOR = 'ncsim' if 'FPGA_SERVER' not in os.environ else 'vivado'

def test_loopback():
    # get list of packages
    packages = list(get_dir('build/adapt_fir').glob('*.sv'))

    # Get dependencies for simulation
    INC_DIR = get_dir('inc/cpu')
    deps = get_deps(
        'loopback_stim',
        view_order=['tb', 'cpu_models', 'chip_src'],
        includes=[INC_DIR],
        skip={'analog_if', 'clock_intf'}
    )

    # Run simulation
    DragonTester(
        ext_srcs=packages+deps,
        directory=Path(__file__).parent / 'build',
        top_module='loopback_stim',
        inc_dirs=[INC_DIR],
        simulator=SIMULATOR
    ).run()

if __name__ == '__main__':
    test_loopback()
