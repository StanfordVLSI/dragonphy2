import numpy as np
from pathlib import Path
import matplotlib
import matplotlib.pyplot as plt
from scipy import signal, stats, cluster
import scipy
from copy import deepcopy
from dragonphy import create_init_viterbi_state, run_error_viterbi, run_iteration_error_viterbi
from rich.progress import track
from rich.console import Console
from rich.markdown import Markdown
#matplotlib.use('TkAgg')


def convert_csv_to_npy(filename):
    np.save(filename + '.npy', np.loadtxt(filename+'.csv'))

def model_viterbi(viterbi_depth, trace_pos, est_channel, est_err):#=None):
    #est_err = np.load('est_err.npy') if est_err is None else est_err
    #est_channel = np.load('est_channel.npy') if est_channel is None else est_channel

    if len(est_channel) < viterbi_depth:
        est_channel = np.array(list(est_channel) + [0]*(viterbi_depth-len(est_channel)))
    elif len(est_channel) > viterbi_depth:
        est_channel = est_channel[:viterbi_depth]


    trace = est_err[trace_pos:trace_pos+viterbi_depth]

    viterbi_state = create_init_viterbi_state(len(est_channel), est_channel, 4)
    for val in trace:
        viterbi_state = run_iteration_error_viterbi(viterbi_state, val)

    err, trc = viterbi_state.get_best_path()

    return err[:-4], trc[:-4], trace[:-4]

def model_error_checker(est_channel, est_errs):
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

        plt.plot(precomputed_errs[ii, :])
        plt.plot(np.convolve(est_channel, check_patterns[ii]))
        plt.show()
    
    flags = np.zeros((len(est_errs),))
    energies = np.zeros((len(est_errs),))
    for ii in range(len(est_errs)-3):
        flags[ii] = 0
        lowest_energy = np.sum(np.square(est_errs[ii:ii+3]))
        energies[ii] = lowest_energy
        print(f'------------------ {ii} ------------------')
        print(0, lowest_energy, est_errs[ii:ii+3])
        for jj in range(2*len(check_patterns)):
            energy = np.sum(np.square(est_errs[ii:ii+3] - precomputed_errs[jj, :]))
            print(jj+1, energy, est_errs[ii:ii+3] - precomputed_errs[jj, :])
            if energy < lowest_energy:
                flags[ii] = jj+1
                energies[ii] = energy
                lowest_energy = energy
    
    return flags, energies

def gray_code_mappings(select_mapping):
    mappings = [{}, {}, {}, {}, {}, {}, {}, {}]
    mappings[0][3]  = [1, 0]
    mappings[0][1]  = [0, 0] 
    mappings[0][-1] = [0, 1]
    mappings[0][-3] = [1, 1]

    mappings[1][3]  = [1, 1]
    mappings[1][1]  = [1, 0] 
    mappings[1][-1] = [0, 0]
    mappings[1][-3] = [0, 1]


    mappings[2][3]  = [0, 1]
    mappings[2][1]  = [1, 1] 
    mappings[2][-1] = [1, 0]
    mappings[2][-3] = [0, 0]

    mappings[3][3]  = [0, 0]
    mappings[3][1]  = [0, 1] 
    mappings[3][-1] = [1, 1]
    mappings[3][-3] = [1, 0]

    mappings[4][3]  = [0, 1]
    mappings[4][1]  = [0, 0] 
    mappings[4][-1] = [1, 0]
    mappings[4][-3] = [1, 1]

    mappings[5][3]  = [1, 1]
    mappings[5][1]  = [0, 1] 
    mappings[5][-1] = [0, 0]
    mappings[5][-3] = [1, 0]


    mappings[6][3]  = [1, 0]
    mappings[6][1]  = [1, 1] 
    mappings[6][-1] = [0, 1]
    mappings[6][-3] = [0, 0]

    mappings[7][3]  = [0, 0]
    mappings[7][1]  = [1, 0] 
    mappings[7][-1] = [1, 1]
    mappings[7][-3] = [0, 1]
    return mappings[select_mapping]

def pam4_to_bits(sym, mapping={3: [1,1], 1: [1,0], -1: [0,1], -3: [0,0]}):
    return np.array(mapping[sym], dtype=int)

def prbs_generator(prev_bits, eqn):

    def bitwise_and(a, b):
        return [a[ii] & b[ii] for ii in range(len(a))]
    
    def total_xor(a):
        result = a[0]
        for ii in range(1, len(a)):
            result ^= a[ii]
        return result

    select_bits = bitwise_and(prev_bits, eqn[::-1])
    new_bit = total_xor(select_bits)
    return new_bit

