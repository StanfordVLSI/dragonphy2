source -echo -verbose ../../inputs/adk/adk.tcl
read_db ../../inputs/adk/stdcells.db

create_qtm_model input_divider

set_qtm_global_parameter -param setup -value 0.0
set_qtm_global_parameter -param hold -value 0.0
set_qtm_global_parameter -param clk_to_output -value 0.0

set_qtm_technology -library $::env(qtm_tech_lib)

create_qtm_drive_type -lib_cell $ADK_DRIVING_CELL qtm_drive
create_qtm_load_type -lib_cell $ADK_DRIVING_CELL qtm_load

# define clocks
set clock_list { \
    in \
    in_mdll \
}
create_qtm_port $clock_list -type clock
set_qtm_port_load -type qtm_load -factor 2 $clock_list

# define inputs
set input_list { \
    sel_clk_source \
    en \
    en_meas \
    ndiv[2:0] \
    bypass_div \
    bypass_div2 \
}
create_qtm_port $input_list -type input
set_qtm_port_load -type qtm_load -factor 2 $input_list

# define outputs
set output_list { \
    out \
    out_meas \
}
create_qtm_port $output_list -type output
set_qtm_port_drive -type qtm_drive $output_list

# these arcs are required to cause driver information
# to be placed in the resulting *.lib file
create_qtm_delay_arc -from in -edge rise -to out -value 0
create_qtm_delay_arc -from in -edge rise -to out_meas -value 0

report_qtm_model
save_qtm_model -format {lib db} -library_cell

exit
