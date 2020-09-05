import time
import json
import re
import yaml
import numpy as np
from math import exp, ceil, log2

from msdsl.function import PlaceholderFunction
from anasymod.analysis import Analysis

from dragonphy import *

mode = 'emu_macro'

if mode == 'emu_macro':
    cfg_yaml = 'config/fpga/analog_slice_cfg.yml'
    prj_yaml = 'tests/fpga_system_tests/emu_macro/prj.yaml'
    emu_rate = 80e6
    jtag_sleep_us = 1
else:
    cfg_yaml = 'config/fpga/chan.yml'
    prj_yaml = 'tests/fpga_system_tests/emu/prj.yaml'
    emu_rate = 5e6
    jtag_sleep_us = 10

CFG = yaml.load(open(get_file(cfg_yaml), 'r'))

# read ffe_length
SYSTEM = yaml.load(open(get_file('config/system.yml'), 'r'), Loader=yaml.FullLoader)
ffe_length = SYSTEM['generic']['ffe']['parameters']['length']

# read emu_clk_freq
PRJ = yaml.load(open(get_file(prj_yaml), 'r'), Loader=yaml.FullLoader)
emu_clk_freq = PRJ['PROJECT']['emu_clk_freq']

jtag_inst_width = 5
sc_bus_width = 32
sc_addr_width = 14

tc_bus_width = 32
tc_addr_width = 14

sc_op_width = 2
tc_op_width = 2

sc_cfg_data = 8
sc_cfg_inst = 9
sc_cfg_addr = 10
tc_cfg_data = 12
tc_cfg_inst = 13
tc_cfg_addr = 14

read = 1
write = 2

reg_list = json.load(open(get_file('build/all/jtag/reg_list.json'), 'r'))
reg_dict = {elem['name']: elem['addresses'] for elem in reg_list}
arr_pat = re.compile(r'([a-zA-Z_0-9]+)+\[(\d+)\]')
def get_reg_addr(name):
    m = arr_pat.match(name)
    if m:
        name = m.groups()[0]
        index = int(m.groups()[1])
        return reg_dict[name][index]
    else:
        return reg_dict[name]

# connect to the CPU
print('Connecting to the CPU...')
ana = Analysis(input=str(get_file(f'tests/fpga_system_tests/{mode}')))
ana.set_target(target_name='fpga')
ctrl = ana.launch()
ser = ctrl.ctrl_handler

# functions
def do_reset():
    ser.write('RESET\n'.encode('utf-8'))

def do_init():
    ser.write('INIT\n'.encode('utf-8'))

def set_emu_rst(val):
    ser.write(f'SET_EMU_RST {val}\n'.encode('utf-8'))

def set_rstb(val):
    ser.write(f'SET_RSTB {val}\n'.encode('utf-8'))

def set_jitter_rms(val):
    ser.write(f'SET_JITTER_RMS {val}\n'.encode('utf-8'))

def set_noise_rms(val):
    ser.write(f'SET_NOISE_RMS {val}\n'.encode('utf-8'))

def set_prbs_eqn(val):
    ser.write(f'SET_PRBS_EQN {val}\n'.encode('utf-8'))

def set_emu_dec_thr(val):
    ser.write(f'SET_EMU_DEC_THR {val}\n'.encode('utf-8'))

def set_sleep(val):
    ser.write(f'SET_SLEEP {val}\n'.encode('utf-8'))

def shift_ir(val, width):
    ser.write(f'SIR {val} {width}\n'.encode('utf-8'))

def shift_dr(val, width):
    ser.write(f'SDR {val} {width}\n'.encode('utf-8'))
    return int(ser.readline().strip())

def write_tc_reg(name, val):
    # specify address
    shift_ir(tc_cfg_addr, jtag_inst_width)
    shift_dr(get_reg_addr(name), tc_addr_width)

    # send data
    shift_ir(tc_cfg_data, jtag_inst_width)
    shift_dr(val, tc_bus_width)

    # specify "WRITE" operation
    shift_ir(tc_cfg_inst, jtag_inst_width)
    shift_dr(write, tc_op_width)

def write_sc_reg(name, val):
    # specify address
    shift_ir(sc_cfg_addr, jtag_inst_width)
    shift_dr(get_reg_addr(name), sc_addr_width)

    # send data
    shift_ir(sc_cfg_data, jtag_inst_width)
    shift_dr(val, sc_bus_width)

    # specify "WRITE" operation
    shift_ir(sc_cfg_inst, jtag_inst_width)
    shift_dr(write, sc_op_width)

