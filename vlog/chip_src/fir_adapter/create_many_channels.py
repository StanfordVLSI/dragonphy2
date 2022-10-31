from dragonphy import *
import numpy as np 
import matplotlib.pyplot as plt


real_channels = ["Case4_FM_13SI_20_T_D13_L6.s4p", 
 "peters_01_0605_B12_thru.s4p", 
 "peters_01_0605_B1_thru.s4p",
 "peters_01_0605_T20_thru.s4p",
 "TEC_Whisper42p8in_Meg6_THRU_C8C9.s4p",
 "TEC_Whisper42p8in_Nelco6_THRU_C8C9.s4p",]

def get_real_channel_pulse(s4p_file, f_sig=16e9, mm_lock_pos=12.5e-12, numel=2048, domain=[0,4e-9]):
    file_name = str(get_file(f'data/channel_sparam/{s4p_file}'))
    
    step_size = domain[1]/(numel-1)
    t, imp = s4p_to_impulse(str(file_name), step_size/100.0, 10*domain[1],  zs=50, zl=50)
    cur_pos = np.argmax(imp)
    t_delay = -t[cur_pos] + 2*1/f_sig + mm_lock_pos

    t, pulse = Channel(channel_type='s4p', sampl_rate=10e12, resp_depth=400000, s4p=file_name, zs=50, zl=50).get_pulse_resp(f_sig=f_sig, resp_depth=35, t_delay=t_delay)

    return pulse

for jj in range(len(real_channels)):
    for ii in [1, 2, 4, 8, 16]:
        pulse = get_real_channel_pulse(real_channels[jj], f_sig= ii*1e9, numel=2048, domain=[0,4e-9])
        pulse = pulse * 128 / 0.3
        out_pulse = [int(tap) for tap in pulse]/np.sum([int(tap) for tap in pulse]) * 109
        plt.plot(out_pulse)
        with open(f'chan{jj}_est_vals_{ii}G.txt', 'w') as f:
            print("\n".join([str(int(round(tap))) for tap in list(out_pulse)]), file=f)

plt.show()
