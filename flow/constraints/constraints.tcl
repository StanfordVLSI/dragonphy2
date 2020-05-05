# Adapted from Garnet

# Clock Names
set clock_names [list clk]
set design_clocks [concat $clock_names]

# PARAMETER: clock period
set clock_period(clk) 2.0

# PARAMETER: clock port
set clock_port(clk) clk

# PARAMETER: pre-cts skew estimate
set clock_skew(clk) 0.00

# PARAMETER: clock duty cycle jitter
set clock_jitter(clk) 0.02

# PARAMETER: clock extra setup margin
set clock_extra_setup(clk) 0.00

# PARAMETER: clock extra hold margin
set clock_extra_hold(clk) 0.00

# PARAMETER: pre-cts clock maximum latency
set clock_max_latency(clk) 0.00

# PARAMETER: pre-cts clock minimum latency
set clock_min_latency(clk) 0.00

# PARAMETER: clock setup uncertainty
set clock_uncertainty_setup(clk) \
    [expr $clock_skew(clk) + $clock_jitter(clk) + $clock_extra_setup(clk)]

# PARAMETER: clock hold uncertainty
set clock_uncertainty_hold(clk) \
    [expr $clock_jitter(clk) + $clock_extra_hold(clk)]

# ==============================================================================
# Clock Creation
# ==============================================================================

foreach clock_name $clock_names {
  create_clock -name $clock_name -period $clock_period($clock_name) \
    [get_ports $clock_port($clock_name)]
  set_clock_latency -max $clock_max_latency($clock_name) [get_clocks $clock_name]
  set_clock_latency -min $clock_min_latency($clock_name) [get_clocks $clock_name]
  set_clock_uncertainty -setup $clock_uncertainty_setup($clock_name) [get_clocks $clock_name]
  set_clock_uncertainty -hold $clock_uncertainty_hold($clock_name) [get_clocks $clock_name]
}

# ==============================================================================
# Clock Path Exceptions / False Paths
# ==============================================================================

# from master clock
# set false_paths(clk) [list ]

# foreach clock_name $design_clocks {
#   set_false_path -from [get_clocks $clock_name] -to [get_clocks $false_paths($clock_name)]
# }

# This constraint sets the load capacitance in picofarads of the
# output pins of your design.

set_load -pin_load $ADK_TYPICAL_ON_CHIP_LOAD [all_outputs]

# This constraint sets the input drive strength of the input pins of
# your design. We specifiy a specific standard cell which models what
# would be driving the inputs. This should usually be a small inverter
# which is reasonable if another block of on-chip logic is driving
# your inputs.

set_driving_cell -no_design_rule \
  -lib_cell $ADK_DRIVING_CELL [all_inputs]

# Make all signals limit their fanout

set_max_fanout 20 $dc_design_name

# Make all signals meet good slew

set_max_transition [expr 0.25*${dc_clock_period}] $dc_design_name

# sr 02/2020
# haha IOPAD cells already have dont_touch property but not ANAIOPAD :(
# Without dont_touch, they disappear during dc-synthesis
# set_dont_touch [ get_cells ANAIOPAD* ]

# sr 02/2020
# Arg turns out not all IOPAD cells have dont_touch property I guess
# set_dont_touch [ get_cells IOPAD* ]