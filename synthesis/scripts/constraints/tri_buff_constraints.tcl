
set MAX_TRAN 0.005
set LOAD 0.005
set DELAY 0.03

set_case_analysis 1 [get_ports en]
#set_load $LOAD [all_outputs]
#set_load -pin_load $LOAD [get_ports out]
set_max_transition $MAX_TRAN [get_ports out]
set_max_delay $DELAY -from [get_ports in] -to [get_ports out]









