import pytest
from dragonphy import *

@pytest.mark.parametrize('process', ['freepdk-45nm', 'tsmc16'])
def test_asic_config(process):
    print(f'Test ASIC Config (process={process})')
    print(get_deps_asic('dragonphy_top', process=process))

def test_cpu_sim_config():
    print('Test CPU Sim Config')
    print(get_deps_cpu_sim('dragonphy_top'))

# def test_fpga_models_config():
#     print('Test FPGA Emulation Config')
#     print(get_deps_fpga_emu('tb'))
