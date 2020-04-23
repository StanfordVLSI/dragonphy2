# general imports
import os
import pytest
from pathlib import Path

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'
if 'FPGA_SERVER' in os.environ:
    SIMULATOR = 'vivado'
else:
    SIMULATOR = 'ncsim'

@pytest.mark.parametrize((), [pytest.param(marks=pytest.mark.slow) if SIMULATOR=='vivado' else ()])
def test_sim():
    deps = get_deps_cpu_sim_new(impl_file=THIS_DIR / 'test.sv')
    deps.insert(0, Directory.path() + '/build/all/adapt_fir/ffe_gpack.sv')
    deps.insert(0, Directory.path() + '/build/all/adapt_fir/cmp_gpack.sv')
    deps.insert(0, Directory.path() + '/build/all/adapt_fir/mlsd_gpack.sv')
    deps.insert(0, Directory.path() + '/build/all/adapt_fir/constant_gpack.sv')
    print(deps)

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        top_module='test',
        inc_dirs=[get_mlingua_dir() / 'samples', get_dir('inc/new_cpu')],
        defines={'DAVE_TIMEUNIT': '1fs', 'NCVLOG': None},
        simulator=SIMULATOR
    ).run()