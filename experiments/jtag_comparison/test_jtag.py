import serial
import time
import json
import re
from pathlib import Path
from math import exp, ceil, log2

from dragonphy import *
from anasymod.analysis import Analysis

THIS_DIR = Path(__file__).resolve().parent

class DeferredExpr:
    def __invert__(self):
        return DeferredUnaryOp(lambda a: ~a, self)

    def __neg__(self):
        return DeferredUnaryOp(lambda a: -a, self)

    def __add__(self, other):
        if not isinstance(other, DeferredExpr):
            other = DeferredValue(other)
        return DeferredBinaryOp(lambda a, b: a + b, self, other)

    def __sub__(self, other):
        if not isinstance(other, DeferredExpr):
            other = DeferredValue(other)
        return DeferredBinaryOp(lambda a, b: a - b, self, other)

    def __mul__(self, other):
        if not isinstance(other, DeferredExpr):
            other = DeferredValue(other)
        return DeferredBinaryOp(lambda a, b: a * b, self, other)

    def __lshift__(self, other):
        if not isinstance(other, DeferredExpr):
            other = DeferredValue(other)
        return DeferredBinaryOp(lambda a, b: a << b, self, other)

    def __rshift__(self, other):
        if not isinstance(other, DeferredExpr):
            other = DeferredValue(other)
        return DeferredBinaryOp(lambda a, b: a >> b, self, other)

    def __or__(self, other):
        if not isinstance(other, DeferredExpr):
            other = DeferredValue(other)
        return DeferredBinaryOp(lambda a, b: a | b, self, other)
    __ror__= __or__

    def __and__(self, other):
        if not isinstance(other, DeferredExpr):
            other = DeferredValue(other)
        return DeferredBinaryOp(lambda a, b: a & b, self, other)

    def __xor__(self, other):
        if not isinstance(other, DeferredExpr):
            other = DeferredValue(other)
        return DeferredBinaryOp(lambda a, b: a ^ b, self, other)

class DeferredUnaryOp(DeferredExpr):
    def __init__(self, op, data):
        self.op = op
        self.data = data

    @property
    def value(self):
        return self.op(self.data.value)

class DeferredBinaryOp(DeferredExpr):
    def __init__(self, op, lhs, rhs):
        self.op = op
        self.lhs = lhs
        self.rhs = rhs

    @property
    def value(self):
        return self.op(self.lhs.value, self.rhs.value)

class DeferredValue(DeferredExpr):
    def __init__(self, value=None):
        self.value = value

