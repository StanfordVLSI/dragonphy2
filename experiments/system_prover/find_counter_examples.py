from cvc5.pythonic import *
import sympy as sp
import numpy as np
from scipy import special as spec
from copy import copy
import matplotlib.pyplot as plt
import matplotlib
import matplotlib.cm as cm
from matplotlib.colors import Normalize
from matplotlib import colorbar
import distinctipy

from error_probability import find_error_probabilities_for_channel

from multiprocessing import Pool, Queue, Process

def create_extended_channel(channel, gamma):
    extended_channel = np.array(channel + [gamma**ii * channel[-1] for ii in range(1,100)])
    extended_channel = extended_channel / np.sum(np.abs(extended_channel))

    return extended_channel

def process_unique_error(error_patterns):
    new_error_patterns = []
    for error in error_patterns:
        new_error_pattern = [ err/2 for err in error]
        new_error_pattern_2 = new_error_pattern[::-1]
        for err in new_error_pattern_2:
            if err == 0:
                new_error_pattern.pop()
            else:
                break
        
        new_error_patterns.append(new_error_pattern)
    return new_error_patterns

def build_error_pattern_set(num_of_errors):
    def decrement_pattern(pattern):
        new_pattern = copy(pattern)
        borrow = 2
        for ii in range(len(new_pattern)-1,-1,-1):
            new_pattern[ii] -= borrow
            if new_pattern[ii] < -2:
                borrow = 2
                new_pattern[ii] = 2
            else:
                borrow = 0
        
        return new_pattern

    def insert_new_pattern(patterns, new_pattern):
        for pattern in patterns:
            if (sum([abs(ep) for ep in new_pattern]) == 0):
                return
            if (sum([ abs(p - ep) for (p, ep) in zip(pattern, new_pattern)]) == 0):
                return

        patterns.append(new_pattern)

    error_patterns = [[2]*num_of_errors]
    next_error    =  [2]*num_of_errors
    for ii in range(3**num_of_errors):
        next_error = decrement_pattern(next_error)
        insert_new_pattern(error_patterns, next_error)

    return error_patterns


def build_unique_error_pattern_set(num_of_errors):
    def decrement_pattern(pattern):
        new_pattern = copy(pattern)
        borrow = 2
        for ii in range(len(new_pattern)-1,-1,-1):
            new_pattern[ii] -= borrow
            if new_pattern[ii] < -2:
                borrow = 2
                new_pattern[ii] = 2
            else:
                borrow = 0
        
        return new_pattern

    def insert_new_pattern(patterns, new_pattern):
        def check_for_shift_equivalence(pattern, new_pattern):
            zero_index = 0
            for ii in range(len(new_pattern)):
                if new_pattern[ii] != 0:
                    zero_index = ii-1
                    break
            
            if zero_index == -1:
                return False

            shifted_new_pattern = new_pattern[zero_index+1:] + new_pattern[:zero_index+1]
            return (sum([ abs(p - ep) for (p, ep) in zip(pattern, shifted_new_pattern)]) == 0) or sum([ abs(p + ep) for (p, ep) in zip(pattern, shifted_new_pattern)]) == 0

        for pattern in patterns:
            if (sum([ abs(p - ep) for (p, ep) in zip(pattern, new_pattern)]) == 0) or sum([ abs(p + ep) for (p, ep) in zip(pattern, new_pattern)]) == 0:
                return
            elif check_for_shift_equivalence(pattern, new_pattern):
                return
        
        patterns.append(new_pattern)

    error_patterns = [[2]*num_of_errors]
    next_error    =  [2]*num_of_errors
    for ii in range(3**num_of_errors):
        next_error = decrement_pattern(next_error)
        insert_new_pattern(error_patterns, next_error)

    error_patterns = error_patterns[:-1]
    return error_patterns

single_precursor_unique_error_patterns = build_unique_error_pattern_set(3)
double_precursor_unique_error_patterns = build_unique_error_pattern_set(4)

def find_worst_error_snr(seq_length, num_of_precursors, center=1, overload_channel=None, sigma=1):
    if num_of_precursors == 1:
        error_patterns = single_precursor_unique_error_patterns
    elif num_of_precursors == 2:
        error_patterns = double_precursor_unique_error_patterns
    err_len = len(error_patterns[0])
    R = sp.MutableDenseNDimArray(sp.symbols('0, '*(err_len-1) +' a:%d'%(seq_length+num_of_precursors-center)))
    N = sp.MutableDenseNDimArray(sp.symbols('n:%d'%(seq_length)))

    sub_vals = {}
    if overload_channel is not None:
        for ii in range(seq_length+num_of_precursors-center):
            sub_vals[R[ii+err_len-1]] = overload_channel[ii]
    else:
        for ii in range(num_of_precursors):
            sub_vals[R[ii+err_len-1]] = 0.2#0.5 / (num_of_precursors+1) * (ii + 1)
        
        sub_vals[R[err_len-1+num_of_precursors]] = 1

        for ii in range(1,seq_length-center):
            sub_vals[R[ii+err_len-1+num_of_precursors]] =0.3# 0.7 / (err_len-1+num_of_precursors) * (err_len-1+num_of_precursors-ii)


    worst_error = None
    worst_value  = 2
        

    for (pat_ii, error_pattern) in enumerate(error_patterns):
        error_row     = [0]*err_len
        for ii in range(err_len):
            error_row[ii] = error_pattern[ii]*R[(err_len-1+num_of_precursors-center-ii):(err_len-1+num_of_precursors-center-ii+seq_length)]


        total_margin = 0
        for ii in range(seq_length):
            symbol_left = sp.simplify((sum([error_row[jj][ii] for jj in range(err_len)]) + N[ii])**2)
            symbol_right = N[ii]**2
            total_margin = total_margin + symbol_left - symbol_right


        current_result = sp.simplify(total_margin).subs({'0' : 0})
        noise_terms = 0
        for ii in range(seq_length):
            test_result = current_result
            for jj in [kk for kk in range(seq_length) if kk != ii]:
                test_result = test_result.subs({N[jj] : 0})
            noise_terms += (sp.Poly(test_result, N[ii]).coeffs()[0])**2
        
        #Remove the noise terms
        current_result = current_result.subs({N[ii] : 0 for ii in range(seq_length)})
        #Divide by the noise sigma enhancement
        energy_result = sp.simplify(current_result).subs(sub_vals)
        current_result = sp.simplify(current_result/sp.sqrt(noise_terms)/sigma) 

        #Normalize by the channel conditiom of \sum |channel| = 1
        val = sp.simplify(current_result.subs(sub_vals)/(sum([abs(cval) for cval in overload_channel if cval is not None]) +  abs(overload_channel[-1]*1.5)))
        if val < worst_value:
            worst_value = val
            worst_error = pat_ii
    print(error_patterns[worst_error], worst_value)

    return worst_error, worst_value

