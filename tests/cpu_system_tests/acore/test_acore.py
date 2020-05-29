# general imports
from pathlib import Path

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'
SIMULATOR = 'ncsim'

def test_sim():
    deps = get_deps_cpu_sim(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        top_module='test',
        inc_dirs=[get_mlingua_dir() / 'samples', get_dir('inc/cpu')],
        defines={
            'DAVE_TIMEUNIT': '1fs',
            'NCVLOG': None,
            'SIMULATION': None
        },
        simulator=SIMULATOR
    ).run()
