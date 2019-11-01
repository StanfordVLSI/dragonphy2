from dragonphy import *
from verif.fir.fir import Fir
from verif.mlsd.mlsd import MLSD
from verif.analysis.histogram import *

import numpy as np
import matplotlib.pyplot as plt

def plot_parametric_channel():
    tau1 = [2, 8, 11, 16, 32, 64]
    tau2 = [2, 1, 0.5, 0.25, 0.1, 0.05]
    resp_len_skin = [int(np.exp(np.sqrt(ta/64.0)-1)*300) for ta in tau1]  #[5, 10, 50, 100, 150]
    resp_len_diel = [int(((1+np.abs(1/ta/20))/2)*20) for ta in tau2]  #[5, 10, 50, 100, 150]
    pos = 2

    f, ax = plt.subplots(2, 2) 

    ax[0, 0].set_title('Skineffect Channel, len=50')
    ax[1, 0].set_title('Dielectric Channel, len=50')
    # Create all channels
    for t in tau1: 
        chan_skin = Channel(channel_type='skineffect', normal='area', tau=t, sampl_rate=1, cursor_pos=pos, resp_depth=50)
        ax[0, 0].plot(chan_skin.impulse_response, label='tau='+str(t))

    for t in tau2: 
        chan_dia1 = Channel(channel_type='dielectric1', normal='area', tau=t, sampl_rate=1, cursor_pos=pos, resp_depth=50)
    
        ax[1, 0].plot(chan_dia1.impulse_response, label='tau='+str(t))

    ax[0, 0].legend()
    ax[1, 0].legend()

    ax[0, 1].set_title('Skineffect Channel, tau=16')
    ax[1, 1].set_title('Dielectric Channel, tau=16')
    # Create all channels
    for r_s, r_d in zip(resp_len_skin, resp_len_diel): 
        chan_skin = Channel(channel_type='skineffect', normal='area', tau=11, sampl_rate=1, cursor_pos=pos, resp_depth=r_s)
        chan_dial = Channel(channel_type='dielectric1', normal='area', tau=1, sampl_rate=1, cursor_pos=pos, resp_depth=r_d)
        ax[0, 1].plot(chan_skin.impulse_response, label='len='+str(r_s))
        ax[1, 1].plot(chan_dial.impulse_response, label='len='+str(r_d))
    
    ax[0, 1].legend()
    ax[1, 1].legend()
    plt.show()