def calculate_checker_margins_for_errors(seq_length, num_of_precursors, sigma=1, center=1, additional_patterns=[]):
    def insert_new_pattern(patterns, new_pattern):
        def check_for_shift_equivalence(pattern, new_pattern):
            zero_index = 0
            for ii in range(len(new_pattern)):
                if new_pattern[ii] != 0:
                    zero_index = ii-1
                    break
            
            if zero_index == -1:
                return False

            shifted_new_pattern = new_pattern[zero_index+1:] + new_pattern[:zero_index+1]
            return (sum([ abs(p - ep) for (p, ep) in zip(pattern, shifted_new_pattern)]) == 0) or sum([ abs(p + ep) for (p, ep) in zip(pattern, shifted_new_pattern)]) == 0

        for pattern in patterns:
            if (sum([ abs(p - ep) for (p, ep) in zip(pattern, new_pattern)]) == 0) or sum([ abs(p + ep) for (p, ep) in zip(pattern, new_pattern)]) == 0:
                return
            elif check_for_shift_equivalence(pattern, new_pattern):
                return
        
        patterns.append(new_pattern)
    err_len = 3 + (num_of_precursors-1)
    checker_patterns = create_checker_patterns(num_of_precursors)
    for additional_pattern in additional_patterns:
        insert_new_pattern(checker_patterns, additional_pattern)
    if num_of_precursors == 1:
        error_patterns = single_precursor_unique_error_patterns
    elif num_of_precursors == 2:
        error_patterns = double_precursor_unique_error_patterns

    R = sp.MutableDenseNDimArray(sp.symbols('0, '*(err_len-1) +' a:%d'%(seq_length+num_of_precursors-center)))
    N = sp.MutableDenseNDimArray(sp.symbols('n:%d'%(seq_length)))

    sub_vals = {}
    for ii in range(seq_length+num_of_precursors-center):
        sub_vals[R[ii+err_len-1]] = 0
    matrix = {}
    print(checker_patterns)
    for error in error_patterns:
        matrix[stringify_error(error)] = {}
        for checker in checker_patterns:
            remaining_error = [error[ii] - checker[ii] for ii in range(err_len)]
            removed_row = [0]*err_len
            error_row = [0]*err_len
            for ii in range(err_len):
                removed_row[ii] = remaining_error[ii]*R[(err_len-1+num_of_precursors-center-ii):(err_len-1+num_of_precursors-center-ii+seq_length)]
                error_row[ii] = error[ii]*R[(err_len-1+num_of_precursors-center-ii):(err_len-1+num_of_precursors-center-ii+seq_length)]


            total_margin = 0
            total_left = 0
            total_right = 0
            for ii in range(seq_length):
                total_left += sp.simplify((sum([error_row[jj][ii] for jj in range(err_len)]) + N[ii])**2)
                total_right += sp.simplify((sum([removed_row[jj][ii]  for jj in range(err_len)])+N[ii])**2)
                symbol_left = sp.simplify((sum([error_row[jj][ii] for jj in range(err_len)]) + N[ii])**2)
                symbol_right = sp.simplify((sum([removed_row[jj][ii]  for jj in range(err_len)])+N[ii])**2)
                total_margin = total_margin + symbol_left - symbol_right



            current_result = sp.simplify(total_margin).subs({'0' : 0})
            noise_terms = 0
            for ii in range(seq_length):
                test_result = current_result
                for jj in [kk for kk in range(seq_length) if kk != ii]:
                    test_result = test_result.subs({N[jj] : 0})
                noise_terms += (sp.Poly(test_result, N[ii]).coeffs()[0])**2

            #Remove the noise terms
            current_result = current_result.subs({N[ii] : 0 for ii in range(seq_length)})
            if stringify_error(error) == 'pn00' and (stringify_error(checker) == 'pn00' or stringify_error(checker) == 'pn0p'):
                print(error, checker, total_left, total_right)
                print(current_result)
                print(noise_terms)
            #Divide by the noise sigma enhancement
            current_result = sp.simplify(current_result/sp.sqrt(noise_terms)/sigma)



            matrix[stringify_error(error)][stringify_error(checker)] = current_result

    return matrix

def find_best_checker_pattern(seq_length, num_of_precursors,  checker_patterns, error_pattern,center=1, overload_channel=None, mode='cross', print_out=False, sigma=1):
    err_len = len(error_pattern)
    R = sp.MutableDenseNDimArray(sp.symbols('0, '*(err_len-1) +' a:%d'%(seq_length+num_of_precursors-center)))
    N = sp.MutableDenseNDimArray(sp.symbols('n:%d'%(seq_length)))

    sub_vals = {}
    if overload_channel is not None:
        for ii in range(seq_length+num_of_precursors-center):
            sub_vals[R[ii+err_len-1]] = overload_channel[ii]
    else:
        for ii in range(num_of_precursors):
            sub_vals[R[ii+err_len-1]] = 0.2#0.5 / (num_of_precursors+1) * (ii + 1)
        
        sub_vals[R[err_len-1+num_of_precursors]] = 1

        for ii in range(1,seq_length-center):
            sub_vals[R[ii+err_len-1+num_of_precursors]] =0.3# 0.7 / (err_len-1+num_of_precursors) * (err_len-1+num_of_precursors-ii)


    best_result = None
    best_value  = -99999
        
    output_list = []
    for (pat_ii, checker_pattern) in enumerate(checker_patterns):
        uncorrected_error = (error_pattern - checker_pattern)


        if mode == 'cross':
            #Don't calculate the correlation if the match is perfect!
            if sum([abs(uncr) for uncr in uncorrected_error]) == 0:
                best_value = 0
                best_result= 0
                best_pattern = pat_ii
                break

            uncorrected_row = [0]*err_len
            checker_row     = [0]*err_len
            for ii in range(err_len):
                uncorrected_row[ii] = uncorrected_error[ii]*R[(err_len-1+num_of_precursors-center-ii):(err_len-1+num_of_precursors-center-ii+seq_length)]
                checker_row[ii] = checker_pattern[ii]*R[(err_len-1+num_of_precursors-center-ii):(err_len-1+num_of_precursors-center-ii+seq_length)]


            total_column_sum_products = 0
            for ii in range(seq_length):
                total_column_sum_products += sp.simplify(sum([uncorrected_row[jj][ii]  for jj in range(err_len)])*sum([checker_row[jj][ii]  for jj in range(err_len)]))

            current_result = sp.simplify(total_column_sum_products).subs({'0' : 0})
            output_list += [(checker_pattern, current_result.subs(sub_vals))]
    
        elif mode == 'margin':

            removed_row = [0]*err_len
            error_row     = [0]*err_len
            for ii in range(err_len):
                removed_row[ii] = uncorrected_error[ii]*R[(err_len-1+num_of_precursors-center-ii):(err_len-1+num_of_precursors-center-ii+seq_length)]
                error_row[ii] = error_pattern[ii]*R[(err_len-1+num_of_precursors-center-ii):(err_len-1+num_of_precursors-center-ii+seq_length)]

            total_margin = 0
            for ii in range(seq_length):
                symbol_left = sp.simplify((sum([error_row[jj][ii] for jj in range(err_len)]) + N[ii])**2)
                symbol_right = sp.simplify((sum([removed_row[jj][ii]  for jj in range(err_len)])+N[ii])**2)
                total_margin = total_margin + symbol_left - symbol_right


            current_result = sp.simplify(total_margin).subs({'0' : 0})
            noise_terms = 0
            for ii in range(seq_length):
                test_result = current_result
                for jj in [kk for kk in range(seq_length) if kk != ii]:
                    test_result = test_result.subs({N[jj] : 0})
                noise_terms += (sp.Poly(test_result, N[ii]).coeffs()[0])**2
            
            #Remove the noise terms
            current_result = current_result.subs({N[ii] : 0 for ii in range(seq_length)})
            #Divide by the noise sigma enhancement
            energy_result = sp.simplify(current_result).subs(sub_vals)
            current_result = sp.simplify(current_result/sp.sqrt(noise_terms)/sigma) 

            #Normalize by the channel conditiom of \sum |channel| = 1
            val = current_result.subs(sub_vals)/(sum([abs(cval) for cval in overload_channel if cval is not None]) +  abs(overload_channel[-1]*1.5))
            output_list += [(checker_pattern, val)]

            if val > best_value:
                best_value = val
                best_result= (current_result, energy_result)
                best_pattern = pat_ii

    return output_list

    return best_pattern, best_value, best_result[0], best_result[1] 

