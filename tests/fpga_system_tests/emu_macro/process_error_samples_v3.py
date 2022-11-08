import matplotlib.pyplot as plt 
import numpy as np
import sys
from tqdm import tqdm

from software_error_corrector import error_checker, flag_applicator, wider_flag_applicator

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
print(chan_taps)

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
valuable_data = 0
#Error Trace

if plot_out:
    fig, axes = plt.subplots(5,1)
    fig2, axes2 = plt.subplots(5,1)
    fig3, axes3 = plt.subplots(5,1)
    fig4, axes4 = plt.subplots(5,1)

    axes[0].plot(np.array(range(len(chan_taps))) - 2,  2*chan_taps)
    axes[1].plot(np.array(range(len(chan_taps)+1)) - 2,  np.convolve([2,-2], chan_taps))



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

def create_legal_error_pattern(flip_num, bits, start=0, length=8, flip_pattern_list=[[0,0,0,0], [0,1,0,0],[1,1,0,0],[1,1,1,0],[1,0,1,0],[1,1,1,1]]):
    inj_pat = np.zeros((length,), dtype=np.int64)
    flips = flip_pattern_list[flip_num]
    inj_pat[start:start+len(flips)] = np.array([2*(2*bit-1) if flip > 0 else 0 for (bit, flip) in zip(bits[start:start+len(flips)], flips)])

    return inj_pat, flip_num > 0

def create_legal_error_inject(flips, bits, start=0, length=8):
    inj_pat = np.zeros((length,), dtype=np.int64)
    inj_pat[start:start+len(flips)] = np.array([2*(2*bit-1) if flip > 0 else 0 for (bit, flip) in zip(bits[start:start+len(flips)], flips)])

    return inj_pat, np.sum(flips) > 0

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
        flip_pattern_list = [[[0,0,0,0], [0,1,0,0], [1,1,0,0], [1,1,1,0], [1,0,1,0], [1,1,1,1]], 
                             [[0,0,0],   [0,1,0],   [1,1,0]], 
                             [[0,0,0],   [0,1,0]]]
        
        flip_pattern_depth = [4,3,3]
        
        checker_config     = [4,3,3]

        metric = np.square

        valuable_data += 1
        error_loc    = np.nonzero(data[1]==1)[0][0] + 2
        polarity_loc = error_loc - 2 #removing channel shift!
        error_pol    = data[2][polarity_loc] * 2 - 1 


        act_errors = np.zeros((48,), dtype=np.int32)

        for ii in range(len(act_errors)):
            if data[1][ii] > 0:
                act_errors[ii] = 2 if data[2][ii] > 0 else -2

        act_errors *= error_pol

        total_num_errors += sum(np.abs(act_errors[error_loc-8:error_loc+8])/2)
        error_seq = stringify(act_errors)[error_loc-4:error_loc+5]


        c_print('-----------------')
        c_print('Number Of Errors: ', sum(data[1]), error_loc)
        if (error_loc < 12):
            c_print('Truncated Flag Information')

        c_print('Error Sequence: ', error_seq)

        if not error_seq in error_statistics:
            error_statistics[error_seq] = 0
        error_statistics[error_seq] += 1

        c_print('PRBS Flags: ', data[1][error_loc-4:error_loc+6])


        
        best_soft_res = np.copy(data[0])
        total_soft_inj = np.zeros((48,))
        for ii in range(3):

            energies = error_checker(best_soft_res[2:], data[2][:-2], chan_taps.astype(np.int64), 2, checker_config[ii], 42, flip_pattern_list=flip_pattern_list[ii], metric=metric)

            best_flags = np.argmin(energies, axis=1)
            best_energies = np.min(energies, axis=1)
            best_energies = np.array(np.where(best_flags == 0, 999999, best_energies), dtype=np.int32)


            best_flip_bit = wider_flag_applicator(best_flags, best_energies, 16, 8, flip_pattern_depth[ii], flip_pattern_list=flip_pattern_list[ii])
            best_soft_inj, _no_error_ = create_legal_error_inject(best_flip_bit[:-2], data[2][:-2], start=0, length=48)

            #best_flag_loc = np.argmin(best_energies)
            #ibest_soft_inj, _no_error_ =create_legal_error_pattern(best_flags[best_flag_loc], data[2][:-2], start=best_flag_loc, length=48, flip_pattern_list=flip_pattern_list[ii])


            best_soft_res -= np.convolve(chan_taps.astype(np.int64), best_soft_inj)[0:48]

            total_soft_inj += best_soft_inj


        sft_act_errors = act_errors - total_soft_inj*error_pol
        soft_seq  = stringify(sft_act_errors)
        soft_seq = soft_seq[error_loc-8:error_loc+8]
        total_num_errors_pf_sft += sum(np.abs(sft_act_errors[error_loc-8:error_loc+8])/2)

        orig_seq = error_seq


        c_print(f'Sft App Flag Error Sequence: {orig_seq} -> {soft_seq}')



        if not soft_seq in soft_app_flag_error_statistics:
            soft_app_flag_error_statistics[soft_seq] = 0
        soft_app_flag_error_statistics[soft_seq] += 1

        if not orig_seq in soft_err_transistions:
            soft_err_transistions[orig_seq] = {}

        if not soft_seq in soft_err_transistions[orig_seq]:
            soft_err_transistions[orig_seq][soft_seq] = 0
        soft_err_transistions[orig_seq][soft_seq] += 1

    if plot_out:
        plt.show()

    print(error_statistics)
    print('Sft Flags')
    print(soft_app_flag_error_statistics)
    print('Corrected Sft Flags')
    for nam in soft_err_transistions.keys():
        print(nam, soft_err_transistions[nam])
    #print(soft_err_transistions)
    print(total_num_errors, total_num_errors_pf_sft)
