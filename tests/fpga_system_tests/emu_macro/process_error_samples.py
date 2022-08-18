import matplotlib.pyplot as plt 
import numpy as np
import sys
from tqdm import tqdm
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
    with open(sys.argv[1], 'r') as f:
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
    total_num_errors = 0
    total_num_errors_pf = 0
    for data in iter_item:
        if sum(data[3]) == 0:
            continue

        #total_num_errors += sum(data[1])

        if sum(data[1]) == 1:
            single_bit += 1
        if sum(data[1]) == 2:
            double_bit += 1
        if sum(data[1]) == 3:
            triple_bit += 1

        valuable_data += 1
        error_loc = np.nonzero(data[1]==1)[0][0] - 6
        polarity_loc = error_loc - 2 #removing channel shift!
        error_pol = data[2][polarity_loc] * 2 - 1 

        if plot_out:
            idx = np.array(list(range(len(data[0])))) - error_loc 
            conv_idx = np.array(list(range(len(data[0])+10 - 1))) - error_loc
            axes[sum(data[1])-1].plot(idx, data[0]*error_pol)
            axes2[sum(data[1])-1].plot(conv_idx, np.convolve(zf_taps, data[0])*error_pol)
        
        c_print('-----------------')
        c_print('Number Of Errors: ', sum(data[1]))
        if (error_loc < 12):
            c_print('Truncated Flag Information')


        act_errors = np.zeros((8,), dtype=np.int32)

        for ii in range(len(act_errors)):
            if data[1][error_loc+4+ii] > 0:
                act_errors[ii] = 2 if data[2][error_loc-4+ii] > 0 else -2

        act_errors *= error_pol

        total_num_errors += sum(np.abs(act_errors)/2)

        error_seq = stringify(act_errors)
        c_print('Error Sequence: ', error_seq)

        if not error_seq in error_statistics:
            error_statistics[error_seq] = 0
        error_statistics[error_seq] += 1

        c_print('PRBS Flags: ', data[1][error_loc+4:error_loc+12])

        select_data_3 = np.zeros((48,), dtype=np.int32)
        select_data_3[8:32] = data[3]

        c_print('Checker Flags: ', select_data_3[error_loc-4:error_loc+4])

        c_print('Flip Profile')


        total_flips = np.zeros((8,), dtype=np.int32)
        if len(select_data_3[error_loc-4:error_loc+4]) != 0:
            for ii in range(len(select_data_3[error_loc-4:error_loc+4])-1):
                zeros = np.array([0]*8)
                if select_data_3[error_loc-4+ii] == 1:
                    zeros[ii+1] = 1
                elif select_data_3[error_loc-4+ii] == 2:
                    zeros[ii] = 1
                elif select_data_3[error_loc-4+ii] == 3:
                    zeros[ii] = 1
                    zeros[ii+1] = 1
                c_print(zeros)
                total_flips += zeros
        c_print('Sum Of Flips')
        c_print(total_flips)

        best_inj = np.zeros((8,))
        best_res = np.copy(data[0])
        best_ener = 9999999999999#np.sum(np.square(data[0]))
        for ii in range(len(select_data_3[error_loc-4:error_loc+4])-1):
            inj_pat = np.array([0]*8)
            if select_data_3[error_loc-4+ii] == 1:
                inj_pat[ii+1] = 2 if data[2][error_loc-4+ii+1] > 0 else -2
            elif select_data_3[error_loc-4+ii] == 2:
                inj_pat[ii] = 2 if data[2][error_loc-4+ii] > 0 else -2
            elif select_data_3[error_loc-4+ii] == 3:
                inj_pat[ii] = 2 if data[2][error_loc-4+ii] > 0 else -2
                inj_pat[ii+1] = 2 if data[2][error_loc-4+ii+1] > 0 else -2
            else:
                continue

            inj_err= np.convolve(chan_taps.astype(np.int64), inj_pat)

            new_data = np.copy(data[0])
            new_data[error_loc-4:error_loc-4+15] -= inj_err[0:15]
            new_ener = np.sum(np.square(new_data)[error_loc-2+ii-1:error_loc-2+ii+2]) * ((expon) ** ii)
            old_ener = np.sum(np.square(data[0])[error_loc-2+ii-1:error_loc-2+ii+2]) 

            c_print(data[0][error_loc-2+ii-1:error_loc-2+ii+2])
            c_print(new_data[error_loc-2+ii-1:error_loc-2+ii+2])
            c_print(data[0][error_loc-5:error_loc-5+15])
            c_print(new_data[error_loc-5:error_loc-5+15])
            c_print(stringify(inj_pat), new_ener, best_ener, old_ener)
            if new_ener < best_ener:
                best_ener = new_ener
                best_inj  = inj_pat
                best_res  = new_data

        if plot_out:
            idx = np.array(list(range(len(best_res)))) - error_loc 
            conv_idx = np.array(list(range(len(best_res)+10 - 1))) - error_loc
            axes3[np.sum(data[1])-1].plot(idx, np.array(best_res)*error_pol)
            axes4[np.sum(data[1])-1].plot(conv_idx, np.convolve(zf_taps, best_res)*error_pol)

        act_errors -= best_inj*error_pol

        total_num_errors_pf += sum(np.abs(act_errors)/2)

        error_seq= stringify(act_errors)

        c_print(f'Applied Flag Error Sequence: ', error_seq)

        if not error_seq in applied_flag_error_statistics:
            applied_flag_error_statistics[error_seq] = 0
        applied_flag_error_statistics[error_seq] += 1

    if plot_out:
        plt.show()

    print(expon, valuable_data, single_bit, double_bit, triple_bit)
    print(single_bit + 2*double_bit + 3*triple_bit + 4*(valuable_data-single_bit -double_bit - triple_bit))
    print(error_statistics)
    print(applied_flag_error_statistics)
    print(total_num_errors, total_num_errors_pf)
