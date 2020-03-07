from pathlib import Path
from dragonphy import *

THIS_DIR = Path(__file__).resolve().parent

def test_probes():
    build_dir = str(THIS_DIR / 'build')

    # Adapts the fir weights and returns the package files needed
    config = 'test_loopback_config'
    packages = adapt_fir(build_dir, config)
    packages = get_files_arr(packages)

    # Get dependencies for simulation
    INC_DIR = get_dir('inc/cpu_models')
    deps = get_deps(
        'loopback_stim',
        view_order=['tb', 'cpu_models', 'chip_src'],
        includes=[INC_DIR],
        skip={'analog_if'}
    )

    # Run simulation
    run_sim(srcs=packages + deps, cwd=get_dir(build_dir),
            top='stim', inc_dirs=[INC_DIR], probes=['stim'])

if __name__ == '__main__':
    test_probes()
