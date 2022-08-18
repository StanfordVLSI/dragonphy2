import matplotlib.pyplot as plt 
import numpy as np
import sys
from tqdm import tqdm

from software_error_corrector import error_checker

def read_array(f):
    arr_text = ""

    while True:
        line = f.readline()
        if line == '':
            return 1, []

        arr_text += " " + line.strip()
        if ']' in line:
            break

    arr = np.array([int(val) for val in arr_text[2:-1].split('.')[:-1]])
    return 0, arr



if len(sys.argv) <= 1:
    print('Please provide at least one file!')
    exit()


zf_taps = []
with open('ffe_vals.txt', 'r') as f:
    zf_taps = np.array([int(line.strip()) for line in f.readlines()])



chan_taps = []
with open('chan_est_vals.txt', 'r') as f:
    chan_taps = np.array([float(line.strip()) for line in f.readlines()])

data_sets = []
for filename in sys.argv[1:]:
    print(filename)
    with open(filename, 'r') as f:
        done = False
        while not done:
            arr = [0,0,0,0]

            for ii in range(4):
                status, arr[ii] = read_array(f)
                if status:
                    done = True
                    break

            data_sets += [arr]
        data_sets = data_sets[:-1]
print(len(data_sets))

plot_out = False


est_chan = np.zeros((15,))
num_ave = 0
#Error Trace

if plot_out:
    fig, axes = plt.subplots(5,1)
    fig2, axes2 = plt.subplots(5,1)
    fig3, axes3 = plt.subplots(5,1)
    fig4, axes4 = plt.subplots(5,1)

    axes[0].plot(np.array(range(len(chan_taps))) - 2,  2*chan_taps)
    axes[1].plot(np.array(range(len(chan_taps)+1)) - 2,  np.convolve([2,-2], chan_taps))

valuable_data = 0
single_bit = 0
double_bit = 0
triple_bit = 0



def stringify(arr):
    mapper = {-2:'-', 0 :'0', +2 : '+'}
    return "".join([mapper[ar] for ar in arr])


def create_cond_print(debug=True):
    if debug:
        def cond_print(*args, **kwargs):
            print(*args, **kwargs)
    else:
        def cond_print(*args, **kwargs):
            pass
    return cond_print


debug = True