def prbs_checker(new_bit, prev_checked_bits, eqn):

    def bitwise_and(a, b):
        return [a[ii] & b[ii] for ii in range(len(a))]
    
    def total_xor(a):
        result = a[0]
        for ii in range(1, len(a)):
            result ^= a[ii]
        return result

    select_bits = bitwise_and(prev_checked_bits, eqn[::-1])
    correct_bit = total_xor(select_bits)
    error   = new_bit ^ correct_bit

    return error, correct_bit

def test_prbs_checker():
    prbs_depth = 8
    eqn = np.zeros((prbs_depth,), dtype=int)

    if prbs_depth == 8:
        eqn[5] = 1
        eqn[6] = 1
    elif prbs_depth == 24:
        eqn[0] = 0
        eqn[18] = 1
        eqn[23] = 1

    num_of_bits = 100000

    errors = np.zeros((num_of_bits,), dtype=int)
    test_bits = np.zeros((num_of_bits,), dtype=int)
    test_bits[0] = 1
    received_bits = np.zeros((num_of_bits,), dtype=int)
    received_bits[0] = 1
    checked_bits = np.zeros((num_of_bits,), dtype=int)
    checked_bits[0] = 1
    for ii in range(prbs_depth, len(test_bits)):
        test_bits[ii] = prbs_generator(test_bits[ii-prbs_depth:ii], eqn)
        print(test_bits[ii], test_bits[ii-prbs_depth:ii])
        input()
        if np.random.rand() < 0.0005:
            received_bits[ii] = test_bits[ii] ^ 1
        else:
            received_bits[ii] = test_bits[ii]

    for ii in range(prbs_depth, len(received_bits)):
        errors[ii], checked_bits[ii] = prbs_checker(received_bits[ii], checked_bits[ii-prbs_depth:ii], eqn)

    plt.stem(errors)
    plt.show()



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

def noise_adaptation(eq_tap, eq_signal, signal, gain):
    new_eq_tap = np.zeros(len(eq_tap))
    for ii in range(len(eq_tap)):
        new_eq_tap[ii] = eq_tap[ii] + gain*(5 - eq_signal)*signal[len(signal)-1-ii]

    return new_eq_tap

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


def convert_model_txt():
    with open('adc.txt') as f:
        lines = f.readlines()
        tokens = lines[0].split()
        tokens = [int(float(val)) for val in tokens]
        np.save('model_adc.npy', tokens)

def process_model_data(use_eq_taps=False, use_chan=False, slicer_val=2.13, gains=[1e-6,1e-5]):
    model_adc_vals = np.load('model_adc.npy').astype(float)

    for ii in range(40):
        model_adc_vals[ii::40] -= np.mean(model_adc_vals[ii::40])

    eq_taps = np.zeros((40, 21))
    if use_eq_taps:
        eq_taps = np.load('eq_taps.npy')
    else:
        init_eq_filt = signal.firls(11, [0, 0.45, 0.45, 0.8, 0.8, 1], [0.5, 0.5, 0.5, 0.7, 0.7, 1.2])
        init_eq_filt = np.convolve(init_eq_filt, init_eq_filt)
        init_eq_filt[:16] = init_eq_filt[5:]
        init_eq_filt[16:] = 0
        for ii in range(40):
            eq_taps[ii,:]   = init_eq_filt

    
    num_of_samples = int(len(model_adc_vals))

    syms = np.zeros((num_of_samples,))
    eq_signal = np.zeros((num_of_samples,))
    est_codes = np.zeros((num_of_samples,))
    est_err   = np.zeros((num_of_samples,))

    est_channel = np.zeros((40, 30))
    est_channel[:,1] = 1

    if use_chan:
        est_channel = np.load('est_channel.npy')
        

    for ii in track(range(10,num_of_samples), description='Processing Initial Estimates'):
        eq_signal[ii] = filter(model_adc_vals[ii-10:ii+11], eq_taps[ii % 40, :], 21)
        syms[ii] = slicer(eq_signal[ii], slicer_val)
        eq_taps[ii % 40, :] = pam4_adaptation(eq_taps[ii % 40, :], eq_signal[ii], model_adc_vals[ii-10:ii+11], slicer_val, gains[0])
        if ii > 30:
            est_codes[ii] = filter(syms[ii-30:ii], est_channel[ii % 40, :], 30)
            est_err[ii] = est_codes[ii] - model_adc_vals[ii]
            est_channel[ii % 40, :] = chan_pam4_adaptation(est_channel[ii % 40, :], est_err[ii] , syms[ii-30:ii], gains[1])

    np.save('eq_taps.npy',eq_taps)
    np.save('est_channel.npy',est_channel)
    np.save('eq_signal.npy', eq_signal)
    np.save('est_err.npy', est_err)
    np.save('est_codes.npy', est_codes)

