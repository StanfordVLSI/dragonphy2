# general imports
import shutil
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from math import floor

# AHA imports
import fault
import magma as m

# DragonPHY-specific imports
from dragonphy import get_deps_cpu_sim, Configuration, Channel, Quantizer

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

system_values       = Configuration('system', path_head='/home/zamyers/dev/dragonphy2/config' )
ffe_config          = system_values['generic']['ffe']
constant_config     = system_values['generic']
comp_config         = system_values['generic']['comp']
chan_config         = system_values['generic']['channel']
error_config        = system_values['generic']['error']
detector_config     = system_values['generic']['detector']

ffe_params          = ffe_config['parameters']
constant_params     = constant_config['parameters']
comp_params         = comp_config['parameters']
chan_params         = chan_config['parameters']
error_params        = error_config['parameters']
detector_params     = detector_config['parameters']

class BankIterator:
    def __init__(self, bank):
        self._values = bank.values
        self._width  = bank.width
        self._max_idx = bank.max_idx
        self._idx  = 0

    def __next__(self):
        if self._idx < self._max_idx:
            result = self._values[self._idx*self._width:(self._idx+1)*self._width]
            self._idx += 1
            return result
        raise StopIteration

class Bank:
    def __init__(self, values=None, width=None ):
        self.values     = values if any(values) else 0 
        self.width      = width if width else 1
        self.max_idx    = floor(len(values)/self.width)
        self._idx = 0
    def __getitem__(self, idx):
        if idx >= self.max_idx:
            return None
        else:
            return self.values[idx*self.width:(idx+1)*self.width]
    def __iter__(self):
        return BankIterator(self)

# set defaults
simulator_name = 'ncsim'

# declare circuit
class dut(m.Circuit):
    name = 'datapath'
    io = m.IO(
        clk                          = m.ClockIn,
        rstb                         = m.BitIn,
        unsigned_adc_codes           = m.In(m.Array[(constant_params['channel_width'], m.SInt[constant_params['code_precision']])]),
        unsigned_estimated_bits_out  = m.In(m.Array[(constant_params['channel_width'], m.SInt[ffe_params['output_precision']])]),
        sliced_bits_out              = m.In(m.Array[(constant_params['channel_width'], m.SInt[1])]),
        unsigned_est_codes_out       = m.In(m.Array[(constant_params['channel_width'], m.SInt[constant_params['code_precision']])]),
        unsigned_est_errors_out      = m.In(m.Array[(constant_params['channel_width'], m.SInt[error_params['est_error_precision']])]),
        sd_flags                     = m.In(m.Array[(constant_params['channel_width'], m.SInt[2])]),
        unsigned_weights             = m.In(m.Array[(ffe_params['length'], m.SInt[ffe_params['weight_precision']])]),
        unsigned_channel_est         = m.In(m.Array[(chan_params['est_channel_depth'], m.SInt[chan_params['est_channel_precision']])]),
        ffe_shift                    = m.In(m.Bits[ffe_params['shift_precision']]),
        unsigned_thresh              = m.In(m.Bits[comp_params['thresh_precision']]),
        channel_shift                = m.In(m.Bits[chan_params['shift_precision']]),
        align_pos                    = m.In(m.Bits[4])
    )

#Generate Data with a RC channel response
t_s = 1/(16e9)
chan = Channel(channel_type='exponent', sampl_rate=10e12, resp_depth=200000, tau=1.0e-10)
time, pulse = chan.get_pulse_resp(f_sig=16e9, resp_depth=350)
t_max = time[np.argmax(pulse)]

chan = Channel(channel_type='exponent', sampl_rate=10e12, resp_depth=200000, tau=1.0e-10)

symbols = np.random.randint(2, size=10000)*2 - 1 
data = chan.compute_output(symbols, f_sig=16e9, resp_depth=350, t_delay=-t_max + 3*t_s)

lsb = 2.0/(2**8)
quantized_data = np.clip(np.array([round(val/lsb) for val in data]), -128, 127)


#Convert parallelize serial data
parallel_data = Bank(values=quantized_data, width=16)

# create tester
t = fault.Tester(dut, dut.clk)

# initialize with the right equation
t.zero_inputs()

#
t.step(2)
t.poke(dut.rstb, 1)

for datum in parallel_data:
    for ii in range(16):
        t.poke(dut.unsigned_adc_codes[ii], int(datum[ii]))
    t.step(2)



# run the test
ext_srcs = get_deps_cpu_sim(impl_file=THIS_DIR / 'datapath.sv')

t.compile_and_run(
    target='system-verilog',
    simulator=simulator_name,
    ext_srcs=ext_srcs,
    ext_model_file=True,
    disp_type='realtime',
    dump_waveforms=True,
    directory=BUILD_DIR,
    num_cycles=1e12
)

