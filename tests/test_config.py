from dragonphy import *

def test_config_1():
    print('Test 1')
    get_deps(get_file('verif/tb.sv'), view_order=['beh', 'syn'])

def test_config_2():
    print('Test 2')
    get_deps(get_file('verif/tb.sv'), view_order=['beh', 'syn'], override={'clk_gen': 'beh'})

def test_config_3():
    print('Test 3')
    get_deps(get_file('verif/tb.sv'), view_order=['fpga', 'syn'])

if __name__ == '__main__':
    test_config_1()
    test_config_2()
    test_config_3()
