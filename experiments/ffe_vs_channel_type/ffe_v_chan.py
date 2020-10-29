from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt

from dragonphy import *

THIS_DIR = Path(__file__).resolve().parent
S4P_DIR = get_dir('data/channel_sparam')

t_s = 62.6e-12

system_config = Configuration('system', path_head='../../config')
ffe_config = system_config['generic']['ffe']
for file_name in S4P_DIR.glob('*.s4p'):
    t, imp = s4p_to_impulse(str(file_name), 0.1e-12, 20e-9, zs=50, zl=50)
    am_idx = np.argmax(imp)
    t_max = t[am_idx]



    chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=200000,
                   s4p=file_name, zs=50, zl=50)
    #chan = Channel(channel_type='exponent', sampl_rate=10e12, resp_depth=200000, tau=1e-9)
    time, pulse = chan.get_pulse_resp(f_sig=16e9, resp_depth=350, t_delay=-t_max+3*t_s)
    #time, pulse = chan.get_pulse_resp(f_sig=16e9, resp_depth=350, t_delay=-2e-9 + 62.5e-12)


    im_idx = np.argmax(pulse)
    print(im_idx)
    ffe = FFEHelper(ffe_config, chan, t_max=t_max, sampl_rate=16e9, cursor_pos=im_idx, iterations=50000, blind=False)
    filt_result = ffe.weights




    plt.plot(filt_result)
    plt.show()
    plt.plot(chan.compute_output(filt_result)/np.amax(chan.compute_output(filt_result)))
    plt.plot(pulse/np.amax(pulse))
    plt.show()
    if input() == "a":
        break
