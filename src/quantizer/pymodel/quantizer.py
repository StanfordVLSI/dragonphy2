import numpy as np
import math

# Assuming Binary Fixed Point Representation 
class Quantizer():
	def __init__(self, width=(0, 4), **kwargs):
		if not isinstance(width, tuple) or len(width) != 2:
			print("Fixed input width: {} not a tuple, defaulting to {}=(0, 4)".format('width','width'))
			self.width = (4, 4)
		else:
			self.width = width	
	
	# Performs quantization of the given fixed point size given in the constructor 
	def __call__(self, ideal_signal):
	
		# if width[0] == 0 then we do not round to the left of the radix
		smallest_bit = 1.0/(2**self.width[1])
		print(smallest_bit)
		sat_val = 2**(self.width[0] + 1) - smallest_bit if self.width[0] != 0 else 1e99
		print(sat_val)
		quantized_signal = np.array([round(x / smallest_bit)*smallest_bit for x in ideal_signal])
		
		return np.clip(quantized_signal, -sat_val, sat_val)

# Used for testing
if __name__ == "__main__":
	q = Quantizer((3, 2))
	l = 10 * np.random.random_sample(10) + -10*np.random.random_sample(10)
	print(l)
	print(q(l))
	
