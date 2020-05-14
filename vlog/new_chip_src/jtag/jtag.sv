`default_nettype none

module jtag (
	input wire logic clk,
	input wire logic rstb,
	acore_debug_intf.dcore adbg_intf_i,
	cdr_debug_intf.jtag cdbg_intf_i,
	dcore_debug_intf.jtag ddbg_intf_i,
	sram_debug_intf.jtag sdbg1_intf_i,
	sram_debug_intf.jtag sdbg2_intf_i,
	prbs_debug_intf.jtag pdbg_intf_i,
	wme_debug_intf.jtag wdbg_intf_i,
    mdll_r1_debug_intf.jtag mdbg_intf_i,
	jtag_intf.target jtag_intf_i
);
	raw_jtag_ifc_unq1 rjtag_intf_i(.Clk(clk), .Reset(rstb));

	//Mdll
	assign mdbg_intf_i.rstn_jtag = rstb & rjtag_intf_i.rstn_jtag ;
	assign mdbg_intf_i.en_osc_jtag = rjtag_intf_i.en_osc_jtag ;
	assign mdbg_intf_i.en_dac_sdm_jtag = rjtag_intf_i.en_dac_sdm_jtag ;
	assign mdbg_intf_i.en_monitor_jtag = rjtag_intf_i.en_monitor_jtag ;
	assign mdbg_intf_i.inj_mode_jtag = rjtag_intf_i.inj_mode_jtag ;
	assign mdbg_intf_i.freeze_lf_dco_track_jtag = rjtag_intf_i.freeze_lf_dco_track_jtag ;
	assign mdbg_intf_i.freeze_lf_dac_track_jtag = rjtag_intf_i.freeze_lf_dac_track_jtag ;
	assign mdbg_intf_i.load_lf_jtag = rjtag_intf_i.load_lf_jtag ;
	assign mdbg_intf_i.sel_dac_loop_jtag = rjtag_intf_i.sel_dac_loop_jtag ;
	assign mdbg_intf_i.en_hold_jtag = rjtag_intf_i.en_hold_jtag ;
	assign mdbg_intf_i.fb_ndiv_jtag = rjtag_intf_i.fb_ndiv_jtag ;
  	assign mdbg_intf_i.load_offset_jtag = rjtag_intf_i.load_offset_jtag ;
 	assign mdbg_intf_i.dco_ctl_offset_jtag = rjtag_intf_i.dco_ctl_offset_jtag ;
  	assign mdbg_intf_i.dco_ctl_track_lv_jtag = rjtag_intf_i.dco_ctl_track_lv_jtag ;
  	assign mdbg_intf_i.dac_ctl_track_lv_jtag = rjtag_intf_i.dac_ctl_track_lv_jtag ;
  	assign mdbg_intf_i.gain_bb_jtag = rjtag_intf_i.gain_bb_jtag ;
  	assign mdbg_intf_i.gain_bb_dac_jtag = rjtag_intf_i.gain_bb_dac_jtag ;
 	assign mdbg_intf_i.sel_sdm_clk_jtag = rjtag_intf_i.sel_sdm_clk_jtag ;
  	assign mdbg_intf_i.en_fcal_jtag = rjtag_intf_i.en_fcal_jtag ;
 	assign mdbg_intf_i.fcal_ndiv_ref_jtag = rjtag_intf_i.fcal_ndiv_ref_jtag ;
  	assign mdbg_intf_i.fcal_start_jtag = rjtag_intf_i.fcal_start_jtag ;
  	assign mdbg_intf_i.ctl_dac_bw_thm_jtag = rjtag_intf_i.ctl_dac_bw_thm_jtag ;
  	assign mdbg_intf_i.ctlb_dac_gain_oc_jtag = rjtag_intf_i.ctlb_dac_gain_oc_jtag ;
  	assign mdbg_intf_i.jm_sel_clk_jtag = rjtag_intf_i.jm_sel_clk_jtag ;
  	assign mdbg_intf_i.jm_bb_out_pol_jtag = rjtag_intf_i.jm_bb_out_pol_jtag ;

  	assign rjtag_intf_i.fcal_cnt_2jtag = mdbg_intf_i.fcal_cnt_2jtag ;
  	assign rjtag_intf_i.fcal_ready_2jtag = mdbg_intf_i.fcal_ready_2jtag ;
  	assign rjtag_intf_i.dco_ctl_fine_mon_2jtag = mdbg_intf_i.dco_ctl_fine_mon_2jtag ;
  	assign rjtag_intf_i.dac_ctl_mon_2jtag = mdbg_intf_i.dac_ctl_mon_2jtag ;
  	assign rjtag_intf_i.jm_cdf_out_2jtag = mdbg_intf_i.jm_cdf_out_2jtag ;

	//Analog Input 
	assign adbg_intf_i.rstb   = rstb && ddbg_intf_i.int_rstb;
	assign adbg_intf_i.en_v2t = rjtag_intf_i.en_v2t;
	assign adbg_intf_i.en_slice = rjtag_intf_i.en_slice;
	assign adbg_intf_i.ctl_v2tn = rjtag_intf_i.ctl_v2tn;
	assign adbg_intf_i.ctl_v2tp = rjtag_intf_i.ctl_v2tp;
	assign adbg_intf_i.init = rjtag_intf_i.init;
	assign adbg_intf_i.ALWS_ON = rjtag_intf_i.ALWS_ON;
	assign adbg_intf_i.sel_pm_sign =rjtag_intf_i.sel_pm_sign;
	assign adbg_intf_i.sel_pm_in =rjtag_intf_i.sel_pm_in;
	assign adbg_intf_i.sel_clk_TDC =rjtag_intf_i.sel_clk_TDC;
	assign adbg_intf_i.en_pm =rjtag_intf_i.en_pm;
	assign adbg_intf_i.ctl_dcdl_late=rjtag_intf_i.ctl_dcdl_late;
	assign adbg_intf_i.ctl_dcdl_early=rjtag_intf_i.ctl_dcdl_early;
	assign adbg_intf_i.ctl_dcdl_TDC = rjtag_intf_i.ctl_dcdl_TDC;

	assign adbg_intf_i.en_gf = rjtag_intf_i.en_gf;
	assign adbg_intf_i.en_arb_pi= rjtag_intf_i.en_arb_pi;
	assign adbg_intf_i.en_delay_pi= rjtag_intf_i.en_delay_pi;
	assign adbg_intf_i.en_pm_pi= rjtag_intf_i.en_pm_pi;
	assign adbg_intf_i.en_cal_pi= rjtag_intf_i.en_cal_pi;
	assign adbg_intf_i.ext_Qperi= rjtag_intf_i.ext_Qperi;
	assign adbg_intf_i.en_ext_Qperi = rjtag_intf_i.en_ext_Qperi;
	assign adbg_intf_i.sel_pm_sign_pi= rjtag_intf_i.sel_pm_sign_pi;
	assign adbg_intf_i.del_inc= rjtag_intf_i.del_inc;
	assign adbg_intf_i.ctl_dcdl_slice= rjtag_intf_i.ctl_dcdl_slice;
	assign adbg_intf_i.ctl_dcdl_sw= rjtag_intf_i.ctl_dcdl_sw;
	assign adbg_intf_i.ctl_dcdl_clk_encoder= rjtag_intf_i.ctl_dcdl_clk_encoder;
	assign adbg_intf_i.disable_state= rjtag_intf_i.disable_state;
	assign adbg_intf_i.en_clk_sw= rjtag_intf_i.en_clk_sw;
	assign adbg_intf_i.en_meas_pi=rjtag_intf_i.en_meas_pi;
	assign adbg_intf_i.sel_meas_pi=rjtag_intf_i.sel_meas_pi;

	assign adbg_intf_i.en_slice_rep = rjtag_intf_i.en_slice_rep;
	assign adbg_intf_i.ctl_v2tn_rep = rjtag_intf_i.ctl_v2tn_rep;
	assign adbg_intf_i.ctl_v2tp_rep = rjtag_intf_i.ctl_v2tp_rep;
	assign adbg_intf_i.init_rep = rjtag_intf_i.init_rep;
	assign adbg_intf_i.ALWS_ON_rep = rjtag_intf_i.ALWS_ON_rep;
	assign adbg_intf_i.sel_pm_sign_rep =rjtag_intf_i.sel_pm_sign_rep;
	assign adbg_intf_i.sel_pm_in_rep =rjtag_intf_i.sel_pm_in_rep;
	assign adbg_intf_i.sel_clk_TDC_rep =rjtag_intf_i.sel_clk_TDC_rep;
	assign adbg_intf_i.en_pm_rep =rjtag_intf_i.en_pm_rep;
	assign adbg_intf_i.ctl_dcdl_late_rep=rjtag_intf_i.ctl_dcdl_late_rep;
	assign adbg_intf_i.ctl_dcdl_early_rep=rjtag_intf_i.ctl_dcdl_early_rep;
	assign adbg_intf_i.ctl_dcdl_TDC_rep = rjtag_intf_i.ctl_dcdl_TDC_rep;

	assign adbg_intf_i.sel_pfd_in       = rjtag_intf_i.sel_pfd_in;
	assign adbg_intf_i.sel_pfd_in_meas  = rjtag_intf_i. sel_pfd_in_meas;
	assign adbg_intf_i.en_pfd_inp_meas  = rjtag_intf_i.en_pfd_inp_meas;
	assign adbg_intf_i.en_pfd_inn_meas  = rjtag_intf_i.en_pfd_inn_meas;
	assign adbg_intf_i.sel_del_out      = rjtag_intf_i.sel_del_out;

	assign adbg_intf_i.disable_ibuf_async = rjtag_intf_i.disable_ibuf_async;
	assign adbg_intf_i.disable_ibuf_main   = rjtag_intf_i.disable_ibuf_main;
	assign adbg_intf_i.disable_ibuf_mdll_ref = rjtag_intf_i.disable_ibuf_mdll_ref;
	assign adbg_intf_i.disable_ibuf_mdll_mon = rjtag_intf_i.disable_ibuf_mdll_mon;

	assign adbg_intf_i.en_inbuf = rjtag_intf_i.en_inbuf;
	assign adbg_intf_i.sel_clk_source = rjtag_intf_i.sel_clk_source;
	assign adbg_intf_i.bypass_inbuf_div = rjtag_intf_i.bypass_inbuf_div;
	assign adbg_intf_i.bypass_inbuf_div2 = rjtag_intf_i.bypass_inbuf_div2;
	assign adbg_intf_i.inbuf_ndiv = rjtag_intf_i.inbuf_ndiv;
	assign adbg_intf_i.en_inbuf_meas = rjtag_intf_i.en_inbuf_meas;
	assign adbg_intf_i.en_biasgen = rjtag_intf_i.en_biasgen;
	assign adbg_intf_i.ctl_biasgen = rjtag_intf_i.ctl_biasgen;

	assign adbg_intf_i.sel_del_out_pi = rjtag_intf_i.sel_del_out_pi;
	assign adbg_intf_i.en_del_out_pi  = rjtag_intf_i.en_del_out_pi;

    assign adbg_intf_i.en_TDC_phase_reverse = rjtag_intf_i.en_TDC_phase_reverse;

	//Analog Output

	assign rjtag_intf_i.pm_out = adbg_intf_i.pm_out;
	
	assign rjtag_intf_i.pm_out_pi = adbg_intf_i.pm_out_pi;
	assign rjtag_intf_i.cal_out_pi = adbg_intf_i.cal_out_pi;
	assign rjtag_intf_i.Qperi 		= adbg_intf_i.Qperi;
	assign rjtag_intf_i.max_sel_mux= adbg_intf_i.max_sel_mux;

	assign rjtag_intf_i.pm_out_rep = adbg_intf_i.pm_out_rep;

	//Digital Input
	assign ddbg_intf_i.ext_pi_ctl_offset = rjtag_intf_i.ext_pi_ctl_offset;
	assign ddbg_intf_i.en_ext_pfd_offset = rjtag_intf_i.en_ext_pfd_offset;
	assign ddbg_intf_i.en_bypass_pi_ctl  = rjtag_intf_i.en_bypass_pi_ctl;
	assign ddbg_intf_i.bypass_pi_ctl     = rjtag_intf_i.bypass_pi_ctl;
	assign ddbg_intf_i.ext_pfd_offset=rjtag_intf_i.ext_pfd_offset;
	assign ddbg_intf_i.en_ext_pfd_offset_rep=rjtag_intf_i.en_ext_pfd_offset_rep;
	assign ddbg_intf_i.ext_pfd_offset_rep=rjtag_intf_i.ext_pfd_offset_rep;
	assign ddbg_intf_i.en_ext_max_sel_mux=rjtag_intf_i.en_ext_max_sel_mux;
	assign ddbg_intf_i.ext_max_sel_mux=rjtag_intf_i.ext_max_sel_mux;
	assign ddbg_intf_i.en_pfd_cal=rjtag_intf_i.en_pfd_cal;
	assign ddbg_intf_i.en_pfd_cal_rep=rjtag_intf_i.en_pfd_cal_rep;
	assign ddbg_intf_i.Navg_adc=rjtag_intf_i.Navg_adc;
	assign ddbg_intf_i.Nbin_adc=rjtag_intf_i.Nbin_adc;
	assign ddbg_intf_i.Ndiv_clk_avg=rjtag_intf_i.Ndiv_clk_avg;
	assign ddbg_intf_i.DZ_hist_adc=rjtag_intf_i.DZ_hist_adc;
	assign ddbg_intf_i.Navg_adc_rep=rjtag_intf_i.Navg_adc_rep;
	assign ddbg_intf_i.Nbin_adc_rep=rjtag_intf_i.Nbin_adc_rep;
	assign ddbg_intf_i.DZ_hist_adc_rep=rjtag_intf_i.DZ_hist_adc_rep;
	assign ddbg_intf_i.int_rstb = rjtag_intf_i.int_rstb;
	assign ddbg_intf_i.Ndiv_clk_cdr  		  = rjtag_intf_i.Ndiv_clk_cdr;
	assign ddbg_intf_i.sel_outbuff   = rjtag_intf_i.sel_outbuff;
	assign ddbg_intf_i.sel_trigbuff  = rjtag_intf_i.sel_trigbuff;
	assign ddbg_intf_i.en_outbuff    = rjtag_intf_i.en_outbuff;
	assign ddbg_intf_i.en_trigbuff   = rjtag_intf_i.en_trigbuff;
	assign ddbg_intf_i.Ndiv_outbuff  = rjtag_intf_i.Ndiv_outbuff;
	assign ddbg_intf_i.Ndiv_trigbuff = rjtag_intf_i.Ndiv_trigbuff;
	assign ddbg_intf_i.bypass_trig   = rjtag_intf_i.bypass_trig;
	assign ddbg_intf_i.bypass_out    = rjtag_intf_i.bypass_out;
	assign ddbg_intf_i.sram_rstb 	 = rjtag_intf_i.sram_rstb;
	assign ddbg_intf_i.cdr_rstb 	 = rjtag_intf_i.cdr_rstb;
    assign ddbg_intf_i.prbs_rstb 	 = rjtag_intf_i.prbs_rstb;

	assign ddbg_intf_i.disable_product	= rjtag_intf_i.disable_product;
	assign ddbg_intf_i.ffe_shift		= rjtag_intf_i.ffe_shift;
	assign ddbg_intf_i.mlsd_shift		= rjtag_intf_i.mlsd_shift;
	assign ddbg_intf_i.cmp_thresh		= rjtag_intf_i.cmp_thresh;
	assign ddbg_intf_i.ffe_thresh		= rjtag_intf_i.ffe_thresh;
	assign ddbg_intf_i.adc_thresh		= rjtag_intf_i.adc_thresh;
	assign ddbg_intf_i.sel_prbs_mux		= rjtag_intf_i.sel_prbs_mux;
	assign ddbg_intf_i.retimer_mux_ctrl_1 = rjtag_intf_i.retimer_mux_ctrl_1;
	assign ddbg_intf_i.retimer_mux_ctrl_2 = rjtag_intf_i.retimer_mux_ctrl_2;


	//Digital Output
	assign rjtag_intf_i.adcout_avg=ddbg_intf_i.adcout_avg;
	assign rjtag_intf_i.adcout_sum=ddbg_intf_i.adcout_sum;
	assign rjtag_intf_i.adcout_hist_center=ddbg_intf_i.adcout_hist_center;
	assign rjtag_intf_i.adcout_hist_side=ddbg_intf_i.adcout_hist_side;
	assign rjtag_intf_i.pfd_offset=ddbg_intf_i.pfd_offset;
	assign rjtag_intf_i.adcout_avg_rep=ddbg_intf_i.adcout_avg_rep;
	assign rjtag_intf_i.adcout_sum_rep=ddbg_intf_i.adcout_sum_rep;
	assign rjtag_intf_i.adcout_hist_center_rep=ddbg_intf_i.adcout_hist_center_rep;
	assign rjtag_intf_i.adcout_hist_side_rep=ddbg_intf_i.adcout_hist_side_rep;
	assign rjtag_intf_i.pfd_offset_rep=ddbg_intf_i.pfd_offset_rep;
	
	//SRAM Input
	assign sdbg1_intf_i.in_addr = rjtag_intf_i.in_addr_multi;
	assign rjtag_intf_i.addr_multi = sdbg1_intf_i.addr;
	//SRAM Output
	assign rjtag_intf_i.out_data_multi = sdbg1_intf_i.out_data;

	//SRAM Input FFE/MLSD
	assign sdbg2_intf_i.in_addr = rjtag_intf_i.in_addr_multi_ffe;
	assign rjtag_intf_i.addr_multi_ffe = sdbg2_intf_i.addr;
	//SRAM Output FFE/MLSD
	assign rjtag_intf_i.out_data_multi_ffe = sdbg2_intf_i.out_data;


	//CDR Input
	assign cdbg_intf_i.pd_offset_ext = rjtag_intf_i.pd_offset_ext;
	assign cdbg_intf_i.Ki    = rjtag_intf_i.Ki;
	assign cdbg_intf_i.Kp 	 = rjtag_intf_i.Kp;
	assign cdbg_intf_i.Kr 	 = rjtag_intf_i.Kr;
	assign cdbg_intf_i.en_ext_pi_ctl = rjtag_intf_i.en_ext_pi_ctl;
	assign cdbg_intf_i.ext_pi_ctl    = rjtag_intf_i.ext_pi_ctl;
	assign cdbg_intf_i.en_freq_est   = rjtag_intf_i.en_freq_est;
	assign cdbg_intf_i.en_ramp_est   = rjtag_intf_i.en_ramp_est;
	assign cdbg_intf_i.sel_inp_mux  = rjtag_intf_i.sel_inp_mux;
	assign cdbg_intf_i.sample_state = rjtag_intf_i.sample_state;
	assign cdbg_intf_i.invert = rjtag_intf_i.invert;

	//CDR Output
	assign rjtag_intf_i.phase_est   = cdbg_intf_i.phase_est;
	assign rjtag_intf_i.freq_est    = cdbg_intf_i.freq_est;
	assign rjtag_intf_i.ramp_est    = cdbg_intf_i.ramp_est;



    // PRBS Input
    assign pdbg_intf_i.prbs_cke = rjtag_intf_i.prbs_cke;
    assign pdbg_intf_i.prbs_eqn = rjtag_intf_i.prbs_eqn;
    assign pdbg_intf_i.prbs_chan_sel = rjtag_intf_i.prbs_chan_sel;
    assign pdbg_intf_i.prbs_inv_chicken = rjtag_intf_i.prbs_inv_chicken;
    assign pdbg_intf_i.prbs_checker_mode = rjtag_intf_i.prbs_checker_mode;
    // PRBS Output
    assign rjtag_intf_i.prbs_err_bits_upper = pdbg_intf_i.prbs_err_bits_upper;
    assign rjtag_intf_i.prbs_err_bits_lower = pdbg_intf_i.prbs_err_bits_lower;
    assign rjtag_intf_i.prbs_total_bits_upper = pdbg_intf_i.prbs_total_bits_upper;
    assign rjtag_intf_i.prbs_total_bits_lower = pdbg_intf_i.prbs_total_bits_lower;

    //WME Input
    assign wdbg_intf_i.wme_ffe_data  = rjtag_intf_i.wme_ffe_data;
    assign wdbg_intf_i.wme_ffe_inst  = rjtag_intf_i.wme_ffe_inst;
    assign wdbg_intf_i.wme_ffe_exec  = rjtag_intf_i.wme_ffe_exec;
    assign wdbg_intf_i.wme_mlsd_data = rjtag_intf_i.wme_mlsd_data;
    assign wdbg_intf_i.wme_mlsd_inst = rjtag_intf_i.wme_mlsd_inst;
    assign wdbg_intf_i.wme_mlsd_exec = rjtag_intf_i.wme_mlsd_exec;
    assign rjtag_intf_i.wme_ffe_read  = wdbg_intf_i.wme_ffe_read;
    assign rjtag_intf_i.wme_mlsd_read = wdbg_intf_i.wme_mlsd_read;

	//JTAG Interface - Output Buffer Enable is not passed through *
	assign rjtag_intf_i.tck    = jtag_intf_i.phy_tck;
	assign rjtag_intf_i.trst_n = jtag_intf_i.phy_trst_n;
	assign rjtag_intf_i.tms    = jtag_intf_i.phy_tms;
	assign rjtag_intf_i.tdi    = jtag_intf_i.phy_tdi;
	assign jtag_intf_i.phy_tdo     = rjtag_intf_i.tdo;

    raw_jtag act_jtag(.ifc(rjtag_intf_i));
endmodule

`default_nettype wire
