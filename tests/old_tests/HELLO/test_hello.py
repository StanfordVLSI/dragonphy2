# general imports
import os
from pathlib import Path
from shutil import which

# AHA imports
import magma as m
import fault

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'
if which('iverilog') is not None:
    SIMULATOR = 'iverilog'
elif 'FPGA_SERVER' in os.environ:
    SIMULATOR = 'vivado'
else:
    SIMULATOR = 'ncsim'

def test_sim():
    class test(m.Circuit):
        name = 'test'
        io = m.IO()

    tester = fault.Tester(test)
    tester.compile_and_run(
        target='system-verilog',
        simulator=SIMULATOR,
        ext_srcs=[THIS_DIR / 'test.sv'],
        ext_test_bench=True,
        disp_type='realtime',
        directory=BUILD_DIR
    )