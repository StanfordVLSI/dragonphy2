set MAX_TRAN 0.03
set LOAD 0.03

create_clock -name clk_pi -period $CLK_PERIOD [get_pins iindiv/out]  
create_clock -name clk_cdr -period $CLK_DIV_PERIOD [get_ports clk_cdr]  
create_clock -name clk_async -period $CLK_DIV_PERIOD [get_ports clk_async] 
set_clock_uncertainty 0.01 [all_clocks]

set_clock_groups -asynchronous -group clk_pi -group clk_async
set_clock_groups -asynchronous -group clk_cdr -group clk_async

set_clock_groups -asynchronous -group clk_pi -group clk_cdr


########################################
# Constraints for input and output pins
########################################
set_input_transition $MAX_TRAN [all_inputs]
set_max_transition $MAX_TRAN [current_design]
set_load $LOAD [all_outputs]  
#set_max_delay 1 [all_outputs] -clock clk_cdr



set_dont_touch {iADC* iPI* iterm* iSnH* iBG* iindiv* }
set_dont_touch_network [get_ports {rx_in* Vcm Vcal ext_clk*}]

#set_false_path -from [get_ports clk_async]
#set_false_path -from [get_clocks clk_pi] -to [get_clocks clk_cdr]
#set_false_path -from [get_clocks clk_pi] -to [get_pins {iPI*/Imuxnet/I22/I22/D}]
#set_false_path -from [get_clocks clk_pi] -to [get_pins {iPI*/IPI_dchain/Iunit*/I48/D}]
#set_false_path -from [get_clocks clk_pi] -to [get_pins {iPI*/IPM/uPMSUB/uXOR1/Z}]

set_false_path -from [get_ports {rx_in* Vcm ctl* Vcal adbg_intf_i.rstb adbg_intf_i.en_* adbg_intf_i.ctl* adbg_intf_i.sel_* adbg_intf_i.del_inc* adbg_intf_i.disable_state* adbg_intf_i.init* adbg_intf_i.ALWS_ON* adbg_intf_i.bypass* adbg_intf_i.inbuf_ndiv*}]




