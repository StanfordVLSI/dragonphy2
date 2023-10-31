import numpy as np
import matplotlib.pyplot as plt


with open('adaptation_internal_weights.txt', 'r') as f:
    lines = f.readlines()
    lines = [line.strip()  for line in lines if len(line.strip()) > 0]
    adapt_coeffs = np.zeros((20, len(lines)))
    adapt_indx = np.zeros((20,))


    last_zero = 0
    ii = 0


    for line in lines:
        tokens = line.split(',')

        adapt_coeffs[int(tokens[0]), int(adapt_indx[int(tokens[0])])] = np.array(float(tokens[1]))
        adapt_indx[int(tokens[0])] += 1

print(adapt_coeffs)


fig, axes = plt.subplots(20,1)


for ii in range(20):
    axes[ii].plot(adapt_coeffs[ii, last_zero:-1].T)
plt.show()
