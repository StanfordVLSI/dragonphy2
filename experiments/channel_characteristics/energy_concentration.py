from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np
from dragonphy import *


THIS_DIR = Path(__file__).resolve().parent
sparam_file_list = ["Case4_FM_13SI_20_T_D13_L6.s4p",
"peters_01_0605_B1_thru.s4p",  
                    "peters_01_0605_B12_thru.s4p",  
                    "peters_01_0605_T20_thru.s4p",
                    "TEC_Whisper42p8in_Meg6_THRU_C8C9.s4p",
                    "TEC_Whisper42p8in_Nelco6_THRU_C8C9.s4p"]

num_pre = np.zeros((5,), dtype=np.uint8)

color_list = ['C0','C1','C2', 'C3','C4','C5']

for ii, sparam_file in enumerate(sparam_file_list):
    file_name = str(get_file(f'data/channel_sparam/{sparam_file}'))
    t, imp = s4p_to_impulse(file_name, 0.1e-12, 20e-9, zs=50, zl=50)

    im_idx = np.argmax(imp)
    t_max = t[im_idx]

    chan = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=200000,
                       s4p=file_name, zs=50, zl=50)

    _, pulse = chan.get_pulse_resp(f_sig=16e9, resp_depth=350, t_delay=0)
    #Try to center the sample!
    am_idx = np.argmax(pulse)
    shift_delay = (am_idx*625 - im_idx)*0.1e-12
    _, pulse = chan.get_pulse_resp(f_sig=16e9, resp_depth=350, t_delay=-shift_delay)

    #Calculate the centered sample time
    am_idx = np.argmax(pulse)
    st = np.array(range(0,len(pulse)))/16e9
    st_max = st[am_idx]

    #Calculate the first N bins around the cursor that contain the majority (95%) of the energy
    sqr_pls     = np.multiply(pulse, pulse)
    total_energy = np.dot(pulse, pulse)

    pre_idx  = 0
    post_idx = 0

    finished = False

    cur_pos = am_idx

    partial_energy = sqr_pls[cur_pos]
    while not finished:
        next_pst_ener = sqr_pls[cur_pos+post_idx+1]
        if pre_idx+1 <= cur_pos:
            next_pre_ener = sqr_pls[cur_pos-pre_idx-1]
            if next_pst_ener >= next_pre_ener:
                post_idx += 1
                partial_energy = partial_energy + next_pst_ener
            else:
                pre_idx  += 1
                partial_energy = partial_energy + next_pre_ener
        else:
            post_idx += 1
            partial_energy = partial_energy + next_pst_ener
        finished = partial_energy >= 0.80*total_energy

    print(pre_idx, post_idx, partial_energy/total_energy)
    name = sparam_file.split('.')[0]

    hdl = plt.plot((st - st_max)*1e9 + 2*ii, pulse, label=f'{name} - % of Energy: {partial_energy/total_energy*100 : .1f}')
    color = hdl[0].get_color()
    print(color)
    plt.stem((st[(cur_pos-pre_idx):(cur_pos+post_idx+1)] - st_max)*1e9 + 2*ii, pulse[(cur_pos-pre_idx):(cur_pos+post_idx+1)], markerfmt='ko', linefmt=color)

plt.legend(prop={'size' : 36})
plt.xlim((-2.5, 12))
plt.xlabel('time (ns)', fontdict={'fontsize':32})
plt.title('Impulse Response for Five Channels, with 99% Energy Samples', fontdict={'fontsize':32})
plt.show()