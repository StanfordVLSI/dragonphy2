source -echo -verbose ../../inputs/adk/adk.tcl
read_db ../../inputs/adk/stdcells.db

create_qtm_model output_buffer

set_qtm_global_parameter -param setup -value 0.0
set_qtm_global_parameter -param hold -value 0.0
set_qtm_global_parameter -param clk_to_output -value 0.0

set_qtm_technology -library $::env(qtm_tech_lib)

create_qtm_drive_type -lib_cell $ADK_DRIVING_CELL qtm_drive
create_qtm_load_type -lib_cell $ADK_DRIVING_CELL qtm_load

# define inputs
set input_list { \
    bypass_out_div \
    bypass_trig_div \
    en_outbuff \
    en_trigbuff \
    sel_trigbuff[3:0] \
    bufferend_signals[15:0] \
    Ndiv_trigbuff[2:0] \
    Ndiv_outbuff[2:0] \
    sel_outbuff[3:0] \
}
create_qtm_port $input_list -type input
set_qtm_port_load -type qtm_load -factor 2 $input_list

# define outputs
set output_list { \
    clock_out_n \
    clock_out_p \
    trigg_out_n \
    trigg_out_p \
}
create_qtm_port $output_list -type output
set_qtm_port_drive -type qtm_drive $output_list

report_qtm_model
save_qtm_model -format {lib db} -library_cell

exit