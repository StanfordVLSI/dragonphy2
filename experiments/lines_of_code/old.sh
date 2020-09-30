#!/bin/sh
TOP=`realpath ../../../hslink-emu`
MSEMU=$TOP/msemu
SHARED=$TOP/shared
RUN=$TOP/run
cloc $TOP/fpga $MSEMU/clocks.py $MSEMU/ctle.py \
     $MSEMU/dfe.py $MSEMU/fixed.py $MSEMU/ila.py \
     $MSEMU/lfsr.py $MSEMU/pwl.py $MSEMU/server.py \
     $MSEMU/tf.py $MSEMU/tx_ffe.py $MSEMU/verilog.py \
     $SHARED/clock.sv $SHARED/comp_async.sv \
     $SHARED/comp_sync.sv $SHARED/dut.sv $SHARED/filter.sv \
     $SHARED/lfsr.sv $SHARED/lfsr_cke.sv \
     $SHARED/my_mult_signed.sv $SHARED/my_mult_unsigned.sv \
     $SHARED/my_rom_async.sv $SHARED/my_rom_sync.sv \
     $SHARED/my_sum.sv $SHARED/pwl.sv $SHARED/rx_clock.sv \
     $SHARED/rx_dfe.sv $SHARED/time_manager.sv \
     $SHARED/tx_clock.sv $SHARED/tx_ffe.sv \
     $RUN/build.py $RUN/fpga_build.tcl \
     $RUN/program.py $RUN/program.tcl \
     $RUN/sim.tcl $RUN/sim.sv \
    --force-lang="Tcl/Tk",xdc

# run on: a99f1380c707d34ddc4554b09db50c6d24605838

# github.com/AlDanial/cloc v 1.74  T=0.05 s (798.8 files/s, 93503.1 lines/s)
# -----------------------------------------------------------------------------------
# Language                         files          blank        comment           code
# -----------------------------------------------------------------------------------
# Python                              13            549            261           1926
# Verilog-SystemVerilog               21            200            177           1084
# Tcl/Tk                               5             78             53            237
# -----------------------------------------------------------------------------------
# SUM:                                39            827            491           3247
# -----------------------------------------------------------------------------------