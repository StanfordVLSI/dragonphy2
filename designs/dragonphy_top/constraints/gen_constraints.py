import os
from pathlib import Path

OUTPUT_FILE = 'constraints.tcl'

design_name = os.environ['design_name']
time_scale = float(os.environ['constr_time_scale'])
cap_scale = float(os.environ['constr_cap_scale'])
main_per = float(os.environ['constr_main_per'])

output = ''

output += f'''
# Modified from ButterPHY and Garnet constraints

############
# Main clock
############

# Frequency is 1.4 GHz (40% above nominal) 
# For timining analysis, the IO of analog core is considered to be clocked on 
# ext_clk (input) rather than clk_adc (output).  Hence the ext_clk signal is 
# declared to have the same frequency as clk_adc.  This should be OK because there
# is no synthesized logic that actually runs on ext_clk, and the ext_clk transition
# time is set to be very fast later in this constraints file.
create_clock -name clk_main_buf \\
    -period {main_per*time_scale} \\
    -waveform {{0 {0.5*main_per*time_scale}}} \\
    [get_pin ibuf_main/clk]
create_clock -name clk_retimer \\
    -period {main_per*time_scale} \\
    -waveform {{0 {0.5*main_per*time_scale}}} \\
    [get_pins iacore/clk_adc]

# clock uncertainty
set_clock_uncertainty -setup 0.03 clk_retimer
set_clock_uncertainty -hold 0.03 clk_retimer

################
# JTAG interface
################

# These numbers come from looking at datasheets for JTAG cables
# https://www.analog.com/media/en/technical-documentation/application-notes/ee-68.pdf
# https://www2.lauterbach.com/pdf/arm_app_jtag.pdf

# TCK clock signal: 20 MHz max
create_clock -name clk_jtag -period 50.0 [get_ports jtag_intf_i.phy_tck]
set_clock_uncertainty -setup 0.03 clk_jtag
set_clock_uncertainty -hold 0.03 clk_jtag

# TCK constraints
set_input_transition 0.5 [get_port jtag_intf_i.phy_tck]

# timing constraints for TDI (changes 0 to 5 ns from falling edge of JTAG clock)
set_input_transition 0.5 [get_port jtag_intf_i.phy_tdi]
set_input_delay -clock clk_jtag -max 0.5 -clock_fall [get_port jtag_intf_i.phy_tdi]
set_input_delay -clock clk_jtag -min 0.0 -clock_fall [get_port jtag_intf_i.phy_tdi]

# timing constraints for TMS (changes 0 to 5 ns from falling edge of JTAG clock)
set_input_transition 0.5 [get_port jtag_intf_i.phy_tms]
set_input_delay -clock clk_jtag -max 5.0 -clock_fall [get_port jtag_intf_i.phy_tms]
set_input_delay -clock clk_jtag -min 0.0 -clock_fall [get_port jtag_intf_i.phy_tms]

# timing constraints for TDO (setup time 12.5 ns, hold time 0.0)
# TDO changes on the falling edge of TCK but is sampled on the rising edge
set_output_delay -clock clk_jtag -max 12.5 [get_port jtag_intf_i.phy_tdo]
set_output_delay -clock clk_jtag -min 0.0 [get_port jtag_intf_i.phy_tdo]

# TRST_N is asynchronous
set_input_transition 0.5 [get_port jtag_intf_i.phy_trst_n]

############################
# Asynchronous clock domains
############################

set_clock_groups -asynchronous \\
    -group {{ clk_jtag }} \\
    -group {{ clk_retimer clk_main_buf }}

####################
# Other external I/O
####################

# external analog inputs

set ext_dont_touch_false_path {{ \\
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
    ext_mdll_clk_refp \\
    ext_mdll_clk_refn \\
    ext_mdll_clk_monp \\
    ext_mdll_clk_monn \\
    clk_out_p \\
    clk_out_n \\
    clk_trig_p \\
    clk_trig_n \\
}}

set_dont_touch_network [get_ports $ext_dont_touch_false_path]
set_false_path -through [get_ports $ext_dont_touch_false_path]

set ext_false_path_only {{ \\
    ext_rstb \\
    ext_dump_start \\
}}

set_false_path -through [get_ports $ext_false_path_only]

###################
# Top-level buffers
###################

# IOS for buffers are all false paths
set_false_path -through [get_pins ibuf_*/*]

#############
# Analog core
#############

# TODO do any signals in the debug interface need special treatment?
set_false_path -through [get_pins iacore/adbg_intf_i.*]

# TODO specify timing for ADC outputs
set_false_path -through [get_pins iacore/adder_out*]
set_false_path -through [get_pins iacore/sign_out*]

######
# MDLL
######

# IOs for MDLL are all false paths
set_false_path -through [get_pins -of_objects imdll]

################
# Output buffer
################

# IOs for output buffer are all false paths
# The output signals previously had dont_touch_network applied
set_false_path -through [get_pins -of_objects idcore/out_buff_i]

###############
# Case analysis
###############

# Need to specify nominal control codes for the retimer; otherwise
# there will be timing violations (the point of the retimer is to 
# account for differences in timing from nominal)

set ctrl_1 "0000111111110000"

for {{set idx 0}} {{$idx < 16}} {{incr idx}} {{
    set_case_analysis \\
        [string index $ctrl_1 [expr {{15 - $idx}}]] \\
        "idcore/jtag_i/ddbg_intf_i.retimer_mux_ctrl_1[$idx]"
}}

#################
# Net constraints
#################

# specify defaults for all nets
set_driving_cell -no_design_rule -lib_cell $ADK_DRIVING_CELL [all_inputs]
set_max_transition {0.2*time_scale} [current_design]
set_max_capacitance {0.1*cap_scale} [current_design]
set_max_fanout 20 {design_name}

# specify loads for outputs
# value is low, but all outputs are dont_touch_network anyway
set_load {0.02*cap_scale} [all_outputs]

# Tighten transition constraint for clocks declared so far
set_max_transition {0.1*time_scale} -clock_path [get_clock clk_retimer]
set_max_transition {0.1*time_scale} -clock_path [get_clock clk_jtag]

# Set transition time for high-speed signals monitored from iacore
# transition time is 10% of a 4 GHz period.  Note that we have to
# create a clock before the transition constraint is applied
# (appears to be related to the fact that these are internal nets)
set mon_nets [get_pins {{ \\
    iacore/*del_out_pi* \\
    iacore/*pi_out_meas* \\
    iacore/*del_out_rep* \\
    iacore/*inbuf_out_meas* \\
    iacore/*pfd_inp_meas* \\
    iacore/*pfd_inn_meas* \\
}}]
foreach x [get_object_name $mon_nets] {{
    create_clock -name clk_mon_net_$x -period {0.25*time_scale} [get_pins $x]
    set_max_transition {0.025*time_scale} -clock_path [get_clocks clk_mon_net_$x]
}}

# Set transition time for clk_async
create_clock -name clk_async_buf -period {1.0*time_scale} [get_pin ibuf_async/clk]
set_max_transition {0.1*time_scale} -clock_path [get_clock clk_async_buf]

# Set transition time for the 8 GHz output of the main buffer
# Note that the period of this clock is declared as 1 GHz due to 
# limitations in QTMs models mentioned earlier, but the transition
# constraint is 10% of an 8 GHz clock (rather than a 1 GHz clock)
set_max_transition {0.0125*time_scale} -clock_path [get_clock clk_main_buf]

# Set transition time for MDLL reference
create_clock -name clk_mdll_refp -period {8.0*time_scale} [get_pin ibuf_mdll_ref/clk]
set_max_transition {0.03*time_scale} -clock_path [get_clock clk_mdll_refp]
create_clock -name clk_mdll_refn -period {8.0*time_scale} [get_pin ibuf_mdll_ref/clk_b]
set_max_transition {0.03*time_scale} -clock_path [get_clock clk_mdll_refn]

# Set transition time for MDLL monitor
create_clock -name clk_mdll_monp -period {1.0*time_scale} [get_pin ibuf_mdll_mon/clk]
set_max_transition {0.1*time_scale} -clock_path [get_clock clk_mdll_monp]
create_clock -name clk_mdll_monn -period {1.0*time_scale} [get_pin ibuf_mdll_mon/clk_b]
set_max_transition {0.1*time_scale} -clock_path [get_clock clk_mdll_monn]

# Set transition time for the MDLL output
create_clock -name clk_mdll_out -period {0.25*time_scale} [get_pin imdll/clk_0]
set_max_transition {0.03*time_scale} -clock_path [get_clock clk_mdll_out]

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
