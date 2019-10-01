from butterphy import read_ti_adc, read_rx_input

import numpy as np
import matplotlib.pyplot as plt
from sklearn import linear_model

class AdcModel:
    def __init__(self, x, y):
        self.x = x
        self.y = y

        self.compute_regr()

    def compute_regr(self):
        self.regr = linear_model.LinearRegression()
        self.regr.fit(self.x[:, np.newaxis], self.y)

    @property
    def hist_dnl(self):
        signed = True
        data   = self.y

        bins_ = int(max(data) - min(data))
        range_ = (min(data), max(data)) if signed else (0, 2**(N-1)-1) #In our case, the sign is independent of the value 

        hist_val, bin_edges = np.histogram(data, bins=bins_, range=range_, density=False)
        hist_val = hist_val[1:-1]

        average_count = sum(hist_val)/(1.0*len(hist_val))
        hist_val = hist_val/average_count - 1
        return hist_val

    @property
    def hist_inl_graph(self):
        _dnl = self.hist_dnl
        _inl = np.zeros(len(_dnl)+1)
        for jj in range(1,len(_dnl)+1,1):
                _inl[jj] += _inl[jj-1] + _dnl[jj-1]
        return _inl

    @property
    def hist_inl(self):
        return np.max(np.abs(self.hist_inl_graph))
    

    @property
    def inl_graph(self):
        y_fit = self.regr.predict(self.x[:, np.newaxis])
        return  y_fit - self.y 

    @property
    def inl(self):
        return np.max(np.abs(self.inl_graph))

    @property
    def offset(self):
        return self.regr.intercept_

    @property
    def gain(self):
        return self.regr.coef_[0]

class AdcChecker:
    def __init__(self, inl_limit=11, offset_limit=3, nominal_gain=256/0.8, rel_gain_deviation=0.15, use_channels=None,
                 suffix=None):
        self.inl_limit = inl_limit
        self.offset_limit = offset_limit
        self.nominal_gain = nominal_gain
        self.rel_gain_deviation = rel_gain_deviation
        self.suffix = suffix
        self.use_channels = use_channels

    def get_tf(self):
        # read RX input voltages
        x = np.array(read_rx_input(self.file_name('rx_input', 'txt')), dtype=float)

        # read ADC outputs
        y = np.array(read_ti_adc(self.file_name('ti_adc', 'txt'), self.use_channels), dtype=float)

        # make sure that length of y is an integer multiple of length of x
        assert len(y) % len(x) == 0, "Number of ADC codes must be an integer multiple of the number of input samples."

        # repeat input as necessary
        num_repeat = len(y) // len(x)
        x = np.repeat(x, num_repeat)

        # make sure the lengths match
        assert len(x) == len(y), 'Input and outputs lengths should match at this point'

        return x, y

    def get_model(self):
        x, y = self.get_tf()
        return AdcModel(x=x, y=y)

    def plot(self, extension='eps'):
        x, y = self.get_tf()

        plt.plot(x, y, '*')
        plt.xlabel('Differential input voltage')
        plt.ylabel('ADC Code')

        plt.savefig(self.file_name('dc', extension))

        plt.cla()
        plt.clf()

    def check(self):
        model = self.get_model()

        # INL
        inl = model.hist_inl
        assert inl <= self.inl_limit, f'INL out of spec: {inl}.'
        print(f'INL OK: {inl}')

        # offset
        offset = model.offset
        assert -self.offset_limit <= offset <= +self.offset_limit, f'Offset out of spec: {offset}.'
        print(f'Offset OK: {offset}')

        # gain
        gain = model.gain

        # compute gain bounds (since gain may be signed)
        gain_lim_a = self.nominal_gain * (1 - self.rel_gain_deviation)
        gain_lim_b = self.nominal_gain * (1 + self.rel_gain_deviation)
        gain_min = min(gain_lim_a, gain_lim_b)
        gain_max = max(gain_lim_a, gain_lim_b)

        assert gain_min <= gain <= gain_max, f'Gain out of spec: {gain} LSB/Volt.'
        print(f'Gain OK: {gain} LSB/Volt.')

    def file_name(self, prefix, extension):
        if self.suffix is None:
            return f'{prefix}.{extension}'
        else:
            return f'{prefix}_{self.suffix}.{extension}'
