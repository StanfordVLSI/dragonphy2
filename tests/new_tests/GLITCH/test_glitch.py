# general imports
import os
import pytest
from pathlib import Path

# DragonPHY imports
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'
if 'FPGA_SERVER' in os.environ:
    SIMULATOR = 'vivado'
else:
    SIMULATOR = 'ncsim'

# Set DUMP_WAVEFORMS to True if you want to dump all waveforms for this
# test.  The waveforms are stored in tests/new_tests/GLITCH/build/waves.shm
DUMP_WAVEFORMS = True

@pytest.mark.parametrize((), [pytest.param(marks=pytest.mark.slow) if SIMULATOR=='vivado' else ()])
def test_sim():
    deps = get_deps_cpu_sim_new(impl_file=THIS_DIR / 'test.sv')
    print(deps)

    defines = {
        # how many code transitions should be tested?
        # the codes ramp up and down between min and
        # max, repeating until N_TRIAL transitions
        # have been tested.  as a result, this value
        # should be at least twice the number of codes
        'N_TRIALS': 550,

        # how long should the test monitor for glitches
        # before switching to the next test?  empirically,
        # this value should be at least 2ns to be sure we
        # see glitches that might occur
        'MONITOR_TIME': 5e-9,

        # for the clock waveforms being checked for glitches, how
        # much of a deviation from the nominal period / low / high
        # duration should be tolerated?  this should be higher than
        # the worst-case resolution of the PI
        'WIDTH_TOL': 2e-12,

        # what is the initial code and code change direction?
        # INITIAL_CODE can be 0 through (2**Npi)-1
        # INITIAL_DIR can be either +1 (increasing) or -1 (decreasing)
        'INITIAL_CODE': 0,
        'INITIAL_DIR': +1,

        # PI and CDR clock frequencies.  Probably don't have
        # to change these...
        'PI_CLK_FREQ': 4.0e9,
        'CDR_CLK_FREQ': 1.0e9,

        # options for DaVE
        'DAVE_TIMEUNIT': '1fs',
        'NCVLOG': None
    }
    flags = ['-unbuffered']
    if DUMP_WAVEFORMS:
        defines['DUMP_WAVEFORMS'] = None
        flags += ['-access', '+r']

    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        top_module='test',
        inc_dirs=[get_mlingua_dir() / 'samples', get_dir('inc/new_cpu')],
        defines=defines,
        flags=flags,
        simulator=SIMULATOR,
		num_cycles=1e12
    ).run()