def create_energy_metric(seq_length, curs_pos, error_vals):
    expression = 0
    exp_str    = ""
    for ii in range(seq_length):
        sub_seq = 0
        sub_seq_str = ""
        for jj in range(4):
            if (ii - jj - curs_pos) > -3:
                sub_seq += error_vals[jj] * h[ii-jj - curs_pos]
                if error_vals[jj] == 1:
                    #sub_seq += h[ii-jj - curs_pos]
                    sub_seq_str += f' + h[{ii-jj -curs_pos}]' if jj > 0 else f'h[{ii-jj -curs_pos}]'
                elif error_vals[jj] == -1:
                    sub_seq_str += f' - h[{ii-jj -curs_pos}]' if jj > 0 else f'-h[{ii-jj -curs_pos}]'
                    #sub_seq -= h[ii-jj-curs_pos]
        if len(sub_seq_str) > 0:
            exp_str += f' + ({sub_seq_str})**2' if ii > 0 else f'({sub_seq_str})**2'
        expression += sub_seq**2
    return expression, exp_str

def calculate_worst_energy(index, queue, channel, matrix):
    worst_overall_error = 0
    worst_overall_snr = 9999
    worst_overall_checker = 0


    sub_vals = {}
    for ii, cval in enumerate(channel):
        sub_vals[f'a{ii}'] = cval

    for error_pattern in matrix.keys():
        best_error = 0
        best_snr = 0
        best_checker = 0
        for checker_pattern in matrix[error_pattern].keys():
            snr = matrix[error_pattern][checker_pattern].subs(sub_vals)/(sum([abs(cval) for cval in channel]) +  abs(channel[-1]*1.5))
            if snr > best_snr:
                best_snr = snr
                best_error = error_pattern
                best_checker = checker_pattern

        if best_snr < worst_overall_snr:
            worst_overall_snr = best_snr
            worst_overall_error = best_error
            worst_overall_checker = best_checker
    queue.put((index, worst_overall_error, worst_overall_checker, worst_overall_snr))

def calculate_all_error_snrs(index, queue, channel, matrix):

    sub_vals = {}
    for ii, cval in enumerate(channel):
        sub_vals[f'a{ii}'] = cval

    snrs = []
    for error_pattern in matrix.keys():
        best_snr = 0
        best_checker = 0
        for checker_pattern in matrix[error_pattern].keys():
            snr = matrix[error_pattern][checker_pattern].subs(sub_vals)/(sum([abs(cval) for cval in channel]) +  abs(channel[-1]*1.5))
            if error_pattern == 'pn00':
                print(checker_pattern, snr)
                print(matrix[error_pattern][checker_pattern])
            if snr > best_snr:
                best_snr = snr
                best_checker = checker_pattern
            
        snrs += [best_snr]

    queue.put((index, snrs))

def calculate_all_probabilities(index, queue, channel, num_of_precursors, target_ber=1e-3):
    if num_of_precursors == 1:
        errors = process_unique_error(single_precursor_unique_error_patterns)
    else:
        errors = process_unique_error(double_precursor_unique_error_patterns)

    chan = create_extended_channel(channel, 0.6)
    sigma = 1e-6
    ber = 0

    try:
        while ber < target_ber:
            ber = find_error_probabilities_for_channel([[1.0]], chan, 8, 16, sigma, plot_out=False, bound_size=3)[0][0]
            if ber == 0.0:
                sigma = sigma * 2
            else:
                sigma = sigma * 1.1

        while ber > 1.001*target_ber or ber < 0.999*target_ber:
            ber = find_error_probabilities_for_channel([[1.0]], chan, 8, 16, sigma)[0][0]
            if ber < 1.001*target_ber and ber > 0.999*target_ber:
                break
            sigma = sigma * (1 + np.log10(target_ber/ber)/20)
        error_prob = find_error_probabilities_for_channel(errors, chan, 8, 16, sigma, print_out=False, bound_size=3)[0]
    except np.linalg.LinAlgError:
        print(chan, sigma, ber, target_ber)
        exit()
    queue.put((index, error_prob, sigma))

def calculate_worst_probability(index, queue, channel, error):
    error = process_unique_error([error])[0]
    chan = create_extended_channel(channel, 0.6)
    target_ber = 1E-4
    sigma = 1e-4
    ber = 0
    while ber < target_ber:
        ber = find_error_probabilities_for_channel([[1.0]], chan, 8, 16, sigma, plot_out=False, bound_size=3)[0][0]
        if ber == 0.0:
            sigma = sigma * 2
        else:
            sigma = sigma * 1.1

    while ber > 1.001*target_ber or ber < 0.999*target_ber:
        ber = find_error_probabilities_for_channel([[1.0]], chan, 8, 16, sigma, bound_size=3)[0][0]
        if ber < 1.001*target_ber and ber > 0.999*target_ber:
            break
        sigma = sigma * (1 + np.log10(target_ber/ber)/20)

    error_prob = find_error_probabilities_for_channel([error], chan, 8, 16, sigma, print_out=True, bound_size=3)[0][0]
    print(f'Error prob: {error_prob} for sigma: {sigma} and BER: {ber} for channel: {channel}')
    queue.put((index, error_prob))

def launch_processes(input_struct_list, num_of_cores, num_of_runs, target=calculate_worst_energy):
    queue_data = []
    print(num_of_cores, num_of_runs, len(input_struct_list))
    for ii in range(num_of_runs):
        end_index = (ii+1)*num_of_cores if (ii+1)*num_of_cores < len(input_struct_list) else len(input_struct_list)
        print(f'Starting run {ii+1} out of {num_of_runs} with {end_index - ii*num_of_cores} processes')
        processes = [Process(target=target, args=input_struct_list[ii]) for ii in range(ii*num_of_cores, end_index)]
        for proc in processes:
            proc.start()
        for proc in processes:
            proc.join(timeout=50)

        while [process.is_alive() for process in processes].count(True) > 0:
            continue

        while not queue.empty():
            queue_data.append(queue.get())
    return queue_data


