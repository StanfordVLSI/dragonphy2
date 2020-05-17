create_qtm_model mdll_r1_top

create_qtm_port -type input { fb_ndiv_jtag[3:0] }
set_qtm_port_load -value 0.010000 { fb_ndiv_jtag[3:0] }

create_qtm_port -type input { dco_ctl_offset_jtag[1:0] }
set_qtm_port_load -value 0.010000 { dco_ctl_offset_jtag[1:0] }

create_qtm_port -type input { dco_ctl_track_lv_jtag[9:0]Ö }
set_qtm_port_load -value 0.010000 { dco_ctl_track_lv_jtag[9:0]Ö }

create_qtm_port -type input { dac_ctl_track_lv_jtag[5:0] }
set_qtm_port_load -value 0.010000 { dac_ctl_track_lv_jtag[5:0] }

create_qtm_port -type input { gain_bb_jtag[3:0] }
set_qtm_port_load -value 0.010000 { gain_bb_jtag[3:0] }

create_qtm_port -type input { gain_bb_dac_jtag[3:0] }
set_qtm_port_load -value 0.010000 { gain_bb_dac_jtag[3:0] }

create_qtm_port -type input { sel_sdm_clk_jtag[2:0] }
set_qtm_port_load -value 0.010000 { sel_sdm_clk_jtag[2:0] }

create_qtm_port -type input { fcal_ndiv_ref_jtag[3:0] }
set_qtm_port_load -value 0.010000 { fcal_ndiv_ref_jtag[3:0] }

create_qtm_port -type input { ctl_dac_bw_thm_jtag[6:0] }
set_qtm_port_load -value 0.010000 { ctl_dac_bw_thm_jtag[6:0] }

create_qtm_port -type input { ctlb_dac_gain_oc_jtag[3:0] }
set_qtm_port_load -value 0.010000 { ctlb_dac_gain_oc_jtag[3:0] }

create_qtm_port -type output { fcal_cnt_2jtag[9:0] }
set_qtm_port_drive -value 1.000000 { fcal_cnt_2jtag[9:0] }

create_qtm_port -type output { dco_ctl_fine_mon_2jtag[9:0] }
set_qtm_port_drive -value 1.000000 { dco_ctl_fine_mon_2jtag[9:0] }

create_qtm_port -type output { dac_ctl_mon_2jtag[5:0] }
set_qtm_port_drive -value 1.000000 { dac_ctl_mon_2jtag[5:0] }

create_qtm_port -type input { jm_sel_clk_jtag[2:0] }
set_qtm_port_load -value 0.010000 { jm_sel_clk_jtag[2:0] }

create_qtm_port -type output { jm_cdf_out_2jtag[24:0] }
set_qtm_port_drive -value 1.000000 { jm_cdf_out_2jtag[24:0] }

set single_bit_inputs { \
    clk_refp clk_refn rstn_jtag clk_monp clk_monn en_osc_jtag \
    en_dac_sdm_jtag en_monitor_jtag inj_mode_jtag \
    freeze_lf_dco_track_jtag freeze_lf_dac_track_jtag load_lf_jtag \
    sel_dac_loop_jtag en_hold_jtag load_offset_jtag en_fcal_jtag \
    fcal_start_jtag jm_bb_out_pol_jtag \
}
create_qtm_port -type input $single_bit_inputs
set_qtm_port_load -value 0.010000 $single_bit_inputs

set single_bit_outputs { \
    clk_0 clk_90 clk_180 clk_270 fcal_ready_2jtag jm_clk_fb_out \
}
create_qtm_port -type output $single_bit_outputs
set_qtm_port_drive -value 1.000000 $single_bit_outputs

report_qtm_model
save_qtm_model -format {lib db} -library_cell

exit