def plot_processed_data(whiten=False):
    est_channel = np.load('est_channel.npy')
    eq_taps = np.load('eq_taps.npy')
    est_codes = np.load('est_codes.npy')
    model_adc_vals = np.load('model_adc.npy')
    est_err = np.load('est_err.npy')
    eq_signal = np.load('eq_signal.npy')

    if whiten:
        wf_taps = np.load('noise_eq_taps.npy')
        for ii in range(40):
            model_adc_vals[ii::40] = np.convolve(model_adc_vals[ii::40], wf_taps[ii,:])[:len(model_adc_vals[ii::40])]
            est_channel[ii,:] = np.convolve(est_channel[ii,:], wf_taps[ii,:])[:len(est_channel[ii,:])]
            eq_signal[ii::40] = np.convolve(eq_signal[ii::40], wf_taps[ii,:])[:len(eq_signal[ii::40])]
            est_err[ii::40] = np.convolve(est_err[ii::40], wf_taps[ii,:])[:len(est_err[ii::40])]
    #plt.plot(est_channel.T) 
    #plt.show()
    #plt.plot(eq_taps.T)
    #plt.title('Equalizer Taps')
    #plt.show()
    #plt.plot(est_codes)
    #plt.plot(model_adc_vals)
    #plt.show()
    
    #fig, axs = plt.subplots(8, 5)
#
    #for ii in track(range(40), description='Plotting Histograms'):
    #    axs[ii//5, ii%5].hist(eq_signal[ii::40], bins=100)
    #    axs[ii//5, ii%5].set_title(f'Interleave {ii}')
    #    kmean_vals, dist = cluster.vq.kmeans(eq_signal[ii::40], 4, iter=20, thresh=1e-07)
#
    #    kmean_vals = np.sort(kmean_vals)
    #    mid_val = (kmean_vals[1:] + kmean_vals[:-1])/2
    #    print(mid_val)
#
    #    for jj in range(4):
    #        axs[ii//5, ii%5].axvline(kmean_vals[jj], color='r')
    #    for jj in range(3):
    #        axs[ii//5, ii%5].axvline(mid_val[jj], color='b')
#
    #plt.show()
    #plt.plot(eq_signal)
    #plt.show()
    plt.plot(est_err)
    plt.show()

    plt.hist(est_err, bins=256, log=True)
    print(np.max(np.abs(est_err)))
    plt.show()

def plot_error_checker_results(whiten=False):
    est_errs = np.load('est_err.npy')
    flags = np.load('flags.npy')
    if whiten:
        wf_taps = np.load('noise_eq_taps.npy')
        for ii in range(40):
            est_errs[ii::40] = np.convolve(est_errs[ii::40], wf_taps[ii,:])[:len(est_errs[ii::40])]
    fig, ax = plt.subplots(2,1)
    ax[0].plot(est_errs[3000000:3000000+30000])
    ax[1].plot(flags[3000000:3000000+30000])
    plt.show()

def error_checker(whiten=False):
    est_channel = np.mean(np.load('est_channel.npy'), axis=0)
    wf_taps = np.load('noise_eq_taps.npy')


    est_errs = np.load('est_err.npy')
    if whiten:
        plt.plot(est_errs)
        for ii in range(40):
            est_errs[ii::40] = np.convolve(est_errs[ii::40], wf_taps[ii,:])[:len(est_errs[ii::40])]
        plt.plot(est_errs)
        plt.show()
        plt.plot(est_channel)
        est_channel = np.convolve(est_channel, np.mean(wf_taps, axis=0))
        plt.plot(est_channel)
        plt.show()

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

    
    flags = np.zeros((len(est_errs),))
    energies = np.zeros((len(est_errs),))
    for ii in track(range(len(est_errs)-3), description='Processing Error Checker'):
        flags[ii] = 0
        lowest_energy = np.sum(np.square(est_errs[ii:ii+3]))
        energies[ii] = lowest_energy
        #print(lowest_energy, est_errs[ii:ii+3])
        for jj in range(2*len(check_patterns)):
            energy = np.sum(np.square(est_errs[ii:ii+3] - precomputed_errs[jj, :]))
            #print(energy, est_errs[ii:ii+3] - precomputed_errs[jj, :])
            if energy < lowest_energy:
                flags[ii] = jj+1
                energies[ii] = energy
                lowest_energy = energy
        #print(flags[ii])
    np.save('flags.npy', flags)
    np.save('energies.npy', energies)

