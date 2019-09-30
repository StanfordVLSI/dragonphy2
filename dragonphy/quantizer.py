import numpy as np
import math

# Assuming Binary Fixed Point Representation 
class Quantizer():
	def __init__(self, width=4, full_scale=1.0, signed=False, **kwargs):
		self.pos_only = pos_only
		self.full_scale = full_scale
		self.width = width
	
	# Performs quantization of the given fixed point size given in the constructor 
	def quantize(self, ideal_signal):
	
		lsb = full_scale/(2**self.width)
		quantized_signal = np.array([round(x / lsb)*lsb for x in ideal_signal])
		
		if signed:
			return np.clip(quantized_signal, -full_scale, full_scale)
		else:
			return np.clip(quantized_signal, 0, full_scale)

	def quantize_int(self, ideal_signal):
	
		lsb = full_scale/(2**self.width)
		quantized_signal = np.array([round(x / lsb) for x in ideal_signal])
		
		if signed:
			return np.clip(quantized_signal, -full_scale, full_scale)
		else:
			return np.clip(quantized_signal, 0, full_scale)

# Used for testing
if __name__ == "__main__":
	q = Quantizer()
	l = 10 * np.random.random_sample(10) + -10*np.random.random_sample(10)
	print(l)
	print(q.quantize(l))
	print(q.quantize_int(l))
	
