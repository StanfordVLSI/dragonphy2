from dragonphy import *

def test_new_asic():
    print('Test New ASIC Config')
    print(get_deps_new_asic('dragonphy_top'))

def test_new_chip_src_config():
    print('Test New Chip Source Config')
    print(get_deps_cpu_sim_new('dragonphy_top'))

def test_cpu_models_config():
    print('Test CPU Simulation Config')
    print(get_deps_cpu_sim('tb'))

def test_fpga_models_config():
    print('Test FPGA Emulation Config')
    print(get_deps_fpga_emu('tb'))

if __name__ == '__main__':
    test_cpu_models_config()
    test_fpga_models_config()
