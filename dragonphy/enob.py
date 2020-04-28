import numpy as np
from scipy import optimize

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

    # extract amplitude and phase of a sine wave
    # these are used as initial guesses for an
    # optimization routine
    c_init = np.sqrt(b[0]**2 + b[1]**2)
    if b[1] != 0:
        K_init = np.arctan(b[0]/b[1])
    else:
        K_init = np.sign(b[0])*(np.pi/2)

    # fine-tune phase, amplitude, and offset
    def model_func(x_data, c_param, K_param, o_param):
        return c_param*np.sin(x_data+K_param) + o_param
    params, _ = optimize.curve_fit(model_func, p_vec, y, p0=[c_init, K_init, 0.0])

    # compute model of noiseless signal
    y_mod = model_func(p_vec, *params)

    # compute RMS signal amplitude
    As = params[0]/np.sqrt(2)

    # compute noise amplitude
    An = np.std(y-y_mod)

    # calculate SNDR
    sndr = 20*np.log10(As/An)

    # return enob
    return (sndr - 1.76) / 6.02
