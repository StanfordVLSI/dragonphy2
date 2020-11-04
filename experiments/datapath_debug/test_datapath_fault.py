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

system_values       = Configuration('system', path='/sim/zamyers/dragonphy2/config' )
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
if simulator_name is None:
    if shutil.which('iverilog'):
        simulator_name = 'iverilog'
    else:
        simulator_name = 'ncsim'

# declare circuit
class dut(m.Circuit):
    name = 'datapath∂'
    io = m.IO(
        clk                 = m.ClockIn,
        rstb                = m.BitIn,
        adc_codes           = m.In(m.Array(m.Bits[constant_params['code_precision']], constant_params['channel_width'])),
        estimated_bits_out  = m.In(m.Array(m.Bits[ffe_params['output_precision']], constant_params['channel_width'])),
        sliced_bits_out     = m.In(m.Array(m.Bits[1],   constant_params['channel_width'])),
        est_codes_out       = m.In(m.Array(m.Bits[constant_params['code_precision']], constant_params['channel_width'])),
        est_errors_out      = m.In(m.Array(m.Bits[error_params['est_error_precision']], constant_params['channel_width'])),
        sd_flags            = m.In(m.Array(m.Bits[2], constant_params['channel_width']))
    )

# create tester
t = fault.Tester(dut, dut.clk)

# initialize with the right equation
t.zero_inputs()

# run the test
ext_srcs = get_deps_cpu_sim(impl_file=THIS_DIR / 'datapath.sv')

t.compile_and_run(
    target='system-verilog',
    simulator=simulator_name,
    ext_srcs=ext_srcs,
    parameters=parameters,
    ext_model_file=True,
    disp_type='realtime',
    dump_waveforms=dump_waveforms,
    directory=BUILD_DIR,
    num_cycles=1e12
)

