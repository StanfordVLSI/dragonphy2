
#set_dont_touch [get_nets {Iosc_core/* Iosc_core/* Iosc_core/*/* Iosc_core/*/*}]
set_dont_touch [get_nets {Iosc_core/pul* Iinput_network/pul* }]

#set_dont_touch [get_cells {Iosc_core/Idcdl_fine/* }] 
#set_dont_touch [get_nets {Iosc_core/Idcdl_fine/mux_out* Iosc_core/sampb Iosc_core/sampb_d } ]
set_dont_touch {Iosc_core/Idcdl_fine*} 

set_dont_touch [get_cells {Iinput_network/Iff_in1 Iinput_network/Iff_in2 Iinput_network/Inor_in Iinput_network/Inand_in Iinput_network/Inand_lat*  Iinput_network/Iinv_lat1  Iinput_network/Iinv_lat2 Iinput_network/Iinv_in1 Iinput_network/Iinv_in2}]
set_dont_touch [get_nets {Iinput_network/Tin*  Iinput_network/lat*  Iinput_network/net143 Iinput_network/net144}]

set_dont_touch [get_nets {Iosc_core/Y* Iosc_core/mid3}]
set_dont_touch [get_cells {Iosc_core/Inand_skew Iosc_core/mux_samp}]

set_dont_touch [get_nets {Iosc_core/net053 Iosc_core/net063 Iosc_core/samp}]
set_dont_touch [get_nets {start stop}]

