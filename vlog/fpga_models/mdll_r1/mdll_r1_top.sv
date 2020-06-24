module mdll_r1_top import mdll_pkg::*; #(
) (
// I/Os here
// clock & reset
	input clk_refp,		// (+) reference clock, external input
	input clk_refn,		// (-) reference clock, external input
	input rstn_jtag,			// reset ; active low; Note that this signal is also from jtag
	input clk_monp,     //(+) clk for jitter measurement, external input
	input clk_monn,     //(-) clk for jitter measurement, external input
// core
	input en_osc_jtag,		// enable osc; active high, false path
	input en_dac_sdm_jtag,	// enable dco sdm; active high, false path
	input en_monitor_jtag,	// enable measurement mode
	input inj_mode_jtag, 	// 0: ring oscillator mode; 1: injection oscillator mode, false path
	input freeze_lf_dco_track_jtag,	// freeze dco_ctl_track value in the loop filter; active high, false path
	input freeze_lf_dac_track_jtag,	// freeze dac_ctl_track value in the loop filter; active high, false path
	input load_lf_jtag,		// 1: load "load_val" into dco_ctl_fine reg; 0: normal loop filter ops, false path
	input sel_dac_loop_jtag,	// 1: dac-based bb loop; 0: nominal bb loop, false path
    input en_hold_jtag,      // enable holding dco_ctl_track value in dac tracking mode; active high, false path
						// otherwise, both dco_ctl tracking and dac_ctl tracking loops work together
	input [$clog2(N_DIV):0] fb_ndiv_jtag,	// 2**fb_ndiv is the feedback divider ratio
	input load_offset_jtag,	// 1: load dco_ctl_offset value, 0: keep the current offset value
	input [N_DCO_O-1:0] dco_ctl_offset_jtag,			// # of delay coarse stages for supply modulation, false path
	input [N_DCO_T-N_DCO_TF-1:0] dco_ctl_track_lv_jtag,		// init load value of dco_ctl_track in digital loop filter, false path
	input [N_DAC_T-N_DAC_TF-1:0] dac_ctl_track_lv_jtag,		// init load value of dac_ctl_track in digital loop filter, false path
	input [N_BB_GB-1:0] gain_bb_jtag,					// BB gain (2**(gain_bb)) for dco tracking , false path
	input [N_BB_GDAC-1:0] gain_bb_dac_jtag,				// BB gain (2**(gain_dac)) for dac tracking, false path
	input [$clog2(N_DIV)-1:0] sel_sdm_clk_jtag,	// sdm clock select from feedback divider
//	input [$clog2(N_DAC_TF)-1:0] prbs_mag_jtag, 		// prbs gain; 0: 0, 1: 1, 2: 2^1, 3: 2^2, ...
	input en_fcal_jtag,		// enable fcal mode
	input [$clog2(N_FCAL_CNT)-1:0] fcal_ndiv_ref_jtag,	// divide clk_refp by 2**ndiv_ref to create a ref_pulse
	input fcal_start_jtag,						// start counter (request)
	input [N_DAC_BW-1:0] ctl_dac_bw_thm_jtag, 		// DAC bandwidth control (thermometer)
	input [N_DAC_GAIN-1:0] ctlb_dac_gain_oc_jtag,	// r-dac gain control (one cold)
	output clk_0,	// I output clock, to phy core
	output clk_90,	// Q output clock, to phy core
	output clk_180,	// /I output clock, to phy core
	output clk_270,	// /Q output clock, to phy core
	output [N_FCAL_CNT-1:0] fcal_cnt_2jtag, // fcal counter value
	output fcal_ready_2jtag,	// fcal result ready (acknowledge)
	output [N_DCO_TI-1:0] dco_ctl_fine_mon_2jtag,
	output [N_DAC_TI-1:0] dac_ctl_mon_2jtag,
// measurement
    input [2:0] jm_sel_clk_jtag,    // select clock being measured
	input jm_bb_out_pol_jtag,		// 1: take the internal bb_out_mon (inside the measurement module) as it is, 0: invert it
    output jm_clk_fb_out,   // 1/32 feedback clock output for direct jitter measurement by sampling scope, to phy core
	output [N_JIT_CNT-1:0] jm_cdf_out_2jtag // to jatag
);

    assign clk_0 = 1'b0;
    assign clk_90 = 1'b0;
    assign clk_180 = 1'b0;
    assign clk_270 = 1'b0;
    assign fcal_cnt_2jtag = 0;
    assign fcal_ready_2jtag = 1'b0;
    assign dco_ctl_fine_mon_2jtag = 0;
    assign dac_ctl_mon_2jtag = 0;
    assign jm_clk_fb_out = 1'b0;
    assign jm_cdf_out_2jtag = 0;

endmodule