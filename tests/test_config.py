from dragonphy import *

def test_config_1():
    print('Test 1')
    get_deps(get_file('verif/tb.sv'), view_order=['beh'])

def test_config_2():
    print('Test 2')
    get_deps(get_file('verif/tb.sv'), view_order=['beh'], override={'clk_gen': 'beh'})

def test_config_3():
    print('Test 3')
    get_deps(get_file('stim/fpga_stim.sv'), view_order=['fpga_verif', 'fpga'])

def test_config_4():
    print('Test 4')
    get_deps(get_file('verif/fpga_top.sv'), view_order=['fpga'])

if __name__ == '__main__':
    test_config_1()
    test_config_2()
    test_config_3()
    test_config_4()
