from copy import copy
import numpy as np

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

def create_constrained_parent_table(trellis_size, storage_trellis_size):
    trellis_size = 5
    storage_trellis_size = 2

    legal_errors = delete_repeated_errors(build_error_pattern_set(trellis_size)) 
    legal_storage_states = delete_repeated_errors(build_error_pattern_set(storage_trellis_size))
    legal_branches       = delete_repeated_errors(build_error_pattern_set(trellis_size - storage_trellis_size))

    tton = {stringify(ss):ii for ii, ss in enumerate(legal_storage_states)}
    tton_b = {stringify(ss):ii for ii, ss in enumerate(legal_branches)}

    parent_table = {tton[stringify(ss)]:[] for ss in legal_storage_states}
    unique_states = set()
    unique_branches = set()

    number_of_branches_units = 2**(trellis_size+1)-1
    number_of_state_units = 2**(storage_trellis_size+1)-1

    b_map = np.zeros((number_of_branches_units,))
    bs_map = { tton[stringify(ss)]:[] for ss in legal_storage_states}
    sb_map = np.zeros((number_of_branches_units,))
    print(tton_b)
    for (ii, error) in enumerate(legal_errors):
        print(ii, stringify(error[:storage_trellis_size]),  stringify(error[storage_trellis_size:]), stringify(error[-storage_trellis_size:]))
        b_map[ii] = tton_b[stringify(error[storage_trellis_size:])]
        bs_map[tton[stringify(error[-storage_trellis_size:])]] += [ii]
        sb_map[ii] = tton[stringify(error[:storage_trellis_size])]
        unique_branches |= {tton_b[stringify(error[storage_trellis_size:])]}
        unique_states |= {tton[stringify(error[:storage_trellis_size])]}
        child = tton[stringify(error[:storage_trellis_size])]
        parent_table[child] += [(tton[stringify(error[-storage_trellis_size:])], error[storage_trellis_size:])]
    print(b_map)
    print(tton)
    print(bs_map)
    print(sb_map)
    return parent_table

if __name__ == "__main__":
    table = create_constrained_parent_table(4, 2)

    for key in table.keys():
        print(key, [it[0] for it in table[key]])