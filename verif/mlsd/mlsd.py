from dragonphy import *

import numpy as np
import matplotlib.pyplot as plt
import scipy.special

class MLSD:
    def __init__(self, cursor_pos, chan_resp, n_pre=None, n_post=None, n_bits_after=0, n_bits_before=0, bitwidth=8, quantizer_lsb=1):
        self.chan_resp_depth = len(chan_resp)
        self.chan_resp = chan_resp
        self.chan_cursor_pos = cursor_pos
        self.n_pre = self.chan_resp_depth - self.chan_cursor_pos - 1 if n_pre is None else n_pre
        self.n_post = self.chan_cursor_pos if n_post is None else n_post
        self.n_bits_after = n_bits_after
        self.n_bits_before = n_bits_before
        self.bw = bitwidth    
        self.lsb = quantizer_lsb

    def perform_mlsd_single(self, recovered_bits, chan_out, index=0, debug=False):
        #assert(index >= (self.n_pre + self.n_bits_after))
        #assert(len(recovered_bits) > index + self.n_post + self.n_bits_after)  

        qc = Quantizer(self.bw, lsb=self.lsb, signed=True)        

        difference_1 = []
        difference_0 = []
        for i in range(-self.n_bits_before, self.n_bits_after + 1):
            # Treat this as our "estimates" of the symbols
            recovered_bits_windowed = recovered_bits[index + i - self.n_pre: index + i + self.n_post + 1]
            recovered_1 = np.copy(recovered_bits_windowed)
            recovered_1[self.n_pre] = 1

            recovered_0 = np.copy(recovered_bits_windowed)
            recovered_0[self.n_pre] = -1
            
            if debug:
                print(f'{index + i - self.n_pre}, {index + i + self.n_post}')
                print(f'Recovered win: {recovered_bits_windowed}')
                print(f'Recovered 1: {recovered_1}')   
                print(f'Recovered 0: {recovered_0}')   
 
            chan_start = self.chan_resp_depth - self.chan_cursor_pos - 1 - self.n_pre
            chan_end = self.chan_resp_depth + (self.n_post - self.chan_cursor_pos)
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
                print(chan_out[index + i - self.n_pre + self.chan_cursor_pos]) 
            
            chan_out_idx = index + i - self.n_pre + self.chan_cursor_pos
            difference_1.append(chan_out[chan_out_idx] - q_se1)
            difference_0.append(chan_out[chan_out_idx] - q_se0) 

        difference_1 = np.inner(difference_1, difference_1)
        difference_0 = np.inner(difference_0, difference_0)
    
        if debug:
            print(f'Difference assuming 1: {difference_1}')
            print(f'Difference assuming 0: {difference_0}')


        bit_decision = -1 if difference_1 > difference_0 else 1
        return bit_decision

        
    # This function is broken, do not use
    def perform_mlsd_update(self, recovered_bits, chan_out, zero_pad=False):
        start_index = self.chan_resp_depth - self.chan_cursor_pos - 1
        end_index = len(recovered_bits) - self.chan_cursor_pos

        result = np.zeros(end_index - start_index)
        for i in range(start_index, end_index):
            #print(f'=========== Index: {i}')
            mlsd_out = self.perform_mlsd_single(recovered_bits, chan_out, i)
            recovered_bits[i] = mlsd_out 
            result[i - start_index] = mlsd_out

        return result

    def perform_mlsd_update_zeros(self, recovered_bits, chan_out, zero_pad=False):
        result = np.zeros(len(recovered_bits))

        n_front_zeros = self.chan_resp_depth - self.chan_cursor_pos - 1
        n_back_zeros = self.chan_cursor_pos
        r_bits_zero = np.concatenate((np.zeros(n_front_zeros), recovered_bits, np.zeros(n_back_zeros)))

        start_index = self.chan_resp_depth - self.chan_cursor_pos - 1
        end_index = len(r_bits_zero) - self.chan_cursor_pos
        print(f'Zero pad bits: {r_bits_zero}')
        for i in range(start_index, end_index):
            #print(f'=========== Index: {i}')
            mlsd_out = self.perform_mlsd_single(r_bits_zero, chan_out, i)
            r_bits_zero[i] = mlsd_out 
            result[i - start_index] = mlsd_out

        return result

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

