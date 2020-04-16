import numpy as np
from dragonphy import Channel, DelayChannel, StaticQuantizer
from dragonphy.channel import calculate_channel_loss

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
    initial_timing = 5.8e-9
    current_timing = 0
    response_depth = 256
    num_iterations = 50000
    adc_bits       = 16
    cdr_bits       = 16

    cdr = Cdr()
    adc = StaticQuantizer(width=adc_bits, full_scale=1.0)


    chan = DelayChannel(
                            channel_type='arctan', sampl_rate=1e9, resp_depth=response_depth, tau=3e-9, t_delay=initial_timing
    )

    time, pulse_resp = chan.get_pulse_resp()

    plt.plot(time, pulse_resp)
    plt.stem(time, adc(pulse_resp)/(2**(adc_bits-1.0)), use_line_collection=True, linefmt='r-')
    plt.show()



    for ii in range(10):
        chan.adjust_delay(initial_timing + 0.05e-9 * ii)
        time, pulse_resp = chan.get_pulse_resp(t_delay=initial_timing + 0.05e-9 * ii)
        plt.stem(time, pulse_resp, use_line_collection=True)
        print(time[0:5])
    plt.show()



    timing_history = np.zeros((num_iterations,1))
    adjust_history = np.zeros((num_iterations,1))
    error_history  = np.zeros((num_iterations,1))
    mean_history   = np.zeros((num_iterations,1))


    for ii in range(num_iterations):
        data = np.random.randint(2, size=(256,))*2-1
        code = adc(chan.compute_output(data))[:-response_depth+2]*1.0

        cdr_estimate  = cdr.calculate_timing_error(code)
        int_and_dump  = np.sum(cdr_estimate) / (2**(adc_bits-1)) * 0.5
        current_timing -= int_and_dump
        mean_history[ii] = np.sum(code) / 16.0

        timing_history[ii] = int(current_timing)*0.8e-12
        adjust_history[ii] = int_and_dump

        chan.adjust_delay(initial_timing + int(current_timing)*0.8e-12)

        __, pulse_resp = chan.get_pulse_resp()
        cursor_position = np.where(pulse_resp == np.amax(pulse_resp))[0]
        error_history[ii]  = (pulse_resp[cursor_position+1] - pulse_resp[cursor_position-1])/(pulse_resp[cursor_position])


    plt.plot(timing_history/0.8e-12)
    plt.show()

    plt.plot(20*np.log10(np.abs(adjust_history)))


    #plt.plot(error_history )
    #plt.show()

    plt.plot(20*np.log10(np.abs(error_history)))
    plt.show()

    #plt.plot(adjust_history/np.max(np.abs(adjust_history)))
    #plt.plot(mean_history/np.max(np.abs(mean_history)))
    #plt.show()

    time, pulse_resp = chan.get_pulse_resp()

    plt.plot(time, pulse_resp)
    plt.show()