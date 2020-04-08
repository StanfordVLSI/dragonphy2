import os
from pathlib import Path
from dragonphy import *

THIS_DIR = Path(__file__).resolve().parent
SIMULATOR = 'ncsim' if 'FPGA_SERVER' not in os.environ else 'vivado'

def test_loopback():
    DragonTester(
        ext_srcs=get_deps_cpu_sim('loopback_stim'),
        directory=Path(__file__).parent / 'build',
        top_module='loopback_stim',
        inc_dirs=[get_dir('inc/cpu')],
        simulator=SIMULATOR
    ).run()

if __name__ == '__main__':
    test_loopback()
