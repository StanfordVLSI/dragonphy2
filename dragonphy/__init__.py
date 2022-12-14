# Check versions of critical packages
# TODO: is there a cleaner way to do this?  We currently
# need to define this in two places -- setup.py and here
import pkg_resources
REQUIRED_PACKAGE_VERSIONS = [
    ('justag', '0.0.4.6'),
    ('svinst' , '0.1.8')
]
for name, version in REQUIRED_PACKAGE_VERSIONS:
    assert pkg_resources.get_distribution(name).version == version, (
            f'{name} version does not match {version}.  ' +
            f'Please use pip install -e . to reinstall DragonPHY, ' +
            f'and check there are no errors.'
    )

# Some Quality Of Life Libraries
from .real_type      import get_dragonphy_real_type, add_placeholder_inputs
from .sparams        import s4p_to_impulse, s4p_to_step
from .subprocess_run import subprocess_run
from .enob           import enob
from .remap          import remap
from .cmdparser		 import CmdLineParser
from .packager       import Packager
from .config 		 import Configuration
from .tester     	 import DragonTester
from .directory      import Directory
from .graph.graph    import BuildGraph
from .viterbi        import ViterbiState, create_init_viterbi_state, run_error_viterbi, run_iteration_error_viterbi

# Some analysis libraries
from .analysis.histogram import Histogram

# Some Python Verification Libraries
from .channel   	import Channel, Filter, DelayChannel
from .adaptation 	import Wiener
from .quantizer 	import Quantizer, StaticQuantizer
from .fir           import Fir
from .ffe           import FFEHelper
from .mlsd          import MLSD
from .cdr           import Cdr
from .software_error_corrector import error_checker, flag_applicator, wider_flag_applicator 
# For FPGA emulation
from .files import (get_file, get_files, get_files_arr, get_dir, get_dirs,
                    TOP_DIR, get_mlingua_dir)
from .views import (get_deps, get_deps_cpu_sim, get_deps_fpga_emu,
                    get_deps_asic)
from .anasymod import AnasymodSourceConfig, AnasymodProjectConfig

# Package generation
from .adapt_fir import AdaptFir
