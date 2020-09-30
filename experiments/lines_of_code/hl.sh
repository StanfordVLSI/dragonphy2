#!/bin/sh
TOP=`realpath ../..`
BUILD="$TOP/tests/fpga_system_tests/emu_macro"
VLOG="$TOP/vlog/fpga_models"
cloc "$TOP/dragonphy/fpga_models/analog_slice.py" \
     "$TOP/config/fpga/analog_slice_cfg.yml" \
     "$TOP/inc/fpga/iotype.sv" \
     $BUILD/*.c "$BUILD/clks.yaml" \
     "$BUILD/simctrl.pre.yaml" $BUILD/*.sv $BUILD/*.py \
     "$VLOG/analog_core/analog_core.sv" \
     $VLOG/buffers/*.sv


# run on: a6e3d2aab2616182b4816be51e69a8e5b2c533e3

#       12 text files.
#       12 unique files.
#        0 files ignored.
#
# github.com/AlDanial/cloc v 1.74  T=0.02 s (672.0 files/s, 126007.2 lines/s)
# -----------------------------------------------------------------------------------
# Language                         files          blank        comment           code
# -----------------------------------------------------------------------------------
# Verilog-SystemVerilog                6            123             90            513
# Python                               2            140            146            449
# C                                    1             42             40            291
# YAML                                 3             14            253            149
# -----------------------------------------------------------------------------------
# SUM:                                12            319            529           1402
-----------------------------------------------------------------------------------
