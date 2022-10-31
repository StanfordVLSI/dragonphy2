import matplotlib.pyplot as plt
import numpy as np
import sys

ffe_length = int(sys.argv[2])

data_dict = {}

for ii in range(ffe_length):
    data_dict[ii] = []

with open(sys.argv[1], 'r') as f:
    for line in f:
        tokens = line.strip().split(',')
        if len(tokens) < 2:
            break

        if tokens[1] == '':
            break
        data_dict[int(tokens[0])] += [int(tokens[1])]

min_len = len(data_dict[0])
for ii in range(1,ffe_length):
    if len(data_dict[ii]) < min_len:
        min_len = len(data_dict[ii])

data = np.zeros((ffe_length, min_len-1))

for ii in range(ffe_length):
    data[ii] = data_dict[ii][1:min_len]
data = data /(2.0 ** 22)

plt.plot(data.T)
plt.legend(list(range(ffe_length)))
plt.show()

plt.plot(data.T[-1])
plt.show()
