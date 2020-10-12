from pathlib import Path

import fault
import magma as m

from dragonphy import *

THIS_DIR = Path(__file__).parent.resolve()
BUILD_DIR = THIS_DIR / 'build'

class dut(m.Circuit):
    name = 'test'
    io = m.IO(
        rstb=m.BitIn,
        clk=m.ClockIn,
        ffe_weights=m.In(m.Array[10, m.Bits[10]]),
        channel_est=m.In(m.Array[30, m.Bits[8]]),
        adc_codes  =m.In(m.Array[16, m.Bits[8]])
    )

t = fault.Tester(dut, dut.clk)
t.zero_inputs()
t.poke(dut.rstb, 0)

for ii in range(16):
    t.poke(dut.adc_codes[ii], ii)

t.compile_and_run(
    target='system-verilog',
    simulator='ncsim',
    ext_srcs=get_deps_cpu_sim(impl_file=THIS_DIR/'test.sv'),
    disp_type='realtime',
    dump_waveforms=False,
    directory=BUILD_DIR
)
