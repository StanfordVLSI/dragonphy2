from pathlib import Path
import numpy as np
from scipy import linalg
import matplotlib.pyplot as plt

from dragonphy import *

THIS_DIR = Path(__file__).resolve().parent
S4P_DIR = get_dir('data/channel_sparam')

f_sig = 16e9
t_s = 1/f_sig
ffe_length = 12
system_config = Configuration('system', path_head='../../config')
ffe_config = system_config['generic']['ffe']
ffe_config['parameters']['length']=ffe_length
for file_name in S4P_DIR.glob('*.s4p'):
    t, imp = s4p_to_impulse(str(file_name), 0.1e-12, 20e-9, zs=50, zl=50)
    am_idx = np.argmax(imp)
    t_max = t[am_idx]



    chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=200000,
                   s4p=file_name, zs=50, zl=50)
    #chan = Channel(channel_type='exponent', sampl_rate=10e12, resp_depth=200000, tau=1e-9)
    time, pulse = chan.get_pulse_resp(f_sig=f_sig, resp_depth=350, t_delay=-t_max+3*t_s)


    plt.semilogy(pulse)
    plt.show()

    chan_mat = linalg.convolution_matrix(pulse, ffe_length)

    imp = np.zeros((330,1))
    imp[8] = 1

    zf_ffe = np.reshape(np.linalg.pinv(chan_mat) @ imp, (ffe_length,))

    zf_equal = chan.compute_output(zf_ffe.T, f_sig=f_sig, resp_depth=350, t_delay=-t_max+3*t_s)

    #time, pulse = chan.get_pulse_resp(f_sig=16e9, resp_depth=350, t_delay=-2e-9 + 62.5e-12)
    im_idx = np.argmax(pulse)

    fm = file_name.stem

    print(f'Channel: {fm}')
    print(f'Cursor Position: {im_idx}')
    ffe = FFEHelper(ffe_config, chan, t_max=t_max, step_size=0.01, sampl_rate=f_sig, cursor_pos=im_idx, iterations=100000, blind=False, quant=False)
    filt_result = ffe.weights

    mmse_equal = chan.compute_output(filt_result, f_sig=f_sig, resp_depth=25, t_delay=-t_max+3*t_s)

    fig1, axes1 = plt.subplots(2)
    axes1[0].stem(filt_result)
    axes1[0].title.set_text('LMS/MMSE')
    axes1[1].stem(zf_ffe)
    axes1[1].title.set_text('Zero Forcing')

    fig2, axes2 = plt.subplots(2)
    axes2[0].stem(mmse_equal/np.amax(mmse_equal))
    axes2[0].title.set_text('LMS/MMSE')
    axes2[1].stem(zf_equal[:33]/np.amax(zf_equal))
    axes2[1].title.set_text('Zero Forcing')

    fig3 = plt.figure()
    plt.stem(pulse[:24]/np.amax(pulse))
    plt.show()

    if input() == "a":
        break