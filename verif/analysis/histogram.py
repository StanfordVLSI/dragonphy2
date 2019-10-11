from dragonphy import *
from verif.fir.fir import Fir

import numpy as np
import matplotlib.pyplot as plt


def plot_histogram(ffe_out, ideal_in, delay_ffe=0, delay_ideal=0, bins=50, plt_show=True, save_dir=None):
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

    f.suptitle('FFE Output Histogram')
    f.legend(loc='upper right')

    if save_dir is not None:
       plt.savefig(save_dir + str('/histogram')) 

    if plt_show:
        plt.show() 

def plot_multi_hist(ffe_out, ideal_in, delay_ffe=0, delay_ideal=0, bins=50, n_bits=1, plt_show=True, save_dir=None):
    ideal_in = np.clip(ideal_in[delay_ideal:-1], 0, None)
    ffe_out = ffe_out[delay_ffe:-1]
    arr_len = min(len(ideal_in), len(ffe_out))
    
    ideal_in_seq = np.array([np.array2string(ideal_in[i:i+n_bits], separator='')[1:-1] for i in range(arr_len-n_bits+1)])
    ffe_out_seq = np.array([np.sum(ffe_out[i:i+n_bits]) for i in range(arr_len-n_bits+1)])

    f, ax = plt.subplots(2, 1) 
    ax[0].set_title('Overlayed Histogram')

    bit_patterns = generate_bit_patterns(n_bits) 
    print(bit_patterns)
    print(ideal_in_seq)
    total = []
    for bp in bit_patterns:
        match_seq = np.array([ffe_out_seq[i] for i in range(len(ideal_in_seq)) if ideal_in_seq[i] == bp])
        total.append(match_seq)
        ax[0].hist(match_seq, bins, alpha=0.5, label=bp)
        
    ax[1].hist(total, bins, stacked=True, alpha=0.5)
    ax[1].set_title('Stacked Histogram') 

    f.suptitle('FFE Output Histogram, len = ' + str(n_bits))
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

def plot_comparison(ffe_out, ideal, delay_ffe=0, delay_ideal=0, length=100, plt_show=True, save_dir=None, scale=1):
    fig = plt.figure()
    plt.plot(scale*ideal[delay_ideal:delay_ideal + length], label='ideal')
    plt.plot(ffe_out[delay_ffe:delay_ffe + length], label='ffe out')
    
    fig.suptitle('Ideal Codes vs. FFE Output')
    fig.legend(loc='upper right')

    if save_dir is not None:
       plt.savefig(save_dir + str('/comparison')) 

    if plt_show:
        plt.show() 


def main():
    #plot_histogram([1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], [1, -1, 1, 1, 1, -1, 1, -1, 1, -1, 1, 1, 1, 1])
    test_fir()

def test_fir():
    iterations = 200000
    pos = 2
    resp_len = 125
    bitwidth = 8

    ideal_codes = np.random.randint(2, size=iterations)*2 - 1

    chan = Channel(channel_type='skineffect', normal='area', tau=2, sampl_rate=5, cursor_pos=pos, resp_depth=resp_len)
    chan_out = chan(ideal_codes)

    #plot_histogram(chan_out, ideal_codes[pos:-1])
    
    qc = Quantizer(bitwidth, signed=True)
    quantized_chan_out = qc.quantize_2s_comp(chan_out)
    adapt = Wiener(step_size = 0.1, num_taps = 5, cursor_pos=pos)

    for i in range(iterations-pos):
        adapt.find_weights_pulse(ideal_codes[i-pos], chan_out[i])   

    weights = adapt.weights

    qw = Quantizer(11, signed=True)
    quantized_weights = qw.quantize_2s_comp(weights)
    
    f = Fir(len(quantized_weights), quantized_weights, 16)
    single_matrix = f(quantized_chan_out)

    plot_comparison(single_matrix, ideal_codes, delay_ffe=pos, scale=1500)
    plot_multi_hist(single_matrix, ideal_codes, delay_ffe=pos, n_bits=2) 
    

# Used for testing only
if __name__ == "__main__":
    main()

