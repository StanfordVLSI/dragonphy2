from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt

from dragonphy import *

THIS_DIR = Path(__file__).resolve().parent
S4P_DIR = get_dir('data/channel_sparam')

system_config = Configuration('system', path_head='../../config')
ffe_config = system_config['generic']['ffe']
for file_name in S4P_DIR.glob('*.s4p'):
    chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=200000,
                   s4p=file_name, zs=50, zl=50)
    time, pulse = chan.get_pulse_resp(f_sig=16e9, resp_depth=350, t_delay=3.7e-9)

 #   filt_result = FFEHelper(ffe_config, chan).weights
    plt.plot(time, pulse)
    plt.show()
