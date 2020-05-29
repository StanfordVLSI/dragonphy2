# general imports
from pathlib import Path
from dragonphy.git_util import get_git_hash_short

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'
SIMULATOR = 'ncsim'

def test_sim(dump_waveforms):
    # determine the git hash

    git_hash_short = get_git_hash_short()
    GIT_HASH = f"28'h{git_hash_short:07x}"
    print(f'GIT_HASH={GIT_HASH}')

    deps = get_deps_cpu_sim(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    # defines

    defines = {
        'DAVE_TIMEUNIT': '1fs',
        'NCVLOG': None,
        'SIMULATION': None,
        'GIT_HASH': GIT_HASH
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
        simulator=SIMULATOR
    ).run()


if __name__=="__main__":
    test_sim()

