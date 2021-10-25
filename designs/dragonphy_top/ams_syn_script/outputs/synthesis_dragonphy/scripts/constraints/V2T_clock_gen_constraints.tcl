set 

create_clock -name CLK_IN -period $CLK_PERIOD [get_ports clk_in]  
set_clock_uncertainty -setup 0.01 CLK_IN 
set_clock_uncertainty -hold 0.01 CLK_IN

#create_generated_clock -name CLK_div -source [get_ports CLK_IN] -edges {2 6 10} [get_pins iearly_late_gen_dont_touch/CLK_div]
#set_clock_uncertainty -setup 0.01 CLK_div 
#set_clock_uncertainty -hold 0.01 CLK_div

########################################
# Constraints for input and output pins
########################################
set_input_transition 0.03 [all_inputs]
set_load 0.02 [all_outputs] ; # all outputs are driving I/O driver


#set_input_delay 0.2 [all_inputs] -clock clk
#set_output_delay 0.1 [all_outputs] -clock clk

########################################
# Constraints for paths
########################################
set_max_delay 0.05 -fall_from [get_clocks CLK_IN] -to [get_ports {clk_v2t*}]


########################################
# Constraints for nets
########################################
set_max_transition 0.03 [current_design]

set_false_path -from [get_ports {ctl* rstn en_slice en_sync_in init* ALWS_ON en_sw_test en_clk_v2t_next}]


##############
# False Paths
##############
#set_disable_timing -from in2 -to out [get_cells in_or*_dont_touch]
#set_false_path -to [get_pins in_or*_dont_touch/in2]




