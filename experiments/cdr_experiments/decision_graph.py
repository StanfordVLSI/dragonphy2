from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
from matplotlib import ticker, cm
import numpy as np
from copy import copy, deepcopy
from scipy import linalg, stats, special
from dragonphy import *
from rich.progress import Progress
from pptree import print_tree
from corner_sampling import sample_noise_from_quadrant, find_zf_taps, find_reasonable_noise_coeff

def stringify(arr, func=str):
    return "".join([func(val) for val in arr])

def bit_to_string(val):
    if val == -1:
        return "0"
    elif val == 1:
        return "1"

def error_to_string(val):
    if val == 0:
        return "0"
    elif val < 0:
        return '-' #f'$-_{{{abs(val)}}}$'
    elif val > 0:
        return '+'#f'$+_{{{abs(val)}}}$'

def convert_error_descript_to_string(err_dpt, num_of_errcursors, err_length):
    out_str = ["0"]*err_length
    for err in err_dpt:
        out_str[num_of_errcursors+err[0]] = "+" if err[1] > 0 else "-"

    return "".join(out_str)

def error_injection(error_in, target_bits, pulse, fpdt, std=None, flip_inject_list=None, noise=None, unfilt_noise=None):

    num_of_errcursors = fpdt.num_of_errcursors
    num_of_precursors = fpdt.num_of_precursors
    err_length        = fpdt.err_length
    flip_inject_list = flip_inject_list if flip_inject_list else [[0], [1], [1,1],[1,0,0,1]]
    noise            = noise if noise is not None else np.zeros((len(error_in) + len(pulse)-1,))
    target_error = deepcopy(error_in)
    target_bits  = deepcopy(target_bits)

    trial_energies = np.zeros((len(target_error)-3,), dtype='float64')
    trial_injects  = np.zeros((len(target_error)-3, len(target_error)), dtype='int64')
    trial_flags    = []

    for jj in range(len(target_error)-3):
        min_energy = np.sum(np.square(np.convolve(error_in, pulse)[num_of_precursors:num_of_precursors+err_length] + noise))
        best_inject = np.zeros(len(target_error))
        inject_list = np.zeros((len(flip_inject_list), len(target_error)), dtype='int64')
        best_flip_patt = (0,0)
        for ll in range(len(flip_inject_list)):
            flip_patt = flip_inject_list[ll]
            inj_pat = np.zeros((len(target_error),), dtype='int64')

            for kk in range(len(flip_patt)):
                inj_pat[jj+kk] = int(2*target_bits[jj+kk]*flip_patt[kk])

            test_bits  = target_bits  - inj_pat
            test_error = target_error + inj_pat

            test_energy = np.sum(np.square(np.convolve(test_error, pulse)[num_of_precursors:num_of_precursors+err_length] + noise)) 
            if test_energy < min_energy:
                min_energy = test_energy
                best_inject = inj_pat
                best_flip_patt = (ll,jj)

        trial_energies[jj]   = min_energy
        trial_injects[jj,:]  = best_inject
        trial_flags += [best_flip_patt]


    best_idx = np.argmin(trial_energies)
    target_bits  -= trial_injects[best_idx,:]
    target_error += trial_injects[best_idx,:]
    target_flips = trial_flags[best_idx]
    target_energy = trial_energies[best_idx]
    input_energy = np.sum(np.square(np.convolve(error_in, pulse)[num_of_precursors:num_of_precursors+err_length] + noise))

    return target_error, target_bits, target_flips, target_energy, input_energy, np.sum(np.abs(target_error-error_in)) < 1e-5

class FlipPatternDecisionTree:
    def __init__(self, flip_patterns, pulse, num_of_precursors, num_of_errcursors, target_curs_pos, ffe_length):
        self._fpdt = {}
        self.flip_patterns = flip_patterns
        self.pulse         = pulse
        self.num_of_precursors = num_of_precursors
        self.num_of_errcursors = num_of_errcursors
        self.zf_taps           = find_zf_taps(pulse, ffe_length, target_curs_pos)
        self.frame_length      = 60
        self.err_length        = 10
        self.ffe_length = ffe_length
        self.counts        = {}

class Error:
    def __init__(self, error_descript):
        self.error_descript = error_descript

def add_error_decision_node(fpdt, edn):
    return

