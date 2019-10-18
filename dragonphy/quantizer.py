import numpy as np
import math

# Assuming Binary Fixed Point Representation 
class Quantizer():
    def __init__(self, width=4, full_scale=1.0, signed=False, lsb=None, **kwargs):
        self.signed = signed
        self.full_scale = full_scale
        self.width = width
        self.lsb = lsb

    # Performs quantization of the given fixed point size given in the constructor 
    def quantize(self, ideal_signal):
    
        lsb = self.full_scale/(2**self.width)
        quantized_signal = np.array([round(x / lsb)*lsb for x in ideal_signal])
        
        if self.signed:
            return np.clip(quantized_signal, -self.full_scale, self.full_scale)
        else:
            return np.clip(quantized_signal, 0, self.full_scale)

    def quantize_int(self, ideal_signal):
    
        lsb = self.full_scale/(2**self.width)
        quantized_signal = np.array([round(x / lsb) for x in ideal_signal])
        
        if self.signed:
            return np.clip(quantized_signal, -self.full_scale*2**self.width, self.full_scale)
        else:
            return np.clip(quantized_signal, 0, self.full_scale)

    def quantize_2s_comp(self, ideal_signal):
        # Assume width is the size of N-bits 2's complement. E.g. width == 2 --> [-4, 3]

        # self.signed must be true
        assert(self.signed)

        # Set the maximum magnitude ideal signal value to correspond to -127 or
        # 128 depending on if it is signed.
        if self.lsb is None:
            max_idx = np.argmax(np.absolute(ideal_signal))
            if ideal_signal[max_idx] < 0:
                lsb = -ideal_signal[max_idx] / 2**(self.width-1)
            else:
                lsb = ideal_signal[max_idx] / (2**(self.width-1) - 1)
            self.lsb = lsb

        if isinstance(ideal_signal, (list, np.ndarray)):
            quantized_signal = np.array([round(x / self.lsb) for x in ideal_signal])
            return np.clip(quantized_signal, -1 * 2**(self.width-1), 2**(self.width-1)-1)
        else:
            quantized_signal = round(ideal_signal / self.lsb)
            return max(min(quantized_signal, 2**(self.width-1)-1), -1 * 2**(self.width-1))
        

# Used for testing
if __name__ == "__main__":
    q = Quantizer()
    l = 10 * np.random.random_sample(10) + -10*np.random.random_sample(10)
    print(l)
    print(q.quantize(l))
    print(q.quantize_int(l))
    
