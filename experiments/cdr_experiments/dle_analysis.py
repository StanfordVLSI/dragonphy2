from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
from matplotlib import ticker, cm
import numpy as np
from scipy import linalg, stats
from dragonphy import *
from rich.progress import Progress


def heaviside(x):
    return 1.0 if x > 0 else 0.0

def create_error_pattern(bit_seq, inject_pos):
    ep_len = max(inject_pos)
    offset = min(inject_pos)
    error_pattern = [0]*ep_len

    for inj_ii in inject_pos:
        error_pattern[inj_ii-offset] = -bit_seq[inj_ii]


    return error_pattern

def calculate_error_probability(err, cov_mat, step_size, x0, lb, ub_std):
    bd = len(err)
    rv = stats.multivariate_normal(np.zeros(bd,), cov_mat[0:bd,0:bd]*ub_std**2)

    if bd > 3:
        step_size = step_size * int(bd / 1)

    arrs = []
#    print(err, lb)
    for ii in range(bd):
        if err[ii] == 0:
            arrs += [x0]
        else:
            x1 = np.arange(1+lb[ii],2, step_size)
#            print("\t",(-err[ii]+lb[ii]), -err[ii]*2)
            arrs += [-err[ii]*x1]
    pos = np.array(np.meshgrid(*arrs)).T.reshape(-1, bd)
#    print()
    return 2*np.sum(rv.pdf(pos)*step_size**bd)

def calculate_isi_distribution(pulse, zf_taps, num_of_precursors, num_bits, num_bins):
    eq_pulse = np.convolve(pulse, zf_taps)
    eq_pulse[target_curs_pos] = 0

    bits = np.random.randint(2, size=(int(10**num_bits),))*2 - 1
    isi_noise = np.convolve(eq_pulse, bits)

    bit_slices = np.zeros((len(bits)-25, 25 + num_of_precursors))
    values     = np.zeros((len(bits)-25,))
    for ii in range(25, len(bits)):
        values[ii-25]=isi_noise[ii]
        try:
            bit_slices[ii-25,:] = bits[ii-25:ii+num_of_precursors]
        except ValueError:
            adjust = (ii + num_of_precursors) - len(bits)
            print(adjust)
            print(ii)
            print(len(bits))
            print(np.shape(bit_slices[ii-25,:25 + num_of_precursors]))
            print(np.shape(bits[ii-25:ii + num_of_precursors-adjust]))
            bit_slices[ii-25,:25 + num_of_precursors-adjust] = bits[ii-25:ii + num_of_precursors-adjust]

    select = bit_slices[:,25] * values < 0
    values = values[select]
    bit_slices = bit_slices[select]


    sort_idx = np.argsort(np.abs(values))[::-1]
    
    sorted_values = values[sort_idx]
    sorted_bit_slices = bit_slices[sort_idx]
    counts, bin_edges = np.histogram(sorted_values, bins=num_bins)

    bin_width = np.abs(bin_edges[1] - bin_edges[0])

    counts = counts/(len(bits)-num_of_precursors)

    extend_svals = np.tile(sorted_values.reshape((1,len(sorted_values))).T, num_bins)
    extend_counts = np.tile(counts.reshape((1, len(counts))).T, len(sorted_values)).T

    bin_val      = (bin_edges[:-1] + bin_edges[1:])

    extend_bin_val = np.tile(bin_val.reshape((1, len(bin_val))).T, len(sorted_values)).T
    location_mat = np.logical_and(extend_svals > bin_edges[:-1], extend_svals < bin_edges[1:])

    prob_svalues = extend_counts[location_mat]
    bins_svalues = extend_bin_val[location_mat]

    print(f'ISI Values | Bit Pattern')
    for jj in range(25):
        bit_out = "".join(["1" if bit > 0 else "0" for bit in sorted_bit_slices[jj,:]])
        idx = sort_idx[jj]
        print(f'{values[idx-2:idx+3]}\t|\t{bit_out[::-1]}')#, sorted_bit_slices[jj,num_of_precursors], prob_svalues[jj], bins_svalues[jj])
        #print(create_error_pattern(sorted_bit_slices[jj,num_of_precursors-1:num_of_precursors+3], [1,2]))
    print()

    return values, sorted_bit_slices, sort_idx, prob_svalues, bins_svalues

THIS_DIR = Path(__file__).resolve().parent
sparam_file_list = ["Case4_FM_13SI_20_T_D13_L6.s4p",
                    "peters_01_0605_B1_thru.s4p",  
                    "peters_01_0605_B12_thru.s4p",  
                    "peters_01_0605_T20_thru.s4p",
                    "TEC_Whisper42p8in_Meg6_THRU_C8C9.s4p",
                    "TEC_Whisper42p8in_Nelco6_THRU_C8C9.s4p"]


