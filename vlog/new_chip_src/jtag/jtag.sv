`default_nettype none

module jtag (
	input wire logic clk,
	input wire logic rstb,
	acore_debug_intf.dcore adbg_intf_i,
	cdr_debug_intf.jtag cdbg_intf_i,
	dcore_debug_intf.jtag ddbg_intf_i,
	sram_debug_intf.jtag sdbg_intf_i,
	jtag_intf.target jtag_intf_i
);
	raw_jtag_ifc_unq1 rjtag_intf_i(.Clk(clk), .Reset(rstb));

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
	assign adbg_intf_i.en_v2t_clk_next=rjtag_intf_i.en_v2t_clk_next;
	assign adbg_intf_i.en_sw_test =rjtag_intf_i.en_sw_test;
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
	assign adbg_intf_i.en_v2t_clk_next_rep=rjtag_intf_i.en_v2t_clk_next_rep;
	assign adbg_intf_i.en_sw_test_rep =rjtag_intf_i.en_sw_test_rep;
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
	assign adbg_intf_i.disable_ibuf_test0 = rjtag_intf_i.disable_ibuf_test0;
	assign adbg_intf_i.disable_ibuf_test1 = rjtag_intf_i.disable_ibuf_test1;

	assign adbg_intf_i.en_inbuf = rjtag_intf_i.en_inbuf;
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
	assign sdbg_intf_i.in_addr = rjtag_intf_i.in_addr;
	assign rjtag_intf_i.addr = sdbg_intf_i.addr;
	//SRAM Output
	assign rjtag_intf_i.out_data = sdbg_intf_i.out_data;


	//CDR Input
	assign cdbg_intf_i.pd_offset_ext = rjtag_intf_i.pd_offset_ext;
	assign cdbg_intf_i.Ki    = rjtag_intf_i.Ki;
	assign cdbg_intf_i.Kp 	 = rjtag_intf_i.Kp;
	assign cdbg_intf_i.en_ext_pi_ctl = rjtag_intf_i.en_ext_pi_ctl;
	assign cdbg_intf_i.ext_pi_ctl = rjtag_intf_i.ext_pi_ctl;
	assign cdbg_intf_i.en_freq_est   = rjtag_intf_i.en_freq_est;
	assign cdbg_intf_i.sample_state = rjtag_intf_i.sample_state;

	//CDR Output
	assign rjtag_intf_i.phase_est    = cdbg_intf_i.phase_est;
	assign rjtag_intf_i.freq_est    = cdbg_intf_i.freq_est;


	//JTAG Interface - Output Buffer Enable is not passed through *
	assign rjtag_intf_i.tck    = jtag_intf_i.phy_tck;
	assign rjtag_intf_i.trst_n = jtag_intf_i.phy_trst_n;
	assign rjtag_intf_i.tms    = jtag_intf_i.phy_tms;
	assign rjtag_intf_i.tdi    = jtag_intf_i.phy_tdi;
	assign jtag_intf_i.phy_tdo     = rjtag_intf_i.tdo;

    raw_jtag act_jtag(.ifc(rjtag_intf_i));
endmodule

`default_nettype wire
