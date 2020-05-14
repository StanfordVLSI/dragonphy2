`include "iotype.sv"

`default_nettype none

module dragonphy_top import const_pack::*; (
	// analog inputs
	input `pwl_t ext_rx_inp,
	input `pwl_t ext_rx_inn,
	input `real_t ext_Vcm,
	inout `voltage_t ext_Vcal,
	input `pwl_t ext_rx_inp_test,
	input `pwl_t ext_rx_inn_test,

	// clock inputs 
	input wire logic ext_clk_async_p,
	input wire logic ext_clk_async_n,
	
	input wire logic ext_clkp,
	input wire logic ext_clkn,
	
	input wire logic ext_mdll_clk_refp,
	input wire logic ext_mdll_clk_refn,
	input wire logic ext_mdll_clk_monp,
	input wire logic ext_mdll_clk_monn,
	
	input wire logic ramp_clock,

	// clock outputs
	output wire logic clk_out_p,
	output wire logic clk_out_n,
	output wire logic clk_trig_p,
	output wire logic clk_trig_n,

	output wire logic freq_lvl_cross,

	//Reset Logic
	input wire logic ext_rstb,

	// dump control
	input wire logic ext_dump_start,

	// JTAG
	jtag_intf.target jtag_intf_i
);
	// analog core debug interface
	acore_debug_intf adbg_intf_i ();
	mdll_r1_debug_intf mdbg_intf_i ();

	// async clock buffer
	logic clk_async;
	input_buffer ibuf_async (
		.inp(ext_clk_async_p),
		.inm(ext_clk_async_n),
		.pd(adbg_intf_i.disable_ibuf_async),
		.clk(clk_async),
		.clk_b() // unused output
	);

    // main clock buffer
    logic clk_main;
	input_buffer ibuf_main (
		.inp(ext_clkp),
		.inm(ext_clkn),
		.pd(adbg_intf_i.disable_ibuf_main),
		.clk(clk_main),
		.clk_b() // unused output
	);

    // MDLL reference clock
    logic mdll_clk_refp, mdll_clk_refn;
	input_buffer ibuf_mdll_ref (
		.inp(ext_mdll_clk_refp),
		.inm(ext_mdll_clk_refn),
		.pd(adbg_intf_i.disable_ibuf_mdll_ref),
		.clk(mdll_clk_refp),
		.clk_b(mdll_clk_refn)
	);

    // MDLL monitor clock
	logic mdll_clk_monp, mdll_clk_monn;
	input_buffer ibuf_mdll_mon (
		.inp(ext_mdll_clk_monp),
		.inm(ext_mdll_clk_monn),
		.pd(adbg_intf_i.disable_ibuf_mdll_mon),
		.clk(mdll_clk_monp),
		.clk_b(mdll_clk_monn)
	);

    // MDLL outputs
    logic mdll_clk_out;
    logic mdll_jm_clk_fb_out;

    // PI control signals
    logic [Npi-1:0] pi_ctl_cdr [Nout-1:0];
    logic ctl_valid;

    // ADC signals
    logic clk_adc;
    logic [Nadc-1:0] adcout [Nti-1:0];
    logic [Nti-1:0] adcout_sign;
    logic [Nadc-1:0] adcout_rep [Nti_rep-1:0];
    logic [Nti_rep-1:0] adcout_sign_rep;

// temp setting for sim ultil DCORE is fixed -------------
    assign ctl_valid = 1;
