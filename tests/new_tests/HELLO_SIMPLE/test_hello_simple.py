# general imports
import os
from pathlib import Path
from shutil import which

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'
if 'FPGA_SERVER' in os.environ:
    SIMULATOR = 'vivado'
else:
    SIMULATOR = 'ncsim'

def test_sim():
    DragonTester(
        ext_srcs=[THIS_DIR / 'test.sv'],
        directory=BUILD_DIR,
        top_module='test',
        simulator=SIMULATOR
    ).run()