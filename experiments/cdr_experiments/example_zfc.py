import matplotlib.pyplot as plt
from scipy import linalg, stats
import numpy as np


ffe_length = 30
ffe_cursor_pos = 5

precursor = .25
postcursor = 0.25
tail_height = 0.2

pulse = np.ones((200,)) * tail_height
pulse[0] = precursor
pulse[1] = 1
pulse[2] = postcursor

pulse[150:] = 0

chan_mat = linalg.convolution_matrix(pulse, ffe_length)
imp = np.zeros((200 + ffe_length - 1,1))
imp[ffe_cursor_pos] = 1
filt = np.reshape(np.linalg.pinv(chan_mat) @ imp, (ffe_length,))

plt.stem(pulse)
plt.show()

plt.stem(filt)
plt.show()