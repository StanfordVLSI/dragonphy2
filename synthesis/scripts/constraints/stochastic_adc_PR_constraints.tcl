set MAX_TRAN 0.03
set LOAD 0.02

set_case_analysis 0 [get_ports sel_clk_TDC]
set_case_analysis 1 [get_ports sel_pm_in[0]]
set_case_analysis 1 [get_ports sel_pm_in[1]]
 
create_clock -name clk -period $CLK_PERIOD [get_ports clk_in]  
set_clock_uncertainty 0.01 [get_clocks clk] 

#create_generated_clock -name clk_adder -source [get_clocks clk] -edges {4 8 12} [get_pins iV2T_clock_gen/iV2T_buffer_dont_touch/clk_div_sampled]
#create_generated_clock -name clk_adc -source [get_clocks clk] -edges {6 10 14} [get_pins iV2T_clock_gen/clk_adder]
create_clock -name clk_adc -period $CLK_DIV_PERIOD [get_pins iV2T_clock_gen/clk_adder]

create_clock -name clk_async [get_ports clk_async]  -period $CLK_DIV_PERIOD 
set_clock_uncertainty 0.01  [get_clocks clk_async]

create_clock -name clk_TDC [get_pins idcdl_coarse/out]  -period $CLK_DIV_PERIOD
set_clock_uncertainty 0.01  [get_clocks clk_TDC]

create_clock -name clk_pm -period $CLK_DIV_PERIOD [get_pins iPM/iPM_sub/iref_buff1/out]  

create_clock -name clk_TDC_PR -period $CLK_DIV_PERIOD [get_pins clk_TDC_phase_reverse_reg/Q]  

set_clock_groups -asynchronous -group clk_adc -group clk_async
set_clock_groups -asynchronous -group clk_adc -group clk_TDC
set_clock_groups -asynchronous -group clk_adc -group clk_pm
set_clock_groups -asynchronous -group clk_adc -group clk
set_clock_groups -asynchronous -group clk_adc -group clk_TDC_PR

set_clock_groups -asynchronous -group clk -group clk_async
set_clock_groups -asynchronous -group clk -group clk_TDC
set_clock_groups -asynchronous -group clk -group clk_pm
set_clock_groups -asynchronous -group clk -group clk_TDC_PR

set_clock_groups -asynchronous -group clk_pm -group clk_async
set_clock_groups -asynchronous -group clk_pm -group clk_TDC
set_clock_groups -asynchronous -group clk_pm -group clk_TDC_PR

set_clock_groups -asynchronous -group clk_TDC_PR -group clk_async
set_clock_groups -asynchronous -group clk_TDC_PR -group clk_TDC


#create_clock -name clk_v2t_e -period $CLK_DIV_PERIOD  -waveform {0 0.25} [get_pins iV2T_clock_gen/clk_div_sampled_reg_dont_touch/Q]  
#create_clock -name clk_v2t -period $CLK_DIV_PERIOD -waveform {0 0.25} [get_pins iV2T_clock_gen/idcdl_fine1_dont_touch/out]  
#create_clock -name clk_v2t_l -period $CLK_DIV_PERIOD -waveform {0 0.25} [get_pins iV2T_clock_gen/idcdl_fine2_dont_touch/out]  

########################################
# Constraints for input and output pins
########################################
set_max_transition [expr 2*$MAX_TRAN] [current_design]
set_input_transition $MAX_TRAN [all_inputs]
set_load $LOAD [all_outputs] 

set_max_transition -clock_path $MAX_TRAN [get_clocks clk]
set_propagated_clock [all_clocks]


set_false_path -from [get_ports {ctl* rstb en_slice en_sync_in init* VinP VinN Vcal alws_on clk_async en_pm* sel_pm*}]

set_false_path -to [get_pins iPM/iPM_sub/ff_*_reg/CP] 

set_disable_timing [get_cells -hierarchical *xc*]
#set_disable_timing [get_cells -hierarchical *phase_reverse_reg*]








