/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_core.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - Core of MDLL

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_core import mdll_pkg::*; #(
// parameters here
) (
// I/Os here
// clock & reset
	input clk_refp,		// (+) reference clock
	input clk_refn,		// (-) reference clock
	input rstn,			// reset ; active low
// 
	input en_osc,		// enable osc; active high, false path
	input en_dac_sdm,	// enable dco sdm; active high, false path
	input en_monitor,	// enable measurement mode
	input inj_mode, 	// 0: ring oscillator mode; 1: injection oscillator mode, false path
	input freeze_lf_dco_track,	// freeze dco_ctl_track value in the loop filter; active high, false path
	input freeze_lf_dac_track,	// freeze dac_ctl_track value in the loop filter; active high, false path
	input load_lf,		// 1: load "load_val" into dco_ctl_fine reg; 0: normal loop filter ops, false path
	input sel_dac_loop,	// 1: dac-based bb loop; 0: nominal bb loop, false path
    input en_hold,      // enable holding dco_ctl_track value in dac tracking mode; active high, false path
						// otherwise, both dco_ctl tracking and dac_ctl tracking loops work together
	input [$clog2(N_DIV):0] fb_ndiv,	// 2**fb_ndiv is the feedback divider ratio
	input load_offset,	// 1: load dco_ctl_offset value, 0: keep the current offset value
	input [N_DCO_O-1:0] dco_ctl_offset,			// # of delay coarse stages for supply modulation, false path
	input [N_DCO_T-N_DCO_TF-1:0] dco_ctl_track_lv,		// init load value of dco_ctl_track in digital loop filter, false path
	input [N_DAC_T-N_DAC_TF-1:0] dac_ctl_track_lv,		// init load value of dac_ctl_track in digital loop filter, false path
	input [N_BB_GB-1:0] gain_bb,					// BB gain (2**(gain_bb)) for dco tracking , false path
	input [N_BB_GDAC-1:0] gain_bb_dac,				// BB gain (2**(gain_dac)) for dac tracking, false path
	input [$clog2(N_DIV)-1:0] sel_sdm_clk,	// sdm clock select from feedback divider 
//	input [$clog2(N_DAC_TF)-1:0] prbs_mag, 		// prbs gain; 0: 0, 1: 1, 2: 2^1, 3: 2^2, ...
	input en_fcal,		// enable fcal mode
	input [$clog2(N_FCAL_CNT)-1:0] fcal_ndiv_ref,	// divide clk_refp by 2**ndiv_ref to create a ref_pulse
	input fcal_start,						// start counter (request)
	input [N_DAC_BW-1:0] ctl_dac_bw_thm, 		// DAC bandwidth control (thermometer)
	input [N_DAC_GAIN-1:0] ctlb_dac_gain_oc,	// r-dac gain control (one cold)
	output clk_0,	// I output clock
	output clk_90,	// Q output clock
	output clk_180,	// /I output clock
	output clk_270,	// /Q output clock
	output clk_fb_mon,	// feedback clock monitor for RJ measurement
	output osc_0,	// mux delay ahead of clk_0
	output osc_90,	// mux delay ahead of clk_90
	output osc_180,	// mux delay ahead of clk_180
	output osc_270,	// mux delay ahead of clk_270
	output [N_FCAL_CNT-1:0] fcal_cnt, // fcal counter value
	output fcal_ready,	// fcal result ready (acknowledge)
	output [N_DCO_TI-1:0] dco_ctl_fine_mon,
	output [N_DAC_TI-1:0] dac_ctl_mon
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

wire clk_fb;	// feedback clock
wire clk_sdm;	// sdm clock

wire last_cycle;	// the last cycle of osc_0 (before rising edge of clk_fb) for sel_inj gen
wire bb_out_inc;	// bang-bang pd output (early, thus increase delay)
wire inj_mode_sync;
wire [N_DCO_TI-1:0] dco_ctl_fine;		// fine control of the delay
wire [N_DAC_TI-1:0] dac_ctl;			// dac control word

wire [(N_DCO_TI-N_PI)-1:0] dco_ctl_fine_msb;
wire [N_PI-1:0] dco_ctl_fine_lsb;

wire [2**N_DCO_O-2:0] dco_ctl_offset_thm;
wire [2**(N_DCO_TI-N_PI)-2:0] dco_ctl_fine_msb_thm;
wire [2**N_PI-2:0] dco_ctl_fine_lsb_thm;
wire [2**N_DAC_TI-1:0] dac_ctlb_sel;

reg [N_DCO_O-1:0] dco_ctl_offset_sync;
reg [N_DCO_TI-1:0] dco_ctl_fine_mon_reg;
reg [N_DAC_TI-1:0] dac_ctl_mon_reg;

//---------------------
// INSTANTIATION
//---------------------

// Flops for sampling monitoring signals

always @(posedge clk_refp) begin
	if (en_monitor) begin
 		dco_ctl_fine_mon_reg <= dco_ctl_fine;
 		dac_ctl_mon_reg <= dac_ctl;
	end
end

// binary to thermometer decoders

defparam uB2T_FINE_MSB.N = (N_DCO_TI-N_PI);
mdll_bin2therm uB2T_FINE_MSB (
	.din(dco_ctl_fine_msb),
	.dout(dco_ctl_fine_msb_thm)
);

defparam uB2T_FINE_LSB.N = N_PI;
mdll_bin2therm uB2T_FINE_LSB (
	.din(dco_ctl_fine_lsb),
	.dout(dco_ctl_fine_lsb_thm)
);

always @(posedge clk_refp)
	dco_ctl_offset_sync <= load_offset ? dco_ctl_offset : '0;

defparam uB2T_OFFSET.N = N_DCO_O;
mdll_bin2therm uB2T_OFFSET (
	.din(dco_ctl_offset_sync),
	.dout(dco_ctl_offset_thm)
);

// dac decoder
mdll_dac_decoder uDAC_DEC (
    .din(dac_ctl),
    .dinb_sel(dac_ctlb_sel)
);

// frequency calibration counter (RTL)
mdll_fcal_counter uFCAL (
	.en_fcal(en_fcal),
	.clk_refp(clk_refp),
	.fcal_ndiv_ref(fcal_ndiv_ref),
	.clk_fb(clk_fb),
	.fcal_start(fcal_start),
	.fcal_cnt(fcal_cnt),
	.fcal_ready(fcal_ready)
);

// inj_mode sync
defparam uS_INJ_MODE.DEPTH = 2;
mdll_synchronizer uS_INJ_MODE ( .clk(clk_refp), .din(inj_mode), .dout(inj_mode_sync), .din_d() );

// injection oscillator top (structural)
mdll_injection_osc uMOSC ( 
	.clk_refp(clk_refp),
	.clk_refn(clk_refn),
	.en_osc(en_osc),
	.inj_mode(inj_mode_sync),
	.last_cycle(last_cycle),
    .ctl_offset_thm(dco_ctl_offset_thm),
    .ctl_fine_msb_thm(dco_ctl_fine_msb_thm),
    .ctl_fine_lsb_thm(dco_ctl_fine_lsb_thm),
    .ctlb_dac_sel(dac_ctlb_sel),
	.ctl_dac_bw_thm(ctl_dac_bw_thm),
	.ctlb_dac_gain_oc(ctlb_dac_gain_oc),
	.bb_out_inc(bb_out_inc),
	.clk_0(clk_0),
	.clk_90(clk_90),
	.clk_180(clk_180),
	.clk_270(clk_270),
	.osc_0(osc_0),
	.osc_90(osc_90),
	.osc_180(osc_180),
	.osc_270(osc_270)
);

// feedback divider (RTL)	, use CVDD domain
mdll_feedback_div uFDIV (
	.osc_0(osc_0),
	.ndiv(fb_ndiv),
	.sel_sdm_clk(sel_sdm_clk),
	.clk_fb(clk_fb),
	.clk_sdm(clk_sdm),
	.last_cycle(last_cycle),
	.clk_fb_mon(clk_fb_mon)
);

// loop filter (RTL)
mdll_lf uDLF (
	.clk_lf(clk_refp),
	.clk_sdm(clk_sdm),
	.rstn(rstn),
	.en_osc(en_osc),
    .freeze_lf_dco_track(freeze_lf_dco_track),
    .freeze_lf_dac_track(freeze_lf_dac_track),
	.load(load_lf),
	.ld_value(dco_ctl_track_lv),
	.ld_value_dac(dac_ctl_track_lv),
	.sel_dac_loop(sel_dac_loop),
    .en_hold(en_hold),
	.bb_out_inc(bb_out_inc),
	.gain_bb(gain_bb),
	.gain_bb_dac(gain_bb_dac),
	.en_sdm(en_dac_sdm),
//	.prbs_mag(prbs_mag),
	.dco_ctl_fine(dco_ctl_fine),
	.dac_ctl(dac_ctl)
);


//---------------------
// COMBINATIONAL
//---------------------

// bus split
assign dco_ctl_fine_msb = dco_ctl_fine[(N_DCO_TI-1)-:(N_DCO_TI-N_PI)];
assign dco_ctl_fine_lsb = dco_ctl_fine[N_PI-1:0];

assign dco_ctl_fine_mon = dco_ctl_fine_mon_reg;
assign dac_ctl_mon = dac_ctl_mon_reg;

//---------------------
// SEQ
//---------------------


//---------------------
// OTHERS
//---------------------

// synopsys translate_off

// synopsys translate_on

endmodule

