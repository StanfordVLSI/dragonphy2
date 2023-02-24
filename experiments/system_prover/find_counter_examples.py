from cvc5.pythonic import *
import sympy as sp
import numpy as np
from copy import copy
import matplotlib.pyplot as plt
import matplotlib
import matplotlib.cm as cm
from matplotlib.colors import Normalize
from matplotlib import colorbar

matplotlib.use("pgf")
matplotlib.rcParams.update({
    "pgf.texsystem": "pdflatex",
    'font.family': 'serif',
    'text.usetex': True,
    'pgf.rcfonts': False,
})

from multiprocessing import Pool, Queue, Process

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


def find_worst_error_snr(seq_length, num_of_precursors, center=1, overload_channel=None, sigma=1):
    error_patterns = build_unique_error_pattern_set(3+(num_of_precursors-1))
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
    err_len = 3 + (num_of_precursors-1)
    checker_patterns = create_checker_patterns(num_of_precursors) + additional_patterns
    print(checker_patterns)
    error_patterns = build_unique_error_pattern_set(err_len)

    R = sp.MutableDenseNDimArray(sp.symbols('0, '*(err_len-1) +' a:%d'%(seq_length+num_of_precursors-center)))
    N = sp.MutableDenseNDimArray(sp.symbols('n:%d'%(seq_length)))

    sub_vals = {}
    for ii in range(seq_length+num_of_precursors-center):
        sub_vals[R[ii+err_len-1]] = 0
    matrix = {}

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
        if val > best_value:
            best_value = val
            best_result= (current_result, energy_result)
            best_pattern = pat_ii



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

def launch_processes(input_struct_list, num_of_cores, num_of_runs, target=calculate_worst_energy):
    queue_data = []
    print(num_of_cores, num_of_runs)
    for ii in range(num_of_runs):
        end_index = (ii+1)*num_of_cores if (ii+1)*num_of_cores < len(input_struct_list) else len(input_struct_list)
        print(f'Starting run {ii+1} out of {num_of_runs} with {end_index - ii*num_of_cores} processes')
        processes = [Process(target=target, args=input_struct_list[ii]) for ii in range(ii*num_of_cores, end_index)]
        for proc in processes:
            proc.start()
        for proc in processes:
            proc.join(timeout=15)

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

def build_input_struct_for_two_precursor(matrix, queue, h_m1_values, h_p1_values, gamma, loss):

    input_struct_list = []
    for (ii, h_m1_value) in enumerate(h_m1_values):
        for (jj, h_p1_value) in enumerate(h_p1_values):
            if (1 > h_p1_value) and h_p1_value > h_m1_value and calculate_channel_loss([gamma*h_m1_value, h_m1_value, 1, h_p1_value], 0.6, 2) > loss:
                input_struct_list += [((ii, jj), queue, [gamma*h_m1_value, h_m1_value, 1, h_p1_value], matrix)]

    return input_struct_list

def build_input_struct_for_two_precursor_worst_error(queue, h_m1_values, h_p1_values, gamma, loss):

    input_struct_list = []
    for (ii, h_m1_value) in enumerate(h_m1_values):
        for (jj, h_p1_value) in enumerate(h_p1_values):
            if (1 > h_p1_value) and h_p1_value > h_m1_value and calculate_channel_loss([gamma*h_m1_value, h_m1_value, 1, h_p1_value], 0.6, 2) > loss:
                input_struct_list += [((ii, jj), queue, [gamma*h_m1_value, h_m1_value, 1, h_p1_value], 2)]

    return input_struct_list

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
    plt.xlabel('Postcursor Value')
    plt.ylabel('Precursor Value')
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
    worst_error_color = {'+-+' : (255,0,0), '+-0' : (0,255,0), '+0-' : (0,0,255)}
    #checker_pattern_color = {'+000' : (255,0,0), '+-00' : (0,255,0), '+-+0' : (0,0,255)}

    h_p1_values = np.linspace(0.01, 1, num_of_steps)
    h_m1_values = np.linspace(0.01, 1, num_of_steps)
    map_val = np.zeros((num_of_steps, num_of_steps))
    pat_val = np.zeros((num_of_steps, num_of_steps,3))

    input_struct_list = build_input_struct_for_one_precursor(calculate_checker_margins_for_errors(3,1,sigma=1, additional_patterns=additional_patterns), queue, h_p1_values, h_m1_values, loss)
    collected_results = launch_processes(input_struct_list, num_of_cores, round(len(input_struct_list)/num_of_cores + 0.5))

    checked_indexes = []
    for (index, worst_error, worst_checker, worst_snr) in collected_results:
        (aa, bb) = index
        checked_indexes += [index]
        print(f'Channel: {[h_m1_values[aa], 1, h_p1_values[bb]]}')
        print(f'E: {worst_error} <-> C: {worst_checker}, M: {worst_snr}\n')
        map_val[index] = worst_snr

    for (ii, h_m1_value) in enumerate(h_m1_values):
        for (jj, h_p1_value) in enumerate(h_p1_values):
            if (ii, jj) not in checked_indexes:
                map_val[ii, jj] = 1.25

    return map_val

