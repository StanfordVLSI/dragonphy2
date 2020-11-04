# general imports
import shutil
from pathlib import Path

# AHA imports
import fault
import magma as m

# DragonPHY-specific imports
from dragonphy import get_deps_cpu_sim, Configuration

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


# set defaults
simulator_name = 'ncsim'

# declare circuit
class dut(m.Circuit):
    name = 'datapath'
    io = m.IO(
        clk                 = m.ClockIn,
        rstb                = m.BitIn,
        unsigned_adc_codes           = m.In(m.Array[(constant_params['channel_width'], m.SInt[constant_params['code_precision']])]),
        unsigned_estimated_bits_out  = m.In(m.Array[(constant_params['channel_width'], m.SInt[ffe_params['output_precision']])]),
        sliced_bits_out     = m.In(m.Array[(constant_params['channel_width'], m.SInt[1])]),
        unsigned_est_codes_out       = m.In(m.Array[(constant_params['channel_width'], m.SInt[constant_params['code_precision']])]),
        unsigned_est_errors_out      = m.In(m.Array[(constant_params['channel_width'], m.SInt[error_params['est_error_precision']])]),
        sd_flags            = m.In(m.Array[(constant_params['channel_width'], m.SInt[2])])
    )



# create tester
t = fault.Tester(dut, dut.clk)


# initialize with the right equation
t.zero_inputs()
t.step(2)
t.poke(dut.rstb, 1)
t.poke(dut.unsigned_adc_codes[0], -5)

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