def bin_and_collect_error_traces():
    flags = np.load('flags.npy')
    energies = np.load('energies.npy')

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
        nonzero_flags = np.nonzero(red_flag_blocks[ii, :])[0]
        idx = nonzero_flags[np.argmin(red_energy_blocks[ii, nonzero_flags])]
        best_red_flag_blocks[ii, idx] = red_flag_blocks[ii, idx]

    traces = []
    for ii in range(len(best_red_flag_blocks)):
        if not any(best_red_flag_blocks[ii, :]):
            continue
        traces += [(ii)*block_size]


    np.save('traces.npy', np.array(traces))

def identify_viterbi_locations(base_viterbi_depth):
    traces = np.load('traces.npy')

    current_trace = int(traces[0])
    current_depth = base_viterbi_depth
    viterbi_list = [traces[0]]
    viterbi_depth = [base_viterbi_depth]


    for ii in range(len(traces)):
        if traces[ii] - current_trace == current_depth - 4:
            viterbi_depth[-1] += 8
            current_depth += 8
            print(f'touching {traces[ii]} - {current_trace}')
        elif traces[ii] - current_trace < current_depth - 4:
            print(f'jumping {traces[ii]} - {current_trace}')
        elif traces[ii] - current_trace > current_depth - 4:
            viterbi_list += [traces[ii]]
            viterbi_depth += [base_viterbi_depth]
            current_trace = traces[ii]
            current_depth = base_viterbi_depth
            print(f'new trace {traces[ii]} - {current_trace}')

    count_table = {}
    for depth in viterbi_depth:
        if depth in count_table:
            count_table[depth] += 1
        else:
            count_table[depth] = 1

    total_cycles = 0
    for key in count_table:
        total_cycles += count_table[key]*key/8e6

    print(count_table)
    print(total_cycles*100)

    plt.hist(viterbi_depth, bins=100)
    plt.show()

    np.save('viterbi_list.npy', np.array(viterbi_list))
    np.save('viterbi_depth.npy', np.array(viterbi_depth))

def process_error_traces(whiten=False):
    def stringify(err):
        err_str = ""
        if isinstance(err, list):
            err = np.array(err)
        elif isinstance(err, np.float64):
            err = np.array([err])

        for ii in range(0, len(err)):
            if err[ii] == 0:
                err_str += '0'
            elif err[ii] == 2:
                err_str += '+'
            elif err[ii] == -2:
                err_str += '-'
        return err_str
    viterbi_list = np.load('viterbi_list.npy').astype(int)
    viterbi_depths = np.load('viterbi_depth.npy').astype(int)
    est_err = np.load('est_err.npy')
    new_est_err = deepcopy(est_err)
    est_channel = np.mean(np.load('est_channel.npy'), axis=0)[3:]

    if whiten:
        wf_taps = np.load('noise_eq_taps.npy')
        for ii in range(40):
            est_err[ii::40] = np.convolve(est_err[ii::40], wf_taps[ii,:])[:len(est_err[ii::40])]
            est_channel = np.convolve(est_channel, np.mean(wf_taps, axis=0))[:len(est_channel)]
    max_viterbi_depth = max(viterbi_depths)

    if len(est_channel) < max_viterbi_depth:
        est_channel = np.array(list(est_channel) + [0]*(max_viterbi_depth-len(est_channel)))
    elif len(est_channel) > max_viterbi_depth:
        est_channel = est_channel[:max_viterbi_depth]
    history_of_differences = []
    history_of_unique_traces = []
    viterbi_size = 3

    history_of_branches = { ii : 0 for ii in range(3**viterbi_size)}
    correction = np.zeros((len(est_err),))


    for (trace_pos, viterbi_depth) in track(list(zip(viterbi_list, viterbi_depths)), description='Running Viterbi'):
        #print(f'------- Starting Trace {trace_pos} -------')
        history_mat = np.zeros((3**viterbi_size, viterbi_depth-viterbi_size))
        trace_history_branches = np.zeros((3**viterbi_size, viterbi_depth))
        trace = est_err[trace_pos:trace_pos+viterbi_depth]

        viterbi_state = create_init_viterbi_state(viterbi_depth, est_channel[:viterbi_depth], viterbi_size)
        for (pos, val) in enumerate(trace):
            set_of_traces = set()
            viterbi_state, decisions = run_iteration_error_viterbi(viterbi_state, val)
            for ii in range(3**viterbi_size):
                history_mat[ii, :] = viterbi_state.err_history[ii][viterbi_size:]
                if pos > viterbi_size:
                    trace_history_branches[ii, pos] = trace_history_branches[int(decisions[ii][0]), pos-1] + abs(decisions[ii][1])/2
                    set_of_traces.add(stringify(viterbi_state.err_history[ii][viterbi_size:]))

                    history_of_branches[decisions[ii][0]] += 1
            
            history_of_unique_traces += [len(set_of_traces)]

            median_arr = np.median(history_mat, axis=0)
            location_of_differences = np.where(np.abs(history_mat - median_arr) > 0)[1]
            if location_of_differences.size > 0:
                history_of_differences += [np.max(location_of_differences)+1]
                #if np.max(location_of_differences) > 6:
                #    print(f'Error: {trace_pos} - {viterbi_depth} - {np.max(location_of_differences)}')
                #    for ii in range(3**viterbi_size):
                #        print(f'{ii}: {stringify(viterbi_state.err_history[ii][viterbi_size:])} - {trace_history_branches[ii, pos]}')

            else: 
                history_of_differences += [0]
        err, trc = viterbi_state.get_best_path()
        try:
            correction[trace_pos:trace_pos+viterbi_depth-viterbi_size] = err[:viterbi_depth-viterbi_size]
            new_est_err[trace_pos:trace_pos+viterbi_depth-viterbi_size] = trc[:viterbi_depth-viterbi_size]
        except ValueError:
            print(f'ValueError: {trace_pos} - {viterbi_depth} - {len(err)} - {len(trc)}')
    print(history_of_branches)
    #plt.hist(history_of_differences, bins=100, log=True)
    #plt.show()
    #plt.hist(history_of_unique_traces, bins=100, log=True)
    #plt.show()
    np.save('hist_diff.npy', np.array(history_of_differences))
    np.save('hist_unique.npy', np.array(history_of_unique_traces))
    np.save('post_est_err.npy', new_est_err,)
    np.save('correction.npy', correction,)

