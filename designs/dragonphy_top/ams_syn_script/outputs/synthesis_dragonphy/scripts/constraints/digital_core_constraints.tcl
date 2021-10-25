set CLK_PERIOD 1
set MAX_TRAN 0.03
set LOAD 0.03

create_clock -name clk -period $CLK_PERIOD [get_ports clk]  
set_clock_uncertainty 0.01 [get_clocks clk] 
create_clock -name clk_sample -period $CLK_PERIOD [get_ports clk_sample]  
set_clock_uncertainty 0.01 [get_clocks clk_sample] 

set_clock_groups -asynchronous -group clk -group clk_sample

########################################
# Constraints for input and output pins
########################################
set_max_transition [expr $MAX_TRAN] [current_design]
set_input_transition [expr 2*$MAX_TRAN] [all_inputs]
set_load $LOAD [all_outputs] 

set_max_transition -clock_path $MAX_TRAN [get_clocks clk]
set_max_transition -clock_path $MAX_TRAN [get_clocks clk_sample]
set_propagated_clock [all_clocks]

#set_false_path -to [get_pins iPM/iPM_sub/ff_*_reg/CP] 
#set_disable_timing [get_cells -hierarchical *xc_inv*]







