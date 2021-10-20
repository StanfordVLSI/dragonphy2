
set_dont_touch [get_nets clk_in*]
set_dont_touch [get_nets mclk*]
set_dont_touch [get_nets ph_out*]
set_dont_touch [get_nets iinv_chain*/inv_out*]
set_dont_touch [get_nets {iPM/iPM_sub/xor_in_buff iPM/iPM_sub/xor_ref_buff}]
set_dont_touch [get_nets iarbiter/q]
set_dont_touch [get_nets iarbiter/qb]
set_dont_touch [get_nets iarbiter/in*]
