create_qtm_model mdll_r1_top
create_qtm_port {clk_refp clk_refn clk_monp clk_monn rstn_jtag en_osc_jtag en_dac_sdm_jtag en_monitor_jtag inj_mode_jtag freeze_lf_dco_track_jtag freeze_lf_dac_track_jtag load_lf_jtag sel_dac_loop_jtag en_hold_jtag fb_ndiv_jtag[3:0] load_offset_jtag dco_ctl_offset_jtag[1:0] dco_ctl_track_lv_jtag[7:0] dac_ctl_track_lv_jtag[5:0] gain_bb_jtag[3:0] gain_bb_dac_jtag[3:0] sel_sdm_clk_jtag[2:0] en_fcal_jtag fcal_ndiv_ref_jtag[3:0] fcal_start_jtag ctl_dac_bw_thm_jtag[6:0] ctlb_dac_gain_oc_jtag[3:0] jm_sel_clk_jtag[2:0] jm_bb_out_pol_jtag} -type input
create_qtm_port {fcal_cnt_2jtag[9:0] fcal_ready_2jtag dco_ctl_fine_mon_2jtag[7:0] dac_ctl_mon_2jtag[7:0] jm_cdf_out_2jtag[24:0] jm_clk_fb_out} -type output
set_qtm_port_load {clk_refp clk_refn clk_monp clk_monn rstn_jtag en_osc_jtag en_dac_sdm_jtag en_monitor_jtag inj_mode_jtag freeze_lf_dco_track_jtag freeze_lf_dac_track_jtag load_lf_jtag sel_dac_loop_jtag en_hold_jtag fb_ndiv_jtag[3:0] load_offset_jtag dco_ctl_offset_jtag[1:0] dco_ctl_track_lv_jtag[7:0] dac_ctl_track_lv_jtag[5:0] gain_bb_jtag[3:0] gain_bb_dac_jtag[3:0] sel_sdm_clk_jtag[2:0] en_fcal_jtag fcal_ndiv_ref_jtag[3:0] fcal_start_jtag ctl_dac_bw_thm_jtag[6:0] ctlb_dac_gain_oc_jtag[3:0] jm_sel_clk_jtag[2:0] jm_bb_out_pol_jtag} -value 0.02
set_qtm_port_drive {fcal_cnt_2jtag[9:0] fcal_ready_2jtag dco_ctl_fine_mon_2jtag[7:0] dac_ctl_mon_2jtag[7:0] jm_cdf_out_2jtag[24:0] jm_clk_fb_out} -value 100
redirect qtm.rpt report_qtm_model
save_qtm_model -format {lib db} -library_cell
exit
