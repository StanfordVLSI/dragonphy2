import os
import pytest
from time import sleep
from anasymod.analysis import Analysis

@pytest.mark.skipif('FPGA_SERVER' not in os.environ, reason='The FPGA_SERVER environment variable must be set to run this test.')
def test_emu_prog():
    # create analysis object
    ana = Analysis(input=os.path.dirname(__file__))
    ana.setup_filesets()
    ana.set_target(target_name='fpga')      # set the active target to 'fpga'
    ctrl = ana.launch(debug=True)           # start interactive control

    # reset emulator
    ctrl.set_reset(1)
    ctrl.set_param(name='tm_stall', value=0x3FFFFFF)
    sleep(0.1)
    ctrl.set_reset(0)
    sleep(0.1)

    # reset everything else
    ctrl.set_param(name='rx_rstb', value=0b0)
    ctrl.set_param(name='prbs_rst', value=0b1)
    ctrl.set_param(name='lb_mode', value=0b00)
    sleep(0.1)

    # align the loopback tester
    ctrl.set_param(name='rx_rstb', value=0b1)
    ctrl.set_param(name='prbs_rst', value=0b0)
    ctrl.set_param(name='lb_mode', value=0b01)
    sleep(1)

    # run the loopback test
    ctrl.set_param(name='lb_mode', value=0b10)
    sleep(10)

    # halt the emulation
    ctrl.set_param(name='tm_stall', value='0000000')
    sleep(0.1)

    # get results
    print(f'Reading results from VIO.')
    ctrl.refresh_param('vio_0_i')
    lb_latency = int(ctrl.get_param('lb_latency'))
    lb_correct_bits = int(ctrl.get_param('lb_correct_bits'))
    lb_total_bits = int(ctrl.get_param('lb_total_bits'))

    # print results
    print(f'Loopback latency: {lb_latency} cycles.')
    print(f'Loopback correct bits: {lb_correct_bits}.')
    print(f'Loopback total bits: {lb_total_bits}.')

    # check results
    assert (lb_total_bits >= 50e6), 'Not enough total bits transmitted.'
    assert (lb_total_bits == lb_correct_bits), 'Bit error detected.'

if __name__ == "__main__":
    test_emu_prog()
