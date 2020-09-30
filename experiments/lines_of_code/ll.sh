#!/bin/sh
TOP=`realpath ../..`
FPGA_MODELS="$TOP/dragonphy/fpga_models"
CFG="$TOP/config/fpga"
BUILD="$TOP/tests/fpga_system_tests/emu"
VLOG="$TOP/vlog/fpga_models"
cloc "$CFG/chan.yml" \
     "$FPGA_MODELS/chan_core.py" \
     "$CFG/clk_delay.yml" \
     "$FPGA_MODELS/clk_delay_core.py" \
     "$CFG/osc_model.yml" \
     "$FPGA_MODELS/osc_model_core.py" \
     "$CFG/rx_adc.yml" \
     "$FPGA_MODELS/rx_adc_core.py" \
     "$CFG/tx.yml" \
     "$FPGA_MODELS/tx_core.py" \
     "$TOP/inc/fpga/iotype.sv" \
     $BUILD/*.c "$BUILD/clks.yaml" \
     "$BUILD/simctrl.pre.yaml" $BUILD/*.sv $BUILD/*.py \
     "$VLOG/analog_core/input_divider.sv" \
     "$VLOG/analog_core/phase_interpolator.sv" \
     "$VLOG/analog_core/snh.sv" \
     "$VLOG/analog_core/stochastic_adc_PR.sv" \
     "$VLOG/analog_core/V2T_clock_gen_S2D.sv" \
     $VLOG/buffers/*.sv \
     "$VLOG/other/my_edgedet.sv"

# run on: a6e3d2aab2616182b4816be51e69a8e5b2c533e3

# github.com/AlDanial/cloc v 1.74  T=0.03 s (970.4 files/s, 95372.7 lines/s)
# -----------------------------------------------------------------------------------
# Language                         files          blank        comment           code
# -----------------------------------------------------------------------------------
# Verilog-SystemVerilog               11            144            123            652
# Python                               6            202            173            592
# C                                    1             42             40            265
# YAML                                 7              1             25            198
# -----------------------------------------------------------------------------------
# SUM:                                25            389            361           1707
# -----------------------------------------------------------------------------------