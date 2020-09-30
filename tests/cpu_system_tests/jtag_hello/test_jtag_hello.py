# general imports
from pathlib import Path
from dragonphy.git_util import get_git_hash_short

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

def test_sim(dump_waveforms):
    # determine the git hash

    git_hash_short = get_git_hash_short()
    GIT_HASH = f"28'h{git_hash_short:07x}"
    print(f'GIT_HASH={GIT_HASH}')

    deps = get_deps_cpu_sim(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    # defines

    defines = {
        'GIT_HASH': GIT_HASH
    }

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        defines=defines,
        dump_waveforms=dump_waveforms
    ).run()


if __name__=="__main__":
    test_sim()