def find_probalistic_error_children(fpdt, err, std=10e-3, scale=1, N_trials=25):

    frame_length = fpdt.frame_length
    err_descript = err.error_descript

    center_idx = int(frame_length/2)
    error = np.zeros((frame_length,))
    for err_loc, err_val in err_descript:
        error[err_loc + center_idx] = 2*err_val

    error = error[center_idx-fpdt.num_of_errcursors:center_idx-fpdt.num_of_errcursors+fpdt.err_length]
    err_select = np.where(error != 0, 1, 0)
    
    num_of_errors = np.sum(err_select)
    loc_of_errors = list(np.nonzero(error)[0])

    bit_patterns = [[int(bit) for bit in bin(ii)[2:]] for ii in range(2**(len(error)-num_of_errors))]
    bit_patterns = [[0]*(len(error)-len(bit_pattern)-num_of_errors) + bit_pattern for bit_pattern in bit_patterns]
    bit_patterns = [[1 if bit > 0 else -1 for bit in bit_pattern] for bit_pattern in bit_patterns]

    new_bit_patterns = []
    for bit_pattern in bit_patterns:
        new_bit_pattern = deepcopy(bit_pattern)
        for loc in loc_of_errors:
            insert_err = -1 if (error[loc] > 0) else 1
            new_bit_pattern = new_bit_pattern[:loc] + [insert_err] + new_bit_pattern[loc:]
        new_bit_patterns += [new_bit_pattern]
 
    bit_patterns = new_bit_patterns

    err_children = {} 
    counts = {}

    noise_mat = np.zeros((N_trials,fpdt.err_length))
    unfilt_noise_mat = np.zeros((N_trials,frame_length))

    zf_taps = fpdt.zf_taps

    std = find_reasonable_noise_coeff(9e-3, zf_taps, num_of_std=2)*9e-3
    print(std, np.sqrt(np.sum(np.square(zf_taps))))
    base_idx = center_idx + fpdt.num_of_precursors - num_of_errcursors

    energies = []

    for ii in range(N_trials):
        smple_nse, __toss__, __stds__, shft = sample_noise_from_quadrant(err_descript, zf_taps, fpdt.ffe_length, std , frame_length, rand_start=True)
        __std__ = __stds__[-1]
        energy = np.sqrt(np.sum(np.square(np.convolve(fpdt.pulse, smple_nse)[base_idx - shft: base_idx - shft+ fpdt.err_length])))
        energies += [energy]
        #print(__std__)


        if __std__ > std:
            std = std * 1.001
        #    print(f'Increasing STD to {std}')
        unfilt_noise_mat[ii,:] = smple_nse
        noise_mat[ii, :] = np.convolve(fpdt.pulse, smple_nse)[base_idx +shft: base_idx +shft+ fpdt.err_length]


    residual_trace_noise_power = 0

    for ii in range(N_trials):
        residual_trace_noise_power += np.sum(np.square(noise_mat[ii,:] - np.mean(noise_mat, axis=0)))/fpdt.err_length/N_trials
    #for ii in range(N_trials):
    #    plt.plot(noise_mat[ii,:] - np.mean(noise_mat, axis=0))
    #plt.show()
    residual_trace_corr_free = np.convolve(error, fpdt.pulse)[fpdt.num_of_precursors:fpdt.num_of_precursors+fpdt.err_length]
    residual_trace_corr_free_power = np.sum(np.square(residual_trace_corr_free))
    residual_trace_signal = np.convolve(error, fpdt.pulse)[fpdt.num_of_precursors:fpdt.num_of_precursors+fpdt.err_length] + np.mean(noise_mat, axis=0)
    residual_trace_signal_power = np.sum(np.square(residual_trace_signal))
    SNR_corr_free = 10*np.log10(residual_trace_corr_free_power / std**2)
    SNR_std     = 10*np.log10(residual_trace_signal_power / std**2)
    SNR_rst_std = 10*np.log10(residual_trace_signal_power / residual_trace_noise_power)

    fig, axes = plt.subplots(2)
    axes[0].plot(np.convolve(error, fpdt.pulse)[fpdt.num_of_precursors:fpdt.num_of_precursors+fpdt.err_length])
    axes[1].plot(noise_mat.T)
    plt.show()

    plt.plot(residual_trace_signal)
    plt.plot(np.convolve(error, fpdt.pulse)[fpdt.num_of_precursors:fpdt.num_of_precursors+fpdt.err_length])
    plt.show()
    print(residual_trace_noise_power, residual_trace_signal_power/residual_trace_corr_free_power * std**2, std**2)
    print(residual_trace_corr_free_power, residual_trace_signal_power)
    print(SNR_corr_free, 0.5*special.erfc(np.sqrt(residual_trace_corr_free_power/2)/std))
    print(SNR_rst_std, 0.5*special.erfc(np.sqrt(residual_trace_signal_power/residual_trace_noise_power/2)))

    #plt.hist(energies)
    #plt.show()

    #plt.plot(noise_mat.T)
    #plt.show()

    escape_noise = []
    escape_bits  = []
    escape_std   = []
    error_in = stringify(error, func=error_to_string)
    for bit_pattern in bit_patterns:
        for ii in range(N_trials):
            error_out, bit_out, flag_locs, energy, ener_in, escape_flag = error_injection(error, bit_pattern, fpdt.pulse, fpdt, std=std, flip_inject_list=fpdt.flip_patterns, noise=noise_mat[ii,:], unfilt_noise=unfilt_noise_mat[ii,:])
            


            str_error_out = stringify(error_out, func=error_to_string)
            bit_out = stringify([1 if bit > 0 else 0 for bit in bit_out])
            
            if not str_error_out in err_children:
                err_children[str_error_out] = []

            if not str_error_out in counts:
                counts[str_error_out] = (0,0)

            counts[str_error_out] = (counts[str_error_out][0]+1, counts[str_error_out][1]+(ener_in - energy))

            error_out = [(pos-fpdt.num_of_errcursors, err) for pos, err  in enumerate(error_out) if err != 0]
            err_children[str_error_out] += [(error_out, bit_out, fpdt.flip_patterns[flag_locs[0]])]
            #print(error_in, str_error_out, energy)

            if escape_flag:
                escape_noise += [noise_mat[ii,:]]
                escape_bits  += [bit_pattern]
                escape_std   += [np.sqrt(energy)]
                #print(escape_noise[-1], escape_std[-1])

    return err_children, counts, escape_noise, escape_bits, escape_std, np.convolve(error, fpdt.pulse)[fpdt.num_of_precursors:fpdt.num_of_precursors+fpdt.err_length] 


