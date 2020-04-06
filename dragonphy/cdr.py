import numpy as np
from dragonphy.channel import *

import matplotlib.pyplot as plt

class Cdr:
    def __init__(self, cdr_type='sign_mm'):
        self.cdr_timing_error[cdr_type](self)

    def cal_mm_timing_error(self, data):
        sign_data = np.where(data > 0, 1, -1)
        timing_errors = np.multiply(sign_data[2:] - sign_data[:-2], data[1:-1])
        return timing_errors


    def cal_perfect_mm_timing_error(self, data, bits):
        timing_errors = np.multiply(bits[2:] - bits[:-2], data[1:-1])
        return timing_errors

    def set_mm_timing_error(self):
        self.calculate_timing_error = self.cal_mm_timing_error

    def set_pmm_timing_error(self):
        self.calculate_timing_error = self.cal_perfect_mm_timing_error

    cdr_timing_error = { 'sign_mm' : set_mm_timing_error, 'perf_mm' : set_pmm_timing_error}

if __name__ == "__main__":
    cdr = Cdr()


    #chan = JitterPulseChannel(
    #                            JitterModel(jitter_type='RJ+DJ', rj_mean=0.1, rj_std=0, dj_amp=1, dj_mean=0),
    #                            channel_type='dielectric1', shift_sampling_point=0, tau=0.0087, sampl_rate=100, resp_depth=12500
    #                        )

    chan = PulseChannel(
                            channel_type='dielectric1', shift_sampling_point=0, tau=0.0087, sampl_rate=100, resp_depth=12500
                        )

    result1 = chan.pulse_response/chan.sampl_rate
    time1   = chan.real_time(len(chan.pulse_response)/chan.osr)


    training_rate = [0.5, 0.5, 0.25, 0.25, 0.125, 0.0625, 0.125, 0.0625]
    tr_pos = -1

    data = chan(np.random.randint(2, size=(16,))*2-1)

    sampling_points = []

    new_sampling_point = -sum(cdr.calculate_timing_error(data))/10

    for ii in range(800):
        if ii % 100 == 0:
            tr_pos += 1

        data = chan(np.random.randint(2, size=(64,))*2-1)

        chan.move_sampl_pos(new_sampling_point)
        te = sum(cdr.calculate_timing_error(data))/2
        new_sampling_point -= te*training_rate[tr_pos]
        sampling_points += [new_sampling_point]



    plt.plot(sampling_points)
    plt.show()

    result2 = chan(np.array([0, 1,0,0,0,0,0]))
    time2 = chan.sampled_time

    plt.plot(time2, result2)
    chan.move_sampl_pos(0)
    result3 = chan(np.array([0, 1,0,0,0,0,0]))
    time3 = chan.sampled_time
    plt.plot(time3, result3)
    plt.plot(time1 + 1, result1)
    plt.show()
