from pathlib import Path
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

def test_sim():
    DragonTester(
        ext_srcs=[THIS_DIR / 'test.sv'],
        directory=BUILD_DIR
    ).run()