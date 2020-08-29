#!/usr/bin/env python3

# general imports
from pathlib import Path

# AHA imports
import magma as m
import fault

# DragonPHY imports
from dragonphy import get_deps_cpu_sim

THIS_DIR = Path(__file__).resolve().parent
BUILD_DIR = THIS_DIR / 'build'

# declare circuit
class dut(m.Circuit):
    name = 'test'
    io = m.IO(
        clk_a=m.BitIn,
        rst_a=m.BitIn,
        out_a=m.BitOut,
        clk_b=m.BitIn,
        rst_b=m.BitIn,
        out_b=m.Out(m.Bits[16])
    )

# create the tester
t = fault.Tester(dut)

def step(*clks):
    for clk in clks:
        t.poke(clk, 1)
    t.delay(1e-9)
    for clk in clks:
        t.poke(clk, 0)
    t.delay(1e-9)

def step_a():
    step(dut.clk_a)

def step_b():
    step(dut.clk_b)

def step_both():
    step(dut.clk_a, dut.clk_b)

# initialize
t.zero_inputs()
t.delay(1e-9)
t.poke(dut.rst_a, 1)
t.poke(dut.rst_b, 1)
step_both()

# clear reset
t.poke(dut.rst_a, 0)
t.poke(dut.rst_b, 0)
step_both()

# read out bits from "a"
hist_a = []
for _ in range(32*16):
    hist_a.append(t.get_value(dut.out_a))
    step_a()

# read out bits from "b"
hist_b = []
for _ in range(32):
    hist_b.append(t.get_value(dut.out_b))
    step_b()

# run the simulation
ext_srcs = get_deps_cpu_sim(impl_file=THIS_DIR / 'test.sv')
t.compile_and_run(
    target='system-verilog',
    directory=BUILD_DIR,
    simulator='iverilog',
    ext_srcs=ext_srcs,
    ext_model_file=True,
    disp_type='realtime',
    dump_waveforms=True
)

# extract values
hist_a = [elem.value for elem in hist_a]
hist_b = [elem.value for elem in hist_b]

# post-process hist_b so that it can be directly compared with hist_a
hist_b_post = []
for elem in hist_b:
    bin_str = f'{elem:016b}'
    bin_str = bin_str[::-1]
    bin_vals = [int(bit) for bit in bin_str]
    hist_b_post += bin_vals

assert hist_a == hist_b_post, 'Data mismatch.'