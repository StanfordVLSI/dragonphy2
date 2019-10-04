from dragonphy import *

class Fir(Filter):
    def __init__(self, num_channels, weights = [0]):
        self.num_channels = num_channels
        self.impulse_response = weights
    
    def update_weights(weights):
        self.impulse_response = weights

    def __call__(self, symbols):
        return super().__call__(symbols)

    def channelized(self, symbols, iteration=0):
        conv_signal = super().__call__(symbols)
        return [conv_signal[iteration + i:len(self.impulse_response)+i+iteration] for i in range(self.num_channels)]