//--------------------------------------------------------
	
	// Analog core instantiation
	analog_core iacore (
		.rx_inp(ext_rx_inp),              // RX input (+)
		.rx_inn(ext_rx_inn),              // RX input (-)
		.Vcm(ext_Vcm),

		.rx_inp_test(ext_rx_inp_test),
		.rx_inn_test(ext_rx_inn_test),

		.ext_clk(clk_main),                  // External clock
		.mdll_clk(mdll_clk_out),             // clock from MDLL
		.ext_clk_test0(1'b0),                // ibuf_test0 was removed...
		.ext_clk_test1(1'b0),                // ibuf_test1 was removed...
		.clk_async(clk_async),
		.ctl_pi(pi_ctl_cdr),                 // PI control code from CDR
		.ctl_valid(ctl_valid),               // PI control valid flag from CDR

		.Vcal(ext_Vcal),

		.clk_adc(clk_adc),                   // clock for retiming adc data
		.adder_out(adcout),                  // adc output
		.sign_out(adcout_sign),
		.adder_out_rep(adcout_rep),          // adc output
		.sign_out_rep(adcout_sign_rep),

		.adbg_intf_i(adbg_intf_i)            // debug IO
	);
	
	// digital core instantiation

	digital_core idcore (
		.clk_adc(clk_adc),                   // clock for retiming adc data
		.adcout(adcout), 	
		.adcout_sign(adcout_sign),
		.adcout_rep(adcout_rep), 	
		.adcout_sign_rep(adcout_sign_rep),
		.ext_rstb(ext_rstb),
		.clock_out_p(clk_out_p),
    	.clock_out_n(clk_out_n),
    	.trigg_out_p(clk_trig_p),
    	.trigg_out_n(clk_trig_n),
    	.clk_async(clk_async),
		.ctl_valid(ctl_valid), // port should be removed and replaced with ctl_valid!
		.mdll_clk(mdll_clk_out),             // goes to output buffer
		.mdll_jm_clk(mdll_jm_clk_fb_out),    // goes to output buffer
		.int_pi_ctl_cdr(pi_ctl_cdr),         // PI control code from CDR
		.ramp_clock(ramp_clock),
		.freq_lvl_cross(freq_lvl_cross),
		.ext_dump_start(ext_dump_start),

		.adbg_intf_i(adbg_intf_i),		
		.jtag_intf_i(jtag_intf_i),
    	.mdbg_intf_i(mdbg_intf_i)
	);


	 mdll_r1_top imdll (
        .clk_refp(mdll_clk_refp),
        .clk_refn(mdll_clk_refn),
        .rstn_jtag(mdbg_intf_i.rstn_jtag),
        .clk_monp(mdll_clk_monp),
        .clk_monn(mdll_clk_monn),
        .en_osc_jtag(mdbg_intf_i.en_osc_jtag),
        .en_dac_sdm_jtag(mdbg_intf_i.en_dac_sdm_jtag),
        .en_monitor_jtag(mdbg_intf_i.en_monitor_jtag),
        .inj_mode_jtag(mdbg_intf_i.inj_mode_jtag),
        .freeze_lf_dco_track_jtag(mdbg_intf_i.freeze_lf_dco_track_jtag),
        .freeze_lf_dac_track_jtag(mdbg_intf_i.freeze_lf_dac_track_jtag),
        .load_lf_jtag(mdbg_intf_i.load_lf_jtag),
        .sel_dac_loop_jtag(mdbg_intf_i.sel_dac_loop_jtag),
    	.en_hold_jtag(mdbg_intf_i.en_hold_jtag),
        .fb_ndiv_jtag(mdbg_intf_i.fb_ndiv_jtag),
        .load_offset_jtag(mdbg_intf_i.load_offset_jtag),
        .dco_ctl_offset_jtag(mdbg_intf_i.dco_ctl_offset_jtag),
        .dco_ctl_track_lv_jtag(mdbg_intf_i.dco_ctl_track_lv_jtag),
        .dac_ctl_track_lv_jtag(mdbg_intf_i.dac_ctl_track_lv_jtag),
        .gain_bb_jtag(mdbg_intf_i.gain_bb_jtag),
        .gain_bb_dac_jtag(mdbg_intf_i.gain_bb_dac_jtag),
        .sel_sdm_clk_jtag(mdbg_intf_i.sel_sdm_clk_jtag),
        .en_fcal_jtag(mdbg_intf_i.en_fcal_jtag),
        .fcal_ndiv_ref_jtag(mdbg_intf_i.fcal_ndiv_ref_jtag),
        .fcal_start_jtag(mdbg_intf_i.fcal_start_jtag),
        .ctl_dac_bw_thm_jtag(mdbg_intf_i.ctl_dac_bw_thm_jtag),
        .ctlb_dac_gain_oc_jtag(mdbg_intf_i.ctlb_dac_gain_oc_jtag),
        .jm_sel_clk_jtag(mdbg_intf_i.jm_sel_clk_jtag),
        .jm_bb_out_pol_jtag(mdbg_intf_i.jm_bb_out_pol_jtag),

        .clk_0(mdll_clk_out),
        .clk_90(),
        .clk_180(),
        .clk_270(),
        .fcal_cnt_2jtag(mdbg_intf_i.fcal_cnt_2jtag),
        .fcal_ready_2jtag(mdbg_intf_i.fcal_ready_2jtag),
        .dco_ctl_fine_mon_2jtag(mdbg_intf_i.dco_ctl_fine_mon_2jtag),
        .dac_ctl_mon_2jtag(mdbg_intf_i.dac_ctl_mon_2jtag),
        .jm_clk_fb_out(mdll_jm_clk_fb_out),
        .jm_cdf_out_2jtag(mdbg_intf_i.jm_cdf_out_2jtag)
	);

endmodule

`default_nettype wire
