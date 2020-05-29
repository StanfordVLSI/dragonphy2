from dragonphy import *

import numpy as np
import matplotlib.pyplot as plt
import scipy.special

class MLSD:
    def __init__(self, cursor_pos, chan_resp, n_post=None, n_pre=None, n_future=0, n_prev=0, bitwidth=8, quantizer_lsb=1):
        self.chan_resp_depth = len(chan_resp)
        self.chan_resp = chan_resp
        self.chan_cursor_pos = cursor_pos
        self.n_post = self.chan_resp_depth - self.chan_cursor_pos - 1 if n_post is None else n_post
        self.n_pre = self.chan_cursor_pos if n_pre is None else n_pre
        self.n_future = n_future
        self.n_prev = n_prev
        self.bw = bitwidth    
        self.lsb = quantizer_lsb

    def calculate_norm(self, recovered_bits, chan_out, index=0, bit=1, debug=False):
        qc = Quantizer(self.bw, lsb=self.lsb, signed=True)        

        difference = []
        for i in range(-self.n_prev, self.n_future + 1):
            # Treat this as our "estimates" of the symbols
            recovered_bits_windowed = recovered_bits[index + i - self.n_post: index + i + self.n_pre + 1]
            recovered = np.copy(recovered_bits_windowed)
            recovered[self.n_post] = bit

            if debug:
                print(f'{index + i - self.n_post}, {index + i + self.n_pre}')
                print(f'Recovered win: {recovered_bits_windowed}')
                print(f'Recovered 1: {recovered}')   
 
            chan_start = self.chan_resp_depth - self.chan_cursor_pos - 1 - self.n_post
            chan_end = self.chan_resp_depth + (self.n_pre - self.chan_cursor_pos)
            chan_resp_modified = self.chan_resp[chan_start:chan_end] 

            se = np.dot(chan_resp_modified, recovered)
            if debug:
                print(se)
            
            q_se = qc.quantize_2s_comp(se)
            if debug:
                print(q_se)
                print(chan_out[index + i - self.n_post + self.chan_cursor_pos]) 
            
            chan_out_idx = index + i - self.n_post + self.chan_cursor_pos
            difference.append(chan_out[chan_out_idx] - q_se)

        difference = np.inner(difference, difference)
        return difference

    def perform_mlsd_single(self, recovered_bits, chan_out, index=0, debug=False):
        #assert(index >= (self.n_post + self.n_future))
        #assert(len(recovered_bits) > index + self.n_pre + self.n_future)  

        qc = Quantizer(self.bw, lsb=self.lsb, signed=True)        

        difference = []
        seq = []
        for i in range(-self.n_prev, self.n_future + 1):
            # Treat this as our "estimates" of the symbols
            recovered_bits_windowed = recovered_bits[index + i - self.n_post: index + i + self.n_pre + 1]
            recovered_1 = np.copy(recovered_bits_windowed)
            recovered_1[self.n_post] = 1

            recovered_0 = np.copy(recovered_bits_windowed)
            recovered_0[self.n_post] = -1
            
            if debug:
                print(f'{index + i - self.n_post}, {index + i + self.n_pre}')
                print(f'Recovered win: {recovered_bits_windowed}')
                print(f'Recovered 1: {recovered_1}')   
                print(f'Recovered 0: {recovered_0}')   
 
            chan_start = self.chan_resp_depth - self.chan_cursor_pos - 1 - self.n_post
            chan_end = self.chan_resp_depth + (self.n_pre - self.chan_cursor_pos)
            chan_resp_modified = self.chan_resp[::-1][chan_start:chan_end] 

            se1 = np.dot(chan_resp_modified, recovered_1)
            se0 = np.dot(chan_resp_modified, recovered_0)
            if debug:
                print(se1)
                print(se0)
            
            q_se1 = qc.quantize_2s_comp(se1)
            q_se0 = qc.quantize_2s_comp(se0)
            if debug:
                print(q_se1)
                print(q_se0)
                print(chan_out[index + i - self.n_post + self.chan_cursor_pos]) 
            
            chan_out_idx = index + i - self.n_post + self.chan_cursor_pos
            difference = self.combinations(chan_out[chan_out_idx] - q_se0, chan_out[chan_out_idx] - q_se1, difference)
            seq = self.combinations(-1, 1, seq)

        difference = [np.inner(x, x) for x in np.array(difference)]
    
        if debug:
            print(f'Difference: {difference}')

        bit_decision = np.argmin(difference) 
        return seq[bit_decision]

    def combinations(self, n1, n2, arr):
        result = []
        if arr == []:
            result.append([n1])
            result.append([n2])
        else: 
            for a in arr:
                sub1 = a + [n1]
                sub2 = a + [n2]
                result.append(sub1)
                result.append(sub2)
        return result
        
    def calc_mlsd_err(self, recovered_bits, chan_out, inv=False, debug=False):
        result = np.zeros(len(recovered_bits))

        n_front_zeros = self.chan_resp_depth - self.chan_cursor_pos - 1
        n_back_zeros = self.chan_cursor_pos
        r_bits_zero = np.concatenate((np.zeros(n_front_zeros), recovered_bits, np.zeros(n_back_zeros)))

        start_index = self.chan_resp_depth - self.chan_cursor_pos - 1
        end_index = len(r_bits_zero) - self.chan_cursor_pos
        for i in range(start_index + self.n_prev, end_index - self.n_future):
            bit = r_bits_zero[i] if not inv else -1 * r_bits_zero[i]
            mlsd_out = self.calculate_norm(r_bits_zero, chan_out, i, bit, debug)
            result[i - start_index] = mlsd_out

        return result

    def plot_ffe_mlsd(self, ffe_out, recovered_bits, chan_out, ideal, plot_range=[0, 100]):
        f, ax = plt.subplots(2, 1) 
        ax[0].set_title('FFE Output Error')
        ax[0].plot(np.abs(ffe_out)[plot_range[0]:plot_range[1]], label="ffe_err")
        ffe_norm = self.calc_mlsd_err(recovered_bits, chan_out)
        ffe_norm_inv = self.calc_mlsd_err(recovered_bits, chan_out, inv=True)
        ax[0].plot(ffe_norm[plot_range[0]:plot_range[1]], label="ffe_norm")
        ax[0].plot(ffe_norm_inv[plot_range[0]:plot_range[1]], label="ffe_norm")

        ax[1].set_title('FFE Output Bits')
        ax[1].plot(recovered_bits[plot_range[0]:plot_range[1]], label='ffe_out')
        ax[1].plot(ideal[plot_range[0]:plot_range[1]], label='ideal')
        f.legend()
        plt.show()

        return np.abs(ffe_out)

    def perform_mlsd_zeros(self, recovered_bits, chan_out, step_size=1, bool_arr = None, update=True, debug=False):
        result = np.zeros(len(recovered_bits))

        if bool_arr is None:
            bool_arr = np.ones(len(recovered_bits))

        n_front_zeros = self.chan_resp_depth - self.chan_cursor_pos - 1
        n_back_zeros = self.chan_cursor_pos
        r_bits_zero = np.concatenate((np.zeros(n_front_zeros), recovered_bits, np.zeros(n_back_zeros)))

        start_index = self.chan_resp_depth - self.chan_cursor_pos - 1
        end_index = len(r_bits_zero) - self.chan_cursor_pos
        for i in range(start_index + self.n_prev, end_index - self.n_future, step_size):
            if debug:
                print(f'=========== Index: {i - start_index}')

            if bool_arr[i-n_front_zeros]:
                mlsd_out = self.perform_mlsd_single(r_bits_zero, chan_out, i, debug)
            else:
                mlsd_out = r_bits_zero[i]

            if update:
                r_bits_zero[i] = mlsd_out 

            result[i - start_index - self.n_prev: i - start_index + self.n_future+ 1] = mlsd_out

        return result

    def perform_mlsd_ffe_err(self, recovered_bits, chan_out, threshold = 0, update=True, debug=False):
        ffe_norm = self.calc_mlsd_err(recovered_bits, chan_out) > threshold
        result = self.perform_mlsd_zeros(recovered_bits, chan_out, ffe_norm, update, debug)
        return result
        
    def find_err_idx(self, mlsd, ideal, shift_pos=True, plot=True):
        err_idx = [i for i in range(len(mlsd)) if mlsd[i] != ideal[i]]
        print(f'Mismatches occur: {err_idx}')
        print(f'Num mismatch: {len(err_idx)} \t BER: {len(err_idx)/len(mlsd)}')
        return err_idx 

def main():
    ideal = np.array([-1, -1, 1, -1, -1, 1, 1, 1, -1, -1, -1, -1])
    chan_resp = np.array([0, 0.2458, 0.3033, 0.2505, 0.2004])
    cursor_pos = np.argmax(chan_resp)

    print(f'cursor pos = {cursor_pos}') 

    ideal_one_err = np.copy(ideal)
    ideal_one_err[7] = -1 * ideal_one_err[7]

    chan_out = np.convolve(ideal, chan_resp)
    #chan_out = chan_out[cursor_pos:]
    q = Quantizer(signed=True)
    
    q_chan_out = q.quantize_2s_comp(chan_out)     

    print(chan_out)
    m = MLSD(cursor_pos, chan_resp, quantizer_lsb=q.lsb)

    mlsd_out =  m.perform_mlsd_update_zeros(ideal_one_err, q_chan_out)
    print(f'Ideal: {ideal}')
    print(f'Ideal (err): {ideal_one_err}')
    print(f'MLSD: {mlsd_out}')

# Used for testing only
if __name__ == "__main__":
    main()