def plot_difference_history():
    est_channel = np.mean(np.load('est_channel.npy'), axis=0)[6:]
    viterbi_depths = np.load('viterbi_depth.npy').astype(int)

    history_of_differences = np.load('hist_diff.npy')
    fig, axes = plt.subplots()
    N, bins, _ = axes.hist(history_of_differences, weights=np.square(est_channel)[history_of_differences], bins=19, log=True)
    N, bins, _ = axes.hist(history_of_differences, bins=19, log=True, alpha=0.5)

    plt.show()
    history_of_unique_traces = np.load('hist_unique.npy')
    plt.hist(history_of_unique_traces, bins=100, log=True)
    plt.show()
    prev_depth = 0

    print(len(history_of_unique_traces), len(viterbi_depths))

    sliced_history_of_unique_traces = []
    for depth in np.cumsum(viterbi_depths): 
        sliced_history_of_unique_traces += [history_of_unique_traces[prev_depth:depth]]
        prev_depth = depth
    sliced_history_of_unique_traces = np.array(sliced_history_of_unique_traces)
    idx = np.argsort(viterbi_depths)
    map_of_uniqueness = np.zeros((len(viterbi_depths), np.max(viterbi_depths)))
    for ii, hist in enumerate(sliced_history_of_unique_traces[idx]):
        map_of_uniqueness[ii, :len(hist)] = hist
    plt.imshow(map_of_uniqueness, aspect='auto')

    plt.show()

def plot_traces():
    traces = np.load('traces.npy')
    est_err = np.load('est_err.npy')
    new_est_err = np.load('post_est_err.npy')
    correction = np.load('correction.npy')
    viterbi_list = np.load('viterbi_list.npy')
    flags = np.load('flags.npy')
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


def post_viterbi_error_checker():
    est_channel = np.load('est_channel.npy')
    est_errs = np.load('post_est_err.npy')

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
                flags[ii] = jj+1
                energies[ii] = energy
                lowest_energy = energy
        #print(flags[ii])
    np.save('post_viterbi_flags.npy', flags)
    np.save('post_viterbi_energies.npy', energies)


def plot_post_viterbi_error_checker_results():
    est_errs = np.load('post_est_err.npy')
    pv_flags = np.load('post_viterbi_flags.npy')
    flags = np.load('flags.npy')
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


