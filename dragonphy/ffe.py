from dragonphy import *
import numpy as np
import matplotlib.pyplot as plt
class FFEHelper:
    def __init__(self, config, chan, cursor_pos=2, sampl_rate=1e9, t_max=0, iterations=200000, blind=False):
        self.config = config
        self.channel = chan
        self.qc = Quantizer(width=self.config["parameters"]["input_precision"], signed=True)
        self.qw = Quantizer(width=self.config["parameters"]["weight_precision"], signed=True)
        self.t_max = t_max
        self.sampl_rate = sampl_rate
        self.cursor_pos = cursor_pos
        self.iterations = iterations
        self.blind=blind

        self.ideal_codes= self.__random_ideal_codes()
        self.channel_output = self.__random_codes()

        self.quantized_channel_output = self.qc.quantize_2s_comp(self.channel_output)

        self.weights = self.calculate_ffe_coefficients(initial=True)
        self.filt    = self.generate_ffe(self.weights)

    def __random_ideal_codes(self):
        return np.random.randint(2, size=self.iterations)*2 - 1

    def __random_codes(self):
        t_delay = -self.t_max + self.cursor_pos/self.sampl_rate
        return self.channel.compute_output(self.ideal_codes, f_sig=16e9, t_delay=t_delay)

    def randomize_codes(self):
        self.ideal_codes = __random_codes();
        self.channel_output = self.channel(self.ideal_codes)

    def calculate_ffe_coefficients(self, mu=0.1, initial=False,blind=None):
        if blind == None:
            blind = self.blind

        ffe_length =  self.config['parameters']['length']
        ffe_adapt_mu = 0.1

        if initial:
            adapt = Wiener(step_size = ffe_adapt_mu, num_taps = ffe_length, cursor_pos=int(ffe_length/2))
        else:
            adapt = Wiener(step_size = ffe_adapt_mu, num_taps = ffe_length, cursor_pos=int(ffe_length/2), weights=self.weights)
        
        st_idx = self.cursor_pos + int(ffe_length/2)

        for i in range(st_idx, self.iterations):
            adapt.find_weights_pulse(self.ideal_codes[i-st_idx], self.channel_output[i], blind=blind)
        return self.qw.quantize_2s_comp(adapt.weights)

    def generate_ffe(self, weights):
        return Fir(len(weights), weights, self.config["parameters"]["width"])

    def calculate_shift(self):
        #The Quantizer can't be used arbitrarily due to its clipping

        #Calculate the average maximum value that will occur on the output of the FFE for the given channel
        max_val = np.sum(np.abs([round(val/self.qc.lsb) for val in self.filt(self.channel_output)]))/len(self.channel_output)
        
        #Calculate tbe bitwidth (and account for the sign)
        val_bitwidth = np.ceil(np.log2(max_val)) + 1 # 
        out_bitwidth = self.config['parameters']['output_precision']  

        #Calculate the amount that the FFE output needs to be shifted to avoid overflow
        #the +1 is a hedge here 
        shift = int(val_bitwidth - out_bitwidth) + 1
        shift = shift if shift >= 0 else 0

        #Calculate the width of the shifter
        #the +1 is also a hedge here as well
        shift_bitwidth = int(np.ceil(np.log2(shift))) + 1

        return shift, shift_bitwidth

    	#Have to add in support for the quantization