c_print = create_cond_print(debug=debug)
for expon in [1]: # [1, 1.05, 1.1, 1.15, 1.2, 1.25, 1.3, 1.35, 1.5, 1.7, 2]:
    iter_item = tqdm(data_sets) if not debug else data_sets
    error_statistics = {}
    applied_flag_error_statistics = {}
    error_transistions = {}
    soft_app_flag_error_statistics = {}
    soft_err_transistions = {}
    total_num_errors = 0
    total_num_errors_pf = 0
    total_num_errors_pf_sft = 0
    for data in iter_item:
        #if sum(data[3]) == 0:
        #    continue

        #total_num_errors += sum(data[1])

        if sum(data[1]) == 1:
            single_bit += 1
        if sum(data[1]) == 2:
            double_bit += 1
        if sum(data[1]) == 3:
            triple_bit += 1

        valuable_data += 1
        error_loc = np.nonzero(data[1]==1)[0][0] + 2
        polarity_loc = error_loc - 2 #removing channel shift!
        error_pol = data[2][polarity_loc] * 2 - 1 


        select_data_3 = np.zeros((48,), dtype=np.int32)
        select_data_3[8:32] = data[3]



       # if sum(select_data_3[error_loc-8:error_loc]) != sum(data[3]):
       #     c_print('Bypassing questionable error log - PRBS contamination')
        #    continue

        act_errors = np.zeros((9,), dtype=np.int32)

        for ii in range(len(act_errors)):
            if data[1][error_loc+ii-4] > 0:
                act_errors[ii] = 2 if data[2][error_loc+ii-4] > 0 else -2

        act_errors *= error_pol

        total_num_errors += sum(np.abs(act_errors)/2)

        error_seq = stringify(act_errors)

        if plot_out and error_seq == "00+-0-+00":
            idx = np.array(list(range(len(data[0])))) - error_loc 
            conv_idx = np.array(list(range(len(data[0])+10 - 1))) - error_loc
            axes[sum(data[1])-1].plot(idx, data[0]*error_pol)
            axes2[sum(data[1])-1].plot(conv_idx, np.convolve(zf_taps, data[0])*error_pol)
        
        c_print('-----------------')
        c_print('Number Of Errors: ', sum(data[1]))
        if (error_loc < 12):
            c_print('Truncated Flag Information')



        c_print('Error Sequence: ', error_seq)

        if not error_seq in error_statistics:
            error_statistics[error_seq] = 0
        error_statistics[error_seq] += 1

        c_print('PRBS Flags: ', data[1][error_loc-2:error_loc+6])


        c_print('Checker Flags: ', select_data_3[error_loc-8:error_loc])
        energies = error_checker(data[0][error_loc-2:error_loc+1+9], data[2][error_loc-4:error_loc+4], chan_taps.astype(np.int64), 2,3,8, flip_pattern_list=[[0,0,0], [0,1,0],[1,1,0],[1,1,1],[1,0,1]])

        print(data[0][error_loc-2:error_loc+1+9])
        print(energies.T)

        alternative_flags = np.argmin(energies, axis=1)
        alternative_energies = np.min(energies, axis=1)
        alternative_energies = np.array(np.where(alternative_flags == 0, 999999, alternative_energies), dtype=np.int32) 

        print('SCheckr Flags: ', alternative_flags)
        print('SCheckr Energ: ', alternative_energies)
        c_print('Flip Profile')


        total_flips = np.zeros((9,), dtype=np.int32)
        if len(select_data_3[error_loc-4:error_loc+4]) != 0:
            for ii in range(len(select_data_3[error_loc-4:error_loc+4])-1):
                zeros = np.array([0]*9)
                if select_data_3[error_loc-4+ii] == 1:
                    zeros[ii+1] = 1
                elif select_data_3[error_loc-4+ii] == 2:
                    zeros[ii] = 1
                    zeros[ii+1] = 1
                elif select_data_3[error_loc-4+ii] == 3:
                    zeros[ii] = 1
                    zeros[ii+1] = 1
                    zeros[ii+2] = 1
                c_print(zeros)
                total_flips += zeros
        c_print('Sum Of Flips')
        c_print(total_flips)

        best_inj = np.zeros((9,), dtype=np.int32)
        best_res = np.copy(data[0])
        best_ener = 9999999999999#np.sum(np.square(data[0]))


        sorted_inj = []
        sorted_res = []
        sorted_ener = np.ones((8,), dtype=np.int32) * 99999999999


        def create_legal_error_pattern(flip_num, bits, start=0, length=8, flip_pattern_list=[[0,0,0], [0,1,0],[1,1,0],[1,1,1], [1,0,1]]):
            inj_pat = np.zeros((length,), dtype=np.int64)
            flips = flip_pattern_list[flip_num]
            inj_pat[start:start+len(flips)] = np.array([2*(2*bit-1) if flip > 0 else 0 for (bit, flip) in zip(bits[start:start+len(flips)], flips)])

            return inj_pat, flip_num > 0

        #print(np.argmin(energies, axis=1), np.min(energies,axis=1))
        for ii in range(len(select_data_3[error_loc-8:error_loc+0])-1):
            inj_pat, no_error = create_legal_error_pattern(select_data_3[error_loc-8+ii], data[2][error_loc-4:error_loc+5], start=ii, length=9,  flip_pattern_list=[[0,0,0], [0,1,0],[1,1,0],[1,1,1]])

            if not no_error:
                continue

            inj_err= np.convolve(chan_taps.astype(np.int64), inj_pat)
            new_data = np.copy(data[0])
            new_data[error_loc:error_loc+15] -= inj_err[0:15]
            new_ener = np.sum(np.square(new_data)[error_loc-2+ii-1:error_loc-2+ii+2]) * ((expon) ** ii)
            old_ener = np.sum(np.square(data[0])[error_loc-1+ii-1:error_loc-1+ii+2]) 

            c_print(data[0][error_loc-1+ii-1:error_loc-1+ii+2])
            c_print(new_data[error_loc-1+ii-1:error_loc-1+ii+2])
            c_print(data[0][error_loc-5:error_loc-5+15])
            c_print(new_data[error_loc-5:error_loc-5+15])
            c_print(stringify(inj_pat), new_ener, best_ener, old_ener)

            if new_ener > old_ener:
                c_print('odd behavior!')
            if new_ener < best_ener:
                best_ener = new_ener
                best_inj  = inj_pat
                best_res  = new_data

            loc = np.where(new_ener < sorted_ener)[0][0]    
            sorted_ener[loc+1:] = sorted_ener[loc:-1]
            sorted_ener[loc]  = new_ener
        


        if plot_out and error_seq == "00+-0-+00":
            idx = np.array(list(range(len(best_res)))) - error_loc 
            conv_idx = np.array(list(range(len(best_res)+10 - 1))) - error_loc
            axes3[np.sum(data[1])-1].plot(idx, np.array(best_res)*error_pol)
            axes4[np.sum(data[1])-1].plot(conv_idx, np.convolve(zf_taps, best_res)*error_pol)


        best_soft_loc = np.argmin(alternative_energies)
        best_soft_flag = alternative_flags[best_soft_loc]

        best_soft_inj, _no_error_ = create_legal_error_pattern(best_soft_flag, data[2][error_loc-4:error_loc+5], start=best_soft_loc, length=9)

        #best_soft_res = np.copy(data[0])
        #best_soft_res[error_loc-6:error_loc-1+15] -= np.convolve(chan_taps.astype(np.int64), best_soft_inj)[0:15]
        #print(best_soft_res[error_loc-6:error_loc+10])
        #print(data[0][error_loc-6:error_loc+10])
        #print(np.convolve(chan_taps.astype(np.int64), best_soft_inj)[0:15])
        #energies = error_checker(best_soft_res[error_loc-2:error_loc+1+9], data[2][error_loc-4:error_loc+4], chan_taps.astype(np.int64), 2,3,8, flip_pattern_list=[[0,0,0], [0,1,0],[1,1,0]])
        #alternative_flags_2 = np.argmin(energies, axis=1)
        #alternative_energies_2 = np.min(energies, axis=1)
        #alternative_energies_2 = np.array(np.where(alternative_flags_2 == 0, 999999, alternative_energies_2), dtype=np.int32) 