def prbs_check_symbols(slice_val=2.13, whiten=False):
    eqn = np.zeros((23,), dtype=int)
    eqn[17]= 1
    eqn[22]= 1
    
 
    def limit(val):
        val = np.where(val > 3, 3, val)
        val = np.where(val < -3, -3, val)
        return val
  
    eq_signal = np.load('eq_signal.npy')[32:-32-4]#[1000000:1000000+1000000]
    est_errors = np.load('est_err.npy')#[32+4:-32]#[1000004:1000004+1000000]
    pv_est_errors = np.load('post_est_err.npy')#[32+4:-32]#[1000004:1000004+1000000]
    #plt.psd(pv_est_errors, NFFT=int(2**14), label='Window Size - 2^14')

    if whiten:
        wf_taps = np.load('noise_eq_taps.npy')
        for ii in range(40):
            est_errors[ii::40] = np.convolve(est_errors[ii::40], wf_taps[ii,:])[:len(est_errors[ii::40])]
            pv_est_errors[ii::40] = np.convolve(pv_est_errors[ii::40], wf_taps[ii,:])[:len(pv_est_errors[ii::40])]
    est_errors = est_errors[32+4:-32]
    pv_est_errors = pv_est_errors[32+4:-32]


   #plt.psd(pv_est_errors, NFFT=int(2**14), label='Whitened - Window Size - 2^14')
    #plt.psd(pv_est_errors, NFFT=1024, label='Window Size - 1024')
    #plt.psd(pv_est_errors, NFFT=256, label='Window Size - 256')
    #plt.legend()
    #plt.title('PSD of Post Viterbi Residual Estimated Error')
   # plt.show()

    if whiten:
        exit()

    corrections = np.load('correction.npy')[32+4:-32]#[1000004:1000004+1000000]
    viterbi_list = (np.load('viterbi_list.npy') - 4 - 32)*2


    flags = np.load('flags.npy')[32+4:-32]
    wide_flags = np.zeros(2*len(flags))
    wide_flags[::2] = flags
    wide_correction = np.zeros(2*len(corrections))
    wide_correction[::2] = corrections
    wide_est_errors = np.zeros(2*len(est_errors))
    wide_est_errors[::2] = est_errors
    wide_est_errors[1::2] = est_errors
    wide_pv_est_errors = np.zeros(2*len(pv_est_errors))
    wide_pv_est_errors[::2] = pv_est_errors
    wide_pv_est_errors[1::2] = pv_est_errors
    syms = [slicer(eq_signal[ii], slice_val) for ii in range(len(eq_signal))]
    corrected_syms = np.array([slicer(eq_signal[ii], slice_val)  +  corrections[ii] for ii in range(len(eq_signal))])
    limit_corrected_syms = limit(corrected_syms)
    bad_syms = np.abs(corrected_syms - limit_corrected_syms)
    wide_bad_syms = np.zeros(2*len(bad_syms))
    wide_bad_syms[::2] = bad_syms
    wide_bad_syms[1::2] = bad_syms
    mapping = gray_code_mappings(6)


    bits = np.zeros((2*len(syms),), dtype=int)
    pv_bits = np.zeros((2*len(syms),), dtype=int)
    for ii in range(len(syms)):
        bits[2*ii:2*ii+2] = pam4_to_bits(syms[ii], mapping=mapping)
        pv_bits[2*ii:2*ii+2] = pam4_to_bits(limit_corrected_syms[ii], mapping=mapping)
    errors = np.zeros((len(bits),), dtype=int)
    pv_errors = np.zeros((len(bits),), dtype=int)
    ber = 0
    pv_ber = 0
    for ii in track(range(23, len(bits)), description=f'Running PRBS - {ber:.4g} - {pv_ber:.4g}'):
        errors[ii], __ = prbs_checker(bits[ii], bits[ii-23:ii], eqn)
        pv_errors[ii],__ = prbs_checker(pv_bits[ii], pv_bits[ii-23:ii], eqn)
        ber += errors[ii]/3/len(errors)
        pv_ber += pv_errors[ii]/3/len(pv_errors)
    print(np.sum(errors)/len(errors)/3)
    print(np.sum(pv_errors)/len(pv_errors)/3)


    red_arr = np.zeros((len(errors),))
    blue_arr = np.zeros((len(errors),))

    locs = np.where(pv_errors > 0)[0]

    ii = 0
    prev_loc = 0
    while ii < len(locs):
        loc = locs[ii]
        if loc - prev_loc > 20:
            blue_arr[loc-4:loc+36] = 1
        prev_loc = loc
        ii += 1

    locs = np.where(errors > 0)[0]
    ii = 0
    prev_loc = 0

    while ii < len(locs):
        loc = locs[ii]
        if loc - prev_loc > 20:
            red_arr[loc-4:loc+36] = 1
        prev_loc = loc
        ii += 1



    edge_red_arr = np.diff(red_arr)
    ext_red_arr = np.zeros((len(red_arr),))
    start_locs = np.where(edge_red_arr > 0)[0]
    end_locs = np.where(edge_red_arr < 0)[0]

    #viterbi_start_indices = []
    start_indices = []
    for (start, end) in zip(start_locs, end_locs):
        if any(blue_arr[start:end] > 0):
            start_indices += [start]
    #        #viterbi_start_indices += np.where(viterbi_list > start and viterbi_list < end)[0]
    #        print(start, end)
    #        print(np.where(viterbi_list >= start)[0])
    #        print(viterbi_list[np.where(viterbi_list <= end)[0]])
    #        print(viterbi_list[np.where(viterbi_list >= start)[0]])
