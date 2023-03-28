import numpy as np
from pathlib import Path
import matplotlib.pyplot as plt
from scipy import signal
import scipy
from copy import deepcopy
from dragonphy import create_init_viterbi_state, run_error_viterbi, run_iteration_error_viterbi

def prbs_checker(current_prbs_state, new_bit, eqn, width):
    new_prbs_state = (current_prbs_state >> 1) | (new_bit << (width-1))
    new_prbs_state = new_prbs_state & ((1 << width) - 1)
    return new_prbs_state, (new_prbs_state & eqn) == 0

def slicer(val, slice_level):
    if val > 2*slice_level:
        return 3
    elif val > 0:
        return 1
    elif val > -2*slice_level:
        return -1
    else:
        return -3
    
def filter(signal, eq_taps, center):
    return np.convolve(signal, eq_taps)[center-1]

def pam4_adaptation(eq_tap, eq_signal, signal, slice_level, gain):
    sym = slicer(eq_signal, slice_level)
    if abs(sym) == 1:
        gain = 3*gain
    new_eq_tap = np.zeros(len(eq_tap))
    for ii in range(len(eq_tap)):
        new_eq_tap[ii] = eq_tap[ii] + gain*(slice_level*sym - eq_signal)*signal[len(signal)-1-ii]

    return new_eq_tap

def chan_pam4_adaptation(chan, chan_err, syms, gain):
    modified_gain = [3*gain if abs(sym) == 1 else gain for sym in syms]


    new_chan = np.zeros(len(chan))
    for ii in range(len(chan)):
        new_chan[ii] = chan[ii] - modified_gain[len(syms)-ii-1]*chan_err*syms[len(syms)-ii-1]
    return new_chan


def convert_amd_txt():
    with open('amd_adc.txt') as f:
        lines = f.readlines()
        tokens = lines[0].split()
        tokens = [int(float(val)) for val in tokens]
        np.savetxt('amd_adc.csv', tokens, delimiter=',')

def process_amd_data():
    amd_adc_vals = np.loadtxt('amd_adc.csv', delimiter=',')


    init_eq_filt = signal.firls(11, [0, 0.45, 0.45, 0.8, 0.8, 1], [0.5, 0.5, 0.5, 0.7, 0.7, 1.2])
    init_eq_filt = np.convolve(init_eq_filt, init_eq_filt)
    init_eq_filt[:16] = init_eq_filt[5:]
    init_eq_filt[16:] = 0
    #plt.hist(np.convolve(init_eq_filt, amd_adc_vals), bins=100)
    #plt.show()


    num_of_samples = int(len(amd_adc_vals))

    syms = np.zeros((num_of_samples,))
    eq_signal = np.zeros((num_of_samples,))
    est_codes = np.zeros((num_of_samples,))
    est_err   = np.zeros((num_of_samples,))
    eq_taps   = init_eq_filt
    est_channel = np.zeros(30)
    est_channel[1] = 1

    for ii in range(10,num_of_samples):
        eq_signal[ii] = filter(amd_adc_vals[ii-10:ii+11], eq_taps, 21)
        syms[ii] = slicer(eq_signal[ii], 2.2)
        eq_taps = pam4_adaptation(eq_taps, eq_signal[ii], amd_adc_vals[ii-10:ii+11], 2.2, 0.000005)
        if ii > 30:
            est_codes[ii] = filter(syms[ii-30:ii], est_channel, 30)
            est_err[ii] = est_codes[ii] - amd_adc_vals[ii]
            est_channel = chan_pam4_adaptation(est_channel, est_err[ii] , syms[ii-30:ii], 0.00001)

    


    np.savetxt('eq_taps.csv', eq_taps, delimiter=',')
    np.savetxt('est_channel.csv', est_channel, delimiter=',')
    np.savetxt('eq_signal.csv', eq_signal, delimiter=',')
    np.savetxt('est_err.csv', est_err, delimiter=',')
    np.savetxt('est_codes.csv', est_codes, delimiter=',')


