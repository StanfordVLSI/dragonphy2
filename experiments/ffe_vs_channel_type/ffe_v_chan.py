from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt

from dragonphy import *

THIS_DIR = Path(__file__).resolve().parent
S4P_DIR = get_dir('data/channel_sparam')

system_config = Configuration('system', path_head='../../config')
ffe_config = system_config['generic']['ffe']
for file_name in S4P_DIR.glob('*.s4p'):
    t, imp = s4p_to_impulse(str(file_name), 0.1e-12, 20e-9, zs=50, zl=50)
    am_idx = np.argmax(imp)
    t_max = t[am_idx]

    chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=200000,
                   s4p=file_name, zs=50, zl=50)
    time, pulse = chan.get_pulse_resp(f_sig=16e9, resp_depth=350, t_delay=-t_max+125e-12)

    im_idx = np.argmax(pulse)
    print(im_idx)
    ffe = FFEHelper(ffe_config, chan, cursor_pos=im_idx)
    filt_result = ffe.weights

    plt.plot(filt_result)
    plt.show()
    plt.plot(chan.compute_output(filt_result)/np.amax(chan.compute_output(filt_result)))
    plt.plot(pulse/np.amax(pulse))
    plt.show()
