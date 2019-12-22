from dragonphy import *
import numpy as np

class FFEHelper:
    def __init__(self, config, chan, cursor_pos=2, iterations=10000):
        self.config = config
        self.channel = chan
        self.qc = Quantizer(width=self.config["parameters"]["input_precision"], signed=True)
        self.qw = Quantizer(width=self.config["parameters"]["weight_precision"], signed=True)

        self.cursor_pos = cursor_pos
        self.iterations = iterations


        self.ideal_codes= self.__random_ideal_codes()
        self.channel_output = self.__random_codes()
        self.quantized_channel_output = self.qc.quantize_2s_comp(self.channel_output)

        self.weights = self.calculate_ffe_coefficients()
        self.filt    = self.generate_ffe(self.weights)

    def __random_ideal_codes(self):
        return np.random.randint(2, size=self.iterations)*2 - 1

    def __random_codes(self):
        return self.channel(self.ideal_codes)

    def randomize_codes(self):
        self.ideal_codes = __random_codes();
        self.channel_output = self.channel(self.ideal_codes)

    def calculate_ffe_coefficients(self):
        ffe_length = self.config['parameters']['length']
        ffe_adapt_mu = 0.1#self.config['adaptation']['args']['mu']

        adapt = Wiener(step_size = ffe_adapt_mu, num_taps = ffe_length, cursor_pos=self.cursor_pos)
        for i in range(self.iterations-self.cursor_pos):
            adapt.find_weights_pulse(self.ideal_codes[i-self.cursor_pos], self.channel_output[i])   
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