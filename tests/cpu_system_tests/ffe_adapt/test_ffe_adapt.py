from pathlib import Path
from dragonphy import *

import matplotlib.pyplot as plt
import numpy as np
import sys

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

def test_sim(dump_waveforms):
    #check for deps file if it doesn't exist, regenerate dependencies:
    if not (THIS_DIR / Path('.deps.txt')).is_file():
        
        #Get dependencies, write to a file
        deps = get_deps_cpu_sim(impl_file=THIS_DIR / 'test.sv')
    
        with open('.deps.txt', 'w') as f:
            for line in deps:
                print(line, file=f)

    deps = []
    with open('.deps.txt', 'r') as f:
        for line in f:
            deps += [Path(line.strip())]

    print(deps)


    DragonTester(
        ext_srcs=deps,
        directory=BUILD_DIR,
        dump_waveforms=dump_waveforms
    ).run()

def display_taps(dump_waveforms):
    channel_length = 30
    ffe_length = 10

    def read_and_plot_file(filename, length, precision):
        data_dict = {}

        for ii in range(length):
            data_dict[ii] = []

        with open(filename, 'r') as f:
            for line in f:
                tokens = line.strip().split(',')
                if len(tokens) < 2:
                    break

                if tokens[1] == '':
                    break
                data_dict[int(tokens[0])] += [int(tokens[1])]

        min_len = len(data_dict[0])
        for ii in range(1,length):
            if len(data_dict[ii]) < min_len:
                min_len = len(data_dict[ii])

        data = np.zeros((length, min_len-1))

        for ii in range(length):
            data[ii] = data_dict[ii][1:min_len]
        data = data /(2.0 ** precision)

        plt.plot(data.T)
        plt.legend(list(range(length)))
        plt.show()

        plt.plot(data.T[-1])
        plt.show()
    
    read_and_plot_file('build/chan_internal_state.txt', 30, 16)
    read_and_plot_file('build/ffe_internal_state.txt', 16, 22)

if __name__ == "__main__":
    display_taps(dump_waveforms=True)
    exit()
    test_sim(dump_waveforms=True)