def calculate_channel_loss(chan, gamma, num_of_precursors, return_group_delay=False):
    channel = chan[:num_of_precursors+1] + [chan[num_of_precursors+1]*gamma**ii for ii in range(90+(num_of_precursors-1))]
    channel = np.array(channel)/np.sum(np.abs(channel))

    chan_fft = 20*np.log10(np.abs(np.fft.fft(channel))[:int(len(channel)/2)])
    loss = np.min(chan_fft)

    return loss
def plot_channel_characteristics(h_m1_values, h_p1_values):

    map_val = np.zeros((len(h_m1_values), len(h_p1_values)))
    for (ii, h_m1_value) in enumerate(h_m1_values):
        for (jj, h_p1_value) in enumerate(h_p1_values):
            if h_m1_value <  1 and 1 > h_p1_value and h_p1_value > h_m1_value:
                loss, group_delay_deviation = calculate_channel_loss([0.3*h_m1_value, h_m1_value, 1, h_p1_value], 0.6, 2, return_group_delay=True)
                if loss > -40:
                    map_val[ii,jj] = np.max(group_delay_deviation)
    plt.imshow(map_val, cmap='hot', interpolation='nearest', extent=[0.01,1.0,0.01,1.0], origin='lower')
    plt.show()

def build_input_struct_for_one_precursor(matrix, queue, h_m1_values, h_p1_values, loss):

    input_struct_list = []
    for (ii, h_m1_value) in enumerate(h_m1_values):
        for (jj, h_p1_value) in enumerate(h_p1_values):
            if h_m1_value <  1 and 1 > h_p1_value and h_p1_value > h_m1_value and calculate_channel_loss([h_m1_value, 1, h_p1_value], 0.6, 1) > loss:
                input_struct_list += [((ii, jj), queue, [h_m1_value, 1, h_p1_value], matrix)]

    return input_struct_list

def build_input_struct_for_one_precursor_worst_error(queue, h_m1_values, h_p1_values, loss):

    input_struct_list = []
    for (ii, h_m1_value) in enumerate(h_m1_values):
        for (jj, h_p1_value) in enumerate(h_p1_values):
            if h_m1_value <  1 and 1 > h_p1_value and h_p1_value > h_m1_value and calculate_channel_loss([h_m1_value, 1, h_p1_value], 0.6, 1) > loss:
                input_struct_list += [((ii, jj), queue, [h_m1_value, 1, h_p1_value], 1)]

    return input_struct_list

def build_input_struct_for_two_precursor(matrix, queue, h_m1_values, h_p1_values, gamma, loss, seq_length=3):

    chan = [gamma*h_m1_value, h_m1_value, 1, h_p1_value]
    if seq_length > 3:
        chan += [h_p1_value*(0.6)**ii for ii in range(1, seq_length-2)]

    input_struct_list = []
    for (ii, h_m1_value) in enumerate(h_m1_values):
        for (jj, h_p1_value) in enumerate(h_p1_values):
            if (1 > h_p1_value) and h_p1_value > h_m1_value and calculate_channel_loss(chan, 0.6, 2) > loss:
                input_struct_list += [((ii, jj), queue, [gamma*h_m1_value, h_m1_value, 1, h_p1_value], matrix)]

    return input_struct_list

def build_input_struct_for_two_precursor_with_roaming(matrices, map, queue, h_m1_values, h_p1_values, gamma, loss, seq_length=3):

    chan = [gamma*h_m1_value, h_m1_value, 1, h_p1_value]
    if seq_length > 3:
        chan += [h_p1_value*(0.6)**ii for ii in range(1, seq_length-2)]

    input_struct_list = []
    for (ii, h_m1_value) in enumerate(h_m1_values):
        for (jj, h_p1_value) in enumerate(h_p1_values):
            if (1 > h_p1_value) and h_p1_value > h_m1_value and calculate_channel_loss(chan, 0.6, 2) > loss:
                input_struct_list += [((ii, jj), queue, [gamma*h_m1_value, h_m1_value, 1, h_p1_value], matrices[map[ii][jj]])]

    return input_struct_list

def build_input_struct_for_two_precursor_worst_error(queue, h_m1_values, h_p1_values, gamma, loss):

    input_struct_list = []
    for (ii, h_m1_value) in enumerate(h_m1_values):
        for (jj, h_p1_value) in enumerate(h_p1_values):
            if (1 > h_p1_value) and h_p1_value > h_m1_value and calculate_channel_loss([gamma*h_m1_value, h_m1_value, 1, h_p1_value], 0.6, 2) > loss:
                input_struct_list += [((ii, jj), queue, [gamma*h_m1_value, h_m1_value, 1, h_p1_value], 2)]

    return input_struct_list

def build_input_struct_for_two_precursor_probability(error_matrix, queue, h_m1_values, h_p1_values, gamma, loss):
    input_struct_list = []
    for (ii, h_m1_value) in enumerate(h_m1_values):
        for (jj, h_p1_value) in enumerate(h_p1_values):
            if (1 > h_p1_value) and h_p1_value > h_m1_value and calculate_channel_loss([gamma*h_m1_value, h_m1_value, 1, h_p1_value], 0.6, 2) > loss:
                input_struct_list += [((ii, jj), queue, [gamma*h_m1_value, h_m1_value, 1, h_p1_value], double_precursor_unique_error_patterns[int(error_matrix[ii][jj])])]

    return input_struct_list

def build_input_struct_for_two_precursor_all_probabilities(queue, h_m1_values, h_p1_values, gamma, loss):
    input_struct_list = []
    for (ii, h_m1_value) in enumerate(h_m1_values):
        for (jj, h_p1_value) in enumerate(h_p1_values):
            if (1 > h_p1_value) and h_p1_value > h_m1_value and calculate_channel_loss([gamma*h_m1_value, h_m1_value, 1, h_p1_value], 0.6, 2) > loss:
                input_struct_list += [((ii, jj), queue, [gamma*h_m1_value, h_m1_value, 1, h_p1_value], 2)]

    return input_struct_list


def plot_block_figure(vals, bestcase_vals, colorify, num_of_precursors, filename):
    fig, ax = plt.subplots()
    error_pattern_set = build_unique_error_pattern_set(3+(num_of_precursors-1))

    unique_errors = np.unique(vals)


    block_map = np.zeros((vals.shape[0], vals.shape[1], 3))
    for ii in range(vals.shape[0]):
        for jj in range(vals.shape[1]):
            val = int(vals[ii,jj])
            block_map[ii, jj, :] = colorify[val]

    im1 = plt.imshow(block_map, interpolation='nearest', extent=[0.01,1.0,0.01,1.0], origin='lower', aspect='auto')

    for err in unique_errors:
        err = int(err)
        if err != 0:
            plt.plot(0,0, color=colorify[err], label=stringify_error(error_pattern_set[int(err)]))
        print(stringify_error(error_pattern_set[int(err)]))

    plt.xlabel('Postcursor Value')
    plt.ylabel('Precursor Value')
    plt.title('Regions Colored By Error')
    plt.legend(loc='upper left')

    plt.savefig(f'{filename}.pgf', bbox_inches='tight')

