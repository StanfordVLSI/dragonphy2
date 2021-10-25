set MAX_TRAN 0.03
set LOAD 0.02
set DELAY 0.08

set_max_transition $MAX_TRAN [current_design]
set_input_transition [expr $MAX_TRAN/2] [all_inputs]

set_load -pin_load $LOAD [all_outputs]
#set_max_delay $DELAY -fall_from [get_clocks clk_adc] -to [get_ports {v2t_out v2t_outb}]