def read_tc_reg(name):
    # specify address
    shift_ir(tc_cfg_addr, jtag_inst_width)
    shift_dr(get_reg_addr(name), tc_addr_width)

    # specify "READ" operation
    shift_ir(tc_cfg_inst, jtag_inst_width)
    shift_dr(read, tc_op_width)

    # get data
    shift_ir(tc_cfg_data, jtag_inst_width)
    return shift_dr(0, tc_bus_width)

def read_sc_reg(name):
    # specify address
    shift_ir(sc_cfg_addr, jtag_inst_width)
    shift_dr(get_reg_addr(name), sc_addr_width)

    # specify "READ" operation
    shift_ir(sc_cfg_inst, jtag_inst_width)
    shift_dr(read, sc_op_width)

    # get data
    shift_ir(sc_cfg_data, jtag_inst_width)
    return shift_dr(0, sc_bus_width)

def load_weight(
        d_idx, # clog2(ffe_length)
        w_idx, # 4 bits
        value, # 10 bits
):
    print(f'Loading weight d_idx={d_idx}, w_idx={w_idx} with value {value}')

    # determine number of bits for d_idx
    d_idx_bits = int(ceil(log2(ffe_length)))

    # write wme_ffe_inst
    wme_ffe_inst = 0
    wme_ffe_inst |= d_idx & ((1<<d_idx_bits)-1)
    wme_ffe_inst |= (w_idx & 0b1111) << d_idx_bits
    write_tc_reg('wme_ffe_inst', wme_ffe_inst)

    # write wme_ffe_data
    wme_ffe_data = value & 0b1111111111
    write_tc_reg('wme_ffe_data', wme_ffe_data)

    # pulse wme_ffe_exec
    write_tc_reg('wme_ffe_exec', 1)
    write_tc_reg('wme_ffe_exec', 0)

def update_chan(coeff_tuples, offset=0):
    # put together the command
    args = ['UPDATE_CHAN', offset, len(coeff_tuples)]
    for coeff_tuple in coeff_tuples:
        args += coeff_tuple
    cmd = ' '.join(str(elem) for elem in args)
    ser.write((cmd + '\n').encode('utf-8'))

    # stall until confirmation is received
    assert ser.readline().decode('utf-8').strip() == 'OK', 'Serial error'

# Initialize
set_sleep(jtag_sleep_us)
do_init()

# Clear emulator reset.  A bit of delay is added just in case
# the MT19937 generator is being used, because it takes awhile
# to start up (LCG and LFSR start almost immediately)
set_emu_rst(0)
time.sleep(10*20e3/emu_clk_freq)

# Reset JTAG
print('Reset JTAG')
do_reset()

# Release other reset signals
print('Release other reset signals')
set_rstb(1)

# Configure noise
set_jitter_rms(0)
set_noise_rms(0)

# Configure step response function
chan_delay = 19.5694716243e-12
chan_tau = 100e-12
placeholder = PlaceholderFunction(domain=CFG['func_domain'], order=CFG['func_order'],
                                  numel=CFG['func_numel'], coeff_widths=CFG['func_widths'],
                                  coeff_exps=CFG['func_exps'], real_type=get_dragonphy_real_type())