f_sig = 16e9
channel_length = 100
select_channel = True
phase_steps_check = False
ffe_length = 10
num_bits = 8.4
channel_list = [0,1,2,3,4,5]
num_of_precursors = 4
ub_std = 19e-3
std_noise = 0e-3
debug_DLE = True
plot_amplified_noise = False
measure_isi_and_random = False
measure_random = True
tx_eq = False
find_optimal_ffe_point = True

#tx_filt = [1, -0.3]

tx_length = 5
tx_cursor_pos = 1

list_of_target_curs_pos = [3,7,9,8,9,4]
#list_of_target_curs_pos = [50,50,50,50,50,50]
#list_of_target_curs_pos = [4,15,15,15,15,15]

list_of_tx_eq_target_curs_pos = [4,7,9,8,9,4]
list_of_tx_eq = [1,1,1,1,1,1]
list_of_mm_lock_position = [15e-12,15e-12,12e-12,12e-12,3e-12, 15e-12]
list_of_ub_stds = [8e-3, 44.5e-3, 18.5e-3, 2e-3, 24.5e-3, 8.5e-3]
list_of_eq_mm_lock_position = list_of_mm_lock_position# [15e-12,15e-12,25e-12,15e-12,15e-12, 15e-12]

tone = np.zeros((400,))
tone[::2] = 1
tone[1::2] = -1


p_err = [1]
pn_err = [1,-1]
pnp_err = [1,-1,1]
p1p_err = [1,0,1]
p1n_err = [1,0,-1]
pnpn_err = [1,-1,1,-1]
pnp1p_err = [1,-1,1,0,1]
p2n_err = [1,0,0,-1]
pn1n_err = [1,-1,0,-1]

error_patterns = [p_err, pn_err, pnp_err, p1p_err, p1n_err, p2n_err, pnp1p_err, [1,-1,1,-1,1], pnpn_err, pn1n_err]

if find_optimal_ffe_point:
    for ii in channel_list:
        file = sparam_file_list[ii]
        #print(file)
        mm_lock_pos = list_of_mm_lock_position[ii]

        file_name = str(get_file(f'data/channel_sparam/{file}'))
        t, imp = s4p_to_impulse(str(file_name), 0.1e-12, 20e-9, zs=50, zl=50)

        cursor_position = np.argmax(imp)
        shift_delay = -t[cursor_position] + (num_of_precursors)*1.0/(f_sig)
        #Load the S4P into a channel model
        chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=200000, s4p=file_name, zs=50, zl=50)

        time, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay=shift_delay + mm_lock_pos)

        chan_mat = linalg.convolution_matrix(pulse, tx_length)
        tx_length_adj = 0
        if tx_eq:
            imp = np.zeros((200 + tx_length - 1,1))
            imp[tx_cursor_pos] = 1
            tx_filt = np.reshape(np.linalg.pinv(chan_mat) @ imp, (tx_length,))
            tx_filt = tx_filt / np.sum(np.abs(tx_filt))         
            if debug_DLE:
                plt.plot(pulse)
            pulse = np.convolve(pulse, tx_filt)
            if debug_DLE:
                plt.stem(pulse)
                plt.show()
            tx_length_adj = tx_length - 1

            best_val = 1
            best_pos = 0
            for jj in range(tx_length):
                imp = np.zeros((200 + tx_length_adj,1))
                imp[jj] = 1
                tx_filt = np.reshape(np.linalg.pinv(chan_mat) @ imp, (tx_length,))
                tx_filt = tx_filt/ np.sum(np.abs(tx_filt))
                eq_pulse = np.convolve(pulse,tx_filt)
                eq_pulse = eq_pulse / eq_pulse[jj]
                eq_pulse[jj] = 0

                mean_sqr_error = np.sum(np.dot(eq_pulse, eq_pulse))

                if best_val > mean_sqr_error:
                    best_val = mean_sqr_error
                    best_pos = jj

                #print('Pos: ',jj, 'ISI Energy: ', mean_sqr_error)
            list_of_tx_eq[ii] = best_pos

        chan_mat = linalg.convolution_matrix(pulse, ffe_length)
        best_val = 1
        best_pos = 0
        for jj in range(ffe_length):
            imp = np.zeros((200 + ffe_length -1 + tx_length_adj,1))
            imp[jj] = 1

            noise_mat = np.eye(200 + ffe_length -1 + tx_length_adj)* std_noise**2
            inv_mat = np.dot(chan_mat.T, np.linalg.pinv(np.dot(chan_mat, chan_mat.T) + noise_mat))

            zf_taps = np.reshape(inv_mat @ imp, (ffe_length,))
            eq_pulse = np.convolve(pulse,zf_taps)
            eq_pulse = eq_pulse / eq_pulse[jj]
            eq_pulse[jj] = 0

            mean_sqr_error = np.sum(np.dot(eq_pulse, eq_pulse))

            if best_val > mean_sqr_error:
                best_val = mean_sqr_error
                best_pos = jj

            #print('Pos: ',jj, 'ISI Energy: ', mean_sqr_error)

        #if debug_DLE:
        #    plt.stem(zf_taps)
        #    plt.show()
        #    plt.plot(pulse)
        #    plt.plot(np.convolve(pulse, zf_taps))
        #    plt.show()

        list_of_tx_eq_target_curs_pos[ii] = best_pos