def plot_error_checker_results():
    est_errs = np.loadtxt('est_err.csv', delimiter=',')
    flags = np.loadtxt('flags.csv', delimiter=',')
    fig, ax = plt.subplots(2,1)
    ax[0].plot(est_errs[3000000:3000000+3000])
    ax[1].plot(flags[3000000:3000000+3000])
    plt.show()

def error_checker():
    est_channel = np.loadtxt('est_channel.csv', delimiter=',')
    est_errs = np.loadtxt('est_err.csv', delimiter=',')

    check_patterns = [
        [+2,0,0,0],
        [+2,-2,0,0],
        [+2,-2,+2,0],
        [+2,-2,+2,-2]
    ]

    precomputed_errs = np.zeros((2*len(check_patterns), 3))
    for ii in range(len(check_patterns)):
        precomputed_errs[ii, :] = np.convolve(est_channel, check_patterns[ii])[3:6]
        precomputed_errs[ii+len(check_patterns), :] = np.convolve(est_channel, -np.array(check_patterns[ii]))[3:6]

        #plt.plot(precomputed_errs[ii, :])
        #plt.plot(np.convolve(est_channel, check_patterns[ii]))
        #plt.show()
    
    flags = np.zeros((len(est_errs),))
    energies = np.zeros((len(est_errs),))
    for ii in range(len(est_errs)-3):
        flags[ii] = 0
        lowest_energy = np.sum(np.square(est_errs[ii:ii+3]))
        energies[ii] = lowest_energy
        #print(lowest_energy, est_errs[ii:ii+3])
        for jj in range(2*len(check_patterns)):
            energy = np.sum(np.square(est_errs[ii:ii+3] - precomputed_errs[jj, :]))
            #print(energy, est_errs[ii:ii+3] - precomputed_errs[jj, :])
            if energy < lowest_energy:
                flags[ii] = jj
                energies[ii] = energy
                lowest_energy = energy
        #print(flags[ii])
    np.savetxt('flags.csv', flags, delimiter=',')
    np.savetxt('energies.csv', energies, delimiter=',')

def bin_and_collect_error_traces():
    flags = np.loadtxt('flags.csv', delimiter=',')
    energies = np.loadtxt('energies.csv', delimiter=',')
    #est_err = np.loadtxt('est_err.csv', delimiter=',')
    red_flags = flags
    red_energies = energies

    block_size = 4

    print(int((1- (len(red_flags)/block_size - int(len(red_flags)/block_size)))*block_size))
    red_flags = np.pad(red_flags, (0, int((1- (len(red_flags)/block_size - int(len(red_flags)/block_size)))*block_size)), 'constant', constant_values=(0,0))
    red_energies = np.pad(red_energies, (0, int((1- (len(red_energies)/block_size - int(len(red_energies)/block_size)))*block_size)), 'constant', constant_values=(0,9999))

    red_flag_blocks = red_flags.reshape((-1, block_size))
    red_energy_blocks = red_energies.reshape((-1, block_size))

    best_red_flag_blocks = np.zeros((len(red_flag_blocks), block_size))

    for ii in range(len(red_flag_blocks)):
        if not any(red_flag_blocks[ii, :]):
            continue
        print(red_energy_blocks[ii, :])
        print(red_flag_blocks[ii, :])
        nonzero_flags = np.nonzero(red_flag_blocks[ii, :])[0]
        idx = nonzero_flags[np.argmin(red_energy_blocks[ii, nonzero_flags])]
        best_red_flag_blocks[ii, idx] = red_flag_blocks[ii, idx]
        print(best_red_flag_blocks[ii, :])

    traces = []
    for ii in range(len(best_red_flag_blocks)):
        if not any(best_red_flag_blocks[ii, :]):
            continue
        traces += [(ii-1)*block_size]

    print(traces)
    print(len(traces)/len(flags))
    np.savetxt('traces.csv', np.array(traces), delimiter=',')

