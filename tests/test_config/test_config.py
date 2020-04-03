from dragonphy import *


def test_old_chip_src_config():
    print('Test Old Chip Source Config')
    print(get_deps_cpu_sim_old('butterphy_top'))

def test_new_analog_core_config():
    print('Test New Analog Core Config')
    print(get_deps_cpu_sim_new('analog_core'))

def test_cpu_models_config():
    print('Test CPU Simulation Config')
    print(get_deps_cpu_sim('tb'))

def test_fpga_models_config():
    print('Test FPGA Emulation Config')
    print(get_deps_fpga_emu('tb'))

if __name__ == '__main__':
    test_cpu_models_config()
    test_fpga_models_config()