from dataclasses import dataclass
from copy import deepcopy
import numpy as np

@dataclass
class ViterbiState:
    err_history: np.ndarray
    flp_history: np.ndarray
    trc_history: np.ndarray
    energies: np.ndarray
    pulse_resp: np.ndarray
    cur_num_bits: int
    tot_num_bits: int
    depth: int
    parent_table: dict
    child_table: dict 

    def __str__(self):
        best_idx = np.argmin(self.energies)
        return f'trc_history: {self.trc_history[best_idx,::-1]}\nerr_history: {self.err_history[best_idx,::-1]}\nflp_history: {self.flp_history[best_idx,::-1]}\nenergies: {self.energies}\n cur_num_bits: {self.cur_num_bits}'

    def get_best_path(self):
        best_idx = np.argmin(self.energies)
        return self.flp_history[best_idx,::-1]

def create_init_viterbi_state(num_bits, depth, pulse_resp):

    assert(depth <= len(pulse_resp))

    parent_table = dict()
    for node in range(2**num_bits):
        parent_table[node] = [node >> 1, (node >> 1) + 2**(num_bits-1)]

    child_table = dict()
    for node in range(2**num_bits):
        child_table[node] = [(node << 1) % (2**num_bits), ((node << 1) + 1) % (2**num_bits)]

    kwargs = dict(
            err_history = np.zeros((2**num_bits, depth)),
            flp_history = np.zeros((2**num_bits, depth)),
            trc_history = np.zeros((2**num_bits, depth)),
            energies    = np.zeros((2**num_bits, )),
            pulse_resp  = np.array(pulse_resp)[:depth],
            cur_num_bits = 0,
            tot_num_bits = num_bits,
            depth = depth,
            parent_table = parent_table,
            child_table = child_table
    )

    return ViterbiState(**kwargs)


def run_iteration_error_viterbi(viterbi_state, bit, trace_val):

    next_viterbi_state = deepcopy(viterbi_state)
    if(viterbi_state.cur_num_bits < viterbi_state.tot_num_bits):
        viterbi_state.cur_num_bits += 1
        next_viterbi_state.cur_num_bits += 1
        for node in range(2**(viterbi_state.cur_num_bits-1)):
            for(ii, child) in enumerate(viterbi_state.child_table[node]):
                energy                  = viterbi_state.energies[child]

                next_viterbi_state.flp_history[child, 1:] = viterbi_state.flp_history[node, :-1]
                next_viterbi_state.flp_history[child, 0]  = ii

                next_viterbi_state.err_history[child, 1:] = viterbi_state.err_history[node, :-1]
                next_viterbi_state.err_history[child, 0]  = ii * (2 * bit - 1) * -2

                next_viterbi_state.trc_history[child, 1:] = viterbi_state.trc_history[node, :-1]
                next_viterbi_state.trc_history[child, 0]  = trace_val + np.dot(next_viterbi_state.err_history[child,:], viterbi_state.pulse_resp)
                next_viterbi_state.energies[child] = energy + np.square(trace_val + np.dot(next_viterbi_state.err_history[child,:], viterbi_state.pulse_resp))
    else:
        for node in range(2**viterbi_state.cur_num_bits):
            branch_energy_vect     = np.zeros((2, ))
            new_trace_histories    = np.zeros((2, viterbi_state.depth))
            new_err_histories      = np.zeros((2, viterbi_state.depth))
            new_flp_histories      = np.zeros((2, viterbi_state.depth))

            for (ii, parent) in enumerate(viterbi_state.parent_table[node]):
                energy                  = viterbi_state.energies[parent]

                new_flp_histories[ii, 1:] = viterbi_state.flp_history[parent, :-1]
                new_flp_histories[ii, 0]  = node % 2

                new_err_histories[ii, 1:] = viterbi_state.err_history[parent, :-1]
                new_err_histories[ii, 0]  = (node % 2) * (2 * bit - 1) * -2

                new_trace_histories[ii, 1:] = viterbi_state.trc_history[parent, :-1]
                new_trace_histories[ii, 0]  = trace_val + np.dot(new_err_histories[ii,:], viterbi_state.pulse_resp)


                branch_energy_vect[ii]  =  viterbi_state.energies[parent] + np.square(trace_val + np.dot(new_err_histories[ii,:], viterbi_state.pulse_resp))

            best_branch_idx = np.argmin(branch_energy_vect)

            next_viterbi_state.err_history[node, :] = new_err_histories[best_branch_idx, :]
            next_viterbi_state.flp_history[node, :] = new_flp_histories[best_branch_idx, :]
            next_viterbi_state.trc_history[node, :] = new_trace_histories[best_branch_idx, :]

            next_viterbi_state.energies[node] = branch_energy_vect[best_branch_idx]
    return next_viterbi_state

def run_error_viterbi(bits, trace, prbs_flags, viterbi_state, num_iterations = 4):
    for ii in range(num_iterations):
        viterbi_state = run_iteration_error_viterbi(viterbi_state, bits[ii], trace[ii])

    return viterbi_state