def process_error_traces():
    traces = np.loadtxt('traces.csv', delimiter=',')
    est_err = np.loadtxt('est_err.csv', delimiter=',')
    new_est_err = deepcopy(est_err)
    est_channel = np.loadtxt('est_channel.csv', delimiter=',')
    #est_channel = [1, 0.5, 0.25, 0.125, 0.0625] + [0]*19


    current_trace = int(traces[0])
    viterbi_list = []
    for trace in traces[1:]:
        if trace - current_trace < 32:
            continue
        else:
            viterbi_list +=[current_trace]
            current_trace = int(trace)
    est_channel = np.array(list(est_channel)[3:])
    est_channel = np.array(list(est_channel) + [0]*(32-len(est_channel)))
    correction = np.zeros((len(est_err),))
    for (ii, trace_pos) in enumerate(viterbi_list):
        if trace_pos < 200000:
            continue
        trace = est_err[trace_pos:trace_pos+32]

        viterbi_state = create_init_viterbi_state(len(est_channel), est_channel, 4)
        for val in trace:
            viterbi_state = run_iteration_error_viterbi(viterbi_state, val)
        #print(viterbi_state)
        err, trc = viterbi_state.get_best_path()
        print(f'{ii/len(viterbi_list)*100:.2f}%')
#        plt.plot(trc)
#        plt.plot(trace)
#        plt.plot(err)
#        plt.show()
        #input()
        correction[trace_pos:trace_pos+29] = err[:29]
        new_est_err[trace_pos:trace_pos+32] = trc
    correction = np.convolve(est_channel, correction, 'same')
    #plt.plot(new_est_err)
    np.savetxt('post_est_err.csv', new_est_err, delimiter=',')
    np.savetxt('viterbi_list.csv', np.array(viterbi_list), delimiter=',')
    np.savetxt('correction.csv', correction, delimiter=',')
def plot_traces():
    traces = np.loadtxt('traces.csv', delimiter=',')
    est_err = np.loadtxt('est_err.csv', delimiter=',')
    new_est_err = np.loadtxt('post_est_err.csv', delimiter=',')
    correction = np.loadtxt('correction.csv', delimiter=',')
    viterbi_list = np.loadtxt('viterbi_list.csv', delimiter=',')
    flags = np.loadtxt('flags.csv', delimiter=',')
    #plt.plot(est_err)
    #plt.plot(flags)
    for trc_pos in traces:
        if trc_pos < 200000:
            continue
        trc_pos = int(trc_pos)
        plt.plot(new_est_err[trc_pos:trc_pos+32])
        plt.plot(est_err[trc_pos:trc_pos+32])
        plt.plot(correction[-15+trc_pos:-15+trc_pos+32])
        plt.show()

def plot_processed_data():
    est_channel = np.loadtxt('est_channel.csv', delimiter=',')
    eq_taps = np.loadtxt('eq_taps.csv', delimiter=',')
    est_codes = np.loadtxt('est_codes.csv', delimiter=',')
    amd_adc_vals = np.loadtxt('amd_adc.csv', delimiter=',')
    est_err = np.loadtxt('est_err.csv', delimiter=',')
    eq_signal = np.loadtxt('eq_signal.csv', delimiter=',')

    plt.plot(est_channel)
    plt.show()
    plt.plot(eq_taps)
    plt.show()
    plt.plot(est_codes)
    plt.plot(amd_adc_vals)
    plt.show()
    plt.hist(eq_signal, bins=100)
    plt.show()
    plt.plot(est_err)
    plt.show()


