import numpy as np

class FFEHelper:
	def __init__(self, config, weights):
		self.config = config
		self.weights = weights
	def calculate_shift(self, channel):
		max_val = np.sum(np.abs(channel(self.weights)))
		val_bitwidth = np.ceil(np.log2(max_val)) + self.config['parameters']['input_precision']
		out_bitwidth = self.config['parameters']['output_precision']

		shift = int(val_bitwidth - out_bitwidth)
		shift = shift if shift >= 0 else 0
		
		return shift