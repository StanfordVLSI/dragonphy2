

set_max_transition 0.02 [current_design]
set_case_analysis 1 [get_ports en_gf]

set_disable_timing -from S0 -to Z [get_cells -hierarchical *IMUX4]
set_disable_timing -from S1 -to Z [get_cells -hierarchical *IMUX4]

create_clock -name mux_out_0 -period 0.25 [get_pins imux_network/imux4_gf_2nd_even/imux4_dont_touch/IMUX4/Z]
create_clock -name mux_out_1 -period 0.25 [get_pins imux_network/imux4_gf_2nd_odd/imux4_dont_touch/IMUX4/Z]

create_clock -name mux_out_2 -period 0.25 [get_pins imux_network/imux4_gf_1st[3].odd/imux4_dont_touch/IMUX4/Z]
create_clock -name mux_out_3 -period 0.25 [get_pins imux_network/imux4_gf_1st[3].even/imux4_dont_touch/IMUX4/Z]
create_clock -name mux_out_4 -period 0.25 [get_pins imux_network/imux4_gf_1st[2].odd/imux4_dont_touch/IMUX4/Z]
create_clock -name mux_out_5 -period 0.25 [get_pins imux_network/imux4_gf_1st[2].even/imux4_dont_touch/IMUX4/Z]
create_clock -name mux_out_6 -period 0.25 [get_pins imux_network/imux4_gf_1st[1].odd/imux4_dont_touch/IMUX4/Z]
create_clock -name mux_out_7 -period 0.25 [get_pins imux_network/imux4_gf_1st[1].even/imux4_dont_touch/IMUX4/Z]
create_clock -name mux_out_8 -period 0.25 [get_pins imux_network/imux4_gf_1st[0].odd/imux4_dont_touch/IMUX4/Z]
create_clock -name mux_out_9 -period 0.25 [get_pins imux_network/imux4_gf_1st[0].even/imux4_dont_touch/IMUX4/Z]

set_max_delay 0.05 -from [get_clocks mux_out_0] -to [get_pins imux_network/imux4_gf_2nd_even/imux4_dont_touch/IMUX4/S*]
set_max_delay 0.05 -from [get_clocks mux_out_1] -to [get_pins imux_network/imux4_gf_2nd_odd/imux4_dont_touch/IMUX4/S*]

set_max_delay 0.05 -from [get_clocks mux_out_2] -to [get_pins imux_network/imux4_gf_1st[3].odd/imux4_dont_touch/IMUX4/S*]
set_max_delay 0.05 -from [get_clocks mux_out_3] -to [get_pins imux_network/imux4_gf_1st[3].even/imux4_dont_touch/IMUX4/S*]
set_max_delay 0.05 -from [get_clocks mux_out_4] -to [get_pins imux_network/imux4_gf_1st[2].odd/imux4_dont_touch/IMUX4/S*]
set_max_delay 0.05 -from [get_clocks mux_out_5] -to [get_pins imux_network/imux4_gf_1st[2].even/imux4_dont_touch/IMUX4/S*]
set_max_delay 0.05 -from [get_clocks mux_out_6] -to [get_pins imux_network/imux4_gf_1st[1].odd/imux4_dont_touch/IMUX4/S*]
set_max_delay 0.05 -from [get_clocks mux_out_7] -to [get_pins imux_network/imux4_gf_1st[1].even/imux4_dont_touch/IMUX4/S*]
set_max_delay 0.05 -from [get_clocks mux_out_8] -to [get_pins imux_network/imux4_gf_1st[0].odd/imux4_dont_touch/IMUX4/S*]
set_max_delay 0.05 -from [get_clocks mux_out_9] -to [get_pins imux_network/imux4_gf_1st[0].even/imux4_dont_touch/IMUX4/S*]



