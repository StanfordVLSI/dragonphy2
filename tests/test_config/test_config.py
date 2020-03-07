import msdsl, svreal
from dragonphy import *


def test_cpu_models_config():
    print('Test CPU Simulation Config')
    deps = get_deps(
        'tb',
        view_order=['tb', 'cpu_models', 'chip_src'],
        includes=[get_dir('inc/cpu')],
        skip={'analog_if'}
    )
    print(deps)


def test_fpga_models_config():
    print('Test FPGA Emulation Config')
    deps = get_deps(
        'tb',
        view_order=['tb', 'fpga_models', 'chip_src'],
        includes=[get_dir('inc/fpga'), svreal.get_svreal_header().parent, msdsl.get_msdsl_header().parent],
        defines={'DT_WIDTH': 27, 'DT_EXPONENT': -46},
        skip={'svreal', 'assign_real', 'comp_real', 'add_sub_real', 'ite_real', 'dff_real', 'mul_real'}
    )
    print(deps)

if __name__ == '__main__':
    test_cpu_models_config()
    test_fpga_models_config()