#
    #        vx = np.where((viterbi_list >= start ) & (viterbi_list <= end))[0]
#
    #        if len(vx) > 0:
    #            vx = vx[0]
    #            plt.axvline(x=viterbi_list[vx])
    #        plt.plot(errors[start-4:start+48]*10)
    #        plt.plot(pv_errors[start-4:start+48]*10)
    #        plt.plot(wide_pv_est_errors[start-4:start+48])
    #        plt.plot(wide_est_errors[start-4:start+48])
    #        plt.show()
        
    return 
    #plt.plot(red_arr*15+10)
    #plt.plot(blue_arr*15+10)
    plt.plot((errors)*10+12, label='Pre Viterbi Errors')
    plt.plot((pv_errors)*10+8, label='Post Viterbi Errors')
    plt.plot(wide_pv_est_errors - 20, label='Post Viterbi Est Error')
    plt.plot(wide_est_errors, label='Pre Viterbi Est Error')
    plt.plot(wide_bad_syms*4+6, label='Bad Symbols')
    #plt.plot((wide_flags-5))
    #plt.plot(viterbi_list, 15*np.ones((len(viterbi_list),)), 'ro')
    #plt.plot(viterbi_list+40, 15*np.ones((len(viterbi_list),)), 'go')
    #plt.legend()
    plt.title('Pre Viterbi vs Post Viterbi Errors')
    plt.show()
    return

def error_study():
    corrections = np.load('correction.npy')
    viterbi_list = np.load('viterbi_list.npy')
    viterbi_depth = np.load('viterbi_depth.npy')

    def error_stringify(err):
        err_str = ""
        for ii in range(0, len(err)):
            if err[ii] == 0:
                err_str += '0'
            elif err[ii] == 2:
                err_str += '+'
            elif err[ii] == -2:
                err_str += '-'
        return err_str

    error_count = {}
    for trace_pos, viterbi_depth in zip(viterbi_list, viterbi_depth):
        if np.sum(np.abs(corrections[trace_pos-4:trace_pos+viterbi_depth-4])) == 0:
            continue

        first_error_loc = np.where(np.abs(corrections[trace_pos:trace_pos+viterbi_depth]) > 0)[0][0]
        last_error_loc = np.where(np.abs(corrections[trace_pos:trace_pos+viterbi_depth]) > 0)[0][-1]
        error_sample = corrections[trace_pos+first_error_loc:trace_pos+last_error_loc+1]
        err_str = error_stringify(error_sample*corrections[trace_pos+first_error_loc]/2)

        if err_str in error_count:
            error_count[err_str][0] += 1
            error_count[err_str][1] += [trace_pos + first_error_loc]
        else:
            error_count[err_str] = [0, []]
            error_count[err_str][0] = 1
            error_count[err_str][1] = [trace_pos + first_error_loc]

    ordered_by_count = { error_count[err_str][0] : err_str  for err_str in  error_count }
    for count in sorted(ordered_by_count.keys(), reverse=True):
        print(ordered_by_count[count], count/len(corrections))

