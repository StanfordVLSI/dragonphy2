from dataclasses import dataclass
from copy import deepcopy
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

    branch_length = trellis_size - storage_trellis_size

    legal_errors = delete_repeated_errors(build_error_pattern_set(trellis_size)) 
    legal_storage_states = delete_repeated_errors(build_error_pattern_set(storage_trellis_size)) 

    tton = {stringify(ss):ii for ii, ss in enumerate(legal_storage_states)}

    parent_table = {tton[stringify(ss)]:[] for ss in legal_storage_states}

    for error in legal_errors:
        #print(f'error: {stringify(error)}')
        child = tton[stringify(error[branch_length:])]
        parent_table[child] += [(tton[stringify(error[:storage_trellis_size:])], error[storage_trellis_size:])]
        #print(f'child: {stringify(error[branch_length:])}, parent: {stringify(error[:storage_trellis_size])}, branch: {error[storage_trellis_size:]}')
    return parent_table, legal_storage_states

@dataclass
class SkipViterbiState:
    err_history: np.ndarray
    trc_history: np.ndarray
    early_err_history: np.ndarray
    energies: np.ndarray
    pulse_resp: np.ndarray
    trellis_size: int
    storage_trellis_size: int
    depth: int
    parent_table: dict

    def get_best_path(self):
        best_idx = np.argmin(self.energies)
        return self.err_history[best_idx,::-1], self.trc_history[best_idx,::-1]

def create_init_skip_viterbi_state(depth, pulse_resp, trellis_size, storage_trellis_size):
    assert(depth <= len(pulse_resp))

    parent_table, legal_storage_states = create_constrained_parent_table(trellis_size, storage_trellis_size)
    energies = np.ones((len(parent_table), ))*9999
    energies[int((len(parent_table)-1)/2)] = 0

    err_history = np.zeros((len(parent_table), depth))
    for node in range(len(parent_table)):
        err_history[node, :len(legal_storage_states[node])] = legal_storage_states[node]
    #print(err_history)
    kwargs = dict(
            err_history = err_history,
            trc_history = np.zeros((len(parent_table), depth)),
            early_err_history = np.zeros((depth,)),
            energies    = energies,
            pulse_resp  = np.array(pulse_resp)[:depth],
            trellis_size = trellis_size,
            storage_trellis_size = storage_trellis_size,
            depth = depth,
            parent_table = parent_table
    )
    return SkipViterbiState(**kwargs)

def run_iteration_skip_error_viterbi(viterbi_state, trace_vals, ehs):

    next_viterbi_state = deepcopy(viterbi_state)
    for node in range(len(viterbi_state.parent_table)):
        num_of_branches = len(viterbi_state.parent_table[node])
        branch_energy_vect     = np.zeros((num_of_branches, ))
        new_err_histories      = np.zeros((num_of_branches, viterbi_state.depth))
        for (ii, (parent, branch)) in enumerate(viterbi_state.parent_table[node]):
            #print(branch, viterbi_state.err_history[parent,:])
            #print(f'node: {node}, parent: {parent}, branch: {branch}')
            new_err_histories[ii, len(branch):] = viterbi_state.err_history[parent, :-len(branch)]
            #print(stringify(new_err_histories[ii,:]))

            #print(stringify(viterbi_state.err_history[parent,:]))
            new_err_histories[ii, :len(branch)] = branch[::-1]
            new_err_histories[ii, len(branch) + ehs + 2:] =  viterbi_state.early_err_history[:viterbi_state.depth - (len(branch) + ehs + 2)]

            #print(parent)
           # print(stringify(new_err_histories[ii,:len(branch) + 6]) ,stringify(new_err_histories[ii,len(branch) + 6:]))
           # print(stringify(new_err_histories[ii,:len(branch) + 6]) ,stringify(viterbi_state.early_err_history[:viterbi_state.depth - (len(branch) + 6)]))
            #print(stringify(new_err_histories[ii,:]))
            #print(new_err_histories[ii,:])
            #input()
            branch_energy_vect[ii] = viterbi_state.energies[parent]
            for jj in range(len(trace_vals)):
                branch_energy_vect[ii] += np.square(trace_vals[jj] + np.dot(new_err_histories[ii,len(trace_vals)-1-jj:], viterbi_state.pulse_resp[:viterbi_state.depth-(len(trace_vals)-1-jj)]))
                #branch_energy_vect[ii] += np.square(trace_vals[jj] + np.dot(tmp[len(trace_vals)-1-jj:], viterbi_state.pulse_resp[:viterbi_state.depth-(len(trace_vals)-1-jj)]))
            #print(trace_vals[::-1])
            #print(np.convolve(new_err_histories[ii,:], viterbi_state.pulse_resp[:len(new_err_histories[ii,:])])[1:len(branch)+1])
            #input()
        #print(branch_energy_vect)
        best_branch_idx = np.argmin(branch_energy_vect)

        next_viterbi_state.err_history[node, :] = new_err_histories[best_branch_idx, :]
        next_viterbi_state.energies[node] = branch_energy_vect[best_branch_idx]
    next_viterbi_state.early_err_history[len(trace_vals):] = viterbi_state.early_err_history[:-len(trace_vals)]
    next_viterbi_state.early_err_history[:len(trace_vals)] = next_viterbi_state.err_history[np.argmin(next_viterbi_state.energies), ehs + 2 :ehs + 2 +len(trace_vals)]
    
    return next_viterbi_state


