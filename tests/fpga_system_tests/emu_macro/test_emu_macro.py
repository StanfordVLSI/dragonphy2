import os
import time
import json
import re
import yaml
import numpy as np
from datetime import datetime
from tqdm import tqdm

from pathlib import Path
from math import exp, ceil, log2
from scipy import linalg

import matplotlib.pyplot as plt
import matplotlib.animation as animation

from scipy.interpolate import interp1d


from svreal import (RealType, DEF_HARD_FLOAT_WIDTH,
                    get_hard_float_sources, get_hard_float_headers, real2fixed)
from msdsl.function import PlaceholderFunction
from anasymod.analysis import Analysis

from dragonphy import *
from dragonphy.git_util import get_git_hash_short

THIS_DIR = Path(__file__).resolve().parent
CFG = yaml.load(open(get_file('config/fpga/analog_slice_cfg.yml'), 'r'))

real_channels = ["Case4_FM_13SI_20_T_D13_L6.s4p", 
 "peters_01_0605_B12_thru.s4p", 
 "peters_01_0605_B1_thru.s4p",
 "peters_01_0605_T20_thru.s4p",
 "TEC_Whisper42p8in_Meg6_THRU_C8C9.s4p",
 "TEC_Whisper42p8in_Nelco6_THRU_C8C9.s4p",]

def get_real_channel_step(s4p_file, f_sig=16e9, mm_lock_pos=12.5e-12, numel=2048, domain=[0, 4e-9]):
    file_name = str(get_file(f'data/channel_sparam/{s4p_file}'))

    step_size = domain[1]/(numel-1)

    t, imp = s4p_to_impulse(str(file_name), step_size/100.0, 10*domain[1],  zs=50, zl=50)

    cur_pos = np.argmax(imp)

    t_delay = -t[cur_pos] + 2*1/f_sig + mm_lock_pos

    t2, step = s4p_to_step(str(file_name), step_size, 10*domain[1], zs=50, zl=50)

    interp = interp1d(t2, step, bounds_error=False, fill_value=(step[0], step[-1]))
    
    t_step = np.linspace(0, domain[1], numel) - t_delay
    v_step = interp(t_step)

    return v_step

def get_real_channel_pulse(s4p_file, f_sig=16e9, mm_lock_pos=12.5e-12, numel=2048, domain=[0,4e-9]):
    file_name = str(get_file(f'data/channel_sparam/{s4p_file}'))
    
    step_size = domain[1]/(numel-1)
    t, imp = s4p_to_impulse(str(file_name), step_size/100.0, 10*domain[1],  zs=50, zl=50)
    cur_pos = np.argmax(imp)
    t_delay = -t[cur_pos] + 2*1/f_sig + mm_lock_pos

    t, pulse = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=200000, s4p=file_name, zs=50, zl=50).get_pulse_resp(f_sig=f_sig, resp_depth=35, t_delay=t_delay)

    return pulse

def test_1(board_name, emu_clk_freq, fpga_sim_ctrl):
    ########################
    # Write project config #
    ########################

    prj = AnasymodProjectConfig(fpga_sim_ctrl)
    prj.set_board_name(board_name)
    prj.set_emu_clk_freq(emu_clk_freq)

    # uncomment for debug probing
    # prj.config['PROJECT']['cpu_debug_mode'] = 1
    # prj.config['PROJECT']['cpu_debug_hierarchies'] = [[0, 'top']]

    prj.write_to_file(THIS_DIR / 'prj.yaml')

    #######################
    # Write source config #
    #######################

    src_cfg = AnasymodSourceConfig()

    # JTAG-related
    src_cfg.add_edif_files([os.environ['TAP_CORE_LOC']], fileset='fpga')
    src_cfg.add_verilog_sources([get_file('vlog/fpga_models/jtag/tap_core.sv')], fileset='fpga')
    src_cfg.add_verilog_sources([get_file('vlog/fpga_models/jtag/DW_tap.sv')], fileset='fpga')
    src_cfg.add_verilog_sources([os.environ['DW_TAP']], fileset='sim')
    src_cfg.add_verilog_sources([get_file('build/cpu_models/jtag/jtag_reg_pack.sv')], fileset='sim')

    # Verilog Sources
    deps = get_deps_fpga_emu(impl_file=(THIS_DIR / 'tb.sv'))
    deps = [dep for dep in deps if Path(dep).stem != 'tb']  # anasymod already includes tb.sv
    src_cfg.add_verilog_sources(deps)
    src_cfg.add_verilog_sources([THIS_DIR / 'sim_ctrl.sv'], fileset='sim')

    # Verilog Headers
    header_file_list = [get_file('inc/fpga/iotype.sv')]
    src_cfg.add_verilog_headers(header_file_list)

    # Verilog Defines
    src_cfg.add_defines({
        'VIVADO': None,
        'FPGA_MACRO_MODEL': None,
        'CHUNK_WIDTH': CFG['chunk_width'],
        'NUM_CHUNKS': CFG['num_chunks']
    })
    src_cfg.add_defines({'GIT_HASH': str(get_git_hash_short())}, fileset='sim')

    # uncomment to use floating-point for simulation only
    # src_cfg.add_defines({'FLOAT_REAL': None}, fileset='sim')

    # HardFloat-related defines
    # (not yet fully supported)
    if get_dragonphy_real_type() == RealType.HardFloat:
        src_cfg.add_defines({
            'HARD_FLOAT': None,
            'FUNC_DATA_WIDTH': DEF_HARD_FLOAT_WIDTH
        })
        src_cfg.add_verilog_sources(get_hard_float_sources())
        src_cfg.add_verilog_headers(get_hard_float_headers())

    # Firmware
    src_cfg.add_firmware_files([THIS_DIR / 'main.c'])

    # Write source config
    # TODO: interact directly with anasymod library rather than through config files
    src_cfg.write_to_file(THIS_DIR / 'source.yaml')

    # Update simctrl.yaml if needed
    simctrl = yaml.load(open(THIS_DIR / 'simctrl.pre.yaml', 'r'))
    if get_dragonphy_real_type() == RealType.HardFloat:
        simctrl['digital_ctrl_inputs']['chan_wdata_0']['width'] = DEF_HARD_FLOAT_WIDTH
        simctrl['digital_ctrl_inputs']['chan_wdata_1']['width'] = DEF_HARD_FLOAT_WIDTH
    yaml.dump(simctrl, open(THIS_DIR / 'simctrl.yaml', 'w'))

    # "models" directory has to exist
    (THIS_DIR / 'build' / 'models').mkdir(exist_ok=True, parents=True)

