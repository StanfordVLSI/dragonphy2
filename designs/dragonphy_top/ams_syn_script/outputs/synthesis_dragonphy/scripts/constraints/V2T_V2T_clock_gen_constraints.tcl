set CLK_PERIOD 0.25
set CLK_DIV_PERIOD 1.0
set MAX_TRAN 0.05
set LOAD 0.02

 
create_clock -name clk -period $CLK_PERIOD [get_ports clk_in]  
set_clock_uncertainty 0.01 [get_clocks clk] 

create_clock -name clk_adc -period 1 [get_pins iV2T_clock_gen/clk_adder]


set_clock_groups -asynchronous -group clk_adc -group clk

set_max_transition $MAX_TRAN [current_design]
set_input_transition $MAX_TRAN [all_inputs]
set_load $LOAD [all_outputs] 

set_max_transition -clock_path 0.03 [get_clocks clk]
set_propagated_clock [all_clocks]


set_false_path -from [get_ports {ctl* rstb en_slice en_sync_in init* VinP VinN Vcal alws_on }]

set_disable_timing -from in -to out [get_cells -hierarchical *xc*]










