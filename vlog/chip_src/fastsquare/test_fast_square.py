from pathlib import Path
from dragonphy import *
import numpy as np
import os

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

Path(BUILD_DIR).mkdir(parents=True, exist_ok=True)


def test_sim():
    deps = get_deps_cpu_sim(impl_file=THIS_DIR / 'tb_fs.sv')
    print(deps)

    def qwrap(s):
        return f'"{s}"'



    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        defines={}
    ).run()

