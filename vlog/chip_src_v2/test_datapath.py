from pathlib import Path
from dragonphy import *

THIS_DIR=Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR /'build'

deps = get_deps_cpu_sim(impl_file=THIS_DIR/'test.sv')

def qwrap(s):
    return f'"{s}"'

defines = {
    'WEIGHT_TXT': qwrap(THIS_DIR / 'weight.txt'),
    'CHANNEL_TXT': qwrap(THIS_DIR / 'channel.txt')
}

DragonTester(
    ext_srcs=deps,
    defines=defines,
    dump_waveforms=True,
    num_cycles=100,
    directory=BUILD_DIR
).run()

