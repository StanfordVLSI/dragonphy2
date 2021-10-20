set MAX_TRAN 0.03
set LOAD 0.02

create_clock -name clk_pi -period [expr $CLK_PERIOD*0.8] [get_pins iindiv/out]  
create_clock -name clk_adc -period [expr $CLK_DIV_PERIOD*0.8] [get_pins iADC[0].iADC/clk_adder] 
create_clock -name clk_async -period [expr $CLK_DIV_PERIOD*0.8] [get_ports clk_async] 

create_clock -name pi_0_clk_slice -period [expr $CLK_PERIOD*0.8] [get_pins iPI[0].iPI/clk_out_slice] 
create_clock -name pi_1_clk_slice -period [expr $CLK_PERIOD*0.8] [get_pins iPI[1].iPI/clk_out_slice] 
create_clock -name pi_2_clk_slice -period [expr $CLK_PERIOD*0.8] [get_pins iPI[2].iPI/clk_out_slice] 
create_clock -name pi_3_clk_slice -period [expr $CLK_PERIOD*0.8] [get_pins iPI[3].iPI/clk_out_slice] 

create_clock -name pi_0_clk_sw -period [expr $CLK_PERIOD*0.8] [get_pins iPI[0].iPI/clk_out_sw] 
create_clock -name pi_1_clk_sw -period [expr $CLK_PERIOD*0.8] [get_pins iPI[1].iPI/clk_out_sw] 
create_clock -name pi_2_clk_sw -period [expr $CLK_PERIOD*0.8] [get_pins iPI[2].iPI/clk_out_sw] 
create_clock -name pi_3_clk_sw -period [expr $CLK_PERIOD*0.8] [get_pins iPI[3].iPI/clk_out_sw] 

set_clock_uncertainty 0.01 [all_clocks]
set_propagated_clock [all_clocks]

set_clock_groups -asynchronous -group clk_pi -group clk_async
set_clock_groups -asynchronous -group clk_pi -group clk_adc

set_clock_groups -asynchronous -group clk_adc -group clk_async

set_clock_groups -asynchronous -group pi_0_clk_sw -group clk_async
set_clock_groups -asynchronous -group pi_1_clk_sw -group clk_async
set_clock_groups -asynchronous -group pi_2_clk_sw -group clk_async
set_clock_groups -asynchronous -group pi_3_clk_sw -group clk_async

set_clock_groups -asynchronous -group pi_0_clk_sw -group clk_pi
set_clock_groups -asynchronous -group pi_1_clk_sw -group clk_pi
set_clock_groups -asynchronous -group pi_2_clk_sw -group clk_pi
set_clock_groups -asynchronous -group pi_3_clk_sw -group clk_pi

set_clock_groups -asynchronous -group pi_0_clk_sw -group clk_adc
set_clock_groups -asynchronous -group pi_1_clk_sw -group clk_adc
set_clock_groups -asynchronous -group pi_2_clk_sw -group clk_adc
set_clock_groups -asynchronous -group pi_3_clk_sw -group clk_adc

set_clock_groups -asynchronous -group pi_0_clk_slice -group clk_async
set_clock_groups -asynchronous -group pi_1_clk_slice -group clk_async
set_clock_groups -asynchronous -group pi_2_clk_slice -group clk_async
set_clock_groups -asynchronous -group pi_3_clk_slice -group clk_async

set_clock_groups -asynchronous -group pi_0_clk_slice -group clk_pi
set_clock_groups -asynchronous -group pi_1_clk_slice -group clk_pi
set_clock_groups -asynchronous -group pi_2_clk_slice -group clk_pi
set_clock_groups -asynchronous -group pi_3_clk_slice -group clk_pi

set_clock_groups -asynchronous -group pi_0_clk_slice -group clk_adc
set_clock_groups -asynchronous -group pi_1_clk_slice -group clk_adc
set_clock_groups -asynchronous -group pi_2_clk_slice -group clk_adc
set_clock_groups -asynchronous -group pi_3_clk_slice -group clk_adc


set_case_analysis 0 [get_ports *sel_clk_source]
########################################
# Constraints for input and output pins
########################################
set_input_transition $MAX_TRAN [all_inputs]
set_max_transition $MAX_TRAN [current_design]
set_max_transition $MAX_TRAN -clock_path [all_clocks]
set_load $LOAD [all_outputs]  

set_dont_touch {iADC* iPI* iterm* iSnH* iBG* iindiv* isw_s2d* inew_adc}
set_dont_touch_network [get_ports {rx_in* Vcm Vcal *del_out[* *del_out_rep[*}]

set_false_path -from [get_ports {rx_in* Vcm ctl* Vcal *rstb *en_* *ctl*  *del_inc* *disable_state* *init* *ALWS_ON* *bypass* *ndiv* *ctrl* *sel_del* *sel_PFD* *sel_clk* *sel_pm* *sel_meas* *sel_PFD*}]

set_false_path -to [get_pins -hierarchical *reg*/D]
set_false_path -to [get_pins -hierarchical *reg*/CDN]
set_false_path -to [get_pins -hierarchical *reg*/SDN]
set_false_path -to [get_pins -hierarchical *reg*/E]


set_input_delay 0.5 -clock [get_clocks clk_adc] {ctl_pi* ctl_valid} 

