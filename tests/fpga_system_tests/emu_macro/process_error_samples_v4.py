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



if len(sys.argv) <= 2:
    print('Provide directory and at least one file!')
    exit()

directory = sys.argv[1]
files     = sys.argv[2:]

chan_taps = []
with open(f'{directory}/chan_est_vals.txt', 'r') as f:
    chan_taps = np.array([float(line.strip()) for line in f.readlines()])
print(chan_taps)

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



def stringify(arr):
    err_str = ""
    for ii, err in enumerate(arr):
        if err == 2:
            err_str += f'+{ii}'
        elif err == -2:
            err_str += f'-{ii}'
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
for data in data_sets:
    valuable_data += 1

    error_loc    = np.nonzero(data[1]==1)[0][0]
    polarity_loc = error_loc 
    error_pol    = data[2][polarity_loc] * 2 - 1 

    print(data[0][error_loc-4+10:])
    print(data[1][error_loc-4+1:])
    print(data[2][error_loc-4+2:])
    print(data[3][error_loc-4+2:])

    act_errors = np.zeros((36,), dtype=np.int32)
    for ii in range(len(act_errors)):
        if data[1][ii] > 0:
            act_errors[ii] = 2 if data[2][ii] > 0 else -2
    
    act_errors *= error_pol
    error_seq = stringify(act_errors[error_loc-4+2:])

    if error_seq not in labeled_errors:
        labeled_errors[error_seq] = []
    labeled_errors[error_seq] += [data[0][error_loc-3:]*error_pol]
    print(act_errors)

print(labeled_errors.keys())

for error_seq in labeled_errors:
    for data in labeled_errors[error_seq]:
        plt.plot(data)
    plt.title(error_seq)
    plt.show()