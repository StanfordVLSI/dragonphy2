set MAX_TRAN 0.03
set GF_LOOP_DELAY 0.06
set LOAD 0.02

set_max_transition ${MAX_TRAN} [current_design]
set_input_transition ${MAX_TRAN} [all_inputs]
set_load ${LOAD} [all_outputs] 


create_clock -name clk_in -period [expr ${CLK_PERIOD}*0.8] [get_ports clk_in]
set_clock_uncertainty 0.01 clk_in

create_clock -name clk_bld -period [expr ${CLK_PERIOD}*0.8] [get_pins iphase_blender_dont_touch/ph_out]
set_clock_uncertainty 0.01 clk_bld

create_clock -name clk_cdr -period [expr ${CLK_DIV_PERIOD}*0.8] [get_ports clk_cdr]
set_clock_uncertainty 0.01 clk_cdr

create_clock -name clk_async -period [expr ${CLK_DIV_PERIOD}*0.8] [get_ports clk_async]
set_clock_uncertainty 0.01 clk_async

create_clock -name clk_pm -period [expr ${CLK_PERIOD}*0.8] [get_pins iPM/iPM_sub/iref_buff1/out] 


set_case_analysis 1 [get_ports en_gf]

set_clock_groups -asynchronous -group clk_in -group clk_async
set_clock_groups -asynchronous -group clk_bld -group clk_async
set_clock_groups -asynchronous -group clk_cdr -group clk_async
set_clock_groups -asynchronous -group clk_pm -group clk_async

set_clock_groups -asynchronous -group clk_in -group clk_bld
set_clock_groups -asynchronous -group clk_cdr -group clk_bld
set_clock_groups -asynchronous -group clk_pm -group clk_bld

set_clock_groups -asynchronous -group clk_in -group clk_cdr
set_clock_groups -asynchronous -group clk_pm -group clk_cdr

set_clock_groups -asynchronous -group clk_in -group clk_pm


set_disable_timing -from S0 -to Z [get_cells -hierarchical *IMUX4]
set_disable_timing -from S1 -to Z [get_cells -hierarchical *IMUX4]

set_max_transition $MAX_TRAN [get_pins -hierarchical iPI_delay_unit*/arb_in]

set_false_path -from [get_ports {rstb disable_state en_* ctl* inc_del* ext_Qperi* sel_pm* }]
set_false_path -to [get_pins iPM/iPM_sub/ff_*_reg/D]
set_false_path -from [get_pins -hierarchical iPI_delay_unit*/buf_out]
set_false_path -from [get_pins -hierarchical iPI_delay_unit*/arb_out]

set_disable_timing [get_cells thm_sel_bld_sampled_reg*]
set_disable_timing [get_cells -hierarchical *sel_retimed_reg*]



#set_false_path -to [get_pins -hierarchical arb_out_reg/D]
#set_false_path -to [get_pins iPM/iPM_sub_dont_touch/uXOR1/A1] 
#remove_buffer -from [get_ports clk_in] -to [get_pins iPM/iPM_sub_dont_touch/ph_ref]


