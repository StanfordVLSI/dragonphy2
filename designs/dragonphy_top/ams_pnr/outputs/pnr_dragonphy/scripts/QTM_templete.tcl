create_qtm_model DesignName
create_qtm_port INPUT_PORT -type input
create_qtm_port OUTPUT_PORT -type output
set_qtm_port_load INPUT_PORT -value INPUT_CAP
set_qtm_port_drive OUTPUT_PORT -value OUTPUT_RES
redirect qtm.rpt report_qtm_model
save_qtm_model -format {lib db} -library_cell
exit
