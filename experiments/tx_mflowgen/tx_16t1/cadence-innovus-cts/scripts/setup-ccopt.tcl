#=========================================================================
# setup-ccopt.tcl
#=========================================================================
# Author : Christopher Torng
# Date   : March 26, 2018

# Allow clock gate cloning and merging
for {set i 0} {$i < 2} {incr i} {
    # 2-input muxes
    for {set j 1} {$j < 5} {incr j} {
        for {set k 0} {$k < 3} {incr k} {
            set this_pin_name "hr_mux_16t4_$i/iMUX_$j\__mux_4t1_hr_2t1_mux_$k/mux_0/U1/A1"
            set_ccopt_property -pin $this_pin_name -delay_corner delay_default capacitance_override 0.01
            set_ccopt_property -pin $this_pin_name sink_type stop
        }
    }


    for {set j 1} {$j < 5} {incr j} {
        for {set k 0} {$k < 3} {incr k} {
            set this_pin_name "hr_mux_16t4_$i/iMUX_$j\__mux_4t1_hr_2t1_mux_$k/mux_0/U1/B1"
            set_ccopt_property -pin $this_pin_name -delay_corner delay_default capacitance_override 0.01
            set_ccopt_property -pin $this_pin_name sink_type stop
        }
    }

   
    # 4-input muxes
    for {set j 0} {$j < 2} {incr j} {
        set this_pin_name "qr_mux_4t1_$i/mux_4/mux_4_fixed/S$j"
        set_ccopt_property -pin $this_pin_name -delay_corner delay_default capacitance_override 0.01
        set_ccopt_property -pin $this_pin_name sink_type stop
    }
}



set_ccopt_property clone_clock_gates true
set_ccopt_property clone_clock_logic true
set_ccopt_property ccopt_merge_clock_gates true
set_ccopt_property ccopt_merge_clock_logic true
set_ccopt_property cts_merge_clock_gates true
set_ccopt_property cts_merge_clock_logic true

#set_ccopt_property sink_type stop -pin iacore/ext_clk

#set_ccopt_property -pin iacore/ext_clk  capacitance_override  0.004767

set_ccopt_property -pin indiv/in -delay_corner delay_default capacitance_override 0.01
set_ccopt_property -pin indiv/in_mdll -delay_corner delay_default capacitance_override 0.01
#set_ccopt_property -pin iacore/mdll_clk -delay_corner delay_default capacitance_override 0.01
#set_ccopt_property -pin iacore/clk_async -delay_corner delay_default capacitance_override 0.01
#set_ccopt_property -pin imdll/clk_refp -delay_corner delay_default capacitance_override 0.01
#set_ccopt_property -pin imdll/clk_refn -delay_corner delay_default capacitance_override 0.01
#set_ccopt_property -pin imdll/clk_monp -delay_corner delay_default capacitance_override 0.01
#set_ccopt_property -pin imdll/clk_monn -delay_corner delay_default capacitance_override 0.01
set_ccopt_property -pin iPI_0__iPI/clk_encoder -delay_corner delay_default capacitance_override 0.01   
set_ccopt_property -pin iPI_1__iPI/clk_encoder -delay_corner delay_default capacitance_override 0.01   
set_ccopt_property -pin iPI_2__iPI/clk_encoder -delay_corner delay_default capacitance_override 0.01   
set_ccopt_property -pin iPI_3__iPI/clk_encoder -delay_corner delay_default capacitance_override 0.01   
set_ccopt_property -pin iPI_0__iPI/clk_in -delay_corner delay_default capacitance_override 0.01   
set_ccopt_property -pin iPI_1__iPI/clk_in -delay_corner delay_default capacitance_override 0.01   
set_ccopt_property -pin iPI_2__iPI/clk_in -delay_corner delay_default capacitance_override 0.01   
set_ccopt_property -pin iPI_3__iPI/clk_in -delay_corner delay_default capacitance_override 0.01   
set_ccopt_property -pin iPI_0__iPI/clk_async -delay_corner delay_default capacitance_override 0.01   
set_ccopt_property -pin iPI_1__iPI/clk_async -delay_corner delay_default capacitance_override 0.01   
set_ccopt_property -pin iPI_2__iPI/clk_async -delay_corner delay_default capacitance_override 0.01   
set_ccopt_property -pin iPI_3__iPI/clk_async -delay_corner delay_default capacitance_override 0.01   

set_ccopt_property -pin indiv/in sink_type stop
set_ccopt_property -pin indiv/in_mdll sink_type stop
#set_ccopt_property -pin iacore/mdll_clk sink_type stop
#set_ccopt_property -pin iacore/clk_async sink_type stop
#set_ccopt_property -pin imdll/clk_refp sink_type stop
#set_ccopt_property -pin imdll/clk_refn sink_type stop
#set_ccopt_property -pin imdll/clk_monp sink_type stop
#set_ccopt_property -pin imdll/clk_monn sink_type stop
set_ccopt_property -pin iPI_0__iPI/clk_encoder sink_type stop
set_ccopt_property -pin iPI_1__iPI/clk_encoder sink_type stop
set_ccopt_property -pin iPI_2__iPI/clk_encoder sink_type stop
set_ccopt_property -pin iPI_3__iPI/clk_encoder sink_type stop
set_ccopt_property -pin iPI_0__iPI/clk_in sink_type stop
set_ccopt_property -pin iPI_1__iPI/clk_in sink_type stop
set_ccopt_property -pin iPI_2__iPI/clk_in sink_type stop
set_ccopt_property -pin iPI_3__iPI/clk_in sink_type stop
set_ccopt_property -pin iPI_0__iPI/clk_async sink_type stop
set_ccopt_property -pin iPI_1__iPI/clk_async sink_type stop
set_ccopt_property -pin iPI_2__iPI/clk_async sink_type stop
set_ccopt_property -pin iPI_3__iPI/clk_async sink_type stop
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


