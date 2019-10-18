from dragonphy import *
from verif.fir.fir import Fir

import numpy as np
import matplotlib.pyplot as plt


def plot_histogram(ffe_out, ideal_in, delay_ffe=0, delay_ideal=0, bins=50, plt_show=True, save_dir=None, title="FFE Output Histogram"):
    ideal_in = ideal_in[delay_ideal:-1]
    ffe_out = ffe_out[delay_ffe:-1]
    arr_len = min(len(ideal_in), len(ffe_out))

    pos = np.array([ffe_out[i] for i in range(arr_len) if ideal_in[i] >= 0])
    neg = np.array([ffe_out[i] for i in range(arr_len) if ideal_in[i] < 0])

    f, (ax1, ax2) = plt.subplots(2, 1)

    ax1.hist(pos, bins, alpha=0.5, label="+")
    ax1.hist(neg, bins, alpha=0.5, label="-")
    ax1.set_title('Overlayed Histogram')
    
    total = np.array([pos, neg])
    ax2.hist(total, bins, stacked=True, alpha=0.5)
    ax2.set_title('Stacked Histogram')    

    f.suptitle(title)
    f.legend(loc='upper right')

    if save_dir is not None:
       plt.savefig(save_dir + str('/histogram')) 

    if plt_show:
        plt.show() 

def plot_multi_hist(ffe_out, ideal_in, delay_ffe=0, delay_ideal=0, bins=50, n_bits=1, bit_pos=0, plt_show=True, save_dir=None, print_err=False):
    ideal_in = np.clip(ideal_in[delay_ideal:-1], 0, None)
    ffe_out = ffe_out[delay_ffe:-1]
    arr_len = min(len(ideal_in), len(ffe_out))

    assert(bit_pos < n_bits)
    ideal_in_seq = np.array([np.array2string(ideal_in[i:i+n_bits], separator='')[1:-1] for i in range(arr_len-n_bits+1)])
    ffe_out_seq = np.array([ffe_out[i:i+n_bits][bit_pos] for i in range(arr_len-n_bits+1)])

    # TODO: This is broken 
    if print_err:
        mismatch_1 = 0
        mismatch_0 = 0
        for i in range(len(ideal_in_seq)):
            if ideal_in_seq[bit_pos] == '1' and ffe_out[i] < 0:
                mismatch_1 += 1
            elif ideal_in_seq[bit_pos] == '0' and ffe_out[i] > 0:
                mismatch_0 += 1
        print(f'Number errors: {mismatch_1 + mismatch_0}')

    f, ax = plt.subplots(2, 1) 
    ax[0].set_title('Overlayed Histogram')

    bit_patterns = generate_bit_patterns(n_bits) 


    total = []
    for bp in bit_patterns:
        match_seq = np.array([ffe_out_seq[i] for i in range(len(ideal_in_seq)) if ideal_in_seq[i] == bp])
        total.append(match_seq)
        ax[0].hist(match_seq, bins, alpha=0.5, label=bp)
        
    ax[1].hist(total, 2**n_bits*bins, stacked=True, alpha=0.5)
    ax[1].set_title('Stacked Histogram') 

    f.suptitle('FFE Output Histogram, len = ' + str(n_bits) + ', loc = ' + str(bit_pos))
    f.legend(loc='upper right') 

    if save_dir is not None:
        plt.savefig(save_dir + str('/histogram'))

    if plt_show:
        plt.show()
        
def generate_bit_patterns(n=1):
    return generate_bits(n, [''])

def generate_bits(n, bit_list):
    result = []
    for b in bit_list:
        result.append(b+'1')
        result.append(b+'0')
    if n == 0: 
        return bit_list
    elif n == 1:
        return result
    else:
        return generate_bits(n-1, result)

def plot_comparison(ffe_out, ideal, delay_ffe=0, delay_ideal=0, length=100, plt_show=True, save_dir=None, scale=1, labels=None):
    fig = plt.figure()
    if labels is not None:
        plt.plot(scale*ideal[delay_ideal:delay_ideal + length], label=labels[0])
        plt.plot(ffe_out[delay_ffe:delay_ffe + length], label=labels[1])
        fig.suptitle(labels[0] + " vs. " + labels[1])
        fig.legend(loc='upper right')
    else:
        plt.plot(scale*ideal[delay_ideal:delay_ideal + length])
        plt.plot(ffe_out[delay_ffe:delay_ffe + length])

    if save_dir is not None:
       plt.savefig(save_dir + str('/comparison')) 

    if plt_show:
        plt.show() 


def main():
    plot_histogram([1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], [1, -1, 1, 1, 1, -1, 1, -1, 1, -1, 1, 1, 1, 1])
    

# Used for testing only
if __name__ == "__main__":
    main()

