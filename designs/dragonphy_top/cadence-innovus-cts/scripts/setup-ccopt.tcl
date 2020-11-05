#=========================================================================
# setup-ccopt.tcl
#=========================================================================
# Author : Christopher Torng
# Date   : March 26, 2018

# Allow clock gate cloning and merging

set_ccopt_property clone_clock_gates true
set_ccopt_property clone_clock_logic true
set_ccopt_property ccopt_merge_clock_gates true
set_ccopt_property ccopt_merge_clock_logic true
set_ccopt_property cts_merge_clock_gates true
set_ccopt_property cts_merge_clock_logic true

set_ccopt_property sink_type stop -pin iacore/ext_clk

set_ccopt_property -pin iacore/ext_clk  capacitance_override  0.004767

set_ccopt_property -pin itx/indiv/in -delay_corner delay_default capacitance_override 0.1
set_ccopt_property -pin itx/iPI_0__iPI/clk_encoder -delay_corner delay_default capacitance_override 0.1   
set_ccopt_property -pin itx/iPI_1__iPI/clk_encoder -delay_corner delay_default capacitance_override 0.1   
set_ccopt_property -pin itx/iPI_2__iPI/clk_encoder -delay_corner delay_default capacitance_override 0.1   
set_ccopt_property -pin itx/iPI_3__iPI/clk_encoder -delay_corner delay_default capacitance_override 0.1   

set_ccopt_property -pin itx/indiv/in sink_type stop
set_ccopt_property -pin itx/iPI_0__iPI/clk_encoder sink_type stop
set_ccopt_property -pin itx/iPI_1__iPI/clk_encoder sink_type stop
set_ccopt_property -pin itx/iPI_2__iPI/clk_encoder sink_type stop
set_ccopt_property -pin itx/iPI_3__iPI/clk_encoder sink_type stop

# Useful skew
#
# setOptMode -usefulSkew [ true | false ]
#
# - This enables/disables all other -usefulSkew* options (e.g.,
#   -usefulSkewCCOpt, -usefulSkewPostRoute, and -usefulSkewPreCTS)
#
# setOptMode -usefulSkewCCOpt [ none | standard | medium | extreme ]
#
# - If setOptMode -usefulSkew is false, then this entire option is ignored
#
# - Connection to "set_ccopt_effort" .. these are the same:
#   - "set_ccopt_effort -low"    and "setOptMode -usefulSkewCCOpt standard"
#   - "set_ccopt_effort -medium" and "setOptMode -usefulSkewCCOpt medium"
#   - "set_ccopt_effort -high"   and "setOptMode -usefulSkewCCOpt extreme"
#

puts "Info: Useful skew = $::env(useful_skew)"

if { $::env(useful_skew) } {
  setOptMode -usefulSkew      true
  setOptMode -usefulSkewCCOpt extreme
} else {
  setOptMode -usefulSkew      false
}


