from time import sleep
from dragonphy import *

LB_RESET = 0b00
LB_ALIGN = 0b01
LB_TEST = 0b10

class EmuCtrl(VivadoTCL):
    def set_vio_var(self, name, value, t_sleep=0.01):
        self.set_vio(name=f'${name}', value=str(value))
        if t_sleep is not None:
            sleep(t_sleep)

    def get_vio_var(self, name):
        self.refresh_hw_vio('$vio_0_i')
        return int(self.get_vio(f'${name}'))

    def stall(self):
        self.set_vio_var('tm_stall', 0)

    def unstall(self):
        self.set_vio_var('tm_stall', (1<<26)-1)

    def run_ila(self, csv_file):
        # halt the emulation
        self.stall()

        # arm the ILA
        self.sendline('run_hw_ila $ila_0_i')

        # resume emulation (thereby triggering the ILA) and wait for ILA to finish capturing
        self.unstall()
        self.sendline('wait_on_hw_ila $ila_0_i')

        # dump ILA data to a CSV file
        self.sendline('upload_hw_ila_data $ila_0_i')
        self.sendline(f'write_hw_ila_data -csv_file -force {{{csv_file}}} hw_ila_data_1')

def test_emu_prog(mock=False):
    # start TCL interpreter
    ctl = EmuCtrl(cwd=get_dir('emu'), debug=True, mock=mock)

    # program FPGA
    print('Programming FPGA.')
    ctl.source(get_file('emu/program.tcl'))

    # initialize VIO outputs
    ctl.set_vio_var('emu_rst', 1)
    ctl.set_vio_var('prbs_rst', 1)
    ctl.set_vio_var('lb_mode', LB_RESET)
    ctl.unstall()

    # release emulator reset
    ctl.set_vio_var('emu_rst', 0)
    
    # release PRBS reset and wait for the loopback tester to align
    ctl.set_vio_var('prbs_rst', 0)
    ctl.set_vio_var('lb_mode', LB_ALIGN)
    sleep(0.1)

    # capture some data with the ILA
    ctl.run_ila(csv_file=get_file('emu/ila.csv'))

    # run the loopback test
    ctl.set_vio_var('lb_mode', LB_TEST)
    sleep(10.1)

    # halt the emulation
    ctl.stall()

    # get results
    print(f'Reading results from VIO.')
    lb_latency = ctl.get_vio_var('lb_latency')
    lb_correct_bits = ctl.get_vio_var('lb_correct_bits')
    lb_total_bits = ctl.get_vio_var('lb_total_bits')

    # print results
    print(f'Loopback latency: {lb_latency} cycles.')
    print(f'Loopback correct bits: {lb_correct_bits}.')
    print(f'Loopback total bits: {lb_total_bits}.')

    # check results
    assert (lb_total_bits >= 50e6), 'Not enough total bits transmitted.'
    assert (lb_total_bits == lb_correct_bits), 'Bit error detected.'

if __name__ == '__main__':
    test_emu_prog(mock=True)