@dataclass
class ViterbiState:
    err_history: np.ndarray
    trc_history: np.ndarray
    early_err_history: np.ndarray
    energies: np.ndarray
    pulse_resp: np.ndarray
    cur_num_bits: int
    tot_num_bits: int
    depth: int
    parent_table: dict

    def get_best_path(self):
        best_idx = np.argmin(self.energies)
        return self.err_history[best_idx,::-1], self.trc_history[best_idx,::-1]

def create_init_viterbi_state(depth, pulse_resp, num_bits):
    assert(depth <= len(pulse_resp))

    #parent_table = dict()
    #for node in range(3**num_bits):
    #    parent_table[node] = [(int(node/3) + 3**(num_bits-1) * ii) % 3**num_bits for ii in range(3)]

    parent_table, legal_storage_states = create_constrained_parent_table(num_bits+1, num_bits)
    energies = np.ones((len(parent_table), ))*9999
    energies[int((len(parent_table)-1)/2)] = 0

    err_history = np.zeros((len(parent_table), depth))
    for node in range(len(parent_table)):
        err_history[node, :len(legal_storage_states[node])] = legal_storage_states[node]

    #energies = np.ones((3**num_bits, ))*9999
    #energies[int((3**num_bits-1)/2)] = 0

    kwargs = dict(
            err_history = err_history,#np.zeros((3**num_bits, depth)),
            trc_history = np.zeros((len(parent_table), depth)), #np.zeros((3**num_bits, depth)),
            early_err_history = [],
            energies    = energies,
            pulse_resp  = np.array(pulse_resp)[:depth],
            cur_num_bits = num_bits,
            tot_num_bits = num_bits,
            depth = depth,
            parent_table = parent_table
    )
    return ViterbiState(**kwargs)

def run_iteration_error_viterbi(viterbi_state, trace_val):

    next_viterbi_state = deepcopy(viterbi_state)

    for node in range(len(viterbi_state.parent_table)):#range(3**viterbi_state.cur_num_bits):
        branch_energy_vect     = np.zeros((len(viterbi_state.parent_table[node]), ))
        new_trace_histories    = np.zeros((len(viterbi_state.parent_table[node]), viterbi_state.depth))
        new_err_histories      = np.zeros((len(viterbi_state.parent_table[node]), viterbi_state.depth))
        for (ii, (parent, branch)) in enumerate(viterbi_state.parent_table[node]):
            new_err_histories[ii, 1:] = viterbi_state.err_history[parent, :-1]
            new_err_histories[ii, 0]  = branch[0]

            new_trace_histories[ii, 1:] = viterbi_state.trc_history[parent, :-1]
            new_trace_histories[ii, 0]  = trace_val + np.dot(new_err_histories[ii,:], viterbi_state.pulse_resp)

            branch_energy_vect[ii]  =  viterbi_state.energies[parent] + np.square(trace_val + np.dot(new_err_histories[ii,:], viterbi_state.pulse_resp))

        best_branch_idx = np.argmin(branch_energy_vect)

        next_viterbi_state.err_history[node, :] = new_err_histories[best_branch_idx, :]
        next_viterbi_state.trc_history[node, :] = new_trace_histories[best_branch_idx, :]

        next_viterbi_state.energies[node] = branch_energy_vect[best_branch_idx]

    next_viterbi_state.early_err_history +=  [next_viterbi_state.err_history[np.argmin(next_viterbi_state.energies), 5]]

    return next_viterbi_state


def run_error_viterbi(viterbi_state, bits, trace, num_iterations = 4):
    for ii in range(num_iterations):
        viterbi_state = run_iteration_error_viterbi(viterbi_state, bits[ii], trace[ii])

    return viterbi_state

if __name__ == '__main__':
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

    def run_error_viterbi(viterbi_state, bits, trace, num_iterations = 4):
        for ii in range(num_iterations):
            viterbi_state = run_iteration_error_viterbi(viterbi_state, bits[ii], trace[ii])

        return viterbi_state