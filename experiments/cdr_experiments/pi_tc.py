from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np
from dragonphy import *

def pi_curve(arr, f_sig=16.0e9, n_spikes=16, amplitude=0.5, duty_cycle=0.5):
	a = amplitude
	b = duty_cycle
	t = 1/f_sig/n_spikes
	# -ax + a/(b*t) * x^2
	# 3a(x - b*t) - a/(b8t) * (x^2 - (b*t)^2)

	arr_m = np.mod(arr, t)
	#return 
	return arr + f_sig/4*arr**2 + np.where(arr_m < b*t, -a*arr_m + a/(b*t)*arr_m**2, a*(1+b)/(1-b)*(arr_m-b*t) - a/((1-b)*t) * (arr_m**2 - (b*t)**2))


f_sig = 16e9
n_spikes = 17
t = 1/f_sig/n_spikes
arr = np.linspace(0, 1/16e9, 1000)
print(t)
for ii in range(5):
	duty = np.random.rand(1)*0.4 + 0.2
	plt.plot(pi_curve(arr, n_spikes=12, duty_cycle=duty))
plt.show()