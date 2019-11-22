from time import sleep
from dragonphy import *

import os

def write_bits(tx_bit, rx_bit, path='./bit_output.log'):
    with open(path, 'a+') as f:
        f.write("tx: " + str(tx_bit) + "\trx: " + str(rx_bit) + "\n")

def test_emu_prog(mock=False, bitfile_path=None):
    # start TCL interpreter
    tcl = VivadoTCL(cwd=get_dir('emu'), debug=True, mock=mock)

    # program FPGA
    print('Programming FPGA.')
    tcl.source(get_file('emu/program.tcl'))

    # reset emulator
    tcl.set_vio(name='$emu_rst', value=0b1)
    tcl.set_vio(name='$tm_stall', value='3FFFFFF')
    sleep(0.1)
    tcl.set_vio(name='$emu_rst', value=0b0)
    sleep(0.1)
    # reset everything else
    tcl.set_vio(name='$prbs_rst', value=0b1)
    tcl.set_vio(name='$lb_mode', value=0b00)
    sleep(0.1)
    # align the loopback tester
    tcl.set_vio(name='$prbs_rst', value=0b0)
    tcl.set_vio(name='$lb_mode', value=0b01)
    sleep(1)

    # halt the emulation
    tcl.set_vio(name='$tm_stall', value='0000000')

    # arm the ILA
    tcl.sendline('run_hw_ila $ila_0_i')

    # resume emulation and wait for ILA to finish capturing
    tcl.set_vio(name='$tm_stall', value='3FFFFFF')
    tcl.sendline('wait_on_hw_ila $ila_0_i')

    # dump ILA data 
    csv_file_path = get_file('emu/ila.csv')
    tcl.sendline('upload_hw_ila_data $ila_0_i')
    tcl.sendline(f'write_hw_ila_data -csv_file -force {{{csv_file_path}}} hw_ila_data_1')

    # run the loopback test
    tcl.set_vio(name='$lb_mode', value=0b10)
    sleep(10.1)

    # halt the emulation
    tcl.set_vio(name='$tm_stall', value='0000000')
    sleep(0.1)

    # get results
    print(f'Reading results from VIO.')
    tcl.refresh_hw_vio('$vio_0_i')
    lb_latency = int(tcl.get_vio('$lb_latency'))
    lb_correct_bits = int(tcl.get_vio('$lb_correct_bits'))
    lb_total_bits = int(tcl.get_vio('$lb_total_bits'))

    # print results
    print(f'Loopback latency: {lb_latency} cycles.')
    print(f'Loopback correct bits: {lb_correct_bits}.')
    print(f'Loopback total bits: {lb_total_bits}.')

    # check results
    assert (lb_total_bits >= 50e6), 'Not enough total bits transmitted.'
    assert (lb_total_bits == lb_correct_bits), 'Bit error detected.'

if __name__ == '__main__':
    test_emu_prog(mock=True, bitfile_path='./bit_output.log')
