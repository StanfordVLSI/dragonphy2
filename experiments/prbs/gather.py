#!/usr/bin/env python3

# general imports
from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np
# AHA imports
import magma as m
import fault

# DragonPHY imports
from dragonphy import get_deps_cpu_sim

THIS_DIR = Path(__file__).resolve().parent
BUILD_DIR = THIS_DIR / 'build'

# declare circuit
class dut(m.Circuit):
    name = 'gather'
    io = m.IO(
        clk=m.ClockIn,
        rst=m.BitIn,
        out=m.BitOut
    )

# create the tester
t = fault.Tester(dut, dut.clk)

# initialize
t.zero_inputs()
t.poke(dut.rst, 1)
t.step(2)

# clear reset
t.poke(dut.rst, 0)
t.step(2)

# read out bits
hist = []
for _ in range(32*32):
    hist.append(t.get_value(dut.out))
    t.step(2)

# run the simulation
ext_srcs = get_deps_cpu_sim(impl_file=THIS_DIR / 'gather.sv')
t.compile_and_run(
    target='system-verilog',
    directory=BUILD_DIR,
    simulator='iverilog',
    ext_srcs=ext_srcs,
    ext_model_file=True,
    disp_type='realtime',
    dump_waveforms=True
)

# print result
hist = [elem.value for elem in hist]



inits = [list() for _ in range(32)]
for k, elem in enumerate(hist):
    inits[k%32].append(elem)
for k, init in enumerate(inits):
    assert len(init) == 32
    bin_str = ''.join(str(elem) for elem in init)
    bin_val = int(bin_str, 2)
    print(f"32'h{bin_val:08x}")