# general imports
import os
from pathlib import Path

# AHA imports
import magma as m
import fault

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'
if 'FPGA_SERVER' in os.environ:
    SIMULATOR = 'vivado'
else:
    SIMULATOR = 'ncsim'

# test-specific parameters
Nti = 18
Nadc = 8

def test_sim():
    class test(m.Circuit):
        name = 'test'
        io = m.IO()

    def qwrap(s):
        return f'"{s}"'
    defines = {
        'SRAM_IN_TXT': qwrap(BUILD_DIR / 'sram_in.txt'),
        'SRAM_OUT_TXT': qwrap(BUILD_DIR / 'sram_out.txt')
    }

    # determine the config
    deps = []
    cells = ['oneshot_memory', 'sram_recorder']
    for cell in cells:
        deps += get_deps(
            cell,
            view_order=['old_tb', 'old_cpu_models', 'old_chip_src'],
            includes=[get_dir('inc/old_cpu'), get_mlingua_dir() / 'samples'],
            skip={'acore_debug_intf', 'cdr_debug_intf', 'sram_debug_intf',
                  'dcore_debug_intf', 'raw_jtag_ifc_unq1', 'cfg_ifc_unq1'}
        )
    deps = deps + [get_file('vlog/old_pack/const_pack.sv')]
    print(deps)

    tester = fault.Tester(test)
    tester.compile_and_run(
        target='system-verilog',
        simulator=SIMULATOR,
        ext_srcs=deps+[THIS_DIR / 'test.sv'],
        ext_test_bench=True,
        defines=defines,
        disp_type='realtime',
        directory=BUILD_DIR
    )

def read_int_array(filename):
    with open(filename, 'r') as f:
        lines = f.readlines()

    retval = []
    for line in lines:
        tokens = [elem.strip() for elem in line.split(',')]
        tokens = [int(token) for token in tokens]
        retval += tokens

    return retval

def check_sram():
    # read results
    in_ = read_int_array(BUILD_DIR / 'sram_in.txt')
    out = read_int_array(BUILD_DIR / 'sram_out.txt')

    # make sure that input is at least as long as output
    assert len(in_) >= len(out), 'Recorded SRAM input should be at least as long as SRAM output.'

    for k, (sram_in, sram_out) in enumerate(zip(in_[:len(out)], out)):
        assert sram_in == sram_out, f'Data mismatch on line {k//Nti}: {sram_in} != {sram_out}.'

if __name__ == '__main__':
    check_sram()