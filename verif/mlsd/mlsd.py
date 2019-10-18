from dragonphy import *

import numpy as np
import matplotlib.pyplot as plt
import scipy.special

class MLSD:
    def __init__(self, chan, n_pre=None, n_post=None, n_bits_after=0, n_bits_before=0, bitwidth=8, quantizer_lsb=1): 
        self.n_pre = chan.resp_depth - chan.cursor_pos - 1 if n_pre is None else n_pre
        self.n_post = chan.cursor_pos if n_post is None else n_post
        self.n_bits_after = n_bits_after
        self.n_bits_before = n_bits_before
        self.chan = chan
        self.bw = bitwidth    
        self.lsb = quantizer_lsb

    def perform_mlsd_single(self, recovered_bits, ffe_out, chan_out, index=0):
        assert(index >= (self.n_pre + self.n_bits_after))
        assert(len(recovered_bits) > index + self.n_post + self.n_bits_after)  

        qc = Quantizer(self.bw, lsb=self.lsb, signed=True)        

        difference_1 = []
        difference_0 = []
        for i in range(-self.n_bits_before, self.n_bits_after + 1):
            # Treat this as our "estimates" of the symbols
            #chan_out_windowed = chan_out[index + i - self.n_pre: index + i + self.n_post + 1]
            recovered_bits_windowed = recovered_bits[index + i - self.n_pre: index + i + self.n_post + 1]
            #print(recovered_bits_windowed)
            recovered_1 = np.copy(recovered_bits_windowed)
            recovered_1[self.n_pre] = 1

            recovered_0 = np.copy(recovered_bits_windowed)
            recovered_0[self.n_pre] = -1
    
            chan_start = self.chan.resp_depth - self.chan.cursor_pos - 1 - self.n_pre
            chan_end = self.chan.resp_depth + (self.n_post - self.chan.cursor_pos)
            chan_resp_modified = self.chan.impulse_response[::-1][chan_start:chan_end] 

            se1 = np.dot(chan_resp_modified, recovered_1)
            se0 = np.dot(chan_resp_modified, recovered_0)

            q_se1 = qc.quantize_2s_comp(se1)
            q_se0 = qc.quantize_2s_comp(se0)
        
            difference_1.append(chan_out[index + i + self.chan.cursor_pos] - q_se1)
            difference_0.append(chan_out[index + i + self.chan.cursor_pos] - q_se0) 

        #plt.figure()
        #plt.plot(difference_1)
        #plt.plot(difference_0)
       # plt.show()

        difference_1 = np.inner(difference_1, difference_1)
        difference_0 = np.inner(difference_0, difference_0)


        bit_decision = -1 if difference_1 > difference_0 else 1
        return bit_decision

        #plt.figure()
        #plt.plot(12000*recovered_bits[:100])
        #plt.plot(ffe_out[:100])
        #plt.plot(500*chan_out[:100])
        #plt.show()
        
