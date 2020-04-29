import numpy as np

def enob(y, Fs, Fstim):
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
    y_mod = b[0]*c_vec + b[1]*s_vec

    # uncomment for debugging
    # import matplotlib.pyplot as plt
    # plt.plot(y)
    # plt.plot(y_mod)
    # plt.legend(['y', 'y_mod'])
    # plt.show()

    # compute RMS signal amplitude
    As = np.sqrt(np.mean(b**2))

    # compute noise amplitude
    An = np.std(y-y_mod)

    # calculate SNDR
    sndr = 20*np.log10(As/An)

    # return enob
    return (sndr - 1.76) / 6.02