def test_2(simulator_name):
    # set defaults
    if simulator_name is None:
        simulator_name = 'vivado'

    # run simulation
    ana = Analysis(input=str(THIS_DIR), simulator_name=simulator_name)
    ana.set_target(target_name='sim')
    ana.simulate(convert_waveform=False)

def test_3():
    # build bitstream
    ana = Analysis(input=str(THIS_DIR))
    ana.set_target(target_name='fpga')
    ana.build()

def test_ffe(channel_number):
    SYSTEM = yaml.load(open(get_file('config/system.yml'), 'r'), Loader=yaml.FullLoader)
    ffe_length = SYSTEM['generic']['ffe']['parameters']['length'] 
    #channel 4 before
    chan_func_values = get_real_channel_step(real_channels[channel_number], domain=CFG['func_domain'], numel=CFG['func_numel'])
    pulse            = get_real_channel_pulse(real_channels[channel_number], domain=CFG['func_domain'], numel=CFG['func_numel'])
    chan_func_values = chan_func_values.clip(0)
    pulse = pulse / 0.3 * 128
    retval = []
    retval.append(chan_func_values[:])
    retval.append(np.concatenate((np.diff(chan_func_values), [0])))

    retval_2 = []
    for k in range(2):
        retval_2.append([
            real2fixed(
                coeff,
                exp=-16, 
                width=18, 
                treat_as_unsigned=True
            ) for coeff in retval[k]
        ])

    arr = np.array(retval_2[1])

    retval_2[1] = list(np.where(arr > 65336, 0, arr))
    print(retval_2[0])
    with open('chan_vals_0.txt', 'w') as f1:
            with open('chan_vals_1.txt', 'w') as f2:
                print("\n".join([f'{a},' for a in retval_2[0]]), file=f1)
                print("\n".join([f'{b},' for b in retval_2[1]]), file=f2)


    coeffs_bin = retval_2
    #coeffs_bin = coeffs_bin_old

    pulse_width = 62.5e-12;
    idx_pw      = int(62.5e-12 *  2048 / 4e-9)

    pulse_bin = -(np.array(coeffs_bin[0][:-idx_pw:idx_pw]) - np.array(coeffs_bin[0][idx_pw::idx_pw])) / 2**16 * 128 / 0.3
    plt.stem(pulse_bin)
    plt.plot(pulse)
    plt.show()

    chan_mat = linalg.convolution_matrix(pulse, ffe_length)

    fig, axes = plt.subplots(ffe_length,1)

    best_err = -1;
    best_zf_taps = 0
    for ii in range(1,ffe_length-1):
        imp = np.zeros((len(pulse) + ffe_length - 1, 1))
        imp[ii] = 2**15

        zf_taps = np.reshape(np.linalg.pinv(chan_mat) @ imp, (ffe_length,))

        new_eql_pulse = np.convolve(zf_taps, pulse)[0:ffe_length]
        new_eql_pulse[ii] = 0

        ener_err = np.sqrt(np.sum(np.square(new_eql_pulse)))
        abs_err = np.sum(np.abs(new_eql_pulse))
        axes[ii].plot(np.square(new_eql_pulse))
        print(f'{ii}: {abs_err} {ener_err}')
        if (abs_err < best_err) or (best_err < 0):
            best_ii = ii
            best_zf_taps = zf_taps
            best_err = abs_err
    plt.show()
    plt.plot(best_zf_taps)
    plt.show()

    best_eql_pulse = np.convolve(best_zf_taps, pulse)
    print(best_eql_pulse[best_ii], np.sum(np.abs(best_eql_pulse[best_ii+1:ffe_length])) + np.sum(np.abs(best_eql_pulse[:best_ii])))
    print('----------')
    print(best_eql_pulse[best_ii+1:ffe_length])
    print(best_eql_pulse[:best_ii])

    align_pos = np.argmax(best_eql_pulse)
    print(best_ii, align_pos, best_err)

    plt.plot(best_eql_pulse)
    plt.show()
    best_zf_taps = best_zf_taps/2
    while np.max(np.abs(best_zf_taps)) > 255:
        best_zf_taps = best_zf_taps/2
    print(best_zf_taps)

    best_eql_pulse = np.convolve(best_zf_taps, pulse)

    shift = np.ceil(log2(np.sum(np.abs(best_eql_pulse)))) - 9
    print(shift, np.ceil(log2(np.sum(np.abs(best_eql_pulse)))))
    with open('ffe_vals.txt', 'w') as f:
        print("\n".join([str(int(tap)) for tap in [shift, align_pos] + list(best_zf_taps)]), file=f)
    out_pulse = [int(tap) for tap in pulse]/np.sum([int(tap) for tap in pulse]) * 109
    print(out_pulse)

    with open('chan_est_vals.txt', 'w') as f:
        print("\n".join([str(int(round(tap))) for tap in list(out_pulse)]), file=f)

    #print([int(round(pul)) for pul in list(pulse[::-1]*127)])