def find_error_children(fpdt, err):
    err_select = np.where(err.error != 0, 1, 0)
    
    num_of_errors = np.sum(err_select)
    loc_of_errors = list(np.nonzero(err.error)[0])

    bit_patterns = [[int(bit) for bit in bin(ii)[2:]] for ii in range(2**(len(err.error)-num_of_errors))]
    bit_patterns = [[0]*(len(err.error)-len(bit_pattern)-num_of_errors) + bit_pattern for bit_pattern in bit_patterns]
    bit_patterns = [[1 if bit > 0 else -1 for bit in bit_pattern] for bit_pattern in bit_patterns]

    new_bit_patterns = []
    for bit_pattern in bit_patterns:
        new_bit_pattern = deepcopy(bit_pattern)
        for loc in loc_of_errors:
            insert_err = -1 if (err.error[loc] > 0) else 1
            new_bit_pattern = new_bit_pattern[:loc] + [insert_err] + new_bit_pattern[loc:]
        new_bit_patterns += [new_bit_pattern]
 
    bit_patterns = new_bit_patterns

    err_children = {} 

    for bit_pattern in bit_patterns:
        error_out, bit_pattern, flag_locs, energy, ener_in = error_injection(err.error, bit_pattern, fpdt.pulse, flip_inject_list=fpdt.flip_patterns)
        str_error_out = stringify(error_out, func=error_to_string)
        bit_pattern = stringify([1 if bit > 0 else 0 for bit in bit_pattern])
        if not str_error_out in err_children:
            err_children[str_error_out] = []

        err_children[str_error_out] += [(error_out, bit_pattern, fpdt.flip_patterns[flag_locs[0]])]


    return err_children

def find_all_paths_to_no_error(fpdt, entry_err, prob=False, scale=1,std=10e-3, target_curs_pos=0):
    if prob:
        err_children, counts = find_probalistic_error_children(fpdt, entry_err, scale=scale,std=std, target_curs_pos=target_curs_pos)
    else:
        err_children = find_error_children(fpdt, entry_err)

    entry_err_str = convert_error_descript_to_string(entry_err.error_descript, fpdt.num_of_errcursors, fpdt.err_length)
    print(err_children)
    exit()
    if entry_err_str not in fpdt._fpdt:
        fpdt._fpdt[entry_err_str] = []

    for err in err_children:
        if err not in fpdt._fpdt[entry_err_str]:
            fpdt._fpdt[entry_err_str] += [err]

    if prob:
        if entry_err_str not in fpdt.counts:
            fpdt.counts[entry_err_str] = {}

        for err in counts:
            if err not in fpdt.counts[entry_err_str]:
                fpdt.counts[entry_err_str][err] = counts[err]
            else:
                fpdt.counts[entry_err_str][err] += counts[err]

    nonzero_errors = [err_children[err][0][0] for err in err_children if np.sum(np.abs(err_children[err][0][0])) > 0]

    if entry_err_str in err_children:
        return 1

    num_of_nonzero_errors = 0

    for err in nonzero_errors:
        num_of_nonzero_errors += find_all_paths_to_no_error(fpdt, Error(err), prob=prob, scale=scale, std=std, target_curs_pos=target_curs_pos)

    return num_of_nonzero_errors

