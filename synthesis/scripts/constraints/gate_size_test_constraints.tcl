set MAX_TRAN 0.03
set LOAD 0.05
set DELAY 0.08

set_case_analysis 1 [get_ports one]
set_case_analysis 0 [get_ports zero]
set_case_analysis 0 [get_ports zero_2b]
set_case_analysis 0 [get_ports zero_3b]

create_clock -name clk_adc -period $CLK_PERIOD [get_ports clk_in]  
create_clock -name clk_pi -period $CLK_PERIOD [get_ports chain_in]  
set_clock_groups -asynchronous -group clk_adc -group clk_pi

set_propagated_clock [all_clocks]

set_max_transition $MAX_TRAN [current_design]
set_input_transition [expr $MAX_TRAN/2] [all_inputs]

set_load -pin_load $LOAD [get_ports v2t_out*]

set_max_delay $DELAY -fall_from [get_clocks clk_adc] -to [get_ports {v2t_out v2t_outb}]
#set_max_delay 0.02 -from [get_pins iinv_in_test/in] -to [get_pins iinv_load_test/out]
set_max_delay 0.02 -from [get_pins iinv_in_test/in] -to [get_pins iinv_PI_2_test/out]
set_max_delay 0.02 -from [get_pins itri_buff_test/in] -to [get_pins itri_buff_test/out]
set_max_delay 0.02 -from [get_pins iinv_in_test3/in] -to [get_pins iinv_arb_test/out]

set_false_path -from [get_ports clk_div_in]
set_false_path -to [get_pins in_or*/in1]
set_false_path -to [get_pins ifff/D]













