import os
import time
import json
import re
import yaml
import numpy as np
from pathlib import Path
from math import exp, ceil, log2
from scipy import linalg

import matplotlib.pyplot as plt

from svreal import (RealType, DEF_HARD_FLOAT_WIDTH,
                    get_hard_float_sources, get_hard_float_headers, real2fixed)

from scipy.interpolate import interp1d


from msdsl.function import PlaceholderFunction
from anasymod.analysis import Analysis

from dragonphy import *
from dragonphy.git_util import get_git_hash_short

THIS_DIR = Path(__file__).resolve().parent
CFG = yaml.load(open(get_file('config/fpga/analog_slice_cfg.yml'), 'r'))

def get_real_channel_step(s4p_file, f_sig=16e9, mm_lock_pos=0, numel=2048, domain=[0, 4e-9]):
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
    ana.simulate(convert_waveform=True)

def test_3():
    # build bitstream
    ana = Analysis(input=str(THIS_DIR))
    ana.set_target(target_name='fpga')
    ana.build()

def test_4(prbs_test_dur, jitter_rms, noise_rms, chan_tau, chan_delay):
    chan_tau = chan_tau*10
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
        ret = ser.readline().strip()
        return int(ret)#int(ser.readline().strip())

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

    def read_memory():
        data = []
        for ii in range(100):
            write_tc_reg('in_addr_multi', ii)
            for jj in range(16):
                data += [read_sc_reg(f'out_data_multi[{jj}]')]
        return data

    def read_memory_ffe():
        data = []
        for ii in range(100):
            write_tc_reg('in_addr_multi_ffe', ii)
            for jj in range(16):
                data += [read_sc_reg(f'out_data_multi_ffe[{jj}]')]
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

    print(CFG)
    # Configure step response function
    placeholder = PlaceholderFunction(domain=CFG['func_domain'], order=CFG['func_order'],
                                      numel=CFG['func_numel'], coeff_widths=CFG['func_widths'],
                                      coeff_exps=CFG['func_exps'], real_type=get_dragonphy_real_type())
    chan_func = lambda t_vec: (1-np.exp(-(t_vec-chan_delay)/chan_tau))*np.heaviside(t_vec-chan_delay, 0)
    coeffs_bin_old = placeholder.get_coeffs_bin_fmt(chan_func)
    coeffs_bin = placeholder.get_coeffs_bin_fmt(chan_func)

#    chan_func_values = get_real_channel_step("Case4_FM_13SI_20_T_D13_L6.s4p", domain=CFG['func_domain'], numel=CFG['func_numel'])
#    chan_func_values = chan_func_values.clip(0)
#    plt.plot(chan_func_values)
#    plt.show()
#    retval = []
#    retval.append(chan_func_values[:])
#    retval.append(np.concatenate((np.diff(chan_func_values), [0])))

#    retval_2 = []
#    for k in range(2):
#        retval_2.append([
#            real2fixed(
#                coeff,
#                exp=-16, 
#                width=18, 
#                treat_as_unsigned=True
#            ) for coeff in retval[k]
#        ])

#    arr = np.array(retval_2[1])

#    retval_2[1] = list(np.where(arr > 65336, 0, arr))

#    coeffs_bin = retval_2

    plt.plot(coeffs_bin[0] / (0.4) * 255)
#    plt.plot(coeffs_bin_old[0])
#    plt.plot([0]*128 + coeffs_bin[0][:-128])
    plt.show()
    pulse = (np.array(coeffs_bin[0]) - np.array([0]*128 + coeffs_bin[0][:-128]))[::128]
    plt.plot(pulse)
    plt.show()


    chan_mat = linalg.convolution_matrix(pulse, 10)

    imp = np.zeros((len(pulse) + 10 - 1, 1))
    imp[1] = 1

    zf_taps = np.reshape(np.linalg.pinv(chan_mat) @ imp, (10,))
    zf_taps = zf_taps / np.max(np.abs(zf_taps)) * 127
    plt.plot(zf_taps)
    plt.show()


    plt.plot(np.convolve(pulse, zf_taps))
    plt.show()

#    zf_taps = [1,0,0,0,0,0,0,0,0,0]
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
    write_sc_reg('prbs_eqn', 0x100002)  # matches equation used by prbs21 in DaVE

    # Configure PRBS checker
    print('Configure the PRBS checker')
    write_sc_reg('sel_prbs_mux', 1) # "0" is ADC, "1" is FFE, "3" is BIST

    # Release the PRBS checker from reset
    print('Release the PRBS checker from reset')
    write_sc_reg('prbs_rstb', 1)

    # Set up the FFE
    dt=1.0/(16.0e9)
    coeff0 = 128.0/(1.0-exp(-dt/chan_tau))
    coeff1 = -128.0*exp(-dt/chan_tau)/(1.0-exp(-dt/chan_tau))
    print(chan_tau)

    #zf_taps[0] =coeff0
    #zf_taps[1] =coeff1

    #coeff0  = 1
    #coeff1  = 0

    for loop_var in range(16):
        for loop_var2 in range(ffe_length):
            #if (loop_var2 == 0):
            #    # The argument order for load() is depth, width, value
            #    load_weight(loop_var2, loop_var, int(round(coeff0)))
            #elif (loop_var2 == 1):
            #    load_weight(loop_var2, loop_var, int(round(coeff1)))
            #else:
            load_weight(loop_var2, loop_var, int(round(zf_taps[loop_var2])))
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
    # write_tc_reg('retimer_mux_ctrl_1', 0b0000111111110000)
    # write_tc_reg('retimer_mux_ctrl_2', 0b1111000000000000)

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

    # Release the CDR from reset, then wait for it to lock
    # TODO: explore why it is not sufficient to pulse cdr_rstb low here
    # (i.e., seems that it must be set to zero while configuring CDR parameters
    print('Wait for the CDR to lock')
    write_tc_reg('cdr_rstb', 1)
    write_tc_reg('en_int_dump_start', 1)
    write_tc_reg('int_dump_start', 1)
    time.sleep(1.0)

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
    time.sleep(prbs_test_dur)
    write_sc_reg('prbs_checker_mode', 3)
    t_stop = time.time()

    # Print out duration of PRBS test
    print(f'PRBS test took {t_stop-t_start} seconds.')

    # Read out PRBS test results
    print('Read out PRBS test results')

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

    BER = err_bits/total_bits
    plt.plot(read_memory())
    plt.plot(read_memory_ffe())
    plt.show()
    print(f'BER: {BER:e}')

    # check results
    print('Checking the results...')
    assert id_result == 497598771, 'ID mismatch'
    assert BER <= 0.25, 'Bit error detected'
    assert total_bits > 100000, 'Not enough bits detected'
    # finish test
    print('OK!')