class JtagTester:
    def __init__(self, ser_port='/dev/ttyUSB0', ffe_length=10, bit_bang=False, comm_style='uart',
                 jtag_sleep_us=1, use_batch_mode=False, print_mode='debug',
                 cdr_settling_time=0.1, prbs_test_dur=0.1, use_ffe=True):
        # save settings
        self.ser_port = ser_port
        self.bit_bang = bit_bang
        self.comm_style = comm_style
        self.ffe_length = ffe_length
        self.jtag_sleep_us = jtag_sleep_us
        self.use_batch_mode = use_batch_mode
        self.print_mode = print_mode
        self.cdr_settling_time = cdr_settling_time
        self.prbs_test_dur = prbs_test_dur
        self.use_ffe = use_ffe

        # initialize

        self.jtag_inst_width = 5
        self.sc_bus_width = 32
        self.sc_addr_width = 14

        self.tc_bus_width = 32
        self.tc_addr_width = 14

        self.sc_op_width = 2
        self.tc_op_width = 2

        self.sc_cfg_data = 8
        self.sc_cfg_inst = 9
        self.sc_cfg_addr = 10
        self.tc_cfg_data = 12
        self.tc_cfg_inst = 13
        self.tc_cfg_addr = 14

        self.read = 1
        self.write = 2

        # build register dictionary
        reg_list = json.load(open(get_file('build/all/jtag/reg_list.json'), 'r'))
        self.reg_dict = {elem['name']: elem['addresses'] for elem in reg_list}

        # list of transactions queued up
        self.batch_started = False
        self.uart_batch = []
        self.uart_bytes_total = 0
        self.reg_reads = 0
        self.reg_writes = 0

        # connect UART if desired
        if self.comm_style == 'uart':
            self.connect_serial()
        elif self.comm_style == 'vio':
            self.connect_vio()

    def start_batch(self):
        self.batch_started = True
        self.uart_batch = []

    def run_batch(self):
        # write all commands as a block
        all_cmds = [f'{cmd}\n' for cmd, _ in self.uart_batch]
        all_cmds = ''.join(all_cmds).encode('utf-8')
        self.ser.write(all_cmds)

        # keep track of how many bits were sent
        self.uart_bytes_total += len(all_cmds)

        # extract all of the deferred values
        for _, deferred_value in self.uart_batch:
            if deferred_value is not None:
                deferred_value.value = int(self.ser.readline().strip())

        # clear the batch flag
        self.batch_started = False

    def get_reg_addr(self, name):
        if '[' in name:
            lbracket = name.index('[')
            rbracket = name.index(']')
            base_name = name[:lbracket]
            index = int(name[(lbracket+1):rbracket])
            return self.reg_dict[base_name][index]
        else:
            return self.reg_dict[name]

    def connect_serial(self):
        # connect to the CPU
        print('Connecting to the CPU...')
        self.ser = serial.Serial(
            port=self.ser_port,
            baudrate=115200
        )

    def connect_vio(self):
        # Create analysis object
        self.ana = Analysis(input=get_dir('tests/fpga_system_tests/emu_macro'))

        # Select the "FPGA" target (as opposed to CPU simulation)
        self.ana.set_target(target_name='fpga')

        # Start the interactive control
        self.ctrl = self.ana.launch(debug=False)

    # run a serial command
    def ser_cmd(self, cmd, expect_output=False):
        if self.batch_started:
            if expect_output:
                deferred_value = DeferredValue()
                self.uart_batch.append((cmd, deferred_value))
                return deferred_value
            else:
                self.uart_batch.append((cmd, None))
        else:
            # send the command
            cmd_bytes = f'{cmd}\n'.encode('utf-8')
            self.ser.write(cmd_bytes)

            # keep track of how many bytes have been sent
            self.uart_bytes_total += len(cmd_bytes)

            # read output if needed
            if expect_output:
                return int(self.ser.readline().strip())

    # functions
    def do_reset(self):
        if self.bit_bang:
            # initialize JTAG signals
            self.set_tdi(0)
            self.set_tck(0)
            self.set_tms(1)
            self.set_trst_n(0)
            self.cycle_tck()

            # de-assert reset
            self.set_trst_n(1)
            self.cycle_tck()

            # go to the IDLE state
            self.set_tms(1)
            self.cycle_tck()
            for _ in range(10):
                self.cycle_tck()

            self.set_tms(0)
            self.cycle_tck()
        else:
            self.ser_cmd('RESET')

    def do_init(self):
        if self.comm_style == 'uart':
            self.ser_cmd('INIT')
        elif self.comm_style == 'vio':
            # emulator control signal
            self.set_emu_rst(1)

            # JTAG-specific
            self.set_tdi(0)
            self.set_tck(0)
            self.set_tms(1)
            self.set_trst_n(0)

            # Other signals
            self.set_rstb(0)

    def cycle_tck(self):
        self.set_tck(1)
        self.set_tck(0)

    def set_emu_rst(self, val):
        if self.comm_style == 'uart':
            self.ser_cmd(f'SET_EMU_RST {val}')
        elif self.comm_style == 'vio':
            self.ctrl.set_reset(val)

    def set_rstb(self, val):
        if self.comm_style == 'uart':
            self.ser_cmd(f'SET_RSTB {val}')
        elif self.comm_style == 'vio':
            self.ctrl.set_param(name='rstb', value=val)

    def set_sleep(self, val):
        if self.comm_style == 'uart':
            self.ser_cmd(f'SET_SLEEP {val}')

    def set_tdi(self, val):
        if self.comm_style == 'uart':
            self.ser_cmd(f'SET_TDI {val}')
        elif self.comm_style == 'vio':
            self.ctrl.set_param(name='tdi', value=val)

    def set_tck(self, val):
        if self.comm_style == 'uart':
            self.ser_cmd(f'SET_TCK {val}')
        elif self.comm_style == 'vio':
            self.ctrl.set_param(name='tck', value=val)

    def set_tms(self, val):
        if self.comm_style == 'uart':
            self.ser_cmd(f'SET_TMS {val}')
        elif self.comm_style == 'vio':
            self.ctrl.set_param(name='tms', value=val)

    def set_trst_n(self, val):
        if self.comm_style == 'uart':
            self.ser_cmd(f'SET_TRST_N {val}')
        elif self.comm_style == 'vio':
            self.ctrl.set_param(name='trst_n', value=val)

    def get_tdo(self):
        if self.comm_style == 'uart':
            return self.ser_cmd(f'GET_TDO', expect_output=True)
        elif self.comm_style == 'vio':
            self.ctrl.refresh_param('vio_0_i')
            return int(self.ctrl.get_param('tdo'))
        else:
            return 0  # dummy value

    def shift_ir(self, val, width):
        if self.bit_bang:
            # Move to Select-DR-Scan state
            self.set_tms(1)
            self.cycle_tck()

            # Move to Select-IR-Scan state
            self.set_tms(1)
            self.cycle_tck()

            # Move to Capture IR state
            self.set_tms(0)
            self.cycle_tck()

            # Move to Shift-IR state
            self.set_tms(0)
            self.cycle_tck()

            # Remain in Shift-IR state and shift in inst_in.
            # Observe the TDO signal to read the x_inst_out
            for i in range(width-1):
                self.set_tdi((val >> i) & 1)
                self.cycle_tck()

            # Shift in the last bit and switch to Exit1-IR state
            self.set_tdi((val >> (width - 1)) & 1)
            self.set_tms(1)
            self.cycle_tck()

            # Move to Update-IR state
            self.set_tms(1)
            self.cycle_tck()

            # Move to Run-Test/Idle state
            self.set_tms(0)
            self.cycle_tck()
            self.cycle_tck()
        else:
            self.ser_cmd(f'SIR {val} {width}')

    def shift_dr(self, val, width, expect_output=False):
        if self.bit_bang:
            # Move to Select-DR-Scan state
            self.set_tms(1)
            self.cycle_tck()

            # Move to Capture-DR state
            self.set_tms(0)
            self.cycle_tck()

            # Move to Shift-DR state
            self.set_tms(0)
            self.cycle_tck()

            # Remain in Shift-DR state and shift in data_in.
            # Observe the TDO signal to read the data_out
            if expect_output:
                retval = 0
            else:
                retval = None
            for i in range(width-1):
                self.set_tdi((val >> i) & 1)
                if expect_output:
                    retval |= (self.get_tdo() << i)
                self.cycle_tck()

            # Shift in the last bit and switch to Exit1-DR state
            self.set_tdi((val >> (width - 1)) & 1)
            if expect_output:
                retval |= (self.get_tdo() << (width-1))
            self.set_tms(1)
            self.cycle_tck()

            # Move to Update-DR state
            self.set_tms(1)
            self.cycle_tck()

            # Move to Run-Test/Idle state
            self.set_tms(0)
            self.cycle_tck()
            self.cycle_tck()

            # Return result
            return retval
        else:
            if expect_output:
                return self.ser_cmd(f'SDR {val} {width}', expect_output=True)
            else:
                self.ser_cmd(f'QSDR {val} {width}')

    def write_tc_reg(self, name, val):
        # update stats
        self.reg_writes += 1

        # print action
        self.print(f'Writing TC register {name} with value {val}...')

        # specify address
        self.shift_ir(self.tc_cfg_addr, self.jtag_inst_width)
        self.shift_dr(self.get_reg_addr(name), self.tc_addr_width)

        # send data
        self.shift_ir(self.tc_cfg_data, self.jtag_inst_width)
        self.shift_dr(val, self.tc_bus_width)

        # specify "WRITE" operation
        self.shift_ir(self.tc_cfg_inst, self.jtag_inst_width)
        self.shift_dr(self.write, self.tc_op_width)

    def write_sc_reg(self, name, val):
        # update stats
        self.reg_writes += 1

        # print action
        self.print(f'Writing SC register {name} with value {val}...')

        # specify address
        self.shift_ir(self.sc_cfg_addr, self.jtag_inst_width)
        self.shift_dr(self.get_reg_addr(name), self.sc_addr_width)

        # send data
        self.shift_ir(self.sc_cfg_data, self.jtag_inst_width)
        self.shift_dr(val, self.sc_bus_width)

        # specify "WRITE" operation
        self.shift_ir(self.sc_cfg_inst, self.jtag_inst_width)
        self.shift_dr(self.write, self.sc_op_width)

    def read_tc_reg(self, name):
        # update stats
        self.reg_reads += 1

        # print action
        self.print(f'Reading TC register {name}...')

        # specify address
        self.shift_ir(self.tc_cfg_addr, self.jtag_inst_width)
        self.shift_dr(self.get_reg_addr(name), self.tc_addr_width)

        # specify "READ" operation
        self.shift_ir(self.tc_cfg_inst, self.jtag_inst_width)
        self.shift_dr(self.read, self.tc_op_width)

        # get data
        self.shift_ir(self.tc_cfg_data, self.jtag_inst_width)
        return self.shift_dr(0, self.tc_bus_width, expect_output=True)

    def read_sc_reg(self, name):
        # update stats
        self.reg_reads += 1

        # print action
        self.print(f'Reading SC register {name}...')

        # specify address
        self.shift_ir(self.sc_cfg_addr, self.jtag_inst_width)
        self.shift_dr(self.get_reg_addr(name), self.sc_addr_width)

        # specify "READ" operation
        self.shift_ir(self.sc_cfg_inst, self.jtag_inst_width)
        self.shift_dr(self.read, self.sc_op_width)

        # get data
        self.shift_ir(self.sc_cfg_data, self.jtag_inst_width)
        return self.shift_dr(0, self.sc_bus_width, expect_output=True)

    def load_weight(
        self,
        d_idx, # clog2(ffe_length)
        w_idx, # 4 bits
        value, # 10 bits
    ):
        self.print(f'Loading weight d_idx={d_idx}, w_idx={w_idx} with value {value}')

        # determine number of bits for d_idx
        d_idx_bits = int(ceil(log2(self.ffe_length)))

        # write wme_ffe_inst
        wme_ffe_inst = 0
        wme_ffe_inst |= d_idx & ((1<<d_idx_bits)-1)
        wme_ffe_inst |= (w_idx & 0b1111) << d_idx_bits
        self.write_tc_reg('wme_ffe_inst', wme_ffe_inst)

        # write wme_ffe_data
        wme_ffe_data = value & 0b1111111111
        self.write_tc_reg('wme_ffe_data', wme_ffe_data)

        # pulse wme_ffe_exec
        self.write_tc_reg('wme_ffe_exec', 1)
        self.write_tc_reg('wme_ffe_exec', 0)

    def print(self, *args, **kwargs):
        if self.print_mode == 'debug':
            print(*args, **kwargs)

    def run_test(self):
        # record starting time
        start_time = time.time()

        # Start a batch if running in batch mode
        if self.use_batch_mode:
            self.start_batch()

        # Initialize
        if (self.comm_style == 'uart') and not self.bit_bang:
            self.set_sleep(self.jtag_sleep_us)
        self.do_init()

        # Clear emulator reset
        self.set_emu_rst(0)

        # Reset JTAG
        self.print('Reset JTAG')
        self.do_reset()

        # Release other reset signals
        self.print('Release other reset signals')
        self.set_rstb(1)

        # Soft reset
        self.print('Soft reset')
        self.write_tc_reg('int_rstb', 1)
        self.write_tc_reg('en_inbuf', 1)
        self.write_tc_reg('en_gf', 1)
        self.write_tc_reg('en_v2t', 1)

        # read the ID
        self.print('Reading ID...')
        self.shift_ir(1, 5)
        id_result = self.shift_dr(0, 32, expect_output=True)

        # Set PFD offset
        self.print('Set PFD offset')
        for k in range(16):
            self.write_tc_reg(f'ext_pfd_offset[{k}]', 0)

        # Configure PRBS checker
        self.print('Configure the PRBS checker')
        if self.use_ffe:
            # use FFE data
            self.write_tc_reg('sel_prbs_mux', 1)
        else:
            # use ADC data instead
            self.write_tc_reg('sel_prbs_mux', 0)

        # Release the PRBS checker from reset
        self.print('Release the PRBS checker from reset')
        self.write_tc_reg('prbs_rstb', 1)

        # Set up the FFE
        if self.use_ffe:
            dt=1.0/(16.0e9)
            tau=25.0e-12
            coeff0 = 128.0/(1.0-exp(-dt/tau))
            coeff1 = -128.0*exp(-dt/tau)/(1.0-exp(-dt/tau))
            for loop_var in range(16):
                for loop_var2 in range(self.ffe_length):
                    if (loop_var2 == 0):
                        # The argument order for load() is depth, width, value
                        self.load_weight(loop_var2, loop_var, int(round(coeff0)))
                    elif (loop_var2 == 1):
                        self.load_weight(loop_var2, loop_var, int(round(coeff1)))
                    else:
                        self.load_weight(loop_var2, loop_var, 0)
                self.write_tc_reg(f'ffe_shift[{loop_var}]', 7)

        # Configure the CDR offsets
        self.print('Configure the CDR offsets')
        ext_pi_ctl_offset = [0, 128, 256, 384]
        for k in range(4):
            self.write_tc_reg(f'ext_pi_ctl_offset[{k}]', ext_pi_ctl_offset[k])
        self.write_tc_reg('en_ext_max_sel_mux', 1)

        # Configure the retimer
        self.print('Configuring the retimer...')
        self.write_tc_reg('retimer_mux_ctrl_1', 0xffff)
        self.write_tc_reg('retimer_mux_ctrl_2', 0xffff)

        # Configure the CDR
        self.print('Configuring the CDR...')
        self.write_tc_reg('cdr_rstb', 0)
        self.write_tc_reg('Kp', 18)
        self.write_tc_reg('Ki', 0)
        self.write_tc_reg('invert', 1)
        self.write_tc_reg('en_freq_est', 0)
        self.write_tc_reg('en_ext_pi_ctl', 0)
        if self.use_ffe:
            # use FFE data
            self.write_tc_reg('sel_inp_mux', 1)
        else:
            # use ADC data instead
            self.write_tc_reg('sel_inp_mux', 0)

        # Re-initialize ordering
        self.print('Re-initialize ADC ordering')
        self.write_tc_reg('en_v2t', 0)
        self.write_tc_reg('en_v2t', 1)

        # Release the CDR from reset, then wait for it to lock
        # TODO: explore why it is not sufficient to pulse cdr_rstb low here
        # (i.e., seems that it must be set to zero while configuring CDR parameters
        self.print('Wait for the CDR to lock')
        self.write_tc_reg('cdr_rstb', 1)
        if self.use_batch_mode:
            self.run_batch()
        time.sleep(self.cdr_settling_time)
        if self.use_batch_mode:
            self.start_batch()

        # Run PRBS test
        self.print('Run PRBS test')
        self.write_tc_reg('prbs_checker_mode', 2)
        if self.use_batch_mode:
            self.run_batch()
        time.sleep(self.prbs_test_dur)
        if self.use_batch_mode:
            self.start_batch()
        self.write_tc_reg('prbs_checker_mode', 3)

        # Read out PRBS test results
        self.print('Read out PRBS test results')

        self.print('Reading err_bits...')
        err_bits = 0
        err_bits = err_bits | self.read_sc_reg('prbs_err_bits_upper')
        err_bits = err_bits << 32
        err_bits = err_bits | self.read_sc_reg('prbs_err_bits_lower')

        self.print('Reading total_bits...')
        total_bits = 0
        total_bits = total_bits | self.read_sc_reg('prbs_total_bits_upper')
        total_bits = total_bits << 32
        total_bits = total_bits | self.read_sc_reg('prbs_total_bits_lower')

        # Run batch if needed, converting DeferredValue objects to integers afterwards
        if self.use_batch_mode:
            self.run_batch()
            id_result = id_result.value
            err_bits = err_bits.value
            total_bits = total_bits.value

        # Measure stop time
        stop_time = time.time()
        print(f'Test took {stop_time - start_time} seconds.')
        print(f'Register writes: {self.reg_writes}')
        print(f'Register reads: {self.reg_reads}')
        if self.comm_style == 'uart':
            print(f'Total bytes transmitted (UART): {self.uart_bytes_total}')

        # Print results
        print(f'id_result: {id_result}')
        print(f'err_bits: {err_bits}')
        print(f'total_bits: {total_bits}')

        # Check results
        print('Checking the results...')
        assert id_result == 497598771, 'ID mismatch'
        assert err_bits == 0, 'Bit error detected'
        assert total_bits > 100000, 'Not enough bits detected'

        # Finish test
        print('OK!')

def main():
    # UART-based tests
    t = JtagTester(use_batch_mode=False, bit_bang=False, print_mode='test')
    #t = JtagTester(use_batch_mode=True, bit_bang=False, print_mode='test')
    #t = JtagTester(use_batch_mode=False, bit_bang=True, print_mode='debug')
    #t = JtagTester(use_batch_mode=True, bit_bang=True, print_mode='debug')

    # VIO-based test
    #t = JtagTester(comm_style='vio', bit_bang=True, use_ffe=True, print_mode='debug')

    # Run the test
    t.run_test()

if __name__ == '__main__':
    main()