from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
from matplotlib import ticker, cm
import numpy as np
from copy import copy, deepcopy
from scipy import linalg, stats
from dragonphy import *
from rich.progress import Progress
from joblib import Parallel, delayed

def stringify(arr, func=str):
    return "".join([func(val) for val in arr])

def error_to_string(val):

    if val == 0:
        return "0"
    elif val < 0:
        return f'$-_{{{abs(val)}}}$'
    elif val > 0:
        return f'$+_{{{abs(val)}}}$'


def particle_minimizer(target_error, target_bits, noise=None, num_of_iterations=10):
    #inject_list = [[0], [2], [-2], [2,-2], [-2,2], [2,0,-2],[-2,0,2]]#, [1,0,1],[-1,0,-1]]
    flip_inject_list = [[0], [1], [1,1],[1,0,0,1]]
    #conv_inject_list = [np.convolve(inject, pulse) for inject in inject_list]
    #conv_target_error = np.convolve(target_error,pulse)

    target_error = deepcopy(target_error)
    target_bits  = deepcopy(target_bits)

    orig_error = deepcopy(target_error)
    prev_best_inject = -1
    prev_best_idx = -1

    for ii in range(num_of_iterations):
        trial_energies = []
        trial_injects  = []

        for jj in range(len(target_error)-3):
            min_energy = np.sum(np.square(np.convolve(target_error, pulse)+noise))
            best_inject = [0]

            inject_list = []
            for flip_patt in flip_inject_list:
                inj_pat = np.zeros((len(target_error),), dtype='int64')
                for kk in range(len(flip_patt)):
                    inj_pat[jj+kk] = int(2*target_bits[jj+kk]*flip_patt[kk])
                inject_list += [list(inj_pat)]


            for inject in inject_list:
                test_bits  = np.array(target_bits)
                test_error = np.array(target_error)

                #test_bits[jj:jj+len(inject)]  -= np.array(inject)
                #test_error[jj:jj+len(inject)] += np.array(inject)

                test_bits  -= np.array(inject)
                test_error += np.array(inject)

                #overflow_penalty = np.sum(np.abs(test_bits)) - len(test_bits)

                test_energy = np.sum(np.square(np.convolve(test_error, pulse)+noise)) #+ 0.015*overflow_penalty


                if test_energy < min_energy:
                    min_energy = test_energy
                    best_inject = inject

            trial_energies += [min_energy]
            trial_injects  += [best_inject]

        best_idx = np.argmin(trial_energies)
        best_inject = trial_injects[best_idx]

        #target_bits[best_idx:best_idx+len(trial_injects[best_idx])]  -= np.array(trial_injects[best_idx])
        #target_error[best_idx:best_idx+len(trial_injects[best_idx])] += np.array(trial_injects[best_idx])
        target_bits  -= np.array(trial_injects[best_idx])
        target_error += np.array(trial_injects[best_idx])

        if (best_idx == prev_best_idx) and (len(best_inject) == len(prev_best_inject)) and all([val1==val2 for (val1,val2) in zip(best_inject, prev_best_inject)]):
            if np.sum(np.abs(target_error)) > 0:
                print(target_error)
                print(trial_energies[best_idx])
                print(np.sum(np.square(noise)))

                #plt.plot(noise)
                #plt.plot(np.convolve(target_error, pulse) + noise)
                #plt.plot(np.convolve(orig_error, pulse) + noise)
                #plt.show()
            break

        prev_best_inject = best_inject
        prev_best_idx = best_idx


    return target_error, target_bits

def jobify_particle_minimizer(target_error, num_of_iterations):
    def jobified_particle_minimizer(target_bits, noise):
        errors, bits = particle_minimizer(target_error, target_bits, noise=noise, num_of_iterations=num_of_iterations)
        return np.sum(np.abs(errors))/2.0
    return jobified_particle_minimizer


THIS_DIR = Path(__file__).resolve().parent
sparam_file_list = ["Case4_FM_13SI_20_T_D13_L6.s4p",
                    "peters_01_0605_B1_thru.s4p",  
                    "peters_01_0605_B12_thru.s4p",  
                    "peters_01_0605_T20_thru.s4p",
                    "TEC_Whisper42p8in_Meg6_THRU_C8C9.s4p",
                    "TEC_Whisper42p8in_Nelco6_THRU_C8C9.s4p"]


