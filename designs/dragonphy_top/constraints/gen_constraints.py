import os
from pathlib import Path

OUTPUT_FILE = 'constraints.tcl'

design_name = os.environ['design_name']
time_scale = float(os.environ['constr_time_scale'])
cap_scale = float(os.environ['constr_cap_scale'])

output = ''

output += f'''
# Modified from ButterPHY and Garnet constraints

#########
# Params
#########

# primary I/Os being treated as don't touch nets

set analog_io {{ext_rx_inp ext_rx_inn ext_Vcm ext_Vcal ext_rx_inp_test \\
               ext_rx_inn_test ext_clk_async_p ext_clk_async_n ext_clk_test0_p \\
               ext_clk_test0_n ext_clk_test1_p ext_clk_test1_n ext_clkp \\
               ext_clkn clk_out_p clk_out_n clk_trig_p clk_trig_n}}

set analog_net [get_pins ibuf_*/clk]

set primary_digital_inputs {{ext_rstb ext_dump_start jtag_intf_i_phy_tdi \\
                            jtag_intf_i_phy_tck jtag_intf_i_phy_tms \\
                            jtag_intf_i_phy_trst_n}}

#########
# Clocks
#########

create_clock -name clk_retimer -period {0.7*time_scale} [get_pins {{iacore/clk_adc}}]
#create_clock -name clk_in -period {0.7*time_scale} [get_ports ext_clkp]
create_clock -name clk_jtag -period {100.0*time_scale} [get_ports jtag_intf_i_phy_tck]

set_dont_touch_network [get_pins {{iacore/clk_adc}}]
set_dont_touch_network [get_port jtag_intf_i_phy_tck]

set_clock_uncertainty -setup {0.03*time_scale} clk_retimer
set_clock_uncertainty -hold {0.3*time_scale} clk_retimer
set_clock_uncertainty -setup {1.0*time_scale} clk_jtag
set_clock_uncertainty -hold {0.03*time_scale} clk_jtag

###########
# Net const
###########

set_max_capacitance {0.1*cap_scale} [current_design]

set_max_transition {0.2*time_scale} [current_design]
set_max_transition {0.1*time_scale} [all_clocks]

set hs_nets [get_pins {{iacore/*pi_out_meas* iacore/*inbuf_out_meas* \\
                       iacore/*pfd_inp_meas* iacore/*pfd_inn_meas* \\
                       iacore/*del_out_pi*}}]

foreach x [get_object_name $hs_nets] {{
	create_clock -name clk_hs_net_$x -period {0.25*time_scale} [get_pins $x]
	set_max_transition {0.025*time_scale} [get_clocks clk_hs_net_$x]
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

set_input_delay {0.05*time_scale} [get_ports $primary_digital_inputs]
set_input_transition {0.5*time_scale} [get_ports $primary_digital_inputs]

set_input_transition {0.03*time_scale} [all_inputs]
set_load {0.02*cap_scale} [all_outputs]
set_output_delay {0.7*time_scale} [all_outputs]

############
# False path
############

# asynchronous clock domains
set_false_path -from clk_retimer -to clk_jtag
set_false_path -from clk_jtag -to clk_retimer
set_false_path -from clk_retimer -to freq_lvl_cross

# analog core (black box)
set_false_path -through [get_pins -of_objects iacore]

# mdll_r1 (black box)
set_false_path -through [get_pins -of_objects imdll]

# input buffers
set_false_path -through [get_pins -of_objects ibuf_async]
set_false_path -through [get_pins -of_objects ibuf_main]
set_false_path -through [get_pins -of_objects ibuf_mdll_ref]
set_false_path -through [get_pins -of_objects ibuf_mdll_mon]

# output buffers
set_false_path -through [get_pins -of_objects idcore/out_buff_i]

################
# Other options
################

# Make all signals limit their fanout
set_max_fanout 20 {design_name}

# This constraint sets the input drive strength of the input pins of
# your design. We specifiy a specific standard cell which models what
# would be driving the inputs. This should usually be a small inverter
# which is reasonable if another block of on-chip logic is driving
# your inputs.

set_driving_cell -no_design_rule -lib_cell $ADK_DRIVING_CELL [all_inputs]
'''

# process-specific constraints
if os.environ['adk_name'] == 'tsmc16':
    output += f'''
# From ButterPHY

# TODO: what is mvt_target_libs?
# foreach lib $mvt_target_libs {{
#   set_dont_use [file rootname [file tail $lib]]/*D0BWP*
# }}

# From Garnet
# Apparently ANAIOPAD and IOPAD cells don't all have the dont_touch property
# As a result, set the property here if there are any such cells

if {{[llength [get_cells ANAIOPAD*]] > 0}} {{
    set_dont_touch [get_cells ANAIOPAD*]
}}

if {{[llength [get_cells IOPAD*]] > 0}} {{
    set_dont_touch [get_cells IOPAD*]
}}
'''

# create output directory
OUTPUT_DIR = Path('outputs')
OUTPUT_DIR.mkdir(exist_ok=True, parents=True)

# write output text
with open(OUTPUT_DIR / OUTPUT_FILE, 'w') as f:
    f.write(output)
