# general imports
from pathlib import Path

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'
SIMULATOR = 'ncsim'

def test_sim(dump_waveforms):
    deps = get_deps_cpu_sim(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    defines = {
        'DAVE_TIMEUNIT': '1fs',
        'NCVLOG': None
    }
    flags = ['-unbuffered']
    if dump_waveforms:
        defines['DUMP_WAVEFORMS'] = None
        flags += ['-access', '+r']

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        top_module='test',
        inc_dirs=[get_mlingua_dir() / 'samples', get_dir('inc/cpu')],
        defines=defines,
        flags=flags,
        simulator=SIMULATOR,
        num_cycles=1e12
    ).run()
