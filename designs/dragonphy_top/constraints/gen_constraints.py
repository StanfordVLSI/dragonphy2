import os
from pathlib import Path

OUTPUT_FILE = 'constraints.tcl'

design_name = os.environ['design_name']
time_scale = float(os.environ['constr_time_scale'])
cap_scale = float(os.environ['constr_cap_scale'])

output = ''

output += f'''
# Modified from ButterPHY and Garnet constraints

############
# Main clock
############

# frequency is 1.4 GHz (40% above nominal) 
create_clock -name clk_retimer -period {0.7*time_scale} [get_pins {{iacore/clk_adc}}]

# clock uncertainty
set_clock_uncertainty -setup 0.03 clk_retimer
set_clock_uncertainty -hold 0.03 clk_retimer

# prevent synthesis tool from inserting buffers
# TODO: do we want this?
set_dont_touch_network [get_pins iacore/clk_adc]

################
# JTAG interface
################

# These numbers come from looking at datasheets for JTAG cables
# https://www.analog.com/media/en/technical-documentation/application-notes/ee-68.pdf
# https://www2.lauterbach.com/pdf/arm_app_jtag.pdf

# TCK clock signal: 20 MHz max
create_clock -name clk_jtag -period 50.0 [get_ports jtag_intf_i_phy_tck]
set_clock_uncertainty -setup 1.0 clk_jtag
set_clock_uncertainty -hold 1.0 clk_jtag

# TCK constraints
set_input_transition 0.5 [get_port jtag_intf_i_phy_tck]
set_dont_touch_network [get_port jtag_intf_i_phy_tck]

# timing constraints for TDI (changes 0 to 5 ns from falling edge of JTAG clock)
set_input_transition 0.5 [get_port jtag_intf_i_phy_tdi]
set_input_delay -clock clk_jtag -max 0.5 -clock_fall [get_port jtag_intf_i_phy_tdi]
set_input_delay -clock clk_jtag -min 0.0 -clock_fall [get_port jtag_intf_i_phy_tdi]

# timing constraints for TMS (changes 0 to 5 ns from falling edge of JTAG clock)
set_input_transition 0.5 [get_port jtag_intf_i_phy_tms]
set_input_delay -clock clk_jtag -max 5.0 -clock_fall [get_port jtag_intf_i_phy_tms]
set_input_delay -clock clk_jtag -min 0.0 -clock_fall [get_port jtag_intf_i_phy_tms]

# timing constraints for TDO (setup time 12.5 ns, hold time 0.0)
# TDO changes on the falling edge of TCK but is sampled on the rising edge
set_output_delay -clock clk_jtag -max 12.5 [get_port jtag_intf_i_phy_tdo]
set_output_delay -clock clk_jtag -min 0.0 [get_port jtag_intf_i_phy_tdo]

# TRST_N is asynchronous
set_false_path -through [get_port jtag_intf_i_phy_trst_n]

############################
# Asynchronous clock domains
############################

set_false_path -from clk_retimer -to clk_jtag
set_false_path -from clk_jtag -to clk_retimer

####################
# Other external I/O
####################

# external analog inputs

set ext_other_io {{ \\
    ext_rx_inp \\
    ext_rx_inn \\
    ext_Vcm \\
    ext_Vcal \\
    ext_rx_inp_test \\
    ext_rx_inn_test
    ext_clk_async_p \\
    ext_clk_async_n \\
    ext_clkp \\
    ext_clkn \\
    clk_out_p \\
    clk_out_n \\
    clk_trig_p \\
    clk_trig_n \\
    ext_mdll_clk_refp \\
    ext_mdll_clk_refn \\
    ext_mdll_clk_monp \\
    ext_mdll_clk_monn \\
    ext_mdll_clk_monn \\
    ramp_clock \\
    ext_clock_outputs \\
    clk_out_p \\
    clk_out_n \\
    clk_trig_p \\
    clk_trig_n \\
    freq_lvl_cross \\
    ext_rstb \\
    ext_dump_start \\
}}

set_dont_touch_network [get_ports $ext_other_io]
set_false_path -through [get_ports $ext_other_io]

###################
# Top-level buffers
###################

set_dont_touch_network [get_pins -of_objects ibuf_*]
set_false_path -through [get_pins -of_objects ibuf_*]

#############
# Analog core
#############

set_dont_touch_network [get_pins iacore/adbg_intf_i_*]
set_false_path -through [get_pins iacore/adbg_intf_i_*]

# TODO: do some nets on the debug interface need to be
# included in timing analysis?

######
# MDLL
######

set_dont_touch_network [get_pins -of_objects imdll]
set_false_path -through [get_pins -of_objects imdll]

################
# Output buffer
################

set_dont_touch_network [get_pins -of_objects idcore/out_buff_i]
set_false_path -through [get_pins -of_objects idcore/out_buff_i]

#################
# Net constraints
#################

# specify defaults for all nets
set_driving_cell -no_design_rule -lib_cell $ADK_DRIVING_CELL [all_inputs]
set_max_transition {0.2*time_scale} [current_design]
set_max_capacitance {0.1*cap_scale} [current_design]
set_max_fanout 20 {design_name}

# specify loads for outputs
# TODO: this seems low...
set_load {0.02*cap_scale} [all_outputs]

# Tighten transition constraint for clocks declared so far
# This should be clk_jtag and clk_retimer
set_max_transition {0.1*time_scale} [all_clocks]

# Set transition time for high-speed signals monitored from iacore
# transition time is 10% of a 4 GHz period
set iacore_mon_nets {{ \\
    iacore/*del_out_pi* \\
    iacore/*pi_out_meas* \\
    iacore/*del_out_rep* \\
    iacore/*inbuf_out_meas* \\
    iacore/*pfd_inp_meas* \\
    iacore/*pfd_inn_meas* \\
}}
set_max_transition {0.025*time_scale} [get_pins $iacore_mon_nets]

# Set transition time for 8 GHz clock (output of ibuf_main)
# i.e. 10% of an 8 GHz period 
set_max_transition {0.0125*time_scale} [get_pins ibuf_main/clk]

# TODO: are special constraints needed for any of the following nets?
# For the MDLL, since we do not have *.lib or *.db specifying load 
# and drive capabilities, these would probably take the form of a 
# maximum capacitance constraint
# clk_async
# mdll_clk_refp / mdll_clk_refn
# mdll_clk_monp / mdll_clk_monn
# mdll_clk_out

echo [all_clocks]
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
