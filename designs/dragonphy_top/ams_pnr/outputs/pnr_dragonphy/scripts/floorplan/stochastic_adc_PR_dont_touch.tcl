
set_dont_touch [get_nets iV2T_clock_gen/iV2T_buffer/clk*]
set_dont_touch [get_nets iV2T_clock_gen/iV2T_buffer/nor*]
set_dont_touch [get_nets iPFD/iinv_chain/inv_out*]
set_dont_touch [get_nets iPFD/iarbiter/q]
set_dont_touch [get_nets iPFD/iarbiter/qb]
set_dont_touch [get_nets idchain/inv_out*]
set_dont_touch_network [get_ports {rx_in* Vcm Vcal *del_out[*}]



