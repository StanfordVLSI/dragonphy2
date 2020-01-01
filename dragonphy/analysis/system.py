
from dragonphy import *

import time
import numpy as np
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt

seed_num = 4
np.random.seed(seed_num)

def perform_mlsd(margin=None, n_pre=1, n_post=1, update=False, n_bit_mlsd=2):
    return 0

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
    load_model = False
    iterations = 1000000
    training_len = 100000
    pos = 1
    resp_len = 150
    bitwidth = 6
    plot_len = 10 #iterations
    num_taps = 5
    noise_amp = 0.02
    #noise_amp = 0.03 # with iterations of 1000
    #noise_amp = 0.0001 # with iterations of 1M
    noise_en = True
    debug = False
    tau = 0.87

    plot_en = False
    
   
    # Generate weight training codes
    if load_model:
        # Load Ideal Codes
        ideal_codes = np.loadtxt('dragonphy/analysis/ideal_codes.txt', dtype=np.int16)
        print(f'Ideal codes: {ideal_codes[:plot_len]}')
        training_len=len(ideal_codes)
    else:
        # Generate Ideal Codes
        #ideal_codes = np.tile(np.array([-1, 1]), int(training_len/2))    # Harmonic Codes
        ideal_codes = np.random.randint(2, size=training_len)*2 - 1   # Random Codes
        np.savetxt('dragonphy/analysis/ideal_codes.txt', ideal_codes)


    # Create channel model and channel output
    chan = Channel(channel_type='dielectric1', normal='area', tau=tau, sampl_rate=1, cursor_pos=pos, resp_depth=resp_len)
    chan_out = chan(ideal_codes)

    # Plot channel model
    if plot_en:
        plt.stem(chan.impulse_response)
        plt.suptitle("Channel Response")
        plt.show()

    if debug:
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
    for i in range(training_len-pos):
        adapt.find_weights_pulse(ideal_codes[i-pos], chan_out[i])   

    weights = adapt.weights

    # Quantize weights
    qw = Quantizer(11, signed=True)
    quantized_weights = qw.quantize_2s_comp(weights)
    
    if load_model:
        ideal_codes = np.loadtxt('dragonphy/analysis/test_codes.txt')
    else:
        # Generate test codes
        ideal_codes = np.random.randint(2, size=iterations)*2 - 1   # Random Codes
        np.savetxt('dragonphy/analysis/test_codes.txt', ideal_codes)

    chan_out = chan(ideal_codes)
    # Add noise
    if noise_en:
        chan_out = chan_out + np.random.randn(len(chan_out))*noise_amp


    quantized_chan_out = qc.quantize_2s_comp(chan_out)

    # Perform FFE with Fir
    f = Fir(len(quantized_weights), quantized_weights, 16)
    ffe_out = f(quantized_chan_out)

    # Plot histogram of FFE results
    if plot_en:
        Histogram.plot_comparison(quantized_chan_out, ideal_codes, delay_ffe=pos, scale=50, labels=["quantized chan", "ideal"])
        Histogram.plot_comparison(ffe_out, ideal_codes, delay_ffe=pos, scale=15000, labels=["ffe out", "ideal"])
        Histogram.plot_multi_hist(ffe_out, ideal_codes, delay_ffe=pos, n_bits=1, bit_pos=0) 


    # Make decision based on FFE output
    comp_out = np.array([1 if int(np.floor(ffe_val)) >= 0 else -1 for ffe_val in ffe_out])


    # Perform MLSD on FFE output