def plot_snr_figure(vals, filename, bounds = [-0.1, 1.25], aspect=4):
    fig, ax = plt.subplots(1,2)

    norm = Normalize(vmin=bounds[0], vmax=bounds[1])
    new_shape = (vals.shape[0], vals.shape[1], 4)
    image = np.zeros(new_shape)
    for ii in range(vals.shape[0]):
        for jj in range(vals.shape[1]):
            if norm(vals[ii, jj]) < 1:
                image[ii, jj, :] = cm.gist_rainbow(norm(vals[ii, jj]))



    im1 = ax[0].imshow(image, interpolation='nearest', extent=[0.01,1.0,0.01,1.0], origin='lower', aspect='auto')
    ax[0].set_xlabel('Postcursor Value')
    ax[0].set_ylabel('Precursor Value')
    cb2 = colorbar.ColorbarBase(ax[1], cmap='gist_rainbow',
                                norm=norm,
                                extend='neither',
                                spacing='proportional',
                                orientation='vertical', drawedges=False)
    #ax[0].set_aspect(1)
    ax[1].set_aspect(aspect)
    plt.tight_layout()

    #plt.show()
    plt.savefig(f'{filename}.pgf', bbox_inches='tight')

def collect_and_analyze_double_precursor_worst_error(queue, num_of_steps, num_of_cores, gamma=0.3, loss=-35):

    def func_worst_error(index, queue , chan, num_of_precursors):
        worst_error, worst_value = find_worst_error_snr(3, num_of_precursors, overload_channel=chan)

        queue.put((index, worst_error, worst_value))

    h_p1_values = np.linspace(0.01, 1, num_of_steps)
    h_m1_values = np.linspace(0.01, 1, num_of_steps)

    map_val = np.zeros((num_of_steps, num_of_steps))
    pat_val = np.zeros((num_of_steps, num_of_steps))
    input_struct_list = build_input_struct_for_two_precursor_worst_error(queue, h_p1_values, h_m1_values, gamma, loss)
    collected_results = launch_processes(input_struct_list, num_of_cores, round(len(input_struct_list)/num_of_cores + 0.5), target=func_worst_error)

    checked_indexes = []


    for (index, worst_error, worst_error_val) in collected_results:
        (aa, bb) = index
        checked_indexes += [index]
        print(f'Channel: {[gamma*h_m1_values[aa], h_m1_values[aa], 1, h_p1_values[bb]]}')
        print(f'E: {worst_error} M: {worst_error_val}\n')
        map_val[index] = worst_error_val
        pat_val[index] = worst_error

    for (ii, h_m1_value) in enumerate(h_m1_values):
        for (jj, h_p1_value) in enumerate(h_p1_values):
            if (ii, jj) not in checked_indexes:
                map_val[ii, jj] = 1.25

    return map_val, pat_val

def collect_and_analyze_single_precursor_worst_error(queue, num_of_steps, num_of_cores, gamma=0.3, loss=-35):

    def func_worst_error(index, queue , chan, num_of_precursors):
        worst_error, worst_value = find_worst_error_snr(3, num_of_precursors, overload_channel=chan)

        queue.put((index, worst_error, worst_value))

    h_p1_values = np.linspace(0.01, 1, num_of_steps)
    h_m1_values = np.linspace(0.01, 1, num_of_steps)

    map_val = np.zeros((num_of_steps, num_of_steps))
    pat_val = np.zeros((num_of_steps, num_of_steps))
    input_struct_list = build_input_struct_for_one_precursor_worst_error(queue, h_p1_values, h_m1_values, loss)
    collected_results = launch_processes(input_struct_list, num_of_cores, round(len(input_struct_list)/num_of_cores + 0.5), target=func_worst_error)

    checked_indexes = []


    for (index, worst_error, worst_error_val) in collected_results:
        (aa, bb) = index
        checked_indexes += [index]
        print(f'Channel: {[h_m1_values[aa], 1, h_p1_values[bb]]}')
        print(f'E: {worst_error} M: {worst_error_val}\n')
        map_val[index] = worst_error_val
        pat_val[index] = worst_error

    for (ii, h_m1_value) in enumerate(h_m1_values):
        for (jj, h_p1_value) in enumerate(h_p1_values):
            if (ii, jj) not in checked_indexes:
                map_val[ii, jj] = 1.25

    return map_val, pat_val

def collect_and_analyze_single_precursor_results(queue, num_of_steps, num_of_cores, loss=-35, additional_patterns=[]):
    h_p1_values = np.linspace(0.01, 1, num_of_steps)
    h_m1_values = np.linspace(0.01, 1, num_of_steps)
    map_val = np.zeros((num_of_steps, num_of_steps))
    pat_val = np.zeros((num_of_steps, num_of_steps))

    input_struct_list = build_input_struct_for_one_precursor(calculate_checker_margins_for_errors(3,1,sigma=1, additional_patterns=additional_patterns), queue, h_p1_values, h_m1_values, loss)
    collected_results = launch_processes(input_struct_list, num_of_cores, round(len(input_struct_list)/num_of_cores + 0.5))
    unique_errors = build_unique_error_pattern_set(3)

    error_indexer = {}
    for (index, error) in enumerate(unique_errors):
        error_indexer[stringify_error(error)] = index
    

    checked_indexes = []
    for (index, worst_error, worst_checker, worst_snr) in collected_results:
        (aa, bb) = index
        checked_indexes += [index]
        print(f'Channel: {[h_m1_values[aa], 1, h_p1_values[bb]]}')
        print(f'E: {worst_error} <-> C: {worst_checker}, M: {worst_snr}\n')
        map_val[index] = worst_snr
        pat_val[index] = error_indexer[worst_error]

    for (ii, h_m1_value) in enumerate(h_m1_values):
        for (jj, h_p1_value) in enumerate(h_p1_values):
            if (ii, jj) not in checked_indexes:
                map_val[ii, jj] = 1.25

    return map_val, pat_val

def collect_and_analyze_double_precursor_results(queue, num_of_steps, num_of_cores, gamma , loss=-35, additional_patterns=[], roaming_map=None):
    h_p1_values = np.linspace(0.01, 1, num_of_steps)
    h_m1_values = np.linspace(0.01, 1, num_of_steps)

    map_val = np.zeros((num_of_steps, num_of_steps))
    pat_val = np.zeros((num_of_steps, num_of_steps))

    unique_errors = double_precursor_unique_error_patterns

    error_indexer = {}
    for (index, error) in enumerate(unique_errors):
        error_indexer[stringify_error(error)] = index

    if roaming_map is not None:
        print('Building Roaming Matrices')
        roaming_matrices = {}
        print(np.unique(roaming_map))
        for roaming_error_pattern in np.unique(roaming_map):
            if roaming_error_pattern == 0:
                continue
            roaming_matrices[roaming_error_pattern] = calculate_checker_margins_for_errors(3,2,sigma=1, additional_patterns=[unique_errors[int(roaming_error_pattern)]])
        print('Finished Building Roaming Matrices')
        print('Building Input Struct')
        input_struct_list = build_input_struct_for_two_precursor_with_roaming(roaming_matrices, roaming_map, queue, h_p1_values, h_m1_values, gamma, loss)
    else:
        print('Building Input Struct')
        input_struct_list = build_input_struct_for_two_precursor(calculate_checker_margins_for_errors(3,2,sigma=1, additional_patterns=additional_patterns), queue, h_p1_values, h_m1_values, gamma, loss)
    
    collected_results = launch_processes(input_struct_list, num_of_cores, round(len(input_struct_list)/num_of_cores + 0.5))
    checked_indexes = []

    for (index, worst_error, worst_checker, worst_snr) in collected_results:
        (aa, bb) = index
        checked_indexes += [index]
        print(f'Channel: {[gamma*h_m1_values[aa], h_m1_values[aa], 1, h_p1_values[bb]]}')
        print(f'E: {worst_error} <-> C: {worst_checker}, M: {worst_snr}\n')
        map_val[index] = worst_snr
        pat_val[index] = error_indexer[worst_error]


    for (ii, h_m1_value) in enumerate(h_m1_values):
        for (jj, h_p1_value) in enumerate(h_p1_values):
            if (ii, jj) not in checked_indexes:
                map_val[ii, jj] = 1.25

    return map_val, pat_val


