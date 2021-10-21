set CLK_PERIOD 1
set MAX_TRAN 0.03
set LOAD 0.03

set_case_analysis 0 [get_ports ph_sel[0]]
set_case_analysis 0 [get_ports ph_sel[1]]
set_case_analysis 0 [get_ports ctl_dcdl_rstb[0]]
set_case_analysis 0 [get_ports ctl_dcdl_rstb[1]]
 
create_clock -name clk -period $CLK_PERIOD [get_pins Iinput_network/init]  
set_clock_uncertainty 0.01 [get_clocks clk] 

create_clock -name clk_sample -period $CLK_PERIOD [get_pins Iosc_core/Imux_samp/Z]
set_clock_uncertainty 0.01 [get_clocks clk_sample] 

create_clock -name slow -period $CLK_PERIOD [get_pins Iosc_core/I249/Q]
set_clock_uncertainty 0.01 [get_clocks slow] 


set_clock_groups -asynchronous -group clk -group clk_sample
set_clock_groups -asynchronous -group clk -group slow

set_clock_groups -asynchronous -group clk_sample -group slow

########################################
# Constraints for input and output pins
########################################
set_max_transition [expr $MAX_TRAN] [current_design]
set_input_transition $MAX_TRAN [all_inputs]
set_load $LOAD [all_outputs] 

set_max_transition -clock_path $MAX_TRAN [all_clocks]
set_propagated_clock [all_clocks]


set_false_path -from [get_ports {ctl* rstb ph*}]

set_disable_timing [get_cells -hierarchical *nand_lat*]

set_output_delay -clock clk -max 0.1 [get_ports {tdcout* signout}]






