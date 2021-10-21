# Design constraints for synthesis
# time unit : ns
# cap unit: ps

#########
# Clocks
#########
set CLK_TDC 1 ; 
create_clock -name clk -period $CLK_TDC [get_nets clk] ; 
set_clock_uncertainty -setup 0.02 clk 
set_clock_uncertainty -hold 0.02 clk


########################################
# Constraints for input and output pins
########################################
set_input_transition 0.03 [all_inputs]
#set_load 0.02 [all_outputs] ; # all outputs are driving I/O driver
#set_input_delay 0.2 [all_inputs] -clock clk
#set_output_delay 0.1 [all_outputs] -clock clk

# TODO set max output delays
#set_max_delay [expr $CLK_P_MDLL*2] -to icore/mtune_thm*
#set_max_delay [expr $CLK_P_MDLL*2] -from icore/dout_bb
#set_max_delay [expr $CLK_P_MDLL*2] -from icore/dout_tdc
#set_max_delay [expr $CLK_P_MDLL*2] -from isynth/dither_out

########################################
# Constraints for paths
########################################

########################################
# Constraints for nets
########################################
set_max_transition 0.03 [current_design]
#set_max_transition 0.01 [get_pins */ff_out_reg/D]
#set_max_capacitance 0.1 [current_design]
#set_max_transition 0.05 -clock_path [all_clocks]
#set_max_transition 0.03 Tin
#set_dont_touch_network {ext_frefp ext_frefn ext_frefp_jm ext_frefn_jm}
#set_max_transition 0.05 isynth/iclkgen/ck_aux_osc

##############
# Dont touch
##############
#set_dont_touch { icore irefbuf irefbuf_jm isynth/ijm/uBF* isynth/iclkgen/iaux isynth/iclkgen/ibuffer* ibufferp ibuffern}

##############
# False Paths
##############
#set_false_path -from { en_osc ndiv aux_sel en_aux aux_div bypass_dcdl en_jm ncycle_jm en_ext_tune ctune0 ctune1 ext_mtune m_str aux_tune dith_retime add_off ndiv_fref ndiv_aux ndiv_fout en_dith dith_sel en_dsm_lsb_dith en_inj loop_sel gain_ctrl gain_ratio ref_sel ref_sel_jm sel_ph sel_bb_in bypass_bb bypass_tdc bypass_retimer mdll_reserved } ; 

#set_false_path -to d_in*

#set_false_path -from icore/dout_tdc
#set_false_path -from icore/dout_bb
#set_false_path -from fref_div -to clk_err
#set_false_path -from clk_err -to fref_div
#set_false_path -from fref -to dithclk
#set_false_path -from fref_div -to dithclk

# DONT USE CELLS
foreach lib $mvt_target_libs {
  set_dont_use [file rootname [file tail $lib]]/*D0*
  set_dont_use [file rootname [file tail $lib]]/*SK*
}


#DONT TOUCH
set_dont_touch [get_cells *dont_touch*]