f_sig = 29e9
channel_length = 30
ffe_length = 100
num_bits = 8.4
num_of_precursors = 4


list_of_target_curs_pos = [4,10,8,8,12,3]
list_of_mm_lock_position = [15e-12,15e-12,12e-12,12e-12,3e-12, 15e-12]

channel_list = [0,1,2]

error_conv_patterns = [[1],[1,-1],[1,0,-1],[1,-2,2,-1],[1,-1,1],[1,1,-1],[1,-1,-1],[1,1],[1,0,0,0,0,-1],[1,0,0,-1],[1,1,-1,-1],[1,0,0,0,-1],[1,0,0,0,-1,-1],[1,-1,1,-1]]
#error_conv_patterns = [[1],[1,-1],[1,0,-1],[1,-1,1],[1,0,0,-1],[1,-1,1,-1]]

position = np.linspace(0, 1, len(error_conv_patterns))

labels = [stringify(error_conv_pattern, error_to_string) for error_conv_pattern in error_conv_patterns]

error_pattern_energies = np.zeros((len(error_conv_patterns), len(sparam_file_list)))
abs_error_pattern_energies = np.zeros((len(error_conv_patterns), len(sparam_file_list)))

for ii in channel_list:
    file = sparam_file_list[ii]
    target_curs_pos = list_of_target_curs_pos[ii]
    mm_lock_pos = list_of_mm_lock_position[ii]

    file_name = str(get_file(f'data/channel_sparam/{file}'))
    t, imp = s4p_to_impulse(str(file_name), 0.1e-12, 20e-9, zs=50, zl=50)

    cursor_position = np.argmax(imp)
    shift_delay = -t[cursor_position] + (num_of_precursors)*1.0/(f_sig)
    #Load the S4P into a channel model
    chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=600000, s4p=file_name, zs=50, zl=50)
    time, pulse = chan.get_pulse_resp(f_sig=16e9, resp_depth=channel_length, t_delay=shift_delay+mm_lock_pos)

    print(pulse[num_of_precursors])
    print(pulse[num_of_precursors-1]-pulse[num_of_precursors-2],pulse[num_of_precursors-1]+pulse[num_of_precursors-2])
    print(np.sqrt(np.sum(4*np.square(np.pad(pulse, (0,1), mode='constant', constant_values=(0,0))-np.pad(pulse, (1,0), mode='constant', constant_values=(0,0))))))
    print(np.sqrt(np.sum(4*np.square(np.pad(pulse, (0,3), mode='constant', constant_values=(0,0))-np.pad(pulse, (3,0), mode='constant', constant_values=(0,0))))))

    print(np.sqrt(np.sum(4*np.square(pulse))))

    print(np.sqrt(np.sum(np.square(pulse)))/pulse[num_of_precursors])
    print()

    for jj, error_conv_pattern in enumerate(error_conv_patterns):
        test_pattern = 2.0*np.array(error_conv_pattern)
        overflow_penalty = np.sum([(abs(val)-2)**2 for val in test_pattern if abs(val) > 2])
        error_pattern_energies[jj,ii] = np.sum(np.square(np.convolve(pulse, test_pattern))) + 0.015*overflow_penalty
        abs_error_pattern_energies[jj,ii] = np.sum(np.abs(np.convolve(pulse, test_pattern))) + 0.04*overflow_penalty


for ii in channel_list:
    curr_err_enrg = error_pattern_energies[:,ii]
    curr_abs_err_enrg = abs_error_pattern_energies[:,ii]

    sort_idx = np.argsort(curr_err_enrg)

    plt.subplot(len(channel_list),1, ii+1)
    plt.stem(position, curr_err_enrg[sort_idx], label=sparam_file_list[ii])
    plt.title(f'Energy Of Errors - Channel {ii+1}')
    plt.xlabel('Error Patterns')
    plt.ylabel('Energy (A.U)')
    #plt.plot(position, curr_abs_err_enrg[sort_idx], label=sparam_file_list[ii])

    sorted_labels = [labels[idx] for idx in list(sort_idx)]
    plt.legend()
    plt.xticks(position, sorted_labels)
plt.show()

num_samples = 200
noise_arr = np.array([1,-1,0.5])
error_arr  = np.array([-2,2,0])

