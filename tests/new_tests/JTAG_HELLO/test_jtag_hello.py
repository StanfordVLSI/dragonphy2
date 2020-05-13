# general imports
import os
import pytest
from pathlib import Path
from dragonphy.git_util import get_git_hash_short

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'
if 'FPGA_SERVER' in os.environ:
    SIMULATOR = 'vivado'
else:
    SIMULATOR = 'ncsim'

# Set DUMP_WAVEFORMS to True if you want to dump all waveforms for this
# test.  The waveforms are stored in tests/new_tests/JTAG_HELLO/build/waves.shm
DUMP_WAVEFORMS = False


def calc_id_code():
    # get short git hash as an int
    git_hash_short = get_git_hash_short()

    # build up ID code, requiring that the repo is clean
    id_code = 0
    id_code |= git_hash_short << 4
    id_code |= 3

    # return the ID code
    return id_code


@pytest.mark.parametrize((), [pytest.param(marks=pytest.mark.slow) if SIMULATOR=='vivado' else ()])
def test_sim():
    # determine the expected JTAG ID
    id_code = calc_id_code()
    EXPECTED_JTAG_ID = f"32'h{id_code:08x}"
    print(f'EXPECTED_JTAG_ID={EXPECTED_JTAG_ID}')

    deps = get_deps_cpu_sim_new(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    # defines

    defines = {
        'DAVE_TIMEUNIT': '1fs',
        'NCVLOG': None,
        'SIMULATION': None,
        'EXPECTED_JTAG_ID': EXPECTED_JTAG_ID
    }

    if DUMP_WAVEFORMS:
        if SIMULATOR == 'ncsim':
            defines['DUMP_WAVEFORMS_NCSIM'] = None
        elif SIMULATOR == 'vivado':
            defines['DUMP_WAVEFORMS_VIVADO'] = None
        else:
            raise Exception(f'Unsupported simulator for waveform dumping: {SIMULATOR}')

    # flags

    flags = []
    if SIMULATOR == 'ncsim':
        flags += ['-unbuffered']
        if DUMP_WAVEFORMS:
            flags += ['-access', '+r']

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        top_module='test',
        inc_dirs=[get_mlingua_dir() / 'samples', get_dir('inc/new_cpu')],
        defines=defines,
        flags=flags,
        simulator=SIMULATOR,
        unbuffered=True
    ).run()


if __name__=="__main__":
    test_sim()

