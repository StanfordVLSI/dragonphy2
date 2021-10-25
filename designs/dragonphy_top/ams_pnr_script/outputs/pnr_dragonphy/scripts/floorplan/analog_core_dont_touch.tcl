####
set_dont_touch {iADC* iPI* iterm* iSnH* iBG* iindiv* isw_s2d*}
set_dont_touch [get_nets {clk_interp_sw_s2d* clk_interp_swb_s2d*}]
set_dont_touch_network [get_ports {rx_in* Vcm Vcal}]
set_dont_touch [get_ports {*del_out[*] *del_out_rep[*]}]




#
