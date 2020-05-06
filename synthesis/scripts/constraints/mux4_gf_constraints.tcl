set MAX_TRAN 0.03
set DELAY 0.06

set_case_analysis 1 [get_ports en_gf]
create_clock -name clk -period [expr $CLK_PERIOD*0.8] [get_pins imux4_dont_touch/IMUX4/Z]
#set_disable_timing -from sel[0] -to out [get_cells imux4_dont_touch]
#set_disable_timing -from sel[1] -to out [get_cells imux4_dont_touch]
set_disable_timing [get_cells imux4_dont_touch]
#set_false_path -from [get_ports in]
#set_false_path -from[get_pins imux4_dont_touch/sel]

set_max_transition $MAX_TRAN [current_design]
#set_max_delay $DELAY -from [get_pins imux4_dont_touch/out] -to [get_pins imux4_dont_touch/sel[0]]
#set_max_delay $DELAY -from [get_pins imux4_dont_touch/out] -to [get_pins imux4_dont_touch/sel[1]]
set_max_delay $DELAY -from [get_clocks clk] -to [get_pins imux4_dont_touch/sel]






