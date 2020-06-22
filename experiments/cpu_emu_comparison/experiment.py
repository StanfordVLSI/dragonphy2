from pathlib import Path
from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

deps = get_deps_cpu_sim(
    impl_file=THIS_DIR / 'test.sv',
    override={
        'snh': THIS_DIR / 'snh.sv',
        'V2T_clock_gen_S2D': THIS_DIR / 'V2T_clock_gen_S2D.sv',
        'stochastic_adc_PR': THIS_DIR / 'stochastic_adc_PR.sv',
        'phase_interpolator': THIS_DIR / 'phase_interpolator.sv',
        'input_divider': THIS_DIR / 'input_divider.sv',
        'output_buffer': THIS_DIR / 'output_buffer.sv',
        'mdll_r1_top': 'chip_stubs'
    }
)
print(deps)

DragonTester(
    ext_srcs=deps,
    directory=BUILD_DIR,
    dump_waveforms=False
).run()