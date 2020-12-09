source -echo -verbose ../../inputs/adk/adk.tcl
read_db ../../inputs/adk/stdcells.db

create_qtm_model mdll_r1_top

set_qtm_technology -library $::env(qtm_tech_lib)

set_qtm_global_parameter -param setup -value 0.0
set_qtm_global_parameter -param hold -value 0.0
set_qtm_global_parameter -param clk_to_output -value 0.0

if { $::env(qtm_tech_lib) == "NangateOpenCellLibrary" } {
    create_qtm_drive_type -lib_cell $ADK_DRIVING_CELL qtm_drive
} else {
    create_qtm_drive_type -lib_cell INVD0BWP16P90 qtm_drive
}

create_qtm_load_type -lib_cell $ADK_DRIVING_CELL qtm_load

# define clocks
set clock_list { \
    clk_refp \
    clk_refn \
    clk_monp \
    clk_monn \
}
create_qtm_port $clock_list -type clock
set_qtm_port_load -type qtm_load -factor 2 $clock_list

# define inputs
set input_list { \
    fb_ndiv_jtag[3:0] \
    dco_ctl_offset_jtag[1:0] \
    dco_ctl_track_lv_jtag[9:0] \
    dac_ctl_track_lv_jtag[5:0] \
    gain_bb_jtag[3:0] \
    gain_bb_dac_jtag[3:0] \
    sel_sdm_clk_jtag[2:0] \
    fcal_ndiv_ref_jtag[3:0] \
    ctl_dac_bw_thm_jtag[6:0] \
    ctlb_dac_gain_oc_jtag[3:0] \
    jm_sel_clk_jtag[2:0] \
    rstn_jtag \
    en_osc_jtag \
    en_dac_sdm_jtag \
    en_monitor_jtag \
    inj_mode_jtag \
    freeze_lf_dco_track_jtag \
    freeze_lf_dac_track_jtag \
    load_lf_jtag \
    sel_dac_loop_jtag \
    en_hold_jtag \
    load_offset_jtag \
    en_fcal_jtag \
    fcal_start_jtag \
    jm_bb_out_pol_jtag \
}
create_qtm_port $input_list -type input
set_qtm_port_load -type qtm_load -factor 2 $input_list

# define outputs
set output_list { \
    fcal_cnt_2jtag[9:0] \
    dco_ctl_fine_mon_2jtag[9:0] \
    dac_ctl_mon_2jtag[5:0] \
    jm_cdf_out_2jtag[24:0] \
    clk_0 \
    clk_90 \
    clk_180 \
    clk_270 \
    fcal_ready_2jtag \
    jm_clk_fb_out \
}
create_qtm_port $output_list -type output
set_qtm_port_drive -type qtm_drive $output_list

# these arcs are required to cause driver information
# to be placed in the resulting *.lib file
create_qtm_delay_arc -from clk_refp -edge rise -to clk_0 -value 0
create_qtm_delay_arc -from clk_refp -edge rise -to clk_90 -value 0
create_qtm_delay_arc -from clk_refp -edge rise -to clk_180 -value 0
create_qtm_delay_arc -from clk_refp -edge rise -to clk_270 -value 0

report_qtm_model
save_qtm_model -format {lib db} -library_cell

exit