#
        #print(alternative_flags_2)
        #print(alternative_energies_2)
#
        #best_soft_loc = np.argmin(alternative_energies_2)
        #best_soft_flag = alternative_flags_2[best_soft_loc]
#
#
#
        #best_soft_inj_2, _no_error_ = create_legal_error_pattern(best_soft_flag, data[2][error_loc-4:error_loc+5], start=best_soft_loc, length=9)


        sft_act_errors = act_errors - best_soft_inj*error_pol# - best_soft_inj_2*error_pol
        act_errors -= best_inj*error_pol

        total_num_errors_pf += sum(np.abs(act_errors)/2)
        total_num_errors_pf_sft += sum(np.abs(sft_act_errors)/2)
        orig_seq = error_seq
        error_seq= stringify(act_errors)
        soft_seq  = stringify(sft_act_errors)

        c_print(f'Applied Flag Error Sequence: {orig_seq} -> {error_seq}')
        c_print(f'Sft App Flag Error Sequence: {orig_seq} -> {soft_seq}')

        if not error_seq in applied_flag_error_statistics:
            applied_flag_error_statistics[error_seq] = 0
        applied_flag_error_statistics[error_seq] += 1

        if not soft_seq in soft_app_flag_error_statistics:
            soft_app_flag_error_statistics[soft_seq] = 0
        soft_app_flag_error_statistics[soft_seq] += 1

        if not orig_seq in error_transistions:
            error_transistions[orig_seq] = {}

        if not error_seq in error_transistions[orig_seq]:
            error_transistions[orig_seq][error_seq] = 0
        error_transistions[orig_seq][error_seq] += 1

        if not orig_seq in soft_err_transistions:
            soft_err_transistions[orig_seq] = {}

        if not soft_seq in soft_err_transistions[orig_seq]:
            soft_err_transistions[orig_seq][soft_seq] = 0
        soft_err_transistions[orig_seq][soft_seq] += 1

    if plot_out:
        plt.show()

    print(expon, valuable_data, single_bit, double_bit, triple_bit)
    print(single_bit + 2*double_bit + 3*triple_bit + 4*(valuable_data-single_bit -double_bit - triple_bit))
    print(error_statistics)
    print('Act Flags')
    print(applied_flag_error_statistics)
    print(error_transistions)
    print('Sft Flags')
    print(soft_app_flag_error_statistics)
    print(soft_err_transistions)
    print(total_num_errors, total_num_errors_pf, total_num_errors_pf_sft)
