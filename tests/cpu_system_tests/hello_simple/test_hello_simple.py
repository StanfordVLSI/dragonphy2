# general imports
from pathlib import Path

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'
SIMULATOR = 'ncsim'

def test_sim():
    DragonTester(
        ext_srcs=[THIS_DIR / 'test.sv'],
        directory=BUILD_DIR,
        top_module='test',
        simulator=SIMULATOR
    ).run()