def collect_and_analyze_double_precursor_results(queue, num_of_steps, num_of_cores, gamma , loss=-35, additional_patterns=[]):
    checker_pattern_color = {'+000' : (255,0,0), '+-00' : (0,255,0), '+-+0' : (0,0,255), '+-0+' : (0, 125,125), '+--+' : (125, 0, 125), '+0-0' : (125, 125, 0)}
    h_p1_values = np.linspace(0.01, 1, num_of_steps)
    h_m1_values = np.linspace(0.01, 1, num_of_steps)

    map_val = np.zeros((num_of_steps, num_of_steps))
    pat_val = np.zeros((num_of_steps, num_of_steps,3))

    input_struct_list = build_input_struct_for_two_precursor(calculate_checker_margins_for_errors(3,2,sigma=1, additional_patterns=additional_patterns), queue, h_p1_values, h_m1_values, gamma, loss)
    collected_results = launch_processes(input_struct_list, num_of_cores, round(len(input_struct_list)/num_of_cores + 0.5))

    checked_indexes = []

    for (index, worst_error, worst_checker, worst_snr) in collected_results:
        (aa, bb) = index
        checked_indexes += [index]
        print(f'Channel: {[gamma*h_m1_values[aa], h_m1_values[aa], 1, h_p1_values[bb]]}')
        print(f'E: {worst_error} <-> C: {worst_checker}, M: {worst_snr}\n')
        map_val[index] = worst_snr
        pat_val[index] = checker_pattern_color[worst_checker]


    for (ii, h_m1_value) in enumerate(h_m1_values):
        for (jj, h_p1_value) in enumerate(h_p1_values):
            if (ii, jj) not in checked_indexes:
                map_val[ii, jj] = 1.25

    return map_val

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
            new_str += '+'
        elif error_pattern[ii] == -2:
            new_str += '-'
        else:
            new_str += '0'
    return new_str


queue = Queue()
num_of_cores = 30
num_of_points = 50

#plot_channel_characteristics(np.linspace(0.01, 1, num_of_points), np.linspace(0.01, 1, num_of_points))
#exit()
#result1, worst_error = collect_and_analyze_single_precursor_worst_error(queue, num_of_points, num_of_cores, 0.3, loss = -35)
#result2 = collect_and_analyze_single_precursor_results(queue, num_of_points, num_of_cores, loss = -35)
#
#np.savetxt('worst_error_analysis_1.csv', result1, delimiter=',')
#np.savetxt('worst_error_1.csv', worst_error, delimiter=',')
#np.savetxt('worst_checker_analysis_1.csv', result2, delimiter=',')
#
#plot_snr_figure(20*np.log10(result1), '1_precursor', bounds=[-15, 0],aspect=1)
#plot_snr_figure(20*np.log10(result2/result1), 'checker_penalty_1', bounds=[-2.7, 0], aspect=5)
#
#exit()
#result1, worst_error = collect_and_analyze_double_precursor_worst_error(queue, num_of_points, num_of_cores, 0.3, loss = -35)
result1_15, worst_error = collect_and_analyze_double_precursor_worst_error(queue, num_of_points, num_of_cores, 0.15, loss = -50)
#plot_snr_figure(20*np.log10(result1), 'gamma_30_2_precursor', bounds=[-15, 0],aspect=1)

#result2 = collect_and_analyze_double_precursor_results(queue, num_of_points, num_of_cores, 0.3, loss = -35)
result2_15 = collect_and_analyze_double_precursor_results(queue, num_of_points, num_of_cores, 0.15, loss = -50)
#result3 = collect_and_analyze_double_precursor_results(queue, num_of_points, num_of_cores, 0.3, loss = -35, additional_patterns = [[2,-2,0,2]])
#result4 = collect_and_analyze_double_precursor_results(queue, num_of_points, num_of_cores, 0.3, loss = -35, additional_patterns = [[2,-2,-2,2]])

#np.savetxt('worst_error_analysis.csv', result1, delimiter=',')
#np.savetxt('worst_error.csv', worst_error, delimiter=',')
#np.savetxt('worst_checker_analysis.csv', result2, delimiter=',')
#np.savetxt('worst_checker_analysis_plus_pattern.csv', result3, delimiter=',')
#np.savetxt('worst_checker_analysis_plus_diff_pattern.csv', result4, delimiter=',')
np.savetxt('worst_error_analysis_15.csv', result1_15, delimiter=',')
np.savetxt('worst_checker_analysis_15.csv', result2_15, delimiter=',')

#result1 = np.loadtxt('worst_error_analysis.csv', delimiter=',')
result1_15 = np.loadtxt('worst_error_analysis_15.csv', delimiter=',')
#worst_error = np.loadtxt('worst_error.csv', delimiter=',')
#result2 = np.loadtxt('worst_checker_analysis.csv', delimiter=',')
result2_15 = np.loadtxt('worst_checker_analysis_15.csv', delimiter=',')
#result3 = np.loadtxt('worst_checker_analysis_plus_pattern.csv', delimiter=',')
#result4 = np.loadtxt('worst_checker_analysis_plus_diff_pattern.csv', delimiter=',')
#
#print(result2/result1)
#print(worst_error)
#plot_snr_figure(20*np.log10(result2/result1), 'checker_penalty', bounds=[-2.7, 0], aspect=5)
#plot_snr_figure(20*np.log10(result3/result1), 'checker_penalty_improved', bounds=[-2.7, 0], aspect=5)
#plot_snr_figure(20*np.log10(result4/result1), 'checker_penalty_improved_diff_pattern', bounds=[-2.7, 0], aspect=5)
plot_snr_figure(20*np.log10(result2_15/result1_15), 'checker_penalty_15', bounds=[-2.7, 0], aspect=5)
plot_snr_figure(20*np.log10(result1_15), 'gamma_15_2_precursor', bounds=[-15, 0],aspect=1)
exit()

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
