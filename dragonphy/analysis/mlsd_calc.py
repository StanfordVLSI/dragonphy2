from dragonphy import *

import numpy as np
import matplotlib.pyplot as plt
import scipy.special

def mlsd_max_bits(channel):
    chan = channel.impulse_response

    N = np.arange(len(chan))
    f = np.array([np.dot(chan[:n], chan[:n]) for n in N])
    g = np.array([np.sum(chan[:n]) for n in N])
 
    chan_pad = np.pad(chan, (1,1), 'constant', constant_values=(0,0))
    df_approx = np.array([(chan_pad[n+2]**2 + chan_pad[n]**2)/2 for n in N]) 
    dg_approx = np.array([(chan_pad[n+2] + chan_pad[n])/2 for n in N])

    result = np.multiply(df_approx, 2*g) - np.multiply(dg_approx, f) 

    print(chan)
    print(np.dstack((N, result)))

    plt.plot(result)
    plt.plot(chan)
    plt.show()
    return result 

def err_fn(channel):
    chan = channel.impulse_response[channel.cursor_pos:]
    N = np.arange(1, len(chan))
    f = np.array([np.dot(chan[:n], chan[:n]) for n in N])
    g = np.array([np.sum(chan[:n]) for n in N])

    print(f)
    print(g)

    sigma = 0.06
    f_over_g = np.divide(f, np.sqrt(2)*sigma*np.sqrt(g))
    print(f_over_g)
    err_fun = scipy.special.erf(f_over_g)
    print(err_fun)

    err = 0.5 - 0.5 * scipy.special.erf(np.divide(f, np.sqrt(2)*sigma*np.sqrt(g))) 
    print(err)   
 
    plt.plot(err)
    plt.show()

    return err
    

def calculate_err_fn():
    c = Channel(channel_type='skineffect', normal='area', tau=2, sampl_rate=5, cursor_pos=2, resp_depth=125)
    mlsd_max_bits(c) 
    err_fn(c)


def main(): 
    calculate_err_fn() 
    
# Used for testing only
if __name__ == "__main__":
    main()

