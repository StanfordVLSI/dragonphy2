source -echo -verbose ../../inputs/adk/adk.tcl
read_db ../../inputs/adk/stdcells.db

create_qtm_model phase_interpolator

set_qtm_global_parameter -param setup -value 0.0
set_qtm_global_parameter -param hold -value 0.0
set_qtm_global_parameter -param clk_to_-value 0.0

set_qtm_technology -library $::env(qtm_tech_lib)

create_qtm_drive_type -lib_cell $ADK_DRIVING_CELL qtm_drive
create_qtm_load_type -lib_cell $ADK_DRIVING_CELL qtm_load

# define inputs
set input_list { \
	rstb \
    clk_in \
    clk_async \
    clk_encoder \
    disable_state \
    en_arb \
    en_cal \
    en_clk_sw \
    en_delay \
    en_ext_Qperi \
    en_gf \
    ctl_valid \
    ctl[8:0] \
    ctl_dcdl_sw[1:0]\
    ctl_dcdl_slice[1:0] \
    ctl_dcdl_clk_encoder[1:0] \
    inc_del[31:0] \
    en_unit[31:0] \
    ext_Qperi[4:0] \
    sel_pm_sign[1:0] \
    en_pm \
}
create_qtm_port $input_list -type input
set_qtm_port_load -type qtm_load -factor 2 $input_list

# define outputs
set output_list { \
	cal_out \
    clk_out_slice \
    clk_out_sw \
    del_out \
    Qperi[4:0] \
    max_sel_mux[4:0] \
    cal_out_dmm \
    pm_out[19:0] \
}
create_qtm_port $output_list -type output
set_qtm_port_drive -type qtm_drive $output_list

report_qtm_model
save_qtm_model -format {lib db} -library_cell

exit