print(list_of_target_curs_pos)
list_of_target_curs_pos = list_of_tx_eq_target_curs_pos
print(list_of_tx_eq_target_curs_pos)
print(list_of_tx_eq)
for ii in channel_list:
    ub_std = list_of_ub_stds[ii]
    file = sparam_file_list[ii]
    target_curs_pos = list_of_target_curs_pos[ii]
    tx_cursor_pos = list_of_tx_eq[ii]
    mm_lock_pos = list_of_mm_lock_position[ii]

    file_name = str(get_file(f'data/channel_sparam/{file}'))
    t, imp = s4p_to_impulse(str(file_name), 0.1e-12, 20e-9, zs=50, zl=50)

    cursor_position = np.argmax(imp)
    shift_delay = -t[cursor_position] + (num_of_precursors)*1.0/(f_sig)
    #Load the S4P into a channel model
    chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=200000, s4p=file_name, zs=50, zl=50)

    time, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=200, t_delay=shift_delay + mm_lock_pos)
    tx_length_adj = 0
    if tx_eq:
        chan_mat = linalg.convolution_matrix(pulse, tx_length)
        imp = np.zeros((200 + tx_length - 1,1))
        imp[tx_cursor_pos] = 1
        tx_filt = np.reshape(np.linalg.pinv(chan_mat) @ imp, (tx_length,))
        tx_filt = tx_filt / np.sum(np.abs(tx_filt))         

        if debug_DLE:
            plt.plot(pulse)
        pulse = np.convolve(pulse, tx_filt)
        if debug_DLE:
            plt.stem(pulse)
            plt.show()
        target_curs_pos = list_of_tx_eq_target_curs_pos[ii]
        tx_length_adj = tx_length - 1


    chan_mat = linalg.convolution_matrix(pulse, ffe_length)
    imp = np.zeros((200 + ffe_length -1 + tx_length_adj,1))
    imp[target_curs_pos] = 1

    noise_mat = np.eye(200 + ffe_length -1 + tx_length_adj)* std_noise**2

    inv_mat = np.dot(chan_mat.T, np.linalg.pinv(np.dot(chan_mat, chan_mat.T) + noise_mat))

    zf_taps = np.reshape(inv_mat @ imp, (ffe_length,))



    print(np.amax(np.abs(zf_taps)))
    #zf_taps = zf_taps / np.sum(np.abs(zf_taps))
    eq_pulse = np.convolve(pulse,zf_taps)
    eq_pulse[target_curs_pos] = 0

    rx_tap_energy = np.sum(np.dot(zf_taps,zf_taps))
    print('Rx Energy:', rx_tap_energy)
    if tx_eq:
        tx_tap_energy = np.sum(np.dot(tx_filt, tx_filt))
        print('Tx Energy:', tx_tap_energy)

    print('ISI Energy: ', np.sum(np.dot(eq_pulse,eq_pulse)))

    if debug_DLE:
        #print(target_curs_pos)
        #print(zf_taps)
        print(1/np.max(zf_taps))
        print((1/np.max(zf_taps))**2)
        print(np.sum(np.square(zf_taps / np.sum(np.square(zf_taps)))))
        plt.stem(np.convolve(zf_taps, np.flip(zf_taps)) / np.sum(np.square(zf_taps)))
        plt.show()
        plt.stem(zf_taps)
        #if tx_eq:
        #    plt.plot(tx_filt)
        plt.show()
        plt.stem(pulse)
        plt.show()

        eq_pulse = np.convolve(pulse, zf_taps)
        plt.plot(eq_pulse)
        plt.show()

        #print(eq_pulse[target_curs_pos])
        #print(np.sort(np.abs(eq_pulse))[::-1])
        eq_pulse[target_curs_pos] = 0;
        bits = np.random.randint(2, size=(int(10**7),))*2 - 1
        isi =np.convolve(bits, eq_pulse)
        std_isi = np.sqrt(np.sum(np.square(isi))/10**7)
        mad_isi = np.median(np.abs(isi))
        print(std_isi, mad_isi, std_isi/mad_isi)

        plt.hist(isi, bins=100)
        plt.show()

        plt.hist(np.abs(eq_pulse), bins=25)
        plt.show()

        #pos_isi = np.argsort(np.abs(eq_pulse))[::-1][:5]

        #isi_bad_spots = np.zeros((200,))

        #isi_bad_spots[pos_isi] = 1

        #print("".join(["X" if pi else "0" for pi in list(isi_bad_spots)]))

        #num_bits = 6
        #num_bins = 50
        #values, sorted_bit_slices, sort_idx, prob_svalues, bins_svalues = calculate_isi_distribution(pulse, zf_taps, num_of_precursors, num_bits, num_bins)

        continue


    if plot_amplified_noise:

        noise = np.random.randn(10000)*ub_std
        amplified_noise = np.convolve(noise, zf_taps)

        counts, ybins, xbins, image = plt.hist2d(amplified_noise[1:], amplified_noise[:-1], bins=100, norm=LogNorm())
        plt.contour(counts, extent=[xbins.min(), xbins.max(), ybins.min(), ybins.max()], linewidths=3)
        plt.colorbar()
        plt.show()


    if measure_isi_and_random:
        values, sorted_bit_slices, sort_idx, prob_svalues, bins_svalues = calculate_isi_distribution(pulse, zf_taps, num_of_precursors, num_bits, num_bins)

        zf_taps_mat = linalg.convolution_matrix(zf_taps, ffe_length)
        cov_mat = np.dot(zf_taps_mat.T, zf_taps_mat)

        step_size = 0.01

        x0 = np.arange(-2,2, step_size)
    #    x1 = np.arange(0.5,2, step_size)

    #    for err in error_patterns:
    #        err_prob = calculate_error_probability(err, cov_mat, step_size, x0, x1, ub_std)

    #        print(err, err_prob)

        err_table = {}

        convert_err = {-1.0 : '-', 0.0: '0', 1.0:'+'}

        for ii in range(50):
            bit_seq = [bit*sorted_bit_slices[ii, num_of_precursors] for bit in sorted_bit_slices[ii,:]]


            bit_out = "".join(["1" if bit > 0 else "0" for bit in bit_seq])
            print(bit_out, ":\n")
            isi_prob          = prob_svalues[ii]
            single_bit_err    =  create_error_pattern(bit_seq[num_of_precursors-1:num_of_precursors+2], [1])
            err_prob          = calculate_error_probability(single_bit_err, cov_mat, step_size, x0, [values[sort_idx[ii]]], ub_std)

            print(isi_prob, "\n", err_prob,  single_bit_err, values[sort_idx[ii]])

            err_lbl = "".join([convert_err[bit] for bit in single_bit_err])
            if not err_lbl in err_table:
                err_table[err_lbl] = 0
            err_table[err_lbl] += isi_prob*err_prob

            two_bit_err_right = create_error_pattern(sorted_bit_slices[ii,num_of_precursors-1:num_of_precursors+2], [1,2])
            err_prob = calculate_error_probability(two_bit_err_right, cov_mat, step_size, x0, [values[sort_idx[ii]], values[sort_idx[ii]+1]], ub_std)

            err_lbl = "".join([convert_err[bit] for bit in two_bit_err_right])
            if not err_lbl in err_table:
                err_table[err_lbl] = 0
            err_table[err_lbl] += isi_prob*err_prob

            print(err_prob, two_bit_err_right, [values[sort_idx[ii]-1], values[sort_idx[ii]], values[sort_idx[ii]+1]])
            print()
            #two_bit_err_left  = create_error_pattern(sorted_bit_slices[ii,num_of_precursors-1:num_of_precursors+2], [0,1])

        print(err_table)


    if measure_random:
        print(f'Channel {ii}:')
        zf_taps_mat = linalg.convolution_matrix(zf_taps, ffe_length)
        cov_mat = np.dot(zf_taps_mat.T, zf_taps_mat)

        step_size = 0.01

        x0 = np.arange(-2,2, step_size)
        x1 = np.arange(1,2, step_size)

        for err_pattern in error_patterns:
            err_prob = calculate_error_probability(err_pattern, cov_mat, step_size, x0, np.zeros((len(err_pattern),)), ub_std)
            print(err_pattern, err_prob)


