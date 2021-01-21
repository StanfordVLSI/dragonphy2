source -echo -verbose ../../inputs/adk/adk.tcl
read_db ../../inputs/adk/stdcells.db

create_qtm_model termination

set_qtm_global_parameter -param setup -value 0.0
set_qtm_global_parameter -param hold -value 0.0
set_qtm_global_parameter -param clk_to_output -value 0.0

set_qtm_technology -library $::env(qtm_tech_lib)

create_qtm_drive_type -lib_cell $ADK_DRIVING_CELL qtm_drive
create_qtm_load_type -lib_cell $ADK_DRIVING_CELL qtm_load

# define inout(s)
set inout_list { \
    VinP \
    VinN \
    Vcm \
}
create_qtm_port $inout_list -type inout
set_qtm_port_load -type qtm_load -factor 2 $inout_list
set_qtm_port_drive -type qtm_drive $inout_list

report_qtm_model
save_qtm_model -format {lib db} -library_cell

exit
