import numpy as np
from collections import defaultdict

def remap(y, Fs, Fstim, num_bits):
    # Assuming y is sinusoidal, find optimal mapping from values in y to new
    # values to best match a sine wave. Resulting sine wave is always scaled
    # up to maximum size assuming outputs are signed and num_bits wide

    # follow first few steps of enob calculation to get best-fit sine
    # ref: page 7 at http://www.mit.edu/~klund/A2Dtesting.pdf

    # make "y" a vector if it is not already
    y = np.array(y, dtype=float)

    # remove mean
    y -= np.mean(y)

    # generate cos/sin vectors for linear regression
    t_vec = np.arange(len(y))/Fs
    p_vec = 2*np.pi*Fstim*t_vec
    c_vec = np.cos(p_vec)
    s_vec = np.sin(p_vec)

    # do least-squares linear regression
    A = np.column_stack((c_vec, s_vec))
    b, _, _, _ = np.linalg.lstsq(A, y, rcond=None)

    # compute model of noiseless signal
    amp_meas = (b[0]**2 + b[1]**2)**0.5
    amp_des = 2**(num_bits-1)-1
    y_mod = (b[0]*c_vec + b[1]*s_vec) / amp_meas * amp_des

    # uncomment for debugging
    # import matplotlib.pyplot as plt
    # plt.plot(y)
    # plt.plot(y_mod)
    # plt.legend(['y', 'y_mod'])
    # plt.show()

    meas = defaultdict(list)
    for y_i, y_mod_i in zip(y, y_mod):
        meas[y_i].append(y_mod_i)

    map_ = {}
    for k, v in meas.items():
        map_[k] = int(sum(v)/len(v) + .5)

    y_map = [map_[y_i] for y_i in y]

    # import matplotlib.pyplot as plt
    # plt.plot(y_map)
    # plt.plot(y_mod)
    # plt.legend(['y_map', 'y_mod'])
    # plt.show()

    return y_map