arr_1 = np.array([-1, 1, 0.8])
arr_2 = np.array([1,-1, 0.8])
mod_arr = np.array([1/num_samples, -1/num_samples, 1/num_samples*0.5])
energy_results = np.zeros((num_samples,2))

for ii in range(num_samples):
    seq_1 = arr_1 + mod_arr*ii# noise_arr + error_arr + mod_arr*ii
    seq_2 = arr_2 + mod_arr*ii#noise_arr + mod_arr*ii

    energy_results[ii,0] = np.sum(np.abs(np.convolve(pulse, seq_1)))
    energy_results[ii,1] = np.sum(np.abs(np.convolve(pulse, seq_2)))

plt.plot(energy_results[:,0])
plt.plot(energy_results[:,1])
plt.show()


bits = np.random.randint(2, size=(15,))*2 - 1
error = [0,0,-2,0,  0,  0,  0, 0,0,0,0,0,0,0,0]
noise = np.random.randn(15)*10e-3

noise[2] = pulse[num_of_precursors]*1.01
bits[2] = -1

convolved_bits = np.convolve(bits, pulse)[num_of_precursors:num_of_precursors+15] + noise
convolved_est_bits = np.convolve(bits + error, pulse)[num_of_precursors:num_of_precursors+15]

plt.plot(convolved_bits, label='Actual Samples')
plt.plot(convolved_est_bits, label='Estimated Samples')
plt.title('Samples (Actual and Estimated)')
plt.xlabel('Sample Bins (A.U)')
plt.ylabel('Sample Voltage (V)')
plt.legend()
plt.show()

plt.plot(convolved_bits - convolved_est_bits)
plt.title('Error between Actual and Estimated')
plt.xlabel('Sample Bins (A.U)')
plt.ylabel('Error Voltage (V)')
plt.show()
delta = 0.1
target_error = list(np.array([0,0,0,0  -2,  0, 0, 2,0,0, 0 ,0,0,0,0]) * (1 -delta))

num_of_starting_errors = np.sum(np.abs(target_error))/2.0

target_bits = bits = np.random.randint(2, size=(len(target_error),))*2 - 1

for jj in range(len(target_error)):
    if not target_error[jj] == 0:
        target_bits[jj] = -1*(target_error[jj] > 0) + 1*(target_error[jj] < 0)
noise = np.random.randn((channel_length + len(target_error)-1)) * 19e-3



target_error_evolution = np.zeros((len(target_error), 11))
target_error_evolution[:,0] = np.array(target_error)

new_target_error = copy(target_error)
for ii in range(1,4):
    new_target_error, target_bits = particle_minimizer(new_target_error, target_bits, noise=noise, num_of_iterations=1)
    target_error_evolution[:,ii] = new_target_error

plt.imshow(target_error_evolution)
plt.show()
exit()
N_trials = 50000
error_dist = np.zeros((len(target_error),))
num_of_remaining_errors = np.zeros((N_trials,))
running_total = 0

noise = np.random.randn(channel_length + len(target_error)-1, N_trials) * 27.5e-3
target_bits = np.random.randint(2, size=(len(target_error),N_trials))*2 -1
for ii in range(N_trials):
    target_bits[:,ii] = np.array([target_bits[jj,ii] if target_error[jj] == 0  else -1*target_error[jj]/2.0 for jj in range(len(target_error))])

jobified_particle_minimizer = jobify_particle_minimizer(target_error, 4)

results = Parallel(n_jobs=11)(delayed(jobified_particle_minimizer)(target_bits[:,ii], noise[:,ii]) for ii in range(N_trials))
plt.hist(results)
plt.title(f'Error Outcome Distribution, Error Rate: {np.sum(results)/(num_of_starting_errors*N_trials)}')
plt.show()
exit()

for ii in range(N_trials):
    error, bits = particle_minimizer(target_error, target_bits[:,ii], noise=noise[:,ii], num_of_iterations=10)
    error_dist += np.array(error)/N_trials

    error_increase = np.sum(np.abs(error))/2.0

    if error_increase > 0:
        num_of_remaining_errors[ii] = error_increase
        running_total += error_increase
        print(running_total/(ii + 0.001))

plt.plot(error_dist)
plt.show()

plt.hist(num_of_remaining_errors)
plt.title(f'Error Outcome Distribution, Error Rate: {np.sum(num_of_remaining_errors)/(num_of_starting_errors*N_trials)}')
plt.show()
