`include "iotype.sv"

`default_nettype none

module dragonphy_top import const_pack::*; (
	// analog inputs
	input `pwl_t ext_rx_inp,
	input `pwl_t ext_rx_inn,
	input `real_t ext_Vcm,
	input `real_t ext_Vcal,
	input `pwl_t ext_rx_inp_test,
	input `pwl_t ext_rx_inn_test,

	// clock inputs 
	input wire logic ext_clk_async_p,
	input wire logic ext_clk_async_n,

	input wire logic ext_clk_test0_p,
	input wire logic ext_clk_test0_n,
	input wire logic ext_clk_test1_p,
	input wire logic ext_clk_test1_n,
	
	input wire logic ext_clkp,
	input wire logic ext_clkn,
	
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

	wire logic clk_main;
	wire logic clk_async;
	wire logic ext_clk_test0;
	wire logic ext_clk_test1;

	// Signal declaration
	input_buffer ibuf_async (
		.inp(ext_clk_async_p),
		.inm(ext_clk_async_n),
		.pd(adbg_intf_i.disable_ibuf_async),
		.clk(clk_async)
	);

	input_buffer ibuf_main (
		.inp(ext_clkp),
		.inm(ext_clkn),
		.pd(adbg_intf_i.disable_ibuf_main),
		.clk(clk_main)
	);

	input_buffer ibuf_test0 (
		.inp(ext_clk_test0_p),
		.inm(ext_clk_test0_n),
		.pd(adbg_intf_i.disable_ibuf_test0),
		.clk(ext_clk_test0)
	);

	input_buffer ibuf_test1 (
		.inp(ext_clk_test1_p),
		.inm(ext_clk_test1_n),
		.pd(adbg_intf_i.disable_ibuf_test1),
		.clk(ext_clk_test1)
	);

	logic mdll_clk;
	logic clk_cdr;
	logic [Npi-1:0]		pi_ctl_cdr[Nout-1:0];

	logic clk_adc;
	logic [Nadc-1:0] 	adcout 				[Nti-1:0];
	logic [Nti-1:0]  	adcout_sign;
	logic [Nadc-1:0] 	adcout_rep 			[Nti_rep-1:0];
	logic [Nti_rep-1:0] adcout_sign_rep;


// temp setting for sim ultil DCORE is fixed ---------------------------
	logic ctl_valid;
	assign ctl_valid = 1;	
//---------------------------------------------------------------------------
	
	// Analog core instantiation
	analog_core iacore (
		.rx_inp(ext_rx_inp),						// RX input (+) 
		.rx_inn(ext_rx_inn), 						// RX input (-)
		.Vcm(ext_Vcm),

		.rx_inp_test(ext_rx_inp_test),
		.rx_inn_test(ext_rx_inn_test),

		.ext_clk(clk_main),					// External clock (+)
		.mdll_clk(mdll_clk),					// External clock (+)
		.ext_clk_test0(ext_clk_test0),
		.ext_clk_test1(ext_clk_test1),
		.clk_async(clk_async),
		.ctl_pi(pi_ctl_cdr),  // PI control code from CDR
		.ctl_valid(ctl_valid),  // PI control valid flag from CDR
		
		.Vcal(ext_Vcal),
		
		.clk_adc(clk_adc), 						// clock for retiming adc data
		.adder_out(adcout), 						// adc output
		.sign_out(adcout_sign),
		.adder_out_rep(adcout_rep), 						// adc output
		.sign_out_rep(adcout_sign_rep),

		.adbg_intf_i(adbg_intf_i) 				// debug IO
	);
	
	// digital core instantiation

	digital_core idcore (
		.clk_adc(clk_adc), 						// clock for retiming adc data
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
		.clk_cdr(clk_cdr),						// CDR clock (<-- this should be removed)
		.int_pi_ctl_cdr(pi_ctl_cdr),		// PI control code from CDR
		.ramp_clock     (ramp_clock),
		.freq_lvl_cross (freq_lvl_cross),
		.ext_dump_start(ext_dump_start),

		.adbg_intf_i(adbg_intf_i),		
		.jtag_intf_i(jtag_intf_i)
	);
/*
	mdll_r1_top imdll (
		.clk_refp(mdll_ext_clkp),     // (+) reference clock
	    .clk_refn(mdll_ext_clkn),     // (-) reference clock
	    .clk_monp(mdll_ext_clk_monp),     //(+) clk for jitter measurement
	    .clk_monn(mdll_ext_clk_minn),     //(-) clk for jitter measurement
	    
    	.rstn(mall_rstb),         // reset ; active low
		.en_osc_jtag(mdll_en_osc),      // enable osc; active high, false path
	    .en_dac_sdm_jtag(mdll_en_dac_sdm),  // enable dco sdm; active high, false path
	    .en_monitor_jtag(mdll_en_monitor),  // enable measurement mode
	    .inj_mode_jtag(mdll_inj_mode),    // 0: ring oscillator mode; 1: injection oscillator mode, false path
	    .freeze_lf_dco_track_jtag(mdll_freeze_lf_dco_track), // freeze dco_ctl_track value in the loop filter; active high, false path
	    .freeze_lf_dac_track_jtag(mdll_freeze_lf_dac_track), // freeze dac_ctl_track value in the loop filter; active high, false path
	    .load_lf_jtag(mdll_load_lf),     // 1: load "load_val" into dco_ctl_fine reg; 0: normal loop filter ops, false path
	    .sel_dac_loop_jtag(mdll_sel_dac_loop),    // 1: dac-based bb loop; 0: nominal bb loop, false path
	    .en_hold_jtag(mdll_en_hold),      // enable holding dco_ctl_track value in dac tracking mode; active high, false path
	    .fb_ndiv_jtag(mdll_fb_ndiv),   // 2**fb_ndiv is the feedback divider ratio
	    .load_offset_jtag(mdll_load_offset), // 1: load dco_ctl_offset value, 0: keep the current offset value
	    .dco_ctl_offset_jtag(mdll_dco_ctl_offset),            // # of delay coarse stages for supply modulation, false path
    	.dco_ctl_track_lv_jtag(mdll_dco_ctl_track_lv),     // init load value of dco_ctl_track in digital loop filter, false path
	    .dac_ctl_track_lv_jtag(mdll_dac_ctl_track_lv),     // init load value of dac_ctl_track in digital loop filter, false path
	    .gain_bb_jtag(mdll_gain_bb),                   // BB gain (2**(gain_bb)) for dco tracking , false path
	    .gain_bb_dac_jtag(mdll_gain_bb_dac),             // BB gain (2**(gain_dac)) for dac tracking, false path
	    .sel_sdm_clk_jtag(mdll_sel_sdm_clk), // sdm clock select from feedback divider
	    .en_fcal_jtag(mdll_en_fcal),     // enable fcal mode
	    .fcal_ndiv_ref_jtag(mdll_fcal_ndiv_ref),  // divide clk_refp by 2**ndiv_ref to create a ref_pulse
	    .fcal_start_jtag(mdll_fcal_start),                      // start counter (request)
	    .ctl_dac_bw_thm_jtag(mdll_ctl_dac_bw_thm),       // DAC bandwidth control (thermometer)
	    .ctlb_dac_gain_oc_jtag(mdll_ctlb_dac_gain_oc),   // r-dac gain control (one cold)
	    
		.clk_0(mdll_clk_out),   // I .clock
	    .clk_90(),  // Q .clock
	    .clk_180(), // /I .clock
	    .clk_270(), // /Q .clock
	    .fcal_cnt_2jtag(mdll_fcal_cnt), // fcal counter value
	    .fcal_ready_2jtag(mdll_fcal_ready),    // fcal result ready (acknowledge)
	    .dco_ctl_fine_mon_2jtag(mdll_dco_ctl_fine_mon),
	    .dac_ctl_mon_2jtag(mdll_dac_ctl_mon),
	    .jm_sel_clk_jtag(mdll_jm_sel_clk),    // select clock being measured
	    .jm_bb_out_pol_jtag(mdll_jm_bb_out_pol),       // 1: take the internal bb_out_mon (inside the measurement module) as it is, 0: invert it
	    .jm_clk_fb_out(mdll_jm_clk_fb_out),   // 1/32 feedback clock .for direct jitter measurement by sampling scope
	    .jm_cdf_out_2jtag(mdll_jm_cdf_out) // to jatag
	);
*/







endmodule

`default_nettype wire
