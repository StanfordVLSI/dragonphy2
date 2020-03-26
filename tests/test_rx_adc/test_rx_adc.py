# general imports
import os
import pytest
from math import floor
from pathlib import Path

# AHA imports
import magma as m
import fault

# FPGA-specific imports
from svreal import get_svreal_header
from msdsl import get_msdsl_header

# DragonPHY imports
from dragonphy import get_file

BUILD_DIR = Path(__file__).resolve().parent / 'build'
SIMULATOR = 'ncsim' if 'FPGA_SERVER' not in os.environ else 'vivado'

# Timestep options
DT_WIDTH = 27
DT_EXPONENT = -46
DT_MIN = 0.0
DT_MAX = ((2**(DT_WIDTH-1))-1)*(2**DT_EXPONENT)
DT_PREC = 0.25e-12

# ADC option
N_BITS = 8
VN = -1.0
VP = +1.0

# simulator options
TCLK = 1e-6
DELTA = 0.1*TCLK

@pytest.mark.parametrize('float_real', [False, True])
def test_rx_adc(float_real):
    # declare circuit
    class dut(m.Circuit):
        name = 'test_rx_adc'
        io = m.IO(
            in_=fault.RealIn,
            in_valid=m.BitIn,
            out=m.Out(m.SInt[N_BITS]),
            clk_val=m.BitIn,
            dt_req=fault.RealOut,
            emu_clk=m.In(m.Clock),
            emu_rst=m.BitIn
        )

    # create the tester
    t = fault.Tester(dut, dut.emu_clk)

    # utility function to model the ADC response
    def adc_model(x):
        expr = ((x-VN)/(VP-VN)*((2**N_BITS)-1))-(2**(N_BITS-1))
        expr = int(floor(expr))
        if expr < -(2**(N_BITS-1)):
            expr = -(2**(N_BITS-1))
        if expr > (2**(N_BITS-1))-1:
            expr = (2**(N_BITS-1))-1
        return expr

    # utility function for easier waveform debug
    def cycle():
        t.delay((TCLK / 2) - DELTA)
        t.poke(dut.emu_clk, 0)
        t.delay(TCLK / 2)
        t.poke(dut.emu_clk, 1)
        t.delay(DELTA)

    # utility function for checking results
    def check_result(dt_req=None, out=None, abs_tol=DT_PREC):
        if dt_req is not None:
            t.expect(dut.dt_req, dt_req, abs_tol=abs_tol)
        if out is not None:
            t.expect(dut.out, out)

    # initialize
    t.poke(dut.in_, 0.0)
    t.poke(dut.in_valid, 0)
    t.poke(dut.clk_val, 0)
    t.poke(dut.emu_clk, 0)
    t.poke(dut.emu_rst, 1)

    # apply reset
    t.poke(dut.emu_clk, 1)
    t.delay(TCLK/2)
    t.poke(dut.emu_clk, 0)
    t.delay(TCLK/2)

    # check reset value
    check_result(DT_MAX, 0)

    # clear reset
    t.poke(dut.emu_rst, 0)

    # run a few cycles
    for _ in range(3):
        t.poke(dut.emu_clk, 1)
        t.delay(TCLK/2)
        t.poke(dut.emu_clk, 0)
        t.delay(TCLK/2)
    t.poke(dut.emu_clk, 1)
    t.delay(DELTA)

    # test case: output is valid immediately
    t.poke(dut.clk_val, 1)
    t.poke(dut.in_, 0.123)
    t.poke(dut.in_valid, 1)
    cycle()
    check_result(DT_MAX, adc_model(0.123))

    # check the output value is maintained when the clock goes low
    t.poke(dut.clk_val, 0)
    t.poke(dut.in_, 0.234)
    t.poke(dut.in_valid, 1)
    cycle()
    check_result(DT_MAX, adc_model(0.123))

    # test case: output takes one cycle to become valid
    t.poke(dut.clk_val, 1)
    t.poke(dut.in_, 0.345)
    t.poke(dut.in_valid, 0)
    cycle()
    check_result(DT_MIN, adc_model(0.123))
    t.poke(dut.in_, 0.456)
    t.poke(dut.in_valid, 1)
    cycle()
    check_result(DT_MAX, adc_model(0.456))

    # check the output value is maintained when the clock goes low for two cycles,
    # independent of whether the in_valid signal is high or low
    t.poke(dut.clk_val, 0)
    t.poke(dut.in_, 0.567)
    t.poke(dut.in_valid, 0)
    cycle()
    check_result(DT_MAX, adc_model(0.456))
    t.poke(dut.in_, 0.678)
    t.poke(dut.in_valid, 1)
    cycle()
    check_result(DT_MAX, adc_model(0.456))

    # test case: output takes two cycles to become valid
    t.poke(dut.clk_val, 1)
    t.poke(dut.in_, 0.789)
    t.poke(dut.in_valid, 0)
    cycle()
    check_result(DT_MIN, adc_model(0.456))
    t.poke(dut.in_, 0.890)
    t.poke(dut.in_valid, 0)
    cycle()
    check_result(DT_MIN, adc_model(0.456))
    t.poke(dut.in_, 0.901)
    t.poke(dut.in_valid, 1)
    cycle()
    check_result(DT_MAX, adc_model(0.901))

    # check the output value is maintained when the clock goes low
    t.poke(dut.clk_val, 0)
    t.poke(dut.in_, 0.012)
    t.poke(dut.in_valid, 1)
    cycle()
    check_result(DT_MAX, adc_model(0.901))

    # test case: input takes one cycle to become valid, then clk_val
    # remain high for an extra cycle after that
    t.poke(dut.clk_val, 1)
    t.poke(dut.in_, 0.123)
    t.poke(dut.in_valid, 0)
    cycle()
    check_result(DT_MIN, adc_model(0.901))
    t.poke(dut.in_, 0.234)
    t.poke(dut.in_valid, 1)
    cycle()
    check_result(DT_MAX, adc_model(0.234))
    t.poke(dut.in_, 0.345)
    t.poke(dut.in_valid, 1)
    cycle()
    check_result(DT_MAX, adc_model(0.234))

    # check the output value is maintained when the clock goes low
    t.poke(dut.clk_val, 0)
    t.poke(dut.in_, 0.456)
    t.poke(dut.in_valid, 1)
    cycle()
    check_result(DT_MAX, adc_model(0.234))

    # run through some values to exercise the transfer function
    # for this part of the test, the "in_valid" signal is left high
    test_vals = [-1.2, -1.0, -0.567, 0, +0.123, +1.0, +1.2]
    t.poke(dut.in_valid, 1)
    for test_val in test_vals:
        # set the clock value "high"
        t.poke(dut.clk_val, 1)
        t.poke(dut.in_, test_val)
        cycle()
        check_result(DT_MAX, adc_model(test_val))

        # set the clock value "low"
        t.poke(dut.clk_val, 0)
        t.poke(dut.in_, 0.0)
        cycle()
        check_result(DT_MAX, adc_model(test_val))

    # run the simulation
    defines = {
        'DT_WIDTH': DT_WIDTH,
        'DT_EXPONENT': DT_EXPONENT
    }
    if float_real:
        defines['FLOAT_REAL'] = None
    t.compile_and_run(
        target='system-verilog',
        directory=BUILD_DIR,
        simulator=SIMULATOR,
        ext_srcs=[get_file('build/fpga_models/rx_adc_core.sv'),
                  get_file('tests/test_rx_adc/test_rx_adc.sv')],
        inc_dirs=[get_svreal_header().parent, get_msdsl_header().parent],
        ext_model_file=True,
        defines=defines,
        disp_type='realtime'
    )