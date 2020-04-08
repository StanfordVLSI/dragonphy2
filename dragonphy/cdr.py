import numpy as np
from dragonphy import Channel

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

    chan = Channel(
                            channel_type='arctan', sampl_rate=1e9, resp_depth=50, tau=1.0e-9, t_delay=8.1e-9
                            )

    time, pulse_resp = chan.get_pulse_resp()

    data = np.random.randint(2, size=(50000,))*2-1
    code = chan.compute_output(data)[8:-50+10]

#    plt.stem(data, use_line_collection=True)
#    plt.plot(code, 'r')
#    plt.show()


    cdr_partial_estimates = cdr.calculate_timing_error(code)
    cdr_bit_estimates     = cdr.cal_perfect_mm_timing_error(code, data)

    plt.stem(time, pulse_resp, use_line_collection=True)
    plt.show()

#    plt.plot(code[1:-1])
#    plt.stem(cdr_partial_estimates, use_line_collection=True)
#    plt.stem(cdr_bit_estimates, use_line_collection=True, linefmt='r-')
#    plt.show()

    #Average the points together 
    print(np.sum(cdr_partial_estimates)/50000)
    print(np.sum(cdr_bit_estimates)/50000)
    print(pulse_resp[7] - pulse_resp[9])

