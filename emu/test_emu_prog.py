from time import sleep
from anasymod.vivado_tcl import VivadoTCL
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
    # run the loopback test
    tcl.set_vio(name='$lb_mode', value=0b10)
    sleep(0.1)

    # For testing purposes, write to file if necesarry
    if not bitfile_path is None:
        print(f'Writing to file: {bitfile_path}')
        # First delete bitfile if it exists
        if os.path.exists(bitfile_path):
            os.remove(bitfile_path)
        # Write a handful of bits to a file
        iterations = 100
        for i in range(iterations):
            tcl.set_vio(name='$tm_stall', value='0000000')
            sleep(0.1)
            tcl.refresh_hw_vio('$vio_0_i')
            rx_bit = int(tcl.get_vio('$data_rx'))
            tx_bit = int(tcl.get_vio('$mem_rd'))
            write_bits(tx_bit, rx_bit, bitfile_path)
            tcl.set_vio(name='$tm_stall', value='3FFFFFF')
            sleep(0.1)

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