def collect_and_analyze_double_precursor_worst_errror_probabilities(queue, num_of_steps, num_of_cores, gamma , roaming_map, loss=-35):
    h_p1_values = np.linspace(0.01, 1, num_of_steps)
    h_m1_values = np.linspace(0.01, 1, num_of_steps)

    map_val = np.zeros((num_of_steps, num_of_steps))


    input_struct_list = build_input_struct_for_two_precursor_probability(roaming_map, queue, h_p1_values, h_m1_values, gamma, loss)
    
    collected_results = launch_processes(input_struct_list, num_of_cores, round(len(input_struct_list)/num_of_cores + 0.5), target=calculate_worst_probability)
    checked_indexes = []
    for (index, error_probability) in collected_results:
        (aa, bb) = index
        checked_indexes += [index]
        print(f'Channel: {[gamma*h_m1_values[aa], h_m1_values[aa], 1, h_p1_values[bb]]}')
        print(f'E: {roaming_map[aa][bb]} -> {error_probability}\n')
        map_val[index] = np.log10(error_probability)


    for (ii, h_m1_value) in enumerate(h_m1_values):
        for (jj, h_p1_value) in enumerate(h_p1_values):
            if (ii, jj) not in checked_indexes:
                map_val[ii, jj] = 0

    return map_val

def collect_and_analyze_double_precursor_all_probabilities(queue, num_of_steps, num_of_cores, gamma, loss=-35):
    h_p1_values = np.linspace(0.01, 1, num_of_steps)
    h_m1_values = np.linspace(0.01, 1, num_of_steps)

    sigma_val = np.zeros((num_of_steps, num_of_steps))
    error_probability_val = np.zeros((num_of_steps, num_of_steps, len(double_precursor_unique_error_patterns)))

    input_struct_list = build_input_struct_for_two_precursor_all_probabilities(queue, h_p1_values, h_m1_values, gamma, loss)
    
    collected_results = launch_processes(input_struct_list, num_of_cores, round(len(input_struct_list)/num_of_cores + 0.5), target=calculate_all_probabilities)
    checked_indexes = []

    for (index, error_probability, sigma) in collected_results:
        (aa, bb) = index
        checked_indexes += [index]
        print(f'Channel: {[gamma*h_m1_values[aa], h_m1_values[aa], 1, h_p1_values[bb]]}')
        for error, probability in zip(double_precursor_unique_error_patterns, error_probability):
            print(f'E: {error} -> P: {probability}')
        error_probability_val[aa,bb,:] = np.array(error_probability)
        sigma_val[index] = sigma

    return error_probability_val, sigma_val

def collect_and_analyze_double_precursor_all_errors_snr(queue, num_of_steps, num_of_cores, gamma , loss=-35, additional_patterns=[], roaming_map=None, seq_length=3):
    h_p1_values = np.linspace(0.01, 1, num_of_steps)
    h_m1_values = np.linspace(0.01, 1, num_of_steps)

    error_snr_val = np.zeros((num_of_steps, num_of_steps, len(double_precursor_unique_error_patterns)))

    unique_errors = double_precursor_unique_error_patterns


    if roaming_map is not None:
        print('Building Roaming Matrices')
        roaming_matrices = {}
        print(np.unique(roaming_map))
        for roaming_error_pattern in np.unique(roaming_map):
            if roaming_error_pattern == 0:
                continue
            roaming_matrices[roaming_error_pattern] = calculate_checker_margins_for_errors(3,2,sigma=1, additional_patterns=[unique_errors[int(roaming_error_pattern)]])
        print('Finished Building Roaming Matrices')
        print('Building Input Struct')
        input_struct_list = build_input_struct_for_two_precursor_with_roaming(roaming_matrices, roaming_map, queue, h_p1_values, h_m1_values, gamma, loss, seq_length=seq_length)
    else:
        print('Building Input Struct')
        input_struct_list = build_input_struct_for_two_precursor(calculate_checker_margins_for_errors(3,2,sigma=1, additional_patterns=additional_patterns), queue, h_p1_values, h_m1_values, gamma, loss, seq_length=seq_length)
    
    collected_results = launch_processes(input_struct_list, num_of_cores, round(len(input_struct_list)/num_of_cores + 0.5), target=calculate_all_error_snrs)
    checked_indexes = []

    for (index, snrs) in collected_results:
        (aa, bb) = index
        checked_indexes += [index]
        print(f'Index: {index}')
        print(f'Channel: {[gamma*h_m1_values[aa], h_m1_values[aa], 1, h_p1_values[bb]]}')
        print(f'SNRs: {snrs}')
        error_snr_val[aa,bb,:] = np.array(snrs)

    return error_snr_val, checked_indexes

def create_checker_patterns(num_of_precursors):
    if num_of_precursors == 1:
        checker_patterns = [[2,0,0], [+2,-2,0], [2,-2,2]]
    elif num_of_precursors == 2:
        checker_patterns = [[2,0,0,0], [+2,-2,0,0], [+2,-2,+2,0]]

    return checker_patterns

def create_error_color_map(error_length):
    worst_error_color = {}

    def check_repeat_colors(worst_error_color):
        color_set = set()

        for key in worst_error_color:
            color = "".join([str(val) for val in worst_error_color[key]])
            if color in color_set:
                print(f'Color {color} repeated for {key}')
            else:
                color_set.add(color)

    def create_color_from_error(error_pattern):
        color = np.zeros((3,))
        for ii in range(3):
            if error_pattern[ii] == 2:
                color[ii] = 255
            elif error_pattern[ii] == -2:
                color[ii] = 125
        
        for ii in range(3, len(error_pattern)):
            if error_pattern[ii] == 0:
                color = color * 0.75 + 10
            elif error_pattern[ii] == -2:
                color = color * 0.25 + 10
        return color

    error_patterns = build_error_pattern_set(error_length)

    for error_pattern in error_patterns:      
        worst_error_color[stringify_error(error_pattern)] = create_color_from_error(error_pattern)/255.0

    check_repeat_colors(worst_error_color)
    print(worst_error_color)
    return worst_error_color

