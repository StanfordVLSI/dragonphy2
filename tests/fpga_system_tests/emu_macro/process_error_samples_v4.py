import matplotlib.pyplot as plt 
import numpy as np
import sys
from tqdm import tqdm

from dragonphy import ViterbiState, run_error_viterbi, run_iteration_error_viterbi, create_init_viterbi_state

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



if len(sys.argv) <= 2:
    print('Provide directory and at least one file!')
    exit()

directory = sys.argv[1]
files     = sys.argv[2:]

chan_taps = []
with open(f'{directory}/chan_est_vals.txt', 'r') as f:
    chan_taps = np.array([float(line.strip()) for line in f.readlines()])/8
print(chan_taps / 128)

data_sets = []
for filename in files:
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



def stringify_err(arr):
    err_str = ""
    for ii, err in enumerate(arr):
        if err == 2:
            err_str += f'+{ii}'
        elif err == -2:
            err_str += f'-{ii}'
    return err_str

def stringify_pf(arr):
    err_str = ""
    for ii, err in enumerate(arr):
        if err == 1:
            err_str += f'f{ii}'
    return err_str


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
labeled_errors = {}
false_positives = 0
for data in data_sets:
    valuable_data += 1
    skewed_data = []
    for ii in range(int(len(data[1])/2)):
        if sum(data[1][2*ii:2*ii+1+1]) == 1:
                skewed_data += [1]
        elif sum(data[1][2*ii:2*ii+1+1]) == 0:
            skewed_data += [0]
        else:
            print(data[0])
            print(data[1])
            print('WHAT?')
            


    try:
        error_loc    = np.nonzero(np.array(skewed_data)>0)[0][0]

    except IndexError:
        false_positives += 1
        print('False Positive Detected')
        continue
    polarity_loc = error_loc + 4
    #error_pol    = data[2][polarity_loc] * 2 - 1 

    x1 = np.arange(0, len(data[0]), 1) - error_loc - 2
    x2 = np.arange(0, len(skewed_data), 1) - error_loc
    x3 = np.arange(0, len(data[2]), 1) - error_loc - 4

    polarity = 1 if data[3][polarity_loc] % 2 == 1 else -1

    #plt.plot(x1, polarity*data[0])
    #print(data[0][error_loc-4+10:])
    #print(data[1][error_loc-4+1:])
    #print(data[2][error_loc-4+2:])
    #print(data[3][error_loc-4+2:])


    flag_seq = stringify_pf(skewed_data[error_loc-2:])
    lbl = str(data[3][polarity_loc])#//2 - 1 if data[3][polarity_loc] % 2 == 0 else (data[3][polarity_loc]-1)//2 - 1)
    if lbl not in labeled_errors:
        labeled_errors[lbl] = []
    labeled_errors[lbl] += [data[0][error_loc+2-10:]]

    if lbl == '0' or lbl == '1':
        #plt.plot(x1, polarity*data[0])
        plt.plot(data[0][error_loc-4+10-5-9:])
        #print(data[1][error_loc-4+1:])
        #print(data[2][error_loc-4+2:])
        plt.plot(data[3][error_loc-4+2-5:])
        plt.show()
    #print(act_errors)
#plt.show()

#print(labeled_errors.keys())
print(false_positives, valuable_data)
for error_seq in labeled_errors:
    for data in labeled_errors[error_seq]:
        plt.plot(data)
    plt.title(error_seq)
    plt.show()

if '0' in labeled_errors:
    total_list = []
    for item in labeled_errors['0']:
        total_list += list(item)

    plt.hist(total_list, bins=40)
    plt.show()