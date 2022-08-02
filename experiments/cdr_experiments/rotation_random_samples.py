from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
from matplotlib import ticker, cm
import numpy as np
from scipy import linalg, stats
from dragonphy import *
from rich.progress import Progress

phi_1 = np.mod(np.cumsum(np.random.randn(128)*5e-12 + 33.5e-12), 62.5e-12) / 62.5e-12 * 2 * np.pi
phi_2 = np.mod(phi_1[-1] + np.cumsum(np.random.randn(128)*5e-12 + 33.5e-12), 62.5e-12) / 62.5e-12 * 2 * np.pi

plt.plot(np.sort(phi_1))
plt.plot(np.sort(phi_2))
plt.plot(np.sort(np.append(phi_1,phi_2)))
plt.show()

error_val = np.zeros((100000,))
phi_off_val = np.zeros((100000,))

for ii in range(100000):
	phi_offset = ii/100000.0 * 2 * np.pi

	tot_phi = np.append(phi_1, np.mod(phi_offset + phi_2, 2*np.pi))

	error_val[ii] = np.sum(np.square(np.diff(np.sort(tot_phi))))
	phi_off_val[ii] = phi_offset

plt.plot(phi_off_val, error_val)
plt.show()

plt.plot(np.sort(error_val))
plt.show()

opt_phi = np.argmin(error_val)

phi_2_new = np.mod(phi_2 + opt_phi, 2*np.pi)

plt.plot(np.sort(np.append(phi_1, phi_2))-np.linspace(0, 2*np.pi, 256))
plt.plot(np.sort(np.append(phi_1, phi_2_new))-np.linspace(0, 2*np.pi, 256))
plt.show()