def recursive_print_fpdt(fpdt):
    chain_out_strs = [recursive_print_fpdt_core(fpdt, child) for child in fpdt._fpdt]

    for chain in chain_out_strs:
        for sub_chain in chain:
            print(sub_chain)

    return chain_out_strs

def recursive_print_fpdt_core(fpdt, parent):
    new_out_strs = []

    if parent not in fpdt._fpdt:
        return [parent]

    for child in fpdt._fpdt[parent]:
        if child == parent:
            return [parent]

        child_strs = recursive_print_fpdt_core(fpdt, child)

        for child_str in child_strs:
 
            new_out_strs += [parent + " -> " + child_str]

    return new_out_strs

THIS_DIR = Path(__file__).resolve().parent
sparam_file_list = ["Case4_FM_13SI_20_T_D13_L6.s4p",
                    "peters_01_0605_B1_thru.s4p",  
                    "peters_01_0605_B12_thru.s4p",  
                    "peters_01_0605_T20_thru.s4p",
                    "TEC_Whisper42p8in_Meg6_THRU_C8C9.s4p",
                    "TEC_Whisper42p8in_Nelco6_THRU_C8C9.s4p"]


f_sig = 29e9
channel_length = 30
num_bits = 8.4
num_of_precursors = 4
num_of_errcursors = 2
prob = True
std=35e-3
list_of_ffe_scales=np.array([0.09, 0.28, 0.1376, 0.021, 0.1665, 0.09057])*1.5

list_of_mm_lock_position = [15e-12,15e-12,12e-12,12e-12,3e-12, 15e-12]
list_of_target_curs_pos = [4,8,8,8,9,3]
channel_list = [4]