def test_adapt():
    SYSTEM = yaml.load(open(get_file('config/system.yml'), 'r'), Loader=yaml.FullLoader)
    ffe_length = 100 #SYSTEM['generic']['ffe']['parameters']['length']

    est_b = 0
    est_e = 0

    x_vec = np.zeros((20,))
    sub_x_vec = np.zeros((10,))
    est_b_vec = np.zeros((10,))
    est_e_vec = np.zeros((10,))
  
    dg_vec = []
    g_vec = []

    #fig1 = plt.figure()
    #ax1 = fig1.add_subplot(211)
    #ax2 = fig1.add_subplot(212)
    #line1, = ax1.plot(sub_x_vec)
    #line2, = ax2.plot(est_b_vec)

    #zfig2 = plt.figure()
    #ax_3d = plt.axes(projection='3d')

    z_d = np.zeros((10,10))

    f_lines = []
    with open('adapt_data.txt', 'r') as f:
        f_lines = f.readlines()

    for line in f_lines:
        tokens = line.strip().split(',')[:-1]
        est_b = int(tokens[0])
        est_e = int(tokens[1])
        x_vec = np.array([int(tok) for tok in tokens[2:]])
        sub_x_vec[:] = x_vec[10-5:20-5]
        est_b_vec[1:] = est_b_vec[0:9]
        est_b_vec[0] = est_b

        est_e_vec[1:] = est_e_vec[0:9]
        est_e_vec[0] = est_e

        z_d[1:,:] = z_d[0:9,:]
        for ii in range(10):
            z_d[0, ii] = z_d[1, ii] + est_e_vec[0] * x_vec[ii+11 - 3]
        print(z_d)
        print(est_e * x_vec[10 - 5:20-5])
        print(x_vec)
        print(est_b_vec)
        print(est_e_vec)

        #line1.set_ydata(sub_x_vec)
        #ax1.set_ylim([-110, 110])
        #line2.set_ydata(est_e_vec)
        #ax2.set_ylim([-20, 20])
#
        #line3.set_ydata(z_d.flatten())
#
        #fig1.canvas.draw()
        #fig1.canvas.flush_events()
        #fig2.canvas.draw()
        #fig2.canvas.flush_events()
        #plt.pause(0.5)

def test_adapt_mem():
    SYSTEM = yaml.load(open(get_file('config/system.yml'), 'r'), Loader=yaml.FullLoader)
    ffe_length = SYSTEM['generic']['ffe']['parameters']['length']

    x_vec = np.zeros((20,))
    est_b_vec = np.zeros((10,))

    def signed(val, n_bits):
        return val - 256 if val > 2**(n_bits-1) -1 else val

    def slice(val):
        return 1 if val > 0 else -1

    vals = None
    with open('mem.txt', 'r') as f:
        vals = [int(line) for line in f]

    ffe_vals = None
    with open('mem_ffe.txt', 'r') as f:
        ffe_vals = [int(line) for line in f]

    z_d = np.zeros((30,10))


    for ii in range(len(vals)-16):
        x_vec[1:] = x_vec[0:19]
        x_vec[0]  = signed(vals[ii], 8)
        #print(x_vec[0], vals[ii])
        est_b_vec[1:] = est_b_vec[0:9]
        est_b_vec[0] = signed(ffe_vals[ii+16], 8)

        est_e = 40*slice(est_b_vec[0]) - est_b_vec[0]

        z_d[1:,:] = z_d[0:29,:]

        for ii in range(10):
            z_d[0, ii] = z_d[1, ii] + est_e * x_vec[ii+11 - 3]

        print(z_d)
        print(est_e * x_vec[10 - 5:20-5])
        print(x_vec)
        print(est_e, est_b_vec)