def post_viterbi_error_checker():
    est_channel = np.loadtxt('est_channel.csv', delimiter=',')
    est_errs = np.loadtxt('post_est_err.csv', delimiter=',')

    check_patterns = [
        [+2,0,0,0],
        [+2,-2,0,0],
        [+2,-2,+2,0],
        [+2,-2,+2,-2]
    ]

    precomputed_errs = np.zeros((2*len(check_patterns), 3))
    for ii in range(len(check_patterns)):
        precomputed_errs[ii, :] = np.convolve(est_channel, check_patterns[ii])[3:6]
        precomputed_errs[ii+len(check_patterns), :] = np.convolve(est_channel, -np.array(check_patterns[ii]))[3:6]

        #plt.plot(precomputed_errs[ii, :])
        #plt.plot(np.convolve(est_channel, check_patterns[ii]))
        #plt.show()
    
    flags = np.zeros((len(est_errs),))
    energies = np.zeros((len(est_errs),))
    for ii in range(len(est_errs)-3):
        flags[ii] = 0
        lowest_energy = np.sum(np.square(est_errs[ii:ii+3]))
        energies[ii] = lowest_energy
        #print(lowest_energy, est_errs[ii:ii+3])
        for jj in range(2*len(check_patterns)):
            energy = np.sum(np.square(est_errs[ii:ii+3] - precomputed_errs[jj, :]))
            #print(energy, est_errs[ii:ii+3] - precomputed_errs[jj, :])
            if energy < lowest_energy:
                flags[ii] = jj
                energies[ii] = energy
                lowest_energy = energy
        #print(flags[ii])
    np.savetxt('post_viterbi_flags.csv', flags, delimiter=',')
    np.savetxt('post_viterbi_energies.csv', energies, delimiter=',')


def plot_post_viterbi_error_checker_results():
    est_errs = np.loadtxt('post_est_err.csv', delimiter=',')
    pv_flags = np.loadtxt('post_viterbi_flags.csv', delimiter=',')
    flags = np.loadtxt('flags.csv', delimiter=',')
    fig, ax = plt.subplots(2,1)
    ax[0].plot(est_errs)
    ax[1].plot(flags)
    ax[1].plot(pv_flags)
    plt.show()

def process_test_data():
    num_of_samples = 50000

    test_syms = (np.random.randint(0, 4, num_of_samples)*2 - 3)

    channel = [0.25, 0.75, 3, 1, 1/3, 1/9, 1/27, 1/81]

    signal = np.convolve(test_syms, channel)

    syms = np.zeros((num_of_samples,))
    eq_signal = np.zeros((num_of_samples,))
    est_codes = np.zeros((num_of_samples,))
    est_err   = np.zeros((num_of_samples,))
    eq_taps = np.zeros(21)
    est_channel = np.zeros(30)
    eq_taps[11] = 1

    for ii in range(10,num_of_samples):
        eq_signal[ii] = filter(signal[ii-10:ii+11], eq_taps, 21)
        syms[ii] = slicer(eq_signal[ii], 3)
        eq_taps = pam4_adaptation(eq_taps, eq_signal[ii], signal[ii-10:ii+11], 3, 0.00001)
        if ii > 30:
            est_codes[ii] = filter(syms[ii-30:ii], est_channel, 30)
            est_err[ii] = est_codes[ii] - signal[ii-4]
            est_channel = chan_pam4_adaptation(est_channel, est_err[ii] , syms[ii-30:ii], 0.00005)
    
    plt.plot(eq_taps)
    plt.show()
    plt.plot(syms[3:])
    plt.plot(eq_signal[3:]/3.0)
    plt.plot(test_syms[:num_of_samples])
    plt.show()
    plt.plot(est_codes[4:])
    plt.plot(signal)
    plt.show()
    plt.plot(est_err)
    plt.show()



if __name__ == '__main__':
    #convert_amd_txt()
    #process_amd_data()
    #plot_processed_data()
    #error_checker()
    #plot_error_checker_results()
    #bin_and_collect_error_traces()
    #process_error_traces()
    #plot_traces()
    #post_viterbi_error_checker()
    plot_post_viterbi_error_checker_results()
