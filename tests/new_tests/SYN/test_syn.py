# general imports
import os
import pytest
from pathlib import Path

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

TEMPLATE = '''\
set search_path {inc_dirs}
set file_list {src_files}

set status [analyze -format sverilog $file_list]
if {{$status != 1}} {{
    exit 1
}}

set status [elaborate {top_name}]
if {{$status != 1}} {{
    exit 1
}}

exit 0
'''

def tcl_list(vals):
    retval = ' '.join(f'{{{val}}}' for val in vals)
    retval = f'[list {retval}]'
    return retval

@pytest.mark.skipif('FPGA_SERVER' in os.environ,
                    reason='This test cannot run on FPGA servers.')
def test_sim(run_tcl='run.tcl'):
    src_files = get_deps_new_asic(impl_file=THIS_DIR / 'test.sv')
    src_files = [src_file for src_file in src_files]

    inc_dirs = [get_dir('inc/new_asic')]
    top_name = 'test'

    BUILD_DIR.mkdir(exist_ok=True, parents=True)
    with open(BUILD_DIR / run_tcl, 'w') as f:
        f.write(
            TEMPLATE.format(
                inc_dirs=tcl_list(inc_dirs),
                src_files=tcl_list(src_files),
                top_name=top_name
            )
        )

    args = []
    args += ['dc_shell']
    args += ['-f', run_tcl]
    args += ['-no_init']
    args += ['-no_home_init']
    args += ['-no_local_init']
    args += ['-no_gui']
    args += ['-no_log']

    subprocess_run(args, cwd=BUILD_DIR, err_str='error')