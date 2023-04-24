from copy import copy
import numpy as np

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
        if not detect_illegal_error(pattern):
            constrained_error_patterns += [pattern]
    return constrained_error_patterns

def stringify(error):
    return ''.join([str(e) for e in error])

print(build_error_pattern_set(3))

trellis_size = 4

legal_errors = delete_repeated_errors(build_error_pattern_set(trellis_size)) + [[0]*trellis_size]

print(len(legal_errors))

connection_dictionary = {}

for error in legal_errors:
    print(error, error[0:-2], error[-2:])
    if stringify(error[-2:]) not in connection_dictionary:
        connection_dictionary[stringify(error[-2:])] = [error[0:-2]]
    else:
        connection_dictionary[stringify(error[-2:])] += [error[0:-2]]

for key in connection_dictionary:
    print(key, len(connection_dictionary[key]))