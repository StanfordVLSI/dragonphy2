from time import sleep
from dragonphy import *


def test_emu_prog(emu_rate=5e6, sleep_time=1):
    # start TCL interpreter
    tcl = VivadoTCL(cwd=get_dir('emu'), debug=True)

    # program FPGA
    print('Programming FPGA.')
    tcl.source(get_file('emu/program.tcl'))

    # go through reset sequence
    print('Going through the reset sequence.')
    tcl.set_vio(name='$emu_rst', value=1)
    tcl.set_vio(name='$rst_user', value=1)
    tcl.set_vio(name='$emu_rst', value=0)
    tcl.set_vio(name='$rst_user', value=0)

    # wait a bit
    print(f'Waiting {sleep_time:0.3f}s as the emulation runs.')
    sleep(sleep_time)

    # get the number of consecutive correct bits
    print(f'Getting the number of consecutive correct bits.')
    tcl.refresh_hw_vio('$vio_0_i')
    number = int(tcl.get_vio('$number'))

    # check number of correct bits
    expect = int(emu_rate * sleep_time)
    print(f'Making sure that at least {expect} bits were correctly received.')
    assert number >= expect, f'Expected at least {expect} correct bits, got {number}.'

if __name__ == '__main__':
    test_emu_prog()