chan_func = lambda t_vec: (1-np.exp(-(t_vec-chan_delay)/chan_tau))*np.heaviside(t_vec-chan_delay, 0)
coeffs_bin = placeholder.get_coeffs_bin_fmt(chan_func)
coeff_tuples = list(zip(*coeffs_bin))
chunk_size = 32
for k in range(len(coeff_tuples)//chunk_size):
    print(f'Updating channel at chunk {k}...')
    update_chan(coeff_tuples[(k*chunk_size):((k+1)*chunk_size)], offset=k*chunk_size)

# Soft reset
print('Soft reset')
write_tc_reg('int_rstb', 1)
write_tc_reg('en_inbuf', 1)
write_tc_reg('en_gf', 1)
write_tc_reg('en_v2t', 1)

# read the ID
print('Reading ID...')
shift_ir(1, 5)
id_result = shift_dr(0, 32)
print(f'ID: {id_result}')

# Set PFD offset
print('Set PFD offset')
for k in range(16):
    write_tc_reg(f'ext_pfd_offset[{k}]', 0)

# Set the equation for the PRBS checker
print('Setting the PRBS equation')
write_tc_reg('prbs_eqn', 0x100002)  # matches equation used by prbs21 in DaVE

# Configure PRBS checker
print('Configure the PRBS checker')
write_tc_reg('sel_prbs_mux', 1) # "0" is ADC, "1" is FFE, "3" is BIST

# Release the PRBS checker from reset
print('Release the PRBS checker from reset')
write_tc_reg('prbs_rstb', 1)

# Set up the FFE
dt=1.0/(16.0e9)
coeff0 = 128.0/(1.0-exp(-dt/chan_tau))
coeff1 = -128.0*exp(-dt/chan_tau)/(1.0-exp(-dt/chan_tau))
for loop_var in range(16):
    for loop_var2 in range(ffe_length):
        if (loop_var2 == 0):
            # The argument order for load() is depth, width, value
            load_weight(loop_var2, loop_var, int(round(coeff0)))
        elif (loop_var2 == 1):
            load_weight(loop_var2, loop_var, int(round(coeff1)))
        else:
            load_weight(loop_var2, loop_var, 0)
    write_tc_reg(f'ffe_shift[{loop_var}]', 7)

# Configure the CDR offsets
print('Configure the CDR offsets')
write_tc_reg('ext_pi_ctl_offset[0]', 0)
write_tc_reg('ext_pi_ctl_offset[1]', 128)
write_tc_reg('ext_pi_ctl_offset[2]', 256)
write_tc_reg('ext_pi_ctl_offset[3]', 384)
write_tc_reg('en_ext_max_sel_mux', 1)

# Configure the retimer
print('Configuring the retimer...')
write_tc_reg('retimer_mux_ctrl_1', 0b1111111111111111)
write_tc_reg('retimer_mux_ctrl_2', 0b1111111111111111)
#write_tc_reg('retimer_mux_ctrl_1', 0b0000111111110000)
#write_tc_reg('retimer_mux_ctrl_2', 0b1111000000000000)

# Configure the CDR
print('Configuring the CDR...')
write_tc_reg('cdr_rstb', 0)
write_tc_reg('Kp', 18)
write_tc_reg('Ki', 0)
write_tc_reg('invert', 1)
write_tc_reg('en_freq_est', 0)
write_tc_reg('en_ext_pi_ctl', 0)
write_tc_reg('sel_inp_mux', 1) # "0": use ADC output, "1": use FFE output

# Re-initialize ordering
print('Re-initialize ADC ordering')
write_tc_reg('en_v2t', 0)
write_tc_reg('en_v2t', 1)

# jitter

# no noise case
#set_noise_rms(0)
#for k, n_req in [(6, 2.5e9), (7, 125e6), (8, 10*emu_rate), (9, 10*emu_rate), (10, 10*emu_rate)]:

# 30 mV rms noise case
set_noise_rms(300)
for k, n_req in [(6, 10*emu_rate), (7, 10*emu_rate), (8, 10*emu_rate), (9, 10*emu_rate), (10, 10*emu_rate)]:

    print(f'Using jitter={k} ps')
    set_jitter_rms(k*10)

# noise
# for k in range(0, 51, 5):
#     print(f'Using noise={k} mV')
#     set_noise_rms(k*10)

    # Release the CDR from reset, then wait for it to lock
    write_tc_reg('cdr_rstb', 1)
    write_tc_reg('prbs_checker_mode', 0)
    time.sleep(1.0)
    t_start = time.time()
    write_tc_reg('prbs_checker_mode', 2)
    time.sleep(n_req/emu_rate)
    write_tc_reg('prbs_checker_mode', 3)
    t_stop = time.time()

    # read error bits
    err_bits = 0
    err_bits |= read_sc_reg('prbs_err_bits_upper')
    err_bits <<= 32
    err_bits |= read_sc_reg('prbs_err_bits_lower')

    # read error bits
    total_bits = 0
    total_bits |= read_sc_reg('prbs_total_bits_upper')
    total_bits <<= 32
    total_bits |= read_sc_reg('prbs_total_bits_lower')

    # print result
    print(f'BER: {err_bits/total_bits:e}')
    print(f'Total bits: {total_bits}')

# finish test
print('OK!')
