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
for _ in range(32*32 + 4):
    hist.append(t.get_value(dut.out))
    t.step(2)

# run the simulation
ext_srcs = get_deps_cpu_sim(impl_file=THIS_DIR / 'gather.sv')
t.compile_and_run(
    target='system-verilog',
    directory=BUILD_DIR,
    simulator='xcelium',
    ext_srcs=ext_srcs,
    ext_model_file=True,
    disp_type='realtime',
    dump_waveforms=True,
    num_cycles= 20000,
)

# print result
hist = [elem.value for elem in hist]
print(hist)
print(len(hist))


early_inits = [list() for _ in range(2)]
inits = [list() for _ in range(32)]
late_inits = [list() for _ in range(2)]


for k, elem in enumerate(hist):
    if k > 1 and k < len(hist) - 2:
        inits[(k-2)%32].append(elem)

    if k < len(hist) - 4:
        if (k % 32) == 0 or (k % 32) == 1:
            early_inits[k%32].append(elem)
            print(k - 2, (k%32) - 2)
    
    if k > 4:
        if ((k-2) % 32) == 0 or ((k-2) % 32) == 1:
            late_inits[((k-2) % 32)].append(elem)
            print(k - 2, ((k-2)%32))


for init in early_inits:
    assert len(init) == 32
    bin_str = ''.join(str(elem) for elem in init)
    bin_val = int(bin_str, 2)
    print(f"32'h{bin_val:08x}")

for k, init in enumerate(inits):
    assert len(init) == 32
    bin_str = ''.join(str(elem) for elem in init)
    bin_val = int(bin_str, 2)
    print(f"32'h{bin_val:08x}")

for init in late_inits:
    assert len(init) == 32
    bin_str = ''.join(str(elem) for elem in init)
    bin_val = int(bin_str, 2)
    print(f"32'h{bin_val:08x}")