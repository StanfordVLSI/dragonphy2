from pathlib import Path
from dragonphy import *

THIS_DIR=Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR /'build'

deps = get_deps_asic(impl_file=THIS_DIR/'test.sv')
DragonTester(
    ext_srcs=deps,
    directory=BUILD_DIR
).run()

