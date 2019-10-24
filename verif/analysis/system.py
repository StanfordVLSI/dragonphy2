from dragonphy import *
from verif.fir.fir import Fir
from verif.mlsd.mlsd import MLSD
from verif.analysis.histogram import *

import numpy as np
import matplotlib.pyplot as plt

# Run the full system in python (w/ cheating).
# Uses ideal Wiener filter, uniform quantizer, and ideal channel model for
# MLSD
def test_system_cheating():
    # Initialize parameters 
    iterations = 1000
    pos = 1
    resp_len = 6
    bitwidth = 8
    plot_len = 100 #iterations
    tau = 2
    num_taps = 5
    noise_amp = 0.02
    noise_en = False
    
    # Generate Ideal Codes
    ideal_codes = np.random.randint(2, size=iterations)*2 - 1
   
    # Create channel model and channel output
    chan = Channel(channel_type='skineffect', normal='area', tau=10, sampl_rate=1, cursor_pos=pos, resp_depth=resp_len)
    chan_out = chan(ideal_codes)
    print(f'Channel resp: {chan.impulse_response}')
    print(f'Channel out: {chan_out[:plot_len]}')
    print(f'Cursor pos: {chan.cursor_pos}')

    # Add noise
    if noise_en:
        chan_out = chan_out + np.random.randn(len(chan_out))*0.02
   
    # Quantize channel output
    qc = Quantizer(bitwidth, signed=True)
    quantized_chan_out = qc.quantize_2s_comp(chan_out)


    # Adapt Wiener filter to quantized channel output
    adapt = Wiener(step_size = 0.1, num_taps = 5, cursor_pos=pos)
    for i in range(iterations-pos):
        adapt.find_weights_pulse(ideal_codes[i-pos], chan_out[i])   

    weights = adapt.weights

    # Quantize weights
    qw = Quantizer(11, signed=True)
    quantized_weights = qw.quantize_2s_comp(weights)
    
    # Perform FFE with Fir
    f = Fir(len(quantized_weights), quantized_weights, 16)
    ffe_out = f(quantized_chan_out)

    # Plot histogram of FFE results
    plot_comparison(quantized_chan_out, ideal_codes, delay_ffe=pos, scale=50, labels=["quantized chan", "ideal"])
    plot_comparison(ffe_out, ideal_codes, delay_ffe=pos, scale=15000, labels=["ffe out", "ideal"])
    plot_multi_hist(ffe_out, ideal_codes, delay_ffe=pos, n_bits=1, bit_pos=0) 

    # Make decision based on FFE output
    comp_out = np.array([1 if int(np.floor(ffe_val)) >= 0 else -1 for ffe_val in ffe_out])

    print(f'FFE Decision Output: {comp_out[:plot_len]}')

    # Perform MLSD on FFE output
    m = MLSD(chan.cursor_pos, chan.impulse_response, bitwidth=bitwidth, quantizer_lsb=qc.lsb)

    print(f'Ideal Codes: {ideal_codes[:plot_len]}')

    chan_ffe_response = chan(f.impulse_response)
    plt.figure()
    plt.plot(chan_ffe_response)
    plt.suptitle("Channel response * FFE Weights")
    plt.show()
    
    shift_amt = np.argmax(chan_ffe_response)

    plt.figure()
    plt.plot(ideal_codes[:plot_len], label="ideal in")
    plt.plot(comp_out[shift_amt:shift_amt + plot_len], label="ffe out")
    plt.legend()
    plt.show()

    corrected_comp_out = comp_out[shift_amt: iterations + shift_amt]

    ffe_errors = np.inner(corrected_comp_out - ideal_codes, corrected_comp_out - ideal_codes)/4
    print(f'Number of FFE mismatches: {ffe_errors}')
    err_idx = [i for i in range(len(corrected_comp_out)) if corrected_comp_out[i] != ideal_codes[i]]
    print(f'Mismatches occur: {err_idx}')

    start_index = chan.resp_depth - chan.cursor_pos - 1
    end_index = iterations - chan.cursor_pos

    ideal_one_err = np.copy(ideal_codes)
    ideal_one_err[5] = -1 * ideal_one_err[7]

    # MLSD with update
    mlsd_out = m.perform_mlsd_update_zeros(ideal_codes, quantized_chan_out)

    print(f'MLSD Output: {mlsd_out[:plot_len]}')

    plt.figure()
    plt.plot(mlsd_out[:plot_len], label='mlsd')
    plt.plot(ideal_codes[:plot_len], label='ideal')
    plt.legend()
    plt.show()

    err_idx = [i for i in range(len(mlsd_out)) if mlsd_out[i] != ideal_codes[i]]
    print(f'Mismatches occur: {err_idx}')
    print(f'num mismatch: {len(err_idx)}')


    if len(err_idx) == 0:
        print(f'TEST PASSED')
    else:   
        print(f'TEST FAILED') 

def main():
    test_system_cheating()

# Run the digital backend for the RX system in Python
if __name__ == "__main__":
    main()