#    m1 = MLSD(chan.cursor_pos, chan.impulse_response, n_future=1, bitwidth=bitwidth, quantizer_lsb=qc.lsb)
#    m = MLSD(chan.cursor_pos, chan.impulse_response, bitwidth=bitwidth, quantizer_lsb=qc.lsb)
#
    chan_ffe_response = chan(f.impulse_response)

    if plot_en:
        plt.figure()
        plt.stem(chan_ffe_response)
        plt.suptitle("Channel response * FFE Weights")
        plt.show()
    
    shift_amt = np.argmax(chan_ffe_response)

    if plot_en:
        plt.figure()
        plt.plot(ideal_codes[:plot_len], label="ideal in")
        plt.plot(comp_out[shift_amt:shift_amt + plot_len], label="ffe out")
        plt.legend()
        plt.suptitle("Ideal Codes vs. FFE Decision") 
        plt.show()

    corrected_comp_out = comp_out[shift_amt: iterations + shift_amt]
    corrected_ffe_out = ffe_out[shift_amt: iterations + shift_amt]
    print(f'FFE Decision Output: {corrected_comp_out[:plot_len]}')

    ffe_errors = np.inner(corrected_comp_out - ideal_codes, corrected_comp_out - ideal_codes)/4
    print(f'Number of FFE mismatches: {ffe_errors} \t BER: {ffe_errors/iterations}')
    ffe_err_idx = [i for i in range(len(corrected_comp_out)) if corrected_comp_out[i] != ideal_codes[i]]
    print(f'Mismatches occur: {ffe_err_idx}')

  #  margin = 1500 
  #  # Plot MLSD Statistics
  #  print(f'MLSD Output (only on margin < {margin}, no update, look at {m.n_future} bits in the future)')
  #  ffe_mlsd_err = m.plot_ffe_mlsd(corrected_ffe_out, corrected_comp_out, quantized_chan_out, ideal_codes, plot_range=[900,1000]) 
  #  marginal_bits = ffe_mlsd_err < margin
  #  print(f'Marginal indices: {[i for i in range(len(marginal_bits)) if marginal_bits[i]]}')

  #  mlsd_out_ffe_margin = m.perform_mlsd_zeros(corrected_comp_out, quantized_chan_out, bool_arr = marginal_bits, update=False)
  #  err_idx = m.find_err_idx(mlsd_out_ffe_margin, ideal_codes)

  #  # Plot MLSD statistics
  #  print(f'MLSD Output (only on margin < {margin}, no update, look at {m1.n_future} bits in the future)')
  #  mlsd_out = m1.perform_mlsd_zeros(corrected_comp_out, quantized_chan_out, update=False)
  #  err_idx = m1.find_err_idx(mlsd_out, ideal_codes)
    
    # Plot MLSD statistics for 2 future bits
    m2 = MLSD(chan.cursor_pos, chan.impulse_response[:100],n_pre=1, n_post=1, n_future=1, bitwidth=bitwidth, quantizer_lsb=qc.lsb)

    print(f'MLSD output, no update, look at {m2.n_future} bits in the future')
    #mlsd_out_ideal = m2.count_update_iterations_channel(ideal_codes, quantized_chan_out, update=True)
    mlsd_out_comp  = m2.count_update_iterations_channel(corrected_comp_out, quantized_chan_out, update=True, seed_num=seed_num)
    #print(f'MLSD 2bit future slices: {mlsd_out_ideal}')
    #err_idx = m2.find_err_idx(mlsd_out_ideal, ideal_codes)
    print(f'MLSD 2bit future slices: {mlsd_out_comp[:200]}')
    err_idx = m2.find_err_idx(mlsd_out_comp, ideal_codes)

    #MLSD.plot_full_result(mlsd_out_2bit, corrected_comp_out)
    #MLSD.print_full_result(mlsd_out_2bit, corrected_comp_out, ffe_err_idx)

    #print(f'FFE Norm: {ffe_norm[:plot_len]}')

    if len(err_idx) == 0:
        print(f'TEST PASSED')
    else:   
        print(f'TEST FAILED') 

    
   

def main():
    #plot_parametric_channel()
    start_time = time.time()
    test_system_cheating()
    prog_time = int((time.time() - start_time) / 60)

    print(f'Program took {prog_time} minutes to run')

# Run the digital backend for the RX system in Python
if __name__ == "__main__":
    main()

