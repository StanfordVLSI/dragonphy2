from pathlib import Path
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

def test_sim(dump_waveforms):
    deps = get_deps_cpu_sim(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        dump_waveforms=dump_waveforms
    ).run()

if __name__ == "__main__":
    test_sim(dump_waveforms=True)
