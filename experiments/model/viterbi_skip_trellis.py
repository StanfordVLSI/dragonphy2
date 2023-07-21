from copy import copy
import numpy as np

def convert_dict_to_multi_array(d):
    return [d[ii] for ii in range(len(d))]

def create_array_string(arr):
    arr_str = ""

    if not isinstance(arr, list):
        arr = [arr]

    for ar in arr:
        if isinstance(ar, list):
            arr_str =  create_array_string(ar) + ', ' + arr_str
        else:
            arr_str = str(ar) + ', ' + arr_str

    arr_str = arr_str[:-2]
    return f'{{{arr_str}}}'

def create_parameter_array(name, arr, dim=[], type='integer'):
    arr_size = "".join([f'[{d-1}:0]' for d in dim])
        
    arr_str = create_array_string(arr)
    return f'parameter {type} {name} {arr_size}= \'{arr_str};'


def create_viterbi_package(trellis_size, storage_trellis_size):

    filename = f'viterbi_{storage_trellis_size}{trellis_size-storage_trellis_size}_pkg.sv'
    fo = open(filename, 'w')

    nmb_su, nmb_bu, mnmb_bu, bs_map, nmb_bc, b_map, sb_map, s_map, bt_map, initial_energy_map = create_viterbi_param_arrays(trellis_size, storage_trellis_size)

    print(f'package viterbi_{storage_trellis_size}{trellis_size-storage_trellis_size}_pkg;', file=fo)
    print(f'\tparameter number_of_state_units = {nmb_su};', file=fo)
    print(f'\tparameter number_of_branch_units = {nmb_bu};', file=fo)
    print(f'\tparameter max_number_of_branch_connections = {mnmb_bu};', file=fo)
    print('\t' + bs_map, file=fo)
    print('\t' + nmb_bc, file=fo)
    print('\t' + b_map, file=fo)
    print('\t' + sb_map, file=fo)
    print('\t' + s_map, file=fo)
    print('\t' + bt_map, file=fo)
    print('\t' + initial_energy_map, file=fo)
    print('endpackage', file=fo)


def build_error_pattern_set(num_of_errors, remove_zero_pattern=False):
    error_patterns = []
    for ii in range(3**num_of_errors):
        new_err = np.base_repr(ii, base=3)
        if len(new_err) < num_of_errors:
            new_err = '0'*(num_of_errors - len(new_err)) + new_err
        new_err = [(int(e)-1)*2 for e in new_err]
        error_patterns += [new_err]
    if remove_zero_pattern:
        error_patterns.pop(int((3**num_of_errors-1)/2))

    return error_patterns

def delete_repeated_errors(error_patterns):
    constrained_error_patterns = []

    def detect_illegal_error(error):
        error = np.array(error)
        first_err_loc = np.where(error != 0)[0][0]

        error = error[first_err_loc:]
        error = error * np.sign(error[0])

        odd_in_even = np.sum(np.mod(np.where(error > 0)[0], 2) == 1)
        even_in_odd = np.sum(np.mod(np.where(error < 0)[0], 2) == 0)
        return (odd_in_even + even_in_odd) > 0

    for pattern in error_patterns:
        if all([e == 0 for e in pattern]):
            constrained_error_patterns += [pattern]
            continue
        if not detect_illegal_error(pattern):
            constrained_error_patterns += [pattern]

    return constrained_error_patterns

def stringify(error):
    mapper = {-2: '-', 0: '0', 2: '+'}
    return ''.join([mapper[e] for e in error])

def create_viterbi_param_arrays(trellis_size, storage_trellis_size):
    legal_errors = delete_repeated_errors(build_error_pattern_set(trellis_size)) 
    legal_storage_states = delete_repeated_errors(build_error_pattern_set(storage_trellis_size))
    legal_branches       = delete_repeated_errors(build_error_pattern_set(trellis_size - storage_trellis_size))

    tton = {stringify(ss):ii for ii, ss in enumerate(legal_storage_states)}
    tton_b = {stringify(ss):ii for ii, ss in enumerate(legal_branches)}


    number_of_branches_units = 2**(trellis_size+1)-1
    number_of_state_units = 2**(storage_trellis_size+1)-1

    b_map = np.zeros((number_of_branches_units,), dtype=np.int32)
    bs_map = { tton[stringify(ss)]:[] for ss in legal_storage_states}
    sb_map = np.zeros((number_of_branches_units,), dtype=np.int32)

    s_map = [[err//2 for err in error][::-1] for error in legal_storage_states]
    bt_map = [[err//2 for err in error][::-1] for error in legal_branches]
    print(s_map)
    print(bt_map)

    for (ii, error) in enumerate(legal_errors):
        print(ii, stringify(error))
        b_map[ii] = tton_b[stringify(error[storage_trellis_size:])]
        bs_map[tton[stringify(error[-storage_trellis_size:])]] += [ii]
        sb_map[ii] = tton[stringify(error[:storage_trellis_size])]


    bs_map = convert_dict_to_multi_array(bs_map)
    new_bs_map = []
    for bs in bs_map:
        new_bs_map += [bs + [0]*(2**(trellis_size-storage_trellis_size+1) -1- len(bs))]
    
    nmb_su = len(new_bs_map)
    nmb_bu = len(b_map)
    mnmb_bu = max([len(bs) for bs in new_bs_map])
    initial_energy_map = np.ones((nmb_su,), dtype=np.int32) * (2**15 - 1)
    initial_energy_map[(nmb_su-1)//2] = 0
    initial_energy_map_str = create_parameter_array('initial_energy_map', list(initial_energy_map), dim=[nmb_su], type='logic [15:0]')


    bs_map_str = create_parameter_array('bs_map', new_bs_map, dim=[number_of_state_units, 2**(trellis_size-storage_trellis_size+1) - 1])
    number_of_branch_connections = [len(bs_map[ii]) for ii in range(number_of_state_units)]
    nmb_bc_str = create_parameter_array('number_of_branch_connections', number_of_branch_connections, dim=[number_of_state_units])
    b_map_str = create_parameter_array('b_map', list(b_map), dim=[number_of_branches_units])
    sb_map_str = create_parameter_array('sb_map', list(sb_map), dim=[number_of_branches_units])
    s_map_str = create_parameter_array('s_map', s_map, dim=[number_of_state_units, storage_trellis_size], type='logic signed [1:0]')
    bt_map_str = create_parameter_array('bt_map', bt_map, dim=[len(legal_branches), trellis_size-storage_trellis_size], type='logic signed [1:0]')
    return nmb_su, nmb_bu, mnmb_bu, bs_map_str, nmb_bc_str, b_map_str, sb_map_str, s_map_str, bt_map_str, initial_energy_map_str

def create_constrained_parent_table(trellis_size, storage_trellis_size):

    legal_errors = delete_repeated_errors(build_error_pattern_set(trellis_size)) 
    legal_storage_states = delete_repeated_errors(build_error_pattern_set(storage_trellis_size))

    tton = {stringify(ss):ii for ii, ss in enumerate(legal_storage_states)}

    parent_table = {tton[stringify(ss)]:[] for ss in legal_storage_states}

    for error in legal_errors:

        child = tton[stringify(error[:storage_trellis_size])]
        parent_table[child] += [(tton[stringify(error[-storage_trellis_size:])], error[storage_trellis_size:])]

    return parent_table

if __name__ == "__main__":
    create_viterbi_package(5,2)