def test_4(prbs_test_dur, jitter_rms, noise_rms, chan_tau, chan_delay, channel_number, run_adapt_ffe=False):
    # read ffe_length
    SYSTEM = yaml.load(open(get_file('config/system.yml'), 'r'), Loader=yaml.FullLoader)
    ffe_length = SYSTEM['generic']['ffe']['parameters']['length']

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
    ana = Analysis(input=str(THIS_DIR))
    ana.set_target(target_name='fpga')
    ctrl = ana.launch()
    ser = ctrl.ctrl_handler

    # functions
    def load_ffe_vals():
        ffe_vals = []
        with open("ffe_vals.txt", "r") as f:
            for line in f:
                ffe_vals += [int(line.strip().split(',')[0])]



        return ffe_vals[0], ffe_vals[1], ffe_vals[2:]

    def load_chan_vals():
        chan_est_vals = []
        with open("chan_est_vals.txt", "r") as f:
            for line in f:
                chan_est_vals += [int(line.strip().split(',')[0])]

        return chan_est_vals
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


    def update_chan(coeff_tuples, offset=0):
        # put together the command
        args = ['UPDATE_CHAN', offset, len(coeff_tuples)]
        for coeff_tuple in coeff_tuples:
            args += coeff_tuple
        cmd = ' '.join(str(elem) for elem in args)
        ser.write((cmd + '\n').encode('utf-8'))

        # stall until confirmation is received
        assert ser.readline().decode('utf-8').strip() == 'OK', 'Serial error'

    def read_memory(filename=None):
        data = []
        for ii in range(1024):
            write_tc_reg('in_addr_multi', ii)
            for jj in range(16):
                data += [read_sc_reg(f'out_data_multi[{jj}]')]
            print(ii)


        if filename:
            with open(filename, 'w') as f:
                for datum in data:
                    print(f'{datum}' ,file=f)

        return data

    def read_memory_ffe(filename=None):
        data = []
        for ii in range(1024):
            write_tc_reg('in_addr_multi_ffe', ii)
            for jj in range(16):
                data += [read_sc_reg(f'out_data_multi_ffe[{jj}]')]
            print(ii)

        if filename:
            with open(filename, 'w') as f:
                for datum in data:
                    print(f'{datum}' ,file=f)

        return data
    def signed(val, n_bits=8):
        return val-(2**n_bits) if val > 2**(n_bits-1)-1 else val

    def enable_error_tracker():
        write_tc_reg('enable_errt', 1)
    def disable_error_tracker():
        write_tc_reg('enable_errt', 0)

    def toggle_int_rstb():
        write_tc_reg('ctrl_rstb', 0b000)
        write_tc_reg('exec_ctrl_rstb', 1)
        write_tc_reg('exec_ctrl_rstb', 0)

    def toggle_sram_rstb():
        write_tc_reg('ctrl_rstb', 0b001)
        write_tc_reg('exec_ctrl_rstb', 1)
        write_tc_reg('exec_ctrl_rstb', 0)

    def toggle_cdr_rstb():
        write_tc_reg('ctrl_rstb', 0b010)
        write_tc_reg('exec_ctrl_rstb', 1)
        write_tc_reg('exec_ctrl_rstb', 0)

    def toggle_prbs_rstb():
        write_tc_reg('ctrl_rstb', 0b011)
        write_tc_reg('exec_ctrl_rstb', 1)
        write_tc_reg('exec_ctrl_rstb', 0)

    def toggle_prbs_gen_rstb():
        write_tc_reg('ctrl_rstb', 0b100)
        write_tc_reg('exec_ctrl_rstb', 1)
        write_tc_reg('exec_ctrl_rstb', 0)

    def toggle_acore_rstb():
        write_tc_reg('ctrl_rstb', 0b101)
        write_tc_reg('exec_ctrl_rstb', 1)
        write_tc_reg('exec_ctrl_rstb', 0)

    def read_learned_weights():
        ffe_vals = np.zeros((16,), dtype=np.int32)
        chan_vals = np.zeros((30,), dtype=np.int32)
        for ii in range(30):
            write_tc_reg('sample_pos', ii)
            write_tc_reg('sample_fir_est', 1)
            write_tc_reg('sample_fir_est', 0)
            chan_vals[ii] = signed(int(read_sc_reg('ce_sampled_value')), n_bits=10)
            chan_vals[ii] = signed(int(read_sc_reg('ce_sampled_value')), n_bits=10)
            if ii < 16:
                ffe_vals[ii] = signed(int(read_sc_reg('fe_sampled_value')), n_bits=10)
                ffe_vals[ii] = signed(int(read_sc_reg('fe_sampled_value')), n_bits=10)

        return ffe_vals, chan_vals

    def read_error_tracker(flag_width=2, num_of_errors=100):
        def signed(value):
            return value - 512 if ((value >> 8) & 1) == 1 else value

        num_ed_flags = 0
        num_pb_flags = 0
        num_bits     = 0
        tag = 0b00

        if flag_width == 2:
            num_ed_flags = 24
            num_pb_flags = 48
            num_bits     = 48
            tag = 0b11
        elif flag_width == 3:
            num_ed_flags = 24
            num_pb_flags = 36
            num_bits     = 36
            tag = 0b111

        depth = num_of_errors * 4
        write_tc_reg('read_errt', 1)
  
        codes = np.zeros((num_of_errors, 48))
        bits  = np.zeros((num_of_errors, num_bits))
        ed_flags = np.zeros((num_of_errors, num_ed_flags))
        pb_flags = np.zeros((num_of_errors, num_pb_flags))

        data = {}
        for ii in tqdm(range(depth)):
            write_tc_reg('addr_errt', ii)

            idx = ii % 4
            data_set = 0

            if idx < 3:
                for jj in range(5):
                    datum = int(read_sc_reg(f'output_data_frame_errt[{jj}]'))
                    data_set = data_set + (datum << (32 * jj))
                
                codes[int(ii/4), idx * 16:(idx+1) * 16] = [ signed(data_set >> (9 * jj) & 0b111111111) for jj in range(16)]
            else:
                for jj in range(5):
                    datum = int(read_sc_reg(f'output_data_frame_errt[{jj}]'))
                    data_set = data_set + (datum << (32 * jj))
                
                pb_flags[int(ii/4), :] = [data_set >> jj          & 0b1  for jj in range(num_pb_flags)]
                bits[int(ii/4), :]     = [data_set >> (jj + num_pb_flags)   & 0b1  for jj in range(num_bits)]
                ed_flags[int(ii/4), :] = [data_set >> (flag_width*jj + num_pb_flags + num_bits) & tag for jj in range(num_ed_flags)]

        write_tc_reg('read_errt', 0)

        data['codes'] = codes
        data['pb_flags'] = pb_flags
        data['bits'] = bits
        data['ed_flags'] = ed_flags

        return data





    # Initialize 
    set_sleep(1)
    do_init()

    # Clear emulator reset.  A bit of delay is added just in case
    # the MT19937 generator is being used, because it takes awhile
    # to start up (LCG and LFSR start almost immediately)
    set_emu_rst(0)
    time.sleep(10e-3)

    # Reset JTAG
    print('Reset JTAG')
    do_reset()

    # Release other reset signals
    print('Release other reset signals')
    set_rstb(1)

    # Configure noise
    set_jitter_rms(int(round(jitter_rms*1e13)))
    set_noise_rms(int(round(noise_rms*1e4)))

    # Configure step response function
    #placeholder = PlaceholderFunction(domain=CFG['func_domain'], order=CFG['func_order'],
    #                                  numel=CFG['func_numel'], coeff_widths=CFG['func_widths'],
    #                                  coeff_exps=CFG['func_exps'], real_type=get_dragonphy_real_type())
    #chan_func = lambda t_vec: (1-np.exp(-(t_vec-chan_delay)/chan_tau))*np.heaviside(t_vec-chan_delay, 0)
    #coeffs_bin_old = placeholder.get_coeffs_bin_fmt(chan_func)

    chan_func_values = get_real_channel_step(real_channels[channel_number], domain=CFG['func_domain'], numel=CFG['func_numel'])
    pulse            = get_real_channel_pulse(real_channels[channel_number], domain=CFG['func_domain'], numel=CFG['func_numel'])
    chan_func_values = chan_func_values.clip(0)

    def convert_to_pwl(values):
        retval = []
        retval.append(values[:])
        retval.append(np.concatenate((np.diff(values), [0])))
    
        retval_2 = []
        for k in range(2):
            retval_2.append([
                real2fixed(
                    coeff,
                    exp=-16, 
                    width=18, 
                    treat_as_unsigned=True
                ) for coeff in retval[k]
            ])
        arr = np.array(retval_2[1])
        retval_2[1] = list(np.where(arr > 65336, 0, arr))
        return retval_2


    coeffs_bin = convert_to_pwl(chan_func_values)
    coeff_tuples = list(zip(*coeffs_bin))
    chunk_size = 32 
    for k in range(len(coeff_tuples)//chunk_size):
        print(f'Updating channel at chunk {k}...')
        update_chan(coeff_tuples[(k*chunk_size):((k+1)*chunk_size)], offset=k*chunk_size)

    ffe_shift, align_pos, zf_taps = load_ffe_vals()
    chan_taps = load_chan_vals()

    # Soft reset
    print('Soft reset')
    toggle_int_rstb()
    toggle_acore_rstb()
    toggle_sram_rstb()
    write_tc_reg('ce_exec_inst', 0)
    write_tc_reg('fe_exec_inst', 0)
    write_tc_reg('en_inbuf', 1)
    write_tc_reg('en_gf', 1)
    write_tc_reg('mode_errt', 0)
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
    write_sc_reg('prbs_eqn', 0x100002)  # matches equation used by prbs21 in DaVE

    # Configure PRBS checker
    print('Configure the PRBS checker')
    write_sc_reg('sel_prbs_mux', 1) # "0" is ADC, "1" is FFE, "2" Checker, "3" is BIST
    write_sc_reg('sel_trig_prbs_mux', 2) # "0" is ADC, "1" is FFE, "2" Checker, "3" is BIST
    write_sc_reg('sel_prbs_bits', 0); # Chooses which PRBS BER is read out "1" is checker, "0" is FFE 

    # Release the PRBS checker from reset
    print('Release the PRBS checker from reset')
    toggle_prbs_rstb()

    for loop_var2 in range(ffe_length):
        write_tc_reg(f'init_ffe_taps[{loop_var2}]',int(round(zf_taps[loop_var2])))
    write_tc_reg('fe_inst', 0b100)
    write_tc_reg('fe_exec_inst', 1)

    write_tc_reg('ce_inst', 0b100)
    for loop_var2 in range(30):
        write_tc_reg('ce_exec_inst', 0)
        write_tc_reg(f'ce_addr', loop_var2)
        write_tc_reg(f'ce_val', 8*int(round(chan_taps[loop_var2])))
        write_tc_reg('ce_exec_inst', 1)


    for loop_var in range(16):
        write_tc_reg(f'ffe_shift[{loop_var}]', ffe_shift)
        write_tc_reg(f'channel_shift[{loop_var}]', 3)
        #for loop_var2 in range(30):
        #    load_channel_estimate(loop_var2, loop_var, chan_taps[loop_var2])
    #write_tc_reg('align_pos', 8)
    write_tc_reg('align_pos', align_pos)
    write_tc_reg('fe_bit_target_level', 40)

    #for loop_var in range(16):
    #    for loop_var2 in range(19):
    #        load_channel_estimate(loop_var2, loop_var, int(round(act_pulse[loop_var2])))
#        for loop_var2 in range(30):
#            load_channel_estimate(loop_var2, loop_var, int(round(pulse[loop_var2]*127)))

    # Configure the CDR offsets
    print('Configure the CDR offsets')
    write_tc_reg('ext_pi_ctl_offset[0]', 0)
    write_tc_reg('ext_pi_ctl_offset[1]', 128)
    write_tc_reg('ext_pi_ctl_offset[2]', 256)
    write_tc_reg('ext_pi_ctl_offset[3]', 384)
    write_tc_reg('en_ext_max_sel_mux', 1)
    write_tc_reg('ext_max_sel_mux[0]', 128)
    write_tc_reg('ext_max_sel_mux[1]', 128)
    write_tc_reg('ext_max_sel_mux[2]', 128)
    write_tc_reg('ext_max_sel_mux[3]', 128)

    # Configure the retimer
    print('Configuring the retimer...')
    write_tc_reg('retimer_mux_ctrl_1', 0b1111111111111111)
    write_tc_reg('retimer_mux_ctrl_2', 0b1111111111111111)
    # write_tc_reg('retimer_mux_ctrl_1', 0b0000111111110000)
    # write_tc_reg('retimer_mux_ctrl_2', 0b1111000000000000)

    # Configure the CDR
    print('Configuring the CDR...')
    write_tc_reg('Kp', 2)
    write_tc_reg('Ki', 0)
    write_tc_reg('invert', 1)
    write_tc_reg('en_freq_est', 0)
    write_tc_reg('ext_pi_ctl', 0)
    write_tc_reg('en_ext_pi_ctl', 1)
    write_tc_reg('sel_inp_mux', 1) # "0": use ADC output, "1": use FFE output

    # Re-initialize ordering
    print('Re-initialize ADC ordering')

    write_tc_reg('en_v2t', 0)
    write_tc_reg('en_v2t', 1)



    write_tc_reg('ce_gain', 4)
    write_tc_reg('ce_exec_inst', 0)

    time.sleep(5)

    write_tc_reg('ce_gain', 2)
    write_tc_reg('fe_adapt_gain', 2)
    
    write_tc_reg('fe_exec_inst', 0)
    write_tc_reg('ext_pi_ctl', 0)
    #write_tc_reg('fe_bit_target_level', 100)
    time.sleep(10)

#    for ii in range(8):
#        write_tc_reg('fe_adapt_gain', 4)
#        write_tc_reg('fe_inst', 0b010)
#        write_tc_reg('fe_exec_inst', 1)
#        write_tc_reg('fe_exec_inst', 0) 
#        align_pos = align_pos+1
#        write_tc_reg('align_pos', align_pos)
#        time.sleep(3)
#    write_tc_reg('fe_adapt_gain', 1)

#    for ii in range(17, 25):
#        write_tc_reg('fe_adapt_gain', 4)
#        write_tc_reg('ext_pi_ctl', ii)
#        time.sleep(30)
#        write_tc_reg('fe_adapt_gain', 1)
#        write_sc_reg('prbs_checker_mode', 2)
#        time.sleep(10)
#        write_sc_reg('prbs_checker_mode', 3)
#        print(f'PI CODE: {ii}')
#        print('Read out PRBS test results')
#        write_sc_reg('sel_prbs_bits', 0); # Chooses which PRBS BER is read out "1" is checker, "0" is FFE 
#        err_bits = 0
#        err_bits |= read_sc_reg('prbs_err_bits_upper')
#        err_bits <<= 32
#        err_bits |= read_sc_reg('prbs_err_bits_lower')
#        print(f'err_bits: {err_bits}')
#    
#        total_bits = 0
#        total_bits |= read_sc_reg('prbs_total_bits_upper')
#        total_bits <<= 32
#        total_bits |= read_sc_reg('prbs_total_bits_lower')
#        print(f'total_bits: {total_bits}')
#    
#        print(f'BER: {err_bits/total_bits:e}')
#    
#        write_sc_reg('sel_prbs_bits', 1); # Chooses which PRBS BER is read out "1" is checker, "0" is FFE 
#        err_bits = 0
#        err_bits |= read_sc_reg('prbs_err_bits_upper')
#        err_bits <<= 32
#        err_bits |= read_sc_reg('prbs_err_bits_lower')
#        print(f'err_bits: {err_bits}')
#    
#        total_bits = 0
#        total_bits |= read_sc_reg('prbs_total_bits_upper')
#        total_bits <<= 32
#        total_bits |= read_sc_reg('prbs_total_bits_lower')
#        print(f'total_bits: {total_bits}')
#    
#        print(f'BER: {err_bits/total_bits:e}')
#    
#        #learned_ffe_vals, learned_channel_vals = read_learned_weights()
#        #print(learned_ffe_vals)
#        #print(zf_taps)
#        #print(learned_channel_vals)
#        #print(chan_taps)
#        write_sc_reg('prbs_checker_mode', 0)
#        learned_ffe_vals, learned_channel_vals = read_learned_weights()
#        plt.plot(np.convolve(learned_ffe_vals, learned_channel_vals))
#        print(np.convolve(learned_ffe_vals, learned_channel_vals))
#    plt.show()
    # Release the CDR from reset, then wait for it to lock
    # TODO: explore why it is not sufficient to pulse cdr_rstb low here
    # (i.e., seems that it must be set to zero while configuring CDR parameters
    print('Wait for the CDR to lock')
    toggle_cdr_rstb()
    time.sleep(15.0)
    #write_tc_reg('en_int_dump_start', 1)
    #write_tc_reg('int_dump_start', 0)
    #write_tc_reg('int_dump_start', 1)
    #mem = read_memory(filename='mem.txt')
    #mem_ffe = read_memory_ffe(filename='mem_ffe.txt')


    # Run PRBS test.  In order to get a conservative estimate for the throughput, the
    # test duration includes the time it takes to send JTAG commands to start and stop
    # the PRBS bit counter.  This is needed because the counter will start running partway
    # through the first JTAG command, and stop running partway through the second command.
    # Since we don't know exactly when this happens, a conservative estimate should include
    # the full time taken by the two JTAG commands.  The effect of their inclusion can be
    # minimized by running the test for a longer period.
    print('Run PRBS test')
    t_start = time.time()
    write_sc_reg('prbs_checker_mode', 2)

    enable_error_tracker()
    disable_error_tracker()
    total_time_remaining = prbs_test_dur
    pbar = tqdm(total=1000)
    now = datetime.now()
    meas_time = now.strftime("%d%m%Y_%H%M%S")
    cycle = 1
    prev_num_of_logged_errors = 0

    def stingify_noise(noise_rms):
        out_str = ""
        if int(np.log10(noise_rms)) >= -2:
            out_str += f'{noise_rms*1e3:1}mv'
        elif int(np.log10(noise_rms)) >= -5:
            out_str += f'{noise_rms*1e6:1}uv'
        return out_str


    while total_time_remaining > 0:
        zero_counts = 0
        update_time = time.time()
        time.sleep(1)
        num_of_logged_errors = int(read_sc_reg('number_stored_frames_errt')/4)
        #print(num_of_logged_errors)
#        #zero_counts += 1 if num_of_logged_errors == 0 else 0
        #if zero_counts > 24:
        #    enable_error_tracker()
        #    time.sleep(1)
        #    disable_error_tracker()
        #    zero_counts = 0
        #    print('Restarting Error Tracker')
#        #print(num_of_logged_errors)
        if num_of_logged_errors >= 2:
            zero_counts = 0
            update_time = (time.time() - update_time)
            print(f'Error Tracker reached {num_of_logged_errors} - Reading Out')
            e_tracker = read_error_tracker(flag_width=3, num_of_errors=num_of_logged_errors)
            with open(f'error_tracker_data_{channel_number}_{stingify_noise(noise_rms)}_{meas_time}_{cycle}.txt', 'w') as f_wf:
                with open(f'error_tracker_data_no_flags_{channel_number}_{stingify_noise(noise_rms)}_{meas_time}_{cycle}.txt', 'w') as f_nf:
                    for (codes, pb_flags, bits, ed_flags) in zip(e_tracker['codes'], e_tracker['pb_flags'], e_tracker['bits'], e_tracker['ed_flags']):
                        fil = f_wf if np.sum(ed_flags) > 0 else f_nf
                        print(codes, file=fil)
                        print(pb_flags, file=fil)
                        print(bits, file=fil)
                        print(ed_flags, file=fil)
            enable_error_tracker()
            time.sleep(1)
            disable_error_tracker()
            #print(num_of_logged_errors)
            cycle += 1
        else:
            update_time = (time.time() - update_time)
        total_time_remaining -= update_time
        pbar.update(int(num_of_logged_errors-prev_num_of_logged_errors))
        prev_num_of_logged_errors = num_of_logged_errors

    #for ii in range(int(prbs_test_dur/10.0)):
    #    time.sleep(10)
    #    write_sc_reg('prbs_checker_mode', 3)
    #    # Read out PRBS test results
    #    print('Read out PRBS test results')
    #    write_sc_reg('sel_prbs_bits', 0); # Chooses which PRBS BER is read out "1" is checker, "0" is FFE 
    #    err_bits = 0
    #    err_bits |= read_sc_reg('prbs_err_bits_upper')
    #    err_bits <<= 32
    #    err_bits |= read_sc_reg('prbs_err_bits_lower')
    #    print(f'err_bits: {err_bits}')
#
    #    total_bits = 0
    #    total_bits |= read_sc_reg('prbs_total_bits_upper')
    #    total_bits <<= 32
    #    total_bits |= read_sc_reg('prbs_total_bits_lower')
    #    print(f'total_bits: {total_bits}')
#
    #    print(f'BER: {err_bits/total_bits:e}')
#
    #    write_sc_reg('sel_prbs_bits', 1); # Chooses which PRBS BER is read out "1" is checker, "0" is FFE 
    #    err_bits = 0
    #    err_bits |= read_sc_reg('prbs_err_bits_upper')
    #    err_bits <<= 32
    #    err_bits |= read_sc_reg('prbs_err_bits_lower')
    #    print(f'err_bits: {err_bits}')
#
    #    total_bits = 0
    #    total_bits |= read_sc_reg('prbs_total_bits_upper')
    #    total_bits <<= 32
    #    total_bits |= read_sc_reg('prbs_total_bits_lower')
    #    print(f'total_bits: {total_bits}')
#
    #    print(f'BER: {err_bits/total_bits:e}')
    #    write_sc_reg('prbs_checker_mode', 2)

    #time.sleep(prbs_test_dur)
    #disable_error_tracker()
    write_sc_reg('prbs_checker_mode', 3)
    t_stop = time.time()

    # Print out duration of PRBS test
    print(f'PRBS test took {t_stop-t_start} seconds.')

    # Read out PRBS test results
    print('Read out PRBS test results')
    write_sc_reg('sel_prbs_bits', 0); # Chooses which PRBS BER is read out "1" is checker, "0" is FFE 
    err_bits = 0
    err_bits |= read_sc_reg('prbs_err_bits_upper')
    err_bits <<= 32
    err_bits |= read_sc_reg('prbs_err_bits_lower')
    print(f'err_bits: {err_bits}')

    total_bits = 0
    total_bits |= read_sc_reg('prbs_total_bits_upper')
    total_bits <<= 32
    total_bits |= read_sc_reg('prbs_total_bits_lower')
    print(f'total_bits: {total_bits}')

    print(f'BER: {err_bits/total_bits:e}')

    write_sc_reg('sel_prbs_bits', 1); # Chooses which PRBS BER is read out "1" is checker, "0" is FFE 
    err_bits = 0
    err_bits |= read_sc_reg('prbs_err_bits_upper')
    err_bits <<= 32
    err_bits |= read_sc_reg('prbs_err_bits_lower')
    print(f'err_bits: {err_bits}')

    total_bits = 0
    total_bits |= read_sc_reg('prbs_total_bits_upper')
    total_bits <<= 32
    total_bits |= read_sc_reg('prbs_total_bits_lower')
    print(f'total_bits: {total_bits}')

    print(f'BER: {err_bits/total_bits:e}')

    #t_start = time.time()
    #num_of_logged_errors = read_sc_reg('number_stored_frames_errt')
    #print(f'Logged Errors: {num_of_logged_errors}')
    #e_tracker = read_error_tracker(num_of_errors=num_of_logged_errors if num_of_logged_errors < 1024 else 1024)
    #t_stop = time.time()

    #print(f'Error Readout Timne: {t_stop - t_start}')
#
    #now = datetime.now()
    #with open(f'error_tracker_data_{now.strftime("%d%m%Y_%H%M%S")}.txt', 'w') as f_wf:
    #    with open(f'error_tracker_data_no_flags_{now.strftime("%d%m%Y_%H%M%S")}.txt', 'w') as f_nf:
    #        for (codes, pb_flags, bits, ed_flags) in zip(e_tracker['codes'], e_tracker['pb_flags'], e_tracker['bits'], e_tracker['ed_flags']):
    #            fil = f_wf if np.sum(ed_flags) > 0 else f_nf
    #            print(codes, file=fil)
    #            print(pb_flags, file=fil)
    #            print(bits, file=fil)
    #            print(ed_flags, file=fil)

    #    plt.plot(codes)
    #    plt.plot(pb_flags)
    #    plt.plot(bits)
    #    plt.show()


    learned_ffe_vals, learned_channel_vals = read_learned_weights()

    print(learned_ffe_vals, zf_taps)
    print(learned_channel_vals, load_chan_vals())
    #toggle_int_rstb()
    #toggle_acore_rstb()

    # check results
    print('Checking the results...')
    assert id_result == 497598771, 'ID mismatch'
    assert err_bits == 0, 'Bit error detected'
    assert total_bits > 100000, 'Not enough bits detected'

    # finish test
    print('OK!')

