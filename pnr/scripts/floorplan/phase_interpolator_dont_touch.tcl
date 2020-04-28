
set_dont_touch [get_nets clk_in*]
set_dont_touch [get_nets iinv_chain*/inv_out*]
set_dont_touch [get_nets imux_network/imux4_gf*/out_b]
set_dont_touch [get_nets iPM/iPM_sub/ph*]
set_dont_touch [get_nets iPM/iPM_sub/xor*]
set_dont_touch [get_nets iarbiter/q]
set_dont_touch [get_nets iarbiter/qb]
set_dont_touch [get_nets iarbiter/in*]
