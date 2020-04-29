import os
from pathlib import Path
from dragonphy import *

THIS_DIR = Path(__file__).resolve().parent
SIMULATOR = 'ncsim' if 'FPGA_SERVER' not in os.environ else 'vivado'

def test_loopback():
    deps = get_deps_cpu_sim('loopback_stim')

    DragonTester(
        ext_srcs=deps,
        directory=Path(__file__).parent / 'build',
        top_module='loopback_stim',
        inc_dirs=[get_dir('inc/cpu')],
        simulator=SIMULATOR
    ).run()

if __name__ == '__main__':
    test_loopback()
