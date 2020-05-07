# Design constraints for synthesis
# time unit : ns
# cap unit: ps
#
#########
# Params
#########
set P_CLK 0.7
set DELTA_T 0.0625 
set P_JTAGCLK 100.0

# primary I/Os being treated as don't touch nets
set analog_io {ext_rx_inp ext_rx_inn ext_Vcm ext_Vcal ext_rx_inp_test ext_rx_inn_test ext_clk_async_p ext_clk_async_n ext_clk_test0_p ext_clk_test0_n ext_clk_test1_p ext_clk_test1_n ext_clkp ext_clkn clk_out_p clk_out_n clk_trig_p clk_trig_n}
set analog_net [get_pins ibuf_*/clk]
set primary_digital_inputs {ext_rstb ext_dump_start jtag_intf_i_phy_tdi jtag_intf_i_phy_tck jtag_intf_i_phy_tms jtag_intf_i_phy_trst_n}

#########
# Clocks
#########
create_clock -name clk_retimer -period $P_CLK [get_pins {iacore/clk_adc}]
create_clock -name clk_in -period $P_CLK [get_ports ext_clkp]
create_clock -name clk_jtag -period $P_JTAGCLK [get_ports jtag_intf_i_phy_tck]
set_dont_touch_network [get_pins {iacore/clk_adc}]
set_dont_touch_network [get_port jtag_intf_i_phy_tck]

set_clock_uncertainty -setup 0.03 clk_retimer
set_clock_uncertainty -hold 0.03 clk_retimer
set_clock_uncertainty -setup 1.00 clk_jtag
set_clock_uncertainty -hold 0.03 clk_jtag


###########
# Net const
###########
set_max_capacitance 0.1 [current_design]
set_max_transition 0.2 [current_design]
set_max_transition 0.1 [all_clocks]
set hs_nets [get_pins {iacore/*pi_out_meas* iacore/*inbuf_out_meas* iacore/*pfd_inp_meas* iacore/*pfd_inn_meas* iacore/*del_out_pi*}]
foreach x [get_object_name $hs_nets] {
	create_clock -name clk_hs_net_$x -period 0.25 [get_pins $x]
	set_max_transition 0.025 [get_clocks clk_hs_net_$x]
}
echo [all_clocks]

###########
# Analog nets
###########
set_dont_touch_network [get_ports $analog_io]
set_dont_touch_network $analog_net
set_dont_touch_network [all_outputs]

###########
# I/O const
###########

set_input_delay 0.05 [get_ports $primary_digital_inputs]
set_input_transition 0.5 [get_ports $primary_digital_inputs]

# data input delay to clk_retimer
#for {set i 0} {$i < 16} {incr i} {
#	set p ""
#	for {set j 0} {$j < 8} {incr j} {
#		set idx [expr 8*$i+$j]
#		lappend p [get_ports idcore/adcout[$idx]]
#	}
#	lappend p [get_ports idcore/adcout_sign[$i]]
#	set_input_delay [expr 0.05+0.0625*$i] -clock clk_retimer $p
#}

#set_input_delay 0.05 -clock clk_retimer [get_ports idcore/adcout*_rep*]

set_input_transition 0.03 [all_inputs]
set_load 0.02 [all_outputs]
set_output_delay $P_CLK [all_outputs]

############
# False path
############
set_false_path -from clk_retimer -to clk_jtag
set_false_path -from clk_jtag -to clk_retimer

################
# DONT USE CELLS
################
foreach lib $mvt_target_libs {
  set_dont_use [file rootname [file tail $lib]]/*D0BWP*
}
