
########################################
# Constraints for input and output pins
########################################
set_input_transition 0.03 [all_inputs]
set_load 0.05 [get_ports out] 
set_load 0.05 [get_ports outb] 

set_max_transition 0.03 [current_design]
set_max_delay 0.03 -from in -to out
set_max_delay 0.03 -from in -to outb


#set_max_transition 0.01 [get_pins */ff_out_reg/D]
#set_max_capacitance 0.1 [current_design]
#set_max_transition 0.05 -clock_path [all_clocks]
#set_max_transition 0.03 Tin
#set_dont_touch_network {ext_frefp ext_frefn ext_frefp_jm ext_frefn_jm}
#set_max_transition 0.05 isynth/iclkgen/ck_aux_osc


#set_false_path -from icore/dout_tdc
#set_false_path -from icore/dout_bb
#set_false_path -from fref_div -to clk_err
#set_false_path -from clk_err -to fref_div
#set_false_path -from fref -to dithclk
#set_false_path -from fref_div -to dithclk





