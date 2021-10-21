set MAX_TRAN 0.02
set LOAD 0.05
set DELAY 0.08

set_case_analysis 0 [get_ports sel_clk_source]
set_case_analysis 0 [get_ports bypass_div2]
set_case_analysis 0 [get_ports bypass_div]
set_case_analysis 0 [get_ports ndiv]

create_clock -name clk -period [expr $CLK_PERIOD/2.5]  [get_ports in]  
set_clock_uncertainty 0.01 [get_clocks clk]

set_propagated_clock [all_clocks]

set_max_transition $MAX_TRAN [current_design]
set_input_transition [expr $MAX_TRAN] [all_inputs]

set_load -pin_load $LOAD [all_outputs]

#set_max_delay $DELAY -fall_from [get_clocks clk_adc] -to [get_ports {v2t_out v2t_outb}]



set_false_path -from [get_ports in_mdll]













