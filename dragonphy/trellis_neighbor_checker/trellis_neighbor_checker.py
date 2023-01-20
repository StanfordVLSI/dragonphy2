def EnergyMetric(seq_length, injection_error_seq, est_error):
    energy = 0
    for ii in range(seq_length):
        energy += (-injection_error_seq[ii] + est_error[ii])**2
    return energy 

def Argmin(num_of_energies, energies):
    lowest_energy_idx = 0
    lowest_energy = energies[0]
    for ii in range(1,num_of_energies):
        if energies[ii] < lowest_energy:
            lowest_energy_idx = ii
            lowest_energy = energies[ii]
    return (lowest_energy_idx, lowest_energy)

def ErrorInjectionEngine(seq_length, trellis_pattern_depth, channel_shift, nrz_mode, channel, trellis_patterns, cp=2):
    injection_error_seqs = []
    for trellis_pattern in trellis_patterns:
        injection_error_seq_pos = [0]*seq_length
        injection_error_seq_neg = [0]*seq_length

        for ii in range(seq_length):
            for jj in range(trellis_pattern_depth):
                if (cp - jj + ii) < 0:
                    continue
                if nrz_mode == 0:
                    injection_error_seq_pos[ii] += trellis_pattern[jj] * 2 * channel[cp - jj + ii]
                    injection_error_seq_neg[ii] -= trellis_pattern[jj] * 2 * channel[cp - jj + ii]
                else:
                    injection_error_seq_pos[ii] += 3*trellis_pattern[jj] * 2 * channel[cp - jj + ii]
                    injection_error_seq_neg[ii] -= 3*trellis_pattern[jj] * 2 * channel[cp - jj + ii]
        injection_error_seq_pos = [x >> channel_shift for x in injection_error_seq_pos]
        injection_error_seq_neg = [x >> channel_shift for x in injection_error_seq_neg]
        injection_error_seqs += [injection_error_seq_pos, injection_error_seq_neg]
    return injection_error_seqs

def TrellisNeighborCheckerSlice(seq_length, num_of_trellis_patterns, injection_error_seqs, est_error, null_energy):
    energies = [0]*(2*num_of_trellis_patterns+1)
    energies[0] = null_energy
    for ii in range(1,2*num_of_trellis_patterns+1):
        energies[ii] = EnergyMetric(seq_length, injection_error_seqs[ii-1], est_error)
    
    (lowest_energy_idx, lowest_energy) = Argmin(2*num_of_trellis_patterns+1, energies)

    return lowest_energy_idx, lowest_energy

def TrellisNeighborChecker(num_of_channels, seq_length, num_of_trellis_patterns, channel, trellis_patterns, nrz_mode, est_errors, cp=2):
    injection_error_seqs = ErrorInjectionEngine(seq_length, 4, 3, 0, channel, trellis_patterns, cp)

    null_energies = [0]*num_of_channels
    chunked_est_errors = [[0]*seq_length]*num_of_channels
    flags = [0]*num_of_channels

    for ii in range(num_of_channels):
        for jj in range(seq_length):
            chunked_est_errors[ii][jj] = est_errors[num_of_channels-seq_length+ii+jj]
            null_energies[ii] += (chunked_est_errors[ii][jj])**2 
        null_energies[ii] = null_energies[ii] 
        (flags[ii], lowest_energy) = TrellisNeighborCheckerSlice(seq_length, 4, injection_error_seqs, chunked_est_errors[ii], null_energies[ii])
    
    return flags
