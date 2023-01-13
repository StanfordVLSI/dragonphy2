from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
from matplotlib import ticker, cm
import numpy as np
from copy import copy, deepcopy
from scipy import linalg, stats
from dragonphy import *

def stringify(arr, func=str):
    return "".join([func(val) for val in arr])

def error_to_string(val):

    if val == 0:
        return "0"
    elif val < 0:
        return f'$-_{{{abs(val)}}}$'
    elif val > 0:
        return f'$+_{{{abs(val)}}}$'



def error_checker(error_signature, bits, channel, cp, seq_length, width, bitwidth=18, flip_pattern_list=[[0,0,0], [0,1,0],[1,1,0],[1,1,1]], metric=np.square):
    energies = np.zeros((width,len(flip_pattern_list)))
    #print(error_signature)
    for ii in range(width):
        #print(f'{ii} iter:')
        for (jj, flip_pattern) in enumerate(flip_pattern_list):
            error_pattern = np.array([-2*(2*bit-1) if flip > 0 else 0 for (bit, flip) in zip(bits[ii:ii+len(flip_pattern)], flip_pattern)])
            mod_error_signature = error_signature[ii:ii+seq_length] + np.convolve(error_pattern, channel[ cp - 2: cp + seq_length])[cp:cp+seq_length]
            #print('-------------')
            #print(error_pattern)
            #print(error_signature[ii:ii+seq_length])
            #print(np.convolve(error_pattern, channel[ cp - 2: cp + 3])[cp:cp+seq_length])
            #print(mod_error_signature)
            energies[ii][jj] += np.sum(metric(mod_error_signature))

            assert energies[ii][jj] < 2**18

    return energies

def flag_applicator(flags, flag_eners, width, s_width, flip_pattern_depth, flip_pattern_list=[[0,0,0], [0,1,0],[1,1,0],[1,1,1]]):
    best_red_subframe_flags = np.zeros((width*3, ))
    best_blk_subframe_flags = np.zeros((width*3, ))

    flags_ = np.zeros((48,))
    flags_[0:42] = flags

    flag_eners_ = np.ones((48,)) * 999999
    flag_eners_[0:42] = flag_eners

    for ii in range(-1,5):
        sel_red_flag_eners = np.ones((3*width,))*999999
        sel_red_flag_eners[width + s_width*(ii-1)  : width +  s_width*(ii)] = flag_eners_[width + s_width*(ii-1)  : width + s_width*(ii)]
        best_red_subframe_flags[np.argmin(sel_red_flag_eners)] = flags_[np.argmin(sel_red_flag_eners)]
        sel_blk_flag_eners = np.ones((3*width,))*999999
        sel_blk_flag_eners[width + s_width*(ii-2) + int(s_width/2) : width + s_width*(ii-1) + int(s_width/2) ] = flag_eners_[width + s_width*(ii-2) + int(s_width/2)   : width + s_width*(ii-1) + int(s_width/2) ]
        best_blk_subframe_flags[np.argmin(sel_blk_flag_eners)] = flags_[np.argmin(sel_blk_flag_eners)]

    
    #print(best_blk_subframe_flags)
    #print(best_red_subframe_flags)
    selected_flags = np.where(best_blk_subframe_flags == best_red_subframe_flags, best_red_subframe_flags, 0)
    #print(selected_flags)
    unskewed_flip_bits = np.zeros((3*width,))
    for ii in range(2*width):
        for jj in range(flip_pattern_depth):
            unskewed_flip_bits[width-flip_pattern_depth+1+ii+jj] = unskewed_flip_bits[width-flip_pattern_depth+1+ii+jj] or flip_pattern_list[int(selected_flags[width+ii-flip_pattern_depth+1])][jj]
    return unskewed_flip_bits

def wider_flag_applicator(flags, flag_eners, width, s_width, flip_pattern_depth, flip_pattern_list=[[0,0,0], [0,1,0],[1,1,0],[1,1,1]]):
    best_red_subframe_flags = np.zeros((width*3, ))
    best_blk_subframe_flags = np.zeros((width*3, ))

    flags_ = np.zeros((48,))
    flags_[0:42] = flags

    flag_eners_ = np.ones((48,)) * 999999
    flag_eners_[0:42] = flag_eners

    for ii in range(3):
        sel_red_flag_eners = np.ones((3*width,))*999999
        sel_red_flag_eners[width*(ii) : width*(ii+1)] = flag_eners_[width*(ii) : width*(ii+1)]
        best_red_subframe_flags[np.argmin(sel_red_flag_eners)] = flags_[np.argmin(sel_red_flag_eners)]

    for ii in range(2):
        sel_blk_flag_eners = np.ones((3*width,))*999999
        sel_blk_flag_eners[width*(ii)+s_width : width*(ii+1)+s_width] = flag_eners_[width*(ii)+s_width : width*(ii+1)+s_width]
        best_blk_subframe_flags[np.argmin(sel_blk_flag_eners)] = flags_[np.argmin(sel_blk_flag_eners)]

    
    #print(best_blk_subframe_flags)
    #print(best_red_subframe_flags)
    selected_flags = np.where(best_blk_subframe_flags == best_red_subframe_flags, best_red_subframe_flags, 0)
    #print(selected_flags)
    unskewed_flip_bits = np.zeros((3*width,))
    for ii in range(2*width):
        for jj in range(flip_pattern_depth):
            unskewed_flip_bits[width-flip_pattern_depth+1+ii+jj] = unskewed_flip_bits[width-flip_pattern_depth+1+ii+jj] or flip_pattern_list[int(selected_flags[width+ii-flip_pattern_depth+1])][jj]
    return unskewed_flip_bits
