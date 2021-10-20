set MAX_TRAN 0.03
set LOAD 0.03
 
create_clock -name clk -period $CLK_PERIOD [get_ports clk_in]  
set_clock_uncertainty 0.01 [get_clocks clk] 

create_clock -name clk_adc -period [expr $CLK_DIV_PERIOD*0.8] [get_pins iV2T_clock_gen/clk_adder]
set_clock_uncertainty 0.01 [get_clocks clk_adc] 

########################################
# Constraints for input and output pins
########################################
set_max_transition [expr $MAX_TRAN] [current_design]
set_input_transition $MAX_TRAN [all_inputs]
set_load $LOAD [all_outputs] 

set_max_transition -clock_path $MAX_TRAN [get_clocks clk]
set_propagated_clock [all_clocks]

set_false_path -from [get_ports {ctl* rstb en_slice en_sync_in init* VinP VinN Vcal alws_on en_TDC_phase_reverse}]
set_disable_timing [get_cells  iV2T_clock_gen/iV2T_buffer/iS2D*/iV2T_fixed_xc*/U1]

set_dont_touch {inew_tdc*}






