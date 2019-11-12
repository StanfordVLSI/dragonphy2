import numpy as np
import matplotlib.pyplot as plt
from butterphy import read_ti_adc

def sinusx(input_, f, n):
    # Input condition
    # input_ is the input sinusoidal waveform
    # f is the actual frequency (Fin/Fs)
    # n must be integer multiples of the period

    # Make ideal sine and cosine sequence
    sinx = np.sin(2 * np.pi * f * np.arange(n))
    cosx = np.cos(2 * np.pi * f * np.arange(n))

    # Matching the number of input sequence
    input_ = input_[:n]

    # Make Fourier series coefficient
    a0 = np.sum(input_) / n
    a1 = 2 * sinx * input_
    a = np.sum(a1) / n
    b1 = 2 * cosx * input_
    b = np.sum(b1) / n

    # Synthesize first order wave from fourier series with first term
    return a0 + a * sinx + b * cosx

class AdcAcChecker:
    def __init__(self, Nti=16, Nadc=8, Fsample=16e9, Fin=161e6, ENOB_min=4.5, SNDR_min=29, SFDR_min=34,
                 use_channels=None, suffix=None):

        self.Nti = Nti
        self.Nadc = Nadc
        self.Fsample = Fsample
        self.Fin = Fin
        self.ENOB_min = ENOB_min
        self.SNDR_min = SNDR_min
        self.SFDR_min = SFDR_min
        self.use_channels = use_channels
        self.suffix = suffix

        self.get_samples()
        self.extract_performance()

    def process_samples(self):
        minimum_value = min([abs(sample) for sample in self.samples])
        self.samples = [sample-256-minimum_value if sample > 255 else -sample+minimum_value for sample in self.samples]

    def read_ti_adc(self):
        return read_ti_adc(filename=self.file_name('ti_adc','txt'), use_channels=self.use_channels)

    def get_samples(self):
        # reads in samples and trims to an integer number of periods of the input sine wave
        Fcommon = np.gcd(int(self.Fsample), int(self.Fin))
        Nrepeat = int(self.Fsample) // Fcommon
        print(f'Input stimulus repeats every {Nrepeat} cycles.')

        samples = self.read_ti_adc()
        Nsamples = (len(samples)//Nrepeat)*Nrepeat
        print(f'Will use the first {Nsamples} samples recorded.')

        assert Nsamples >= 1, 'Not enough data recorded.'
        self.samples = samples[:Nsamples]

    def extract_performance(self):
        # make a copy of the input samples
        input_ = self.samples.copy()

        # remove DC offset
        input_ -= np.mean(input_)

        # extract signal and noise
        ywindow = np.hanning(len(input_))
        ysignal = len(input_) / np.sum(ywindow) * sinusx(input_ * ywindow, self.Fin / self.Fsample, len(input_))
        ynoise = input_ - ysignal

        # compute signal power
        Psignal = np.sum(np.abs(np.fft.fft(ysignal * ywindow)) ** 2)

        # compute noise power
        Pnoise = np.sum(np.abs(np.fft.fft(ynoise * ywindow)) ** 2)

        # compute SNDR
        self.SNDR = 10 * np.log10(Psignal / Pnoise)  # dB translation for power

        # compute ENOB
        self.Enob = (self.SNDR - 1.76) / 6.02

        # compute power spectrum of signal and noise
        self.Y_dB = 20 * np.log10(abs(np.fft.fft(input_ * ywindow)))
        self.Noise_dB = 20 * np.log10(abs(np.fft.fft(ynoise * ywindow)))

        # Calculate SFDR (spurious free dynamic range)
        self.SFDR = np.max(self.Y_dB) - np.max(self.Noise_dB)

    def state_performance(self):
        print(f'Nsamples = {len(self.samples)}')
        print(f'ENOB = {self.Enob}')
        print(f'SNDR = {self.SNDR} dB')
        print(f'SFDR = {self.SFDR} dB')

    def check_performance(self):
        print(f'Nsamples = {len(self.samples)}')
        print(f'ENOB = {self.Enob}')
        print(f'SNDR = {self.SNDR} dB')
        print(f'SFDR = {self.SFDR} dB')

        # check
        assert self.Enob > self.ENOB_min, f'ENOB is too low (min allowed: {self.ENOB_min}).'
        assert self.SNDR > self.SNDR_min, f'SNDR is too low (min allowed: {self.SNDR_min}).'
        assert self.SFDR > self.SFDR_min, f'SFDR is too low (min allowed: {self.SFDR_min}).'

    def plot_tran(self, Nper=1, extension='eps'):
        # make a copy of the input samples
        input_ = self.samples.copy()

        # trim to just the first few periods
        num = min(int(round((Nper+2) * self.Fsample / self.Fin)), len(input_))
        input_ = input_[:num]

        # plot
        fig = plt.figure()
        plt.plot(np.arange(num) / self.Fsample * 1e9, input_)
        plt.xlabel('Time (ns)')
        plt.ylabel('ADC code')

        # display
        fig.savefig(self.file_name('tran', extension))
        plt.cla()
        plt.clf()

    def plot_hist(self, extension='eps'):
        # make a copy of the input samples
        input_ = self.samples.copy()

        # plot histogram
        # note that the last bin is (1<<(self.Nadc-1))-1, since range() does not include the stop value
        fig = plt.figure()
        plt.hist(input_, list(range(-(1<<(self.Nadc-1)), (1<<(self.Nadc-1)))))
        plt.xlabel('ADC code')
        plt.ylabel('Frequency')

        # display
        fig.savefig(self.file_name('hist', extension))
        plt.cla()
        plt.clf()

    def plot_power(self, extension='eps'):
        # make a copy of the input samples
        input_ = self.samples.copy()

        # remove offset
        input_ -= np.mean(input_)

        # create window function
        window = np.hanning(len(input_))

        # compute power spectrum
        y_dB = 20 * np.log10(abs(np.fft.fft(input_ * window)))

        # trim to just the first half
        y_dB = y_dB[:len(y_dB) // 2]

        # compute associated frequencies
        freq = np.linspace(0, self.Fsample / 2, len(y_dB))

        # plot
        fig = plt.figure()
        plt.semilogx(freq * 1e-6, y_dB - np.max(y_dB), 'k')
        plt.xlabel('Frequency [MHz]')
        plt.ylabel('FFT [dB]')

        # save result
        fig.savefig(self.file_name('power', extension))
        plt.cla()
        plt.clf()

    def file_name(self, prefix, extension):
        if self.suffix is None:
            return f'{prefix}.{extension}'
        else:
            return f'{prefix}_{self.suffix}.{extension}'