def whiten_noise(use_est_err=False):
    pv_est_errors = np.load('post_est_err.npy')
    if use_est_err:
        pv_est_errors = np.load('est_err.npy')[100000:]

    whiten_filter_length = 21
    num_of_samples = len(pv_est_errors)
    covariance_est = np.zeros((40, whiten_filter_length,whiten_filter_length))

    total_length = int(len(pv_est_errors)/40) * 40
    print(total_length)

    itld_est_error = np.reshape(pv_est_errors[:total_length], (40, int(len(pv_est_errors)/40)))


    for ii in track(range(whiten_filter_length-1, int(len(pv_est_errors))), description='Calculating Whitening Filter'):
        covariance_est[ii % 40, :, :] += np.outer(pv_est_errors[ii-whiten_filter_length+1:ii+1], pv_est_errors[ii-whiten_filter_length+1:ii+1])
    imp = np.zeros((whiten_filter_length,))
    imp[0] = 1
    cov_mat = covariance_est/num_of_samples * 40
    zf_taps = np.zeros((40, whiten_filter_length))
    inv_mat = np.zeros((40, whiten_filter_length, whiten_filter_length))
    sqr_inv_mat = np.zeros((40, whiten_filter_length, whiten_filter_length))
    for ii in range(40):
        inv_mat[ii, :, :] = scipy.linalg.inv(cov_mat[ii, :, :])
        sqr_inv_mat = scipy.linalg.cholesky(inv_mat[ii, :,:], lower=True)

        zf_taps[ii, :] = np.reshape(sqr_inv_mat @ imp, (whiten_filter_length,))
        zf_taps[ii, :] = zf_taps[ii,:]/np.sum(zf_taps[ii,:])


    filt_itld_est_error = np.zeros((int(len(pv_est_errors)/40)*40,))
    for ii in range(40):
        filt_itld_est_error[ii::40] = np.convolve(itld_est_error[ii, :], zf_taps[ii, :])[:int(len(pv_est_errors)/40)]

    for ii in range(40):
        plt.psd(itld_est_error[ii, :], NFFT=int(2**10), label='Window Size - 2^10')
        plt.psd(np.convolve(itld_est_error[ii, :], zf_taps[ii, :]), NFFT=1024, label='Mark Data Filtered')
    plt.show()

    plt.psd(filt_itld_est_error, NFFT=int(2**10), label='Window Size - 2^10')
    plt.psd(pv_est_errors, NFFT=1024, label='Mark Data Filtered')
    plt.show()
    plt.plot(filt_itld_est_error)
    plt.plot(pv_est_errors)
    plt.show()
    np.save('noise_eq_taps.npy',zf_taps)

    exit()
    complete_noise = np.zeros((int(len(pv_est_errors)/40)*40,))
    random_noise = np.random.normal(0, 1, (40, int(len(pv_est_errors)/40)))
    for ii in range(40):
        complete_noise[ii::40] = 0

    exit()

    plt.psd(pv_est_errors, NFFT=int(2**14), label='Window Size - 2^14')
    plt.psd(pv_est_errors, NFFT=1024, label='Window Size - 1024')
    plt.psd(pv_est_errors, NFFT=256, label='Window Size - 256')
    plt.legend()
    plt.title('PSD of Post Viterbi Residual Estimated Error')
    plt.show()

    for ii in track(range(whiten_filter_length-1, len(pv_est_errors)), description='Calculating Whitening Filter'):
        covariance_est[ii % 40, :, :] += np.outer(pv_est_errors[ii-whiten_filter_length+1:ii+1], pv_est_errors[ii-whiten_filter_length+1:ii+1])

    cov_mat = covariance_est/num_of_samples
    inv_mat = scipy.linalg.inv(cov_mat)
    sqr_inv_mat = scipy.linalg.cholesky(inv_mat, lower=True)

    imp = np.zeros((whiten_filter_length,))
    imp[0] = 1

    zf_taps = np.reshape(sqr_inv_mat @ imp, (whiten_filter_length,))
    zf_taps = zf_taps/np.sum(zf_taps)
    plt.plot(zf_taps)
    plt.show()
    freq_auto = np.abs(np.fft.fft(np.convolve(zf_taps, zf_taps[::-1])))[0:int(len(zf_taps))]

    plt.plot(np.arange(0, 1, 1/len(freq_auto)), freq_auto, label='Mark Data Filter' )
    plt.psd(pv_est_errors, NFFT=128, label='Mark Data')
    plt.psd(np.convolve(pv_est_errors, zf_taps), NFFT=1024, label='Mark Data Filtered')
    #plt.legend()
    plt.show()

if __name__ == '__main__':
    #convert_model_txt()
    console = Console()
    md = Markdown('# Running Error Checker Algorithm')
    console.print(md)
    #whiten_noise(use_est_err=False)
    #process_model_data(use_chan=False, use_eq_taps=False, slicer_val=2.13)
    #process_model_data(use_chan=True, use_eq_taps=True, slicer_val=2.13, gains=[1e-6, 1e-5])
    #process_model_data(use_chan=True, use_eq_taps=True, slicer_val=2.13, gains=[1e-7, 1e-6])
    #process_model_data(use_chan=True, use_eq_taps=True, slicer_val=2.13, gains=[1e-8, 1e-7])
    #process_model_data(use_chan=True, use_eq_taps=True, slicer_val=2.13, gains=[1e-9, 1e-8])
    #plot_processed_data()
    #error_checker()
    #plot_error_checker_results(whiten=True)
    #bin_and_collect_error_traces()
    #identify_viterbi_locations(16)
    process_error_traces()
    #plot_difference_history()
    #plot_traces()
    #post_viterbi_error_checker()
    #plot_post_viterbi_error_checker_results()
    #test_prbs_checker()
    prbs_check_symbols(slice_val=2.13)
    #error_study()
