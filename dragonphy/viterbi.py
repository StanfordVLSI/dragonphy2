from dataclasses import dataclass
from copy import deepcopy
import numpy as np

@dataclass
class ViterbiState:
    err_history: np.ndarray
    flp_history: np.ndarray
    energies: np.ndarray
    pulse_resp: np.ndarray
    cur_num_bits: int
    tot_num_bits: int
    depth: int
    parent_table: dict

def create_init_viterbi_state(num_bits, depth, pulse_resp):

    assert(depth <= len(pulse_resp))

    parent_table = dict()
    for node in range(2**num_bits):
        parent_table[node] = [node >> 1, (node >> 1) + 2**(num_bits-1)]

    kwargs = dict(
            err_history = np.zeros((2**num_bits, depth)),
            flp_history = np.zeros((2**num_bits, depth)),
            energies    = np.zeros((2**num_bits, )),
            pulse_resp  = np.array(pulse_resp)[:depth],
            cur_num_bits = 0,
            tot_num_bits = num_bits,
            depth = depth,
            parent_table = parent_table
    )

    return ViterbiState(**kwargs)


def run_iteration_error_viterbi(viterbi_state, bit, trace_val):
    next_viterbi_state = deepcopy(viterbi_state)


    if(viterbi_state.cur_num_bits < viterbi_state.tot_num_bits):
        viterbi_state.cur_num_bits += 1

    for node in range(2**viterbi_state.cur_num_bits):
        branch_energy_vect     = np.zeros((2, ))

        new_err_histories      = np.zeros((2, viterbi_state.depth))
        new_flp_histories      = np.zeros((2, viterbi_state.depth))

        for (ii, parent) in enumerate(viterbi_state.parent_table[node]):
            energy                  = viterbi_state.energies[parent]

            new_flp_histories[ii, 1:] = viterbi_state.flp_history[node, 1:]
            new_flp_histories[ii, 0]  = ii

            new_err_history[ii, 1:] = viterbi_state.err_history[node, 1:]
            new_err_history[ii, 0]  = ii * (2 * bit - 1) * -2

            branch_energy_vect[ii]  = np.square(trace_val + np.dot(new_err_history, viterbi_state.pulse_resp))

        best_branch_idx = np.argmin(branch_energy_vect)
        
        next_viterbi_state.err_history[node, :] = new_err_history[ii, :]
        next_viterbi_state.flp_history[node, :] = new_flp_history[ii, :]

        next_viterbi_state.energies[node] += branch_energy_vect[best_branch_idx]

    return next_viterbi_state

def run_error_viterbi(bits, trace, viterbi_state, num_iterations = 4):
    for ii in range(num_iterations):
        viterbi_state = run_iteration_error_viterbi(viterbi_state, bits[ii], trace[ii])
        print(viterbi_state)
    return viterbi_state