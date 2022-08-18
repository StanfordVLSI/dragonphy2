import numpy as np
import matplotlib.pyplot as plt


with open('adaptation_internal_weights.txt', 'r') as f:
    lines = f.readlines()
    lines = [line.strip()  for line in lines if len(line.strip()) > 0]
    adapt_coeffs = np.zeros((10, len(lines)))

    last_zero = 0
    for (ii, line) in enumerate(lines):
        line = line[2:-1]
        print(line)
        tokens = line.split(',')

        if len(tokens) < 10:
            continue

        adapt_coeffs[:, ii] = np.array([float(tok)/(2**22) for tok in tokens])
        if 0 in adapt_coeffs[:, ii]:
            last_zero = ii
print(last_zero)

print(adapt_coeffs)


fig, axes = plt.subplots(10,1)


for ii in range(10):
    axes[ii].plot(adapt_coeffs[ii, last_zero:-1].T)
plt.show()