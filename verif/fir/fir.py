import numpy as np
from dragonphy import *

class Fir(Filter):
    def __init__(self, n_taps, weights = [0], n_channels=1):
        self.n_taps = n_taps
        self.impulse_response = weights
        self.n_channels = n_channels

    def update_weights(weights):
        self.impulse_response = weights

    def __call__(self, symbols):
        return super().__call__(symbols)

    def replicate_weights(self):
        # Replicate weights to n_channels if n_channels > 1
        self.impulse_response = np.tile(self.impulse_response, (self.n_channels, 1)) 

    def single(self, symbols, iteration=0):
        conv_signal = super().__call__(symbols)
        return np.array([conv_signal[iteration + i:len(self.impulse_response)+i+iteration] for i in range(self.n_channels)])

    def channelized(self, symbols, zero_pad=True):
        assert (self.n_channels > 1)

        if self.impulse_response.ndim == 1:
            self.replicate_weights()
        else:
            assert(self.impulse_response.ndim == self.n_channels) 

        # weights for each channel where row i corresponds to channel i. 
        n_inputs = self.n_channels + self.n_taps - 1
        weight_matrix = np.array([np.pad(self.impulse_response[i][::-1], (i, n_inputs - self.n_taps - i), 'constant', constant_values=(0,0)) for i in range(self.n_channels)])
        print(weight_matrix)        
        if zero_pad:
            symbols = np.pad(symbols, (self.n_taps - 1, 0), 'constant', constant_values=(0,0))

        # Ignore remaining inputs if it does not match number
        n_batches = int((len(symbols) - (self.n_taps - 1))/self.n_channels) * self.n_channels 
        symbols = symbols[0:n_batches + self.n_taps - 1] 
        symbol_matrix = np.transpose(np.array([symbols[i:i+n_inputs] for i in range(0, n_batches, self.n_channels)])) 
       
        return np.dot(weight_matrix, symbol_matrix).flatten('F')
         