def stringify_error(error_pattern):
    new_str = ""
    for ii in range(len(error_pattern)):
        if error_pattern[ii] == 2:
            new_str += 'p'
        elif error_pattern[ii] == -2:
            new_str += 'n'
        else:
            new_str += '0'
    return new_str

if __name__ == "__main__":
    matplotlib.use("pgf")
    matplotlib.rcParams.update({
        "pgf.texsystem": "pdflatex",
        'font.family': 'serif',
        'text.usetex': True,
        'pgf.rcfonts': False,
    })

    queue = Queue()
    num_of_cores = 24
    num_of_points = 8

    analyze_single = False
    analyze_double = False
    double_gamma_list = [0.15, 0.3]
    plot = False

    def single_precursor_analysis():
        result1, worst_error = collect_and_analyze_single_precursor_worst_error(queue, num_of_points, num_of_cores, 0.3, loss = -40)
        result2, worst_error_1 = collect_and_analyze_single_precursor_results(queue, num_of_points, num_of_cores, loss = -40)
        np.savetxt('single_precursor_analysis_best_snr.csv', result1, delimiter=',')
        np.savetxt('single_precursor_analysis_best_snr_error.csv', worst_error, delimiter=',')
        np.savetxt('single_precursor_analysis_checker_snr.csv', result2, delimiter=',')
        np.savetxt('single_precursor_analysis_checker_error.csv', worst_error_1, delimiter=',')

    single_precursor_colorify = distinctipy.get_colors(len(build_unique_error_pattern_set(3)))
    single_precursor_colorify[0] = (1,1,1)


    def plot_single_precursor_analysis():
        result1 = np.loadtxt('single_precursor_analysis_best_snr.csv', delimiter=',')
        result2 = np.loadtxt('single_precursor_analysis_checker_snr.csv', delimiter=',')
        worst_error = np.loadtxt('single_precursor_analysis_best_snr_error.csv', delimiter=',')
        worst_error_1 = np.loadtxt('single_precursor_analysis_checker_error.csv', delimiter=',')

        plot_snr_figure(20*np.log10(result1), '1_precursor', bounds=[-15, 0],aspect=1)
        plot_snr_figure(20*np.log10(result2/result1), 'checker_penalty_1', bounds=[-2.7, 0], aspect=5)

        plot_block_figure(worst_error_1, worst_error,single_precursor_colorify, 1, 'worst_error_1')

    def double_precusor_analysis(gamma):
        result1, worst_error = collect_and_analyze_double_precursor_worst_error(queue, num_of_points, num_of_cores, gamma, loss = -40)
        result2, worst_error_1 = collect_and_analyze_double_precursor_results(queue, num_of_points, num_of_cores, gamma, loss = -40)
        prob_result = collect_and_analyze_double_precursor_worst_errror_probabilities(queue, num_of_points, num_of_cores, 0.3, roaming_map=worst_error_1, loss = -40)
        np.savetxt(f'double_precursor_analysis_probability_{int(gamma*100)}.csv', prob_result, delimiter=',')
        result3, worst_error_3 = collect_and_analyze_double_precursor_results(queue, num_of_points, num_of_cores, gamma, loss = -40, roaming_map=worst_error_1)
        np.savetxt(f'double_precursor_analysis_best_snr_{int(gamma*100)}.csv', result1, delimiter=',')
        np.savetxt(f'double_precursor_analysis_best_snr_error_{int(gamma*100)}.csv', worst_error, delimiter=',')
        np.savetxt(f'double_precursor_analysis_checker_snr_{int(gamma*100)}.csv', result2, delimiter=',')
        np.savetxt(f'double_precursor_analysis_checker_error_{int(gamma*100)}.csv', worst_error_1, delimiter=',')
        np.savetxt(f'double_precursor_analysis_roaming_best_snr_{int(gamma*100)}.csv', result3, delimiter=',')
        np.savetxt(f'double_precursor_analysis_roaming_checker_error_{int(gamma*100)}.csv', worst_error_3, delimiter=',')

    two_precursor_colorify = distinctipy.get_colors(len(build_unique_error_pattern_set(4)))
    two_precursor_colorify[0] = (1,1,1)

    def plot_double_precursor_analysis(gamma):
        
        result1 = np.loadtxt(f'double_precursor_analysis_best_snr_{int(gamma*100)}.csv', delimiter=',')
        result2 = np.loadtxt(f'double_precursor_analysis_checker_snr_{int(gamma*100)}.csv', delimiter=',')
        worst_error = np.loadtxt(f'double_precursor_analysis_best_snr_error_{int(gamma*100)}.csv', delimiter=',')
        worst_error_1 = np.loadtxt(f'double_precursor_analysis_checker_error_{int(gamma*100)}.csv', delimiter=',')
        prob_result = np.loadtxt(f'double_precursor_analysis_probability_{int(gamma*100)}.csv', delimiter=',')
        result3 = np.loadtxt(f'double_precursor_analysis_roaming_best_snr_{int(gamma*100)}.csv', delimiter=',')
        worst_error_3 = np.loadtxt(f'double_precursor_analysis_roaming_checker_error_{int(gamma*100)}.csv', delimiter=',')
        plot_snr_figure(20*np.log10(result1), f'2_precursor_{int(gamma*100)}', bounds=[-15, 0],aspect=1)
        plot_snr_figure(20*np.log10(result2/result1), f'checker_penalty_2_{int(gamma*100)}', bounds=[-2.7, 0], aspect=5)
        plot_snr_figure(20*np.log10(result3/result1), f'roaming_checker_penalty_2_{int(gamma*100)}', bounds=[-2.7, 0], aspect=5)
        plot_snr_figure(prob_result, f'probability_2_{int(gamma*100)}', bounds=[-25, 0], aspect=1)

        plot_block_figure(worst_error_1, worst_error, two_precursor_colorify, 2, f'worst_error_2_{int(gamma*100)}')
        plot_block_figure(worst_error_3, worst_error, two_precursor_colorify, 2, f'worst_error_3_{int(gamma*100)}')

    if analyze_single:
        single_precursor_analysis()
    if analyze_double:
        for gamma in double_gamma_list:
            double_precusor_analysis(gamma)

    if plot:
        plot_single_precursor_analysis()
        for gamma in double_gamma_list:
            plot_double_precursor_analysis(gamma)

    def combine_snr_and_err_prob(checked, num_of_steps, num_of_errors, map1, map2, sigma):
        h_p1_values = np.linspace(0.01, 1, num_of_steps)
        h_m1_values = np.linspace(0.01, 1, num_of_steps)

        new_map = np.zeros((num_of_steps, num_of_steps, num_of_errors))

        for (ii, jj) in checked:
            print(ii, jj, [0.3*h_m1_values[ii], h_m1_values[ii], 1, h_p1_values[jj]], sigma[ii,jj])
            for kk in range(num_of_errors):
                new_map[ii, jj, kk] = 0.5*(1- spec.erf(map1[ii, jj, kk]/sigma[ii,jj]/np.sqrt(2))) * map2[ii, jj, kk]
                print(double_precursor_unique_error_patterns[kk], map1[ii, jj, kk], 0.5*(1- spec.erf(map1[ii, jj, kk]/sigma[ii,jj]/np.sqrt(2))), map2[ii, jj, kk],new_map[ii, jj, kk] )

        return new_map

    list_of_channels = [ [0.03, 0.1, 1, 0.3], [0.65*0.3, 0.6, 1, 0.65], [0.15, 0.5, 1, 0.95]]
    list_of_channels = [[0.65*0.3, 0.6, 1, 0.65]]
    print(calculate_channel_loss(list_of_channels[0], 0.6, 2))
    matrix = calculate_checker_margins_for_errors(3, 2, additional_patterns=[[2,-2,0,2]])

    for ii, chan in enumerate(list_of_channels):
        calculate_all_probabilities((ii,0), queue, chan, 2, target_ber=0.5e-3)
        calculate_all_error_snrs((ii,1), queue, chan, matrix)
    snrs = np.zeros((len(list_of_channels), 1, len(double_precursor_unique_error_patterns)))
    sigs = np.zeros((len(list_of_channels), 1))
    probs = np.zeros((len(list_of_channels),1,  len(double_precursor_unique_error_patterns)))
    checked = []
    while not queue.empty():
        result = queue.get()
        ii = result [0][0]
        jj = result [0][1]
        if jj == 0:
            probs[ii] = result[1]
            sigs[ii]  = result[2]
            print(result[2])
        else:
            snrs[ii] = result[1]
            checked.append((ii,0))

    def print_latex_column(error, snr, prob, total_prob, total_prob2):
        error_str = '$\\vec{{e}}_{{('
        for ii in range(len(error)):
            if error[ii] == 0:
                error_str += '0'
            elif error[ii] == 2:
                error_str += '+'
            elif error[ii] == -2:
                error_str += '-'
            if ii != len(error)-1:
                error_str += ','
        error_str += ')}}$'

        print(f'{error_str} & {snr} & {prob} & {total_prob} & {total_prob2} \\\\\\hline')


    for (ii, jj) in checked:
        print(sigs[ii,0])
        print(ii, jj, list_of_channels[ii])

        for kk in range(len(double_precursor_unique_error_patterns)):
            if kk == 22:
                print(snrs[ii,jj,kk], sigs)
                print_latex_column(double_precursor_unique_error_patterns[kk], f'{snrs[ii, jj, kk]:0.2f}', f'{0.5*(1 - spec.erf(snrs[ii, jj, kk]/sigs[ii,0]/np.sqrt(2))):0.2E}', f'{probs[ii, jj, kk]/probs[ii, jj, 13]:0.2E}', f'{0.5*(1- spec.erf(snrs[ii, jj, kk]/sigs[ii,jj]/np.sqrt(2)))*probs[ii, jj, kk]/probs[ii, jj, 13]:0.2E}')



    exit()
    snrs, checked = collect_and_analyze_double_precursor_all_errors_snr(queue, num_of_points, num_of_cores, 0.3, loss = -40)
    probs, sig = collect_and_analyze_double_precursor_all_probabilities(queue, num_of_points, num_of_cores, 0.3, loss = -40)

    total_map = combine_snr_and_err_prob(checked, num_of_points, len(double_precursor_unique_error_patterns), snrs, probs, sig)


    exit()
    single_precursor_matrix = calculate_checker_margins_for_errors(3, 1, sigma=1, center=1, additional_patterns=[])

    channel_1 = [0.2, 1, 0.25]

    sub_vals = {'a0' : 0.2, 'a1' : 1.0, 'a2': 0.25}

    print(find_worst_error_snr(3, 1, overload_channel=channel_1))

    for (ii, error) in enumerate(single_precursor_matrix.keys()):
        best_val = 0
        best_patt = None
        for pattern in single_precursor_matrix[error].keys():
            val = single_precursor_matrix[error][pattern].subs(sub_vals)/(sum([abs(cval) for cval in channel_1]) +  abs(channel_1[-1]*1.5))
            if val > best_val:
                best_val = val
                best_patt = pattern
        print(error, best_patt, best_val)


    exit()

    #print(result2/result1)
    #print(worst_error)
    plot_snr_figure(20*np.log10(result0), '1_precursor', bounds=[-15, 0],aspect=1)
    plot_snr_figure(20*np.log10(result0_p/result0), 'checker_penalty_1', bounds=[-2.7, 0], aspect=5)
    plot_snr_figure(20*np.log10(result1), 'gamma_30_2_precursor', bounds=[-15, 0],aspect=1)
    plot_snr_figure(20*np.log10(result2/result1), 'checker_penalty', bounds=[-2.7, 0], aspect=5)
    plot_snr_figure(20*np.log10(result3/result1), 'checker_penalty_improved', bounds=[-2.7, 0], aspect=5)
    plot_snr_figure(20*np.log10(result4/result1), 'checker_penalty_improved_diff_pattern', bounds=[-2.7, 0], aspect=5)
    plot_snr_figure(20*np.log10(result2_15/result1_15), 'checker_penalty_15', bounds=[-2.7, 0], aspect=5)
    plot_snr_figure(20*np.log10(result1_15), 'gamma_15_2_precursor', bounds=[-15, 0],aspect=1)

    h = Array('h', IntSort(), RealSort())
    i, a, b = Ints('i a b')

    num_of_precursors = 2
    seq_length        = 3
    curs_pos          = 1

    al , bl = +1, +1
    lse_val = [+1, -1, a, b]
    rse_val = [ 0,  0, a, b]
    another_rse_val = [0, -1, a, b]

    i_costraints = [i >= -2, i < 2]
    a_constraint = [a > -2, a < 2]
    b_constraint = [b > -2, b < 2]
    mm_constraint = h[1] == h[-1]

    #Force the channel to have a response that peaks at 0 and is monotonically decreasing off the sides
    struct_constraints = []
    for ii in [-2, -1]:
        struct_constraints.append(h[i+ii] < h[i+ii+1])
    for ii in [0, 1]:
        struct_constraints.append(h[i+ii] > h[i+ii+1])

    #Force all values of the channel within the interest range to be positive
    positivity_constraints = []
    for ii in [-2, -1, 0, 1]:
        positivity_constraints.append(h[i+ii] > 0)

    left_side_expression, lse_str = create_energy_metric(seq_length, curs_pos, lse_val)
    rght_side_expression, rse_str = create_energy_metric(seq_length, curs_pos, rse_val)
    another_rght_side_expression, another_rse_str = create_energy_metric(seq_length, curs_pos, another_rse_val)

    energy_constraints = [left_side_expression < rght_side_expression, left_side_expression < another_rght_side_expression]

    print('lse: ', lse_str)
    print('rse: ', rse_str)
    print('another_rse: ', another_rse_str)

    s = Solver()
    s.setOption(seed=43, verbose=True)
    s.setOption('portfolio-jobs', 16)
    s.add(*i_costraints, *a_constraint, *b_constraint, mm_constraint, *struct_constraints, *positivity_constraints, h[-2] < 1, h[0] == 1, *energy_constraints)
    assert sat == s.check()
    m = s.model()

    for ii in [-3, -2, -1, 0, 1]:
        print('h[{}]:'.format(ii), float(m[h[i+ii]].as_fraction()))
    #print(f'a: {m[a].as_fraction()}')
    print(f'b: {m[b]}')
