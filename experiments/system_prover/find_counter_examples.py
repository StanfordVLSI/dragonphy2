from cvc5.pythonic import *
import sympy as sp
import numpy as np
from copy import copy
import matplotlib.pyplot as plt
from multiprocessing import Pool, Queue, Process

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

def find_best_checker_pattern(seq_length, num_of_precursors,  checker_patterns, error_pattern,center=1, overload_channel=None, mode='cross'):
    err_len = len(error_pattern)
    R = sp.MutableDenseNDimArray(sp.symbols('0, '*(err_len-1) +' a:%d'%(seq_length+num_of_precursors-center)))

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
    smallest_error = None
    smallest_error_energy = 999999

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
                
                total_margin += sp.simplify(sum([error_row[jj][ii]  for jj in range(err_len)])**2)
                total_margin -= sp.simplify(sum([removed_row[jj][ii]  for jj in range(err_len)])**2)

            current_result = sp.simplify(total_margin).subs({'0' : 0})


        if current_result.subs(sub_vals) > best_value:
            best_value = current_result.subs(sub_vals)
            best_result= current_result
            best_pattern = pat_ii



    return best_pattern, best_value, best_result

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

def calculate_worst_energy(index, queue, channel, checker_patterns, unique_error_patterns, num_of_precursors):
    print(f'Calculating for {channel}')
    worst_error = 0
    worst_error_val = 9999
    for error_pattern in unique_error_patterns:
        pat, val, symbs = find_best_checker_pattern(3, num_of_precursors, checker_patterns, error_pattern, overload_channel=channel, mode='margin')
        if val < worst_error_val:
            worst_error_val = val
            worst_error = error_pattern
    queue.put((index, worst_error_val, worst_error))




def post_process_latex(latex_val):
    latex_val = latex_val.replace('a_{0}', 'h_{-2}')
    latex_val = latex_val.replace('a_{1}', 'h_{-1}')
    latex_val = latex_val.replace('a_{2}', 'h_{0}')
    latex_val = latex_val.replace('a_{3}', 'h_{+1}')

    return latex_val

#for error_pattern in unique_error_patterns:
#    pat, val, symbs = find_best_checker_pattern(3, 2, checker_patterns, error_pattern, overload_channel=[0.08,0.4,0.7,0.5], mode='margin')#[0.1,0.2,0.7,0.4])
#    error_pattern_string = f'$\\vec{{e}}^c_{{({",".join([str(x) for x in error_pattern])})}}$'
#    
#    print(f'{error_pattern_string} &  {checker_pat_strings[pat]} & ${symbs}$ &  $h_{{i}} > 0$ {val} \\\\\\hline')
#

num_of_precursors = 2

checker_patterns = np.array([[2,0,0] + [0]*(num_of_precursors-1), [+2,-2,0] + [0]*(num_of_precursors-1), [+2,-2,2] +[0]*(num_of_precursors-1)])
checker_pat_strings = [f'$\\vec{{e}}^c_{{({",".join([str(x) for x in pat])})}}$' for pat in checker_patterns]

unique_error_patterns = build_unique_error_pattern_set(2 + num_of_precursors)

h_m2_values = np.arange(0.0,1.0, 0.05)
h_m1_values = np.arange(0.0,1.0, 0.05)
h_p1_values = np.arange(0.0,1.0, 0.05)


queue = Queue()

input_struct_list = []

if num_of_precursors == 2:
    for (ii, h_m2_value) in enumerate(h_m2_values):
        for (jj, h_m1_value) in enumerate(h_m1_values):
            for (kk, h_p1_value) in enumerate(h_p1_values):
                if h_m2_value < 0.5*h_m1_value and h_m1_value <  0.8 and 0.8 > h_p1_value and h_p1_value > h_m1_value:
                    input_struct_list += [((ii, jj, kk), queue, [h_m2_value, h_m1_value, 1, h_p1_value], checker_patterns, unique_error_patterns, num_of_precursors)]
elif num_of_precursors == 1:
    for (ii, h_m1_value) in enumerate(h_m1_values):
        for (jj, h_p1_value) in enumerate(h_p1_values):
            if h_m1_value <  1 and 1 > h_p1_value and h_p1_value > h_m1_value:
                input_struct_list += [((ii, jj), queue, [h_m1_value, 1, h_p1_value], checker_patterns, unique_error_patterns, num_of_precursors)]

processes_pool = Pool(10)

num_of_runs = round(len(input_struct_list)/12 + 0.5)
print(num_of_runs)
if num_of_precursors == 2:
    map_val = np.zeros((len(h_m2_values), len(h_m1_values), len(h_p1_values)))
elif num_of_precursors == 1:
    map_val = np.zeros((len(h_m1_values), len(h_p1_values)))

for ii in range(num_of_runs):
    end_index = (ii+1)*12 if (ii+1)*12 < len(input_struct_list) else len(input_struct_list)
    print(f'Starting run {ii} out of {num_of_runs} with {end_index - ii*12} processes')
    processes = [Process(target=calculate_worst_energy, args=input_struct_list[ii]) for ii in range(ii*12, end_index)]
    for proc in processes:
        proc.start()
    for proc in processes:
        proc.join()

    while [process.is_alive() for process in processes].count(True) > 0:
        continue

    while not queue.empty():
        (index, worst_error_val, worst_error) = queue.get()
        map_val[index] = worst_error_val
        if num_of_precursors == 2:
            (aa, bb, cc) = index
            print(f'Index: {index}, Channel: {[h_m2_values[aa], h_m1_values[bb], 1, h_p1_values[cc]]}, Worst Error: {worst_error} Worst Error Val: {worst_error_val}')
        elif num_of_precursors == 1:
            (aa, bb) = index
            print(f'Index: {index}, Channel: {[h_m1_values[aa], 1, h_p1_values[bb]]}, Worst Error: {worst_error} Worst Error Val: {worst_error_val}')


if num_of_precursors == 1:
    fig, ax = plt.subplots()
    im1 = ax.imshow(map_val, cmap='hot', interpolation='nearest', extent=[0.01,0.9,0.01,0.9], origin='lower')
    fig.colorbar(im1)
    plt.xlabel('Precursor Value')
    plt.ylabel('Postcursor Value')
    plt.show()

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