# Run the full system in python (w/ cheating).
# Uses ideal Wiener filter, uniform quantizer, and ideal channel model for
# MLSD
def test_system_cheating():
    # Skineffect Channel Parameters:
    #   tau = 9.5  (~30db down)
    #   len = 150


    # Initialize parameters 
    load_codes = False
    iterations = 100000
    pos = 1
    resp_len = 150
    bitwidth = 6
    plot_len = 100 #iterations
    num_taps = 3
    noise_amp = 0.02
    noise_en = True
    tau = 0.87
    
   
    if load_codes:
        # Load Ideal Codes
        ideal_codes = np.loadtxt('verif/analysis/ideal_codes.txt', dtype=np.int16)
        print(f'Ideal codes: {ideal_codes[:plot_len]}')
        iterations=len(ideal_codes)
    else:
        # Generate Ideal Codes
        #ideal_codes = np.tile(np.array([-1, 1]), int(iterations/2))    # Harmonic Codes
        ideal_codes = np.random.randint(2, size=iterations)*2 - 1       # Random Codes
        np.savetxt('verif/analysis/ideal_codes.txt', ideal_codes)


    # Create channel model and channel output
    chan = Channel(channel_type='dielectric1', normal='area', tau=tau, sampl_rate=1, cursor_pos=pos, resp_depth=resp_len)
    chan_out = chan(ideal_codes)

    # Plot channel model
    plt.plot(chan.impulse_response)
    plt.suptitle("Channel Response")
    plt.show()
    print(f'Channel resp: {chan.impulse_response}')
    print(f'Channel out: {chan_out[:plot_len]}')
    print(f'Cursor pos: {chan.cursor_pos}')
    pos = chan.cursor_pos

    # Add noise
    if noise_en:
        chan_out = chan_out + np.random.randn(len(chan_out))*noise_amp
   
    # Quantize channel output
    qc = Quantizer(bitwidth, signed=True)
    quantized_chan_out = qc.quantize_2s_comp(chan_out)

    # Adapt Wiener filter to quantized channel output
    adapt = Wiener(step_size = 0.1, num_taps = num_taps, cursor_pos=pos)
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
    plot_multi_hist(ffe_out, ideal_codes, delay_ffe=pos, n_bits=4, bit_pos=1) 


    # Make decision based on FFE output
    comp_out = np.array([1 if int(np.floor(ffe_val)) >= 0 else -1 for ffe_val in ffe_out])


    # Perform MLSD on FFE output
    m = MLSD(chan.cursor_pos, chan.impulse_response, bitwidth=bitwidth, quantizer_lsb=qc.lsb)

    chan_ffe_response = chan(f.impulse_response)

    #cursor_val = max(chan_ffe_response)    
    #print(sum(np.abs(chan_ffe_response)) - cursor_val)


    plt.figure()
    plt.stem(chan_ffe_response)
    plt.suptitle("Channel response * FFE Weights")
    plt.show()
    
    
    shift_amt = np.argmax(chan_ffe_response)

    plt.figure()
    plt.plot(ideal_codes[:plot_len], label="ideal in")
    plt.plot(comp_out[shift_amt:shift_amt + plot_len], label="ffe out")
    plt.legend()
    plt.suptitle("Ideal Codes vs. FFE Decision") 
    plt.show()

    corrected_comp_out = comp_out[shift_amt: iterations + shift_amt]
    print(f'FFE Decision Output: {corrected_comp_out[:plot_len]}')

    ffe_errors = np.inner(corrected_comp_out - ideal_codes, corrected_comp_out - ideal_codes)/4
    print(f'Number of FFE mismatches: {ffe_errors} \t BER: {ffe_errors/iterations}')
    err_idx = [i for i in range(len(corrected_comp_out)) if corrected_comp_out[i] != ideal_codes[i]]
    print(f'Mismatches occur: {err_idx}')

    
    # Plot FFE Output Statistics
    ffe_mlsd_err = m.plot_ffe_mlsd(ffe_out, corrected_comp_out, quantized_chan_out, ideal_codes, plot_range=[900,1000]) 

    ffe_norm = m.calc_mlsd_err(corrected_comp_out, quantized_chan_out)
    print(f'FFE Norm: {ffe_norm[:plot_len]}')

    mlsd_out_ffe_err = m.perform_mlsd_ffe_err(corrected_comp_out, quantized_chan_out, threshold=4000, update=False)
    print(f'MLSD Output (only on max ffe err): {mlsd_out_ffe_err[:plot_len]}')

    err_idx = [i for i in range(len(mlsd_out_ffe_err)) if mlsd_out_ffe_err[i] != ideal_codes[i]]
    print(f'Mismatches occur: {err_idx}')
    print(f'Num mismatch: {len(err_idx)} \t BER: {len(err_idx)/iterations}')
    

    #plt.figure()
    #plt.plot(mlsd_out[:plot_len], label='mlsd')
    #plt.plot(ideal_codes[:plot_len], label='ideal')
    #plt.legend()
    #plt.show()

    start_index = chan.resp_depth - chan.cursor_pos - 1
    end_index = iterations - chan.cursor_pos

    # MLSD with no update
    mlsd_out_no = m.perform_mlsd_zeros(corrected_comp_out, quantized_chan_out, update=False) 
    print(f'MLSD Output (no update): {mlsd_out_no[:plot_len]}')

    err_idx = [i for i in range(len(mlsd_out_no)) if mlsd_out_no[i] != ideal_codes[i]]
    print(f'Mismatches occur: {err_idx}')
    print(f'Num mismatch: {len(err_idx)} \t BER: {len(err_idx)/iterations}')


    # MLSD with update
    mlsd_out = m.perform_mlsd_zeros(corrected_comp_out, quantized_chan_out)
    print(f'MLSD Output (update): {mlsd_out[:plot_len]}')

    err_idx = [i for i in range(len(mlsd_out)) if mlsd_out[i] != ideal_codes[i]]
    print(f'Mismatches occur: {err_idx}')
    print(f'Num mismatch: {len(err_idx)} \t BER: {len(err_idx)/iterations}')


    if len(err_idx) == 0:
        print(f'TEST PASSED')
    else:   
        print(f'TEST FAILED') 

def main():
    #plot_parametric_channel()
    test_system_cheating()

# Run the digital backend for the RX system in Python
if __name__ == "__main__":
    main()

