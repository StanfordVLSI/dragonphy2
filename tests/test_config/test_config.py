import msdsl, svreal
from dragonphy import *


def test_old_chip_src_config():
    print('Test Old Chip Source Config')
    deps = get_deps(
        'butterphy_top',
        view_order=['old_cpu_models', 'old_chip_src'],
        includes=[get_dir('inc/old_cpu'), get_mlingua_dir() / 'samples'],
        skip={'acore_debug_intf', 'cdr_debug_intf', 'sram_debug_intf',
              'dcore_debug_intf', 'raw_jtag_ifc_unq1', 'cfg_ifc_unq1'}
    )
    print(deps)


def test_new_analog_core_config():
    print('Test New Analog Core Config')
    deps = get_deps(
        'analog_core',
        view_order=['new_cpu_models', 'new_chip_src'],
        includes=[get_dir('inc/old_cpu'), get_mlingua_dir() / 'samples'],
        skip={'snh', 'MUX2D1BWP16P90ULVT', 'PI_delay_unit', 'del_PI'}
    )
    print(deps)


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
        skip={'svreal', 'assign_real', 'comp_real', 'add_sub_real', 'ite_real', 'dff_real', 'mul_real',
              'mem_digital', 'sync_rom_real'}
    )
    print(deps)

if __name__ == '__main__':
    test_cpu_models_config()
    test_fpga_models_config()