for ii in channel_list:
    file = sparam_file_list[ii]
    mm_lock_pos = list_of_mm_lock_position[ii]
    scale = list_of_ffe_scales[ii]
    target_curs_pos = list_of_target_curs_pos[ii]
    file_name = str(get_file(f'data/channel_sparam/{file}'))
    t, imp = s4p_to_impulse(str(file_name), 0.1e-12, 20e-9, zs=50, zl=50)

    cursor_position = np.argmax(imp)
    shift_delay = -t[cursor_position] + (num_of_precursors)*1.0/(f_sig)

    #Load the S4P into a channel model
    chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=600000, s4p=file_name, zs=50, zl=50)
    time, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=channel_length, t_delay=shift_delay+mm_lock_pos)


    print(np.sum(np.square(np.convolve(pulse, [0,0,0,2,-2,0,0,0,0,0]))))

    fpdt = FlipPatternDecisionTree([[0], [1], [1,1], [1,1,1,1]], pulse, num_of_precursors, num_of_errcursors, target_curs_pos, 9)
    
    print(f'Channel: {file}')
    #err_out, counts = find_probalistic_error_children(fpdt, Error([(0,1)]), std=std, scale=scale, N_trials=1000)
    #print(convert_error_descript_to_string([(0,1)], num_of_errcursors, 10), counts)

    noise_list = {}
    err_list = {}
    err_out, counts, escape_noise, escape_bits, escape_eng, err_sig  = find_probalistic_error_children(fpdt, Error([(0,1)]), std=std, scale=scale, N_trials=10)
    print(convert_error_descript_to_string([(0,1)], num_of_errcursors, 10), counts)
    #print(escape_eng)
    err_list["+"] = err_sig
    if len(escape_noise) > 0:
        noise_list["+"] = {}
        for (esc_bits, esc_nse) in zip(escape_bits, escape_noise):
            if not stringify(esc_bits, func=bit_to_string) in noise_list["+"]:
                 noise_list["+"][stringify(esc_bits, func=bit_to_string)] = []     
            noise_list["+"][stringify(esc_bits, func=bit_to_string)] += [esc_nse]

    err_out, counts, escape_noise, escape_bits, escape_eng, err_sig = find_probalistic_error_children(fpdt, Error([(0,1), (1,-1)]), std=std, scale=scale, N_trials=10)
    print(convert_error_descript_to_string([(0,1), (1,-1)], num_of_errcursors, 10), counts)
    #print(escape_eng)
    err_list["+-"] = err_sig
    if len(escape_noise) > 0:
        noise_list["+-"] = {}
        for (esc_bits, esc_nse) in zip(escape_bits, escape_noise):
            if not stringify(esc_bits, func=bit_to_string) in noise_list["+-"]:
                 noise_list["+-"][stringify(esc_bits, func=bit_to_string)] = []     
            noise_list["+-"][stringify(esc_bits, func=bit_to_string)] += [esc_nse]

    err_out, counts, escape_noise, escape_bits, escape_eng, err_sig = find_probalistic_error_children(fpdt, Error([(0,1), (2,1)]), std=std, scale=scale, N_trials=200)
    print(convert_error_descript_to_string([(0,1), (2,1)], num_of_errcursors, 10), counts)
    #print(escape_eng)
    err_list["+.+"] = err_sig
    if len(escape_noise) > 0:
        noise_list["+.+"] = {}
        for (esc_bits, esc_nse) in zip(escape_bits, escape_noise):
            if not stringify(esc_bits, func=bit_to_string) in noise_list["+.+"]:
                 noise_list["+.+"][stringify(esc_bits, func=bit_to_string)] = []     
            noise_list["+.+"][stringify(esc_bits, func=bit_to_string)] += [esc_nse]

    err_out, counts, escape_noise, escape_bits, escape_eng, err_sig = find_probalistic_error_children(fpdt, Error([(0,1), (1,-1), (2,1)]), std=std, scale=scale, N_trials=50)
    print(convert_error_descript_to_string([(0,1), (1,-1), (2,1)], num_of_errcursors, 10), counts)
    #print(escape_eng)
    err_list["+-+"] = err_sig
    if len(escape_noise) > 0:
        noise_list["+-+"] = {}
        for (esc_bits, esc_nse) in zip(escape_bits, escape_noise):
            if not stringify(esc_bits, func=bit_to_string) in noise_list["+-+"]:
                 noise_list["+-+"][stringify(esc_bits, func=bit_to_string)] = []     
            noise_list["+-+"][stringify(esc_bits, func=bit_to_string)] += [esc_nse]

    err_out, counts, escape_noise, escape_bits, escape_eng, err_sig = find_probalistic_error_children(fpdt, Error([(0,1), (3,-1)]), std=std, scale=scale, N_trials=10)
    print(convert_error_descript_to_string([(0,1), (3,-1)], num_of_errcursors, 10), counts)
    #print(escape_eng)
    err_list["+..-"] = err_sig
    if len(escape_noise) > 0:
        noise_list["+..-"] = {}
        for (esc_bits, esc_nse) in zip(escape_bits, escape_noise):
            if not stringify(esc_bits, func=bit_to_string) in noise_list["+..-"]:
                 noise_list["+..-"][stringify(esc_bits, func=bit_to_string)] = [] 
            noise_list["+..-"][stringify(esc_bits, func=bit_to_string)] += [esc_nse]

    err_out, counts, escape_noise , escape_bits, escape_eng, err_sig= find_probalistic_error_children(fpdt, Error([(0,1), (1,-1), (2,1), (3,-1)]), std=std, scale=scale, N_trials=100)
    print(convert_error_descript_to_string([(0,1), (1,-1), (2,1), (3,-1)], num_of_errcursors, 10), counts)
    #print(escape_eng)
    err_list["+-+-"] = err_sig
    if len(escape_noise) > 0:
        noise_list["+-+-"] = {}
        for (esc_bits, esc_nse) in zip(escape_bits, escape_noise):
            if not stringify(esc_bits, func=bit_to_string) in noise_list["+-+-"]:
                 noise_list["+-+-"][stringify(esc_bits, func=bit_to_string)] = [] 
            noise_list["+-+-"][stringify(esc_bits, func=bit_to_string)] += [esc_nse]
    continue

    print(noise_list)
    with open(f'channel_{ii}_log.csv', 'a') as f:
        for err_type in noise_list:
            err_str = ",".join([ str(val) for val in list(err_list[err_type])])
            print(err_type, end=',\n', file=f)
            print(err_str, end=',\n', file=f)
            for esc_bits in noise_list[err_type]:
                print(esc_bits, end=',\n', file=f)
                for esc_bit_vec in noise_list[err_type][esc_bits]:
                    esc_nse_str = ",".join([ str(val) for val in list(esc_bit_vec)])
                    print(esc_nse_str, end=',\n', file=f)






