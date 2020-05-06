import os
from pathlib import Path

OUTPUT_FILE = 'constraints.tcl'

e = os.environ
output = f'''\
# Modified from ButterPHY and Garnet constraints

# Design constraints for synthesis
# time unit : ns
# cap unit: pF

#########
# Params
#########

# primary I/Os being treated as don't touch nets

set analog_io {{ext_rx_inp ext_rx_inn ext_Vcm ext_Vcal ext_rx_inp_test \\
               ext_rx_inn_test ext_clk_async_p ext_clk_async_n ext_clk_test0_p \\
               ext_clk_test0_n ext_clk_test1_p ext_clk_test1_n ext_clkp \\
               ext_clkn clk_out_p clk_out_n clk_trig_p clk_trig_n}}

set analog_net [get_pins ibuf_*/clk]

set primary_digital_inputs {{ext_rstb ext_dump_start jtag_intf_i.phy_tdi \\
                            jtag_intf_i.phy_tck jtag_intf_i.phy_tms \\
                            jtag_intf_i.phy_trst_n}}

#########
# Clocks
#########

create_clock -name clk_retimer -period {e["clk_retimer_period"]} [get_pins {{iacore/clk_adc}}]
create_clock -name clk_in -period {e["clk_in_period"]} [get_ports ext_clkp]
create_clock -name clk_jtag -period {e["clk_jtag_period"]} [get_ports jtag_intf_i.phy_tck]
set_dont_touch_network [get_pins {{iacore/clk_adc}}]
set_dont_touch_network [get_port jtag_intf_i.phy_tck]

set_clock_uncertainty -setup {e["clk_retimer_setup_uncertainty"]} clk_retimer
set_clock_uncertainty -hold {e["clk_retimer_hold_uncertainty"]} clk_retimer
set_clock_uncertainty -setup {e["clk_jtag_setup_uncertainty"]} clk_jtag
set_clock_uncertainty -hold {e["clk_jtag_hold_uncertainty"]} clk_jtag

###########
# Net const
###########

set_max_capacitance {e["max_capacitance"]} [current_design]
set_max_transition {e["max_transition"]} [current_design]
set_max_transition {e["max_clock_transition"]} [all_clocks]

set hs_nets [get_pins {{iacore/*pi_out_meas* iacore/*inbuf_out_meas* \\
                       iacore/*pfd_inp_meas* iacore/*pfd_inn_meas* \\
                       iacore/*del_out_pi*}}]

foreach x [get_object_name $hs_nets] {{
	create_clock -name clk_hs_net_$x -period {e["clk_hs_period"]} [get_pins $x]
	set_max_transition {e["clk_hs_transition"]} [get_clocks clk_hs_net_$x]
}}

echo [all_clocks]

###########
# Analog nets
###########

set_dont_touch_network [get_ports $analog_io]
set_dont_touch_network $analog_net
set_dont_touch_network [all_outputs]

###########
# I/O const
###########

set_input_delay {e["digital_input_delay"]} [get_ports $primary_digital_inputs]
set_input_transition {e["digital_input_transition"]} [get_ports $primary_digital_inputs]

set_input_transition {e["input_transition"]} [all_inputs]
set_load {e["output_load"]} [all_outputs]
set_output_delay {e["output_delay"]} [all_outputs]

############
# False path
############

set_false_path -from clk_retimer -to clk_jtag
set_false_path -from clk_jtag -to clk_retimer

################
# DONT USE CELLS
################

# foreach lib $mvt_target_libs {{
#   set_dont_use [file rootname [file tail $lib]]/*D0BWP*
# }}

# Settings from Garnet to consider
# (all commented out at the moment)

# This constraint sets the input drive strength of the input pins of
# your design. We specifiy a specific standard cell which models what
# would be driving the inputs. This should usually be a small inverter
# which is reasonable if another block of on-chip logic is driving
# your inputs.

# set_driving_cell -no_design_rule \\
#  -lib_cell $ADK_DRIVING_CELL [all_inputs]

# Make all signals limit their fanout
# TODO: should this be included?
# set_max_fanout 20 {e["design_name"]}

# sr 02/2020
# haha IOPAD cells already have dont_touch property but not ANAIOPAD :(
# Without dont_touch, they disappear during dc-synthesis
# set_dont_touch [ get_cells ANAIOPAD* ]

# sr 02/2020
# Arg turns out not all IOPAD cells have dont_touch property I guess
# set_dont_touch [ get_cells IOPAD* ]
'''

# create output directory
OUTPUT_DIR = Path('outputs')
OUTPUT_DIR.mkdir(exist_ok=True, parents=True)

# write output text
with open(OUTPUT_DIR / OUTPUT_FILE, 'w') as f:
    f.write(output)

