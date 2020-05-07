#########################################
#########################################
# build QTM model for analog_core module
#########################################
#########################################

source pt_qtm.tcl
#report_qtm_model
#current_design analog_core
#set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
report_units
save_qtm_model -format lib -library_cell
exit
