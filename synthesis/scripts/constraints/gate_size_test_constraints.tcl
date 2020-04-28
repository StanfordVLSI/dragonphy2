set MAX_TRAN 0.03
set LOAD 0.05
set DELAY 0.1

#set_case_analysis 0 [get_ports sel]

create_clock -name clk -period $CLK_PERIOD [get_ports clk_in]  

set_max_transition $MAX_TRAN [current_design]
set_input_transition $MAX_TRAN [all_inputs]
set_load $LOAD [all_outputs] 

set_propagated_clock [all_clocks]

set_false_path -from [get_ports {CDN SDN clk_div_in}]

set_load -pin_load $LOAD [get_ports {out outb}]
set_max_delay $DELAY -fall_from [get_clocks clk] -to [get_ports {out outb}]

set_false_path -from [get_ports clk_div_in]
set_false_path -to [get_pins in_or*/in1]
set_false_path -to [get_pins ifff/D]


#set_dont_touch [get_nets {*out* *mid*}]











