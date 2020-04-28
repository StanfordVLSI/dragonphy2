set MAX_TRAN 0.02
set LOAD 0.04
set DELAY 0.06

create_clock -name clk -period $CLK_PERIOD [get_pins IMOM/Cbot]  

########################################
# Constraints for input and output pins
########################################
set_load -pin_load $LOAD [get_ports {v2t_out}]
set_propagated_clock [all_clocks]
set_max_transition -clock_path $MAX_TRAN [get_clocks clk]
set_max_delay $DELAY -from [get_pins IMOM/Cbot] -to [get_ports v2t_out]

set_dont_touch [get_nets {Vdch buff* v2t_out nor*}]











