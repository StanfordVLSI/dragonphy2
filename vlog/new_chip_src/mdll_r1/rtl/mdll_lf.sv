`include "mdll_param.vh"
/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_lf.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - Digital loop filter of this MDLL.
  - This computes the fine control word

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_lf import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
	input clk_lf,	// clock for this loop filter
	input clk_sdm,	// SDM clock
	input rstn,		// reset (active low), false path
	input en_osc,	// enable oscillator (active high), false path
	//input freeze,	// freeze dco_ctl_track & dac_ctl_track value; active high, false path
	input freeze_lf_dco_track,	// freeze dco_ctl_track value in the loop filter; active high, false path
	input freeze_lf_dac_track,	// freeze dac_ctl_track value in the loop filter; active high, false path
	input load,		// 1: load "load_val" into dco_ctl_track reg; 0: normal loop filter ops, false path
	input [N_DCO_T-N_DCO_TF-1:0] ld_value,		// init load value to dco_ctl_track, false path, false path
	input [N_DAC_T-N_DAC_TF-1:0] ld_value_dac,   // init load value to dac_ctl_track, false path, false path
	input sel_dac_loop,	                // 1: dac-based bb loop; 0: nominal bb loop, false path
    input en_hold,                      // enable holding dco_ctl_track value in dac tracking mode; active high
	input bb_out_inc,					// bang-bang pd output (1: inc delay, 0: dec delay)
	input [N_BB_GB-1:0] gain_bb,			// 2**(gain_bb) for bb_out in bb loop, false path
	input [N_BB_GDAC-1:0] gain_bb_dac,		// 2**(gain_bb_dac) for bb_out in dac supply loop, false path
	input en_sdm,	// enable sdm; active high, false path
//	input [$clog2(N_DAC_TF)-1:0] prbs_mag, 	// prbs gain; 0: 0, 1: 1, 2: 2^1, 3: 2^2, ..., false path
	output [N_DCO_TI-1:0] dco_ctl_fine, // dco fine control word
	output [N_DAC_TI-1:0] dac_ctl       // dac control word 
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

genvar k;

wire resetn;

reg [N_DCO_T-1:0] dco_ctl_track; // dco track control word (integer+fraction)
wire [N_DAC_DITH-1:0] dac_ctl_dither;     // dco control word (1-bit dither)

wire [N_DCO_T-1:0] dco_ctl_track_nxt;			// next dco_ctl_track (clipped)
wire signed [N_DCO_T+1:0] dco_ctl_track_nxt_unclipped;	// next dco_ctl_track (unclipped)
wire signed [N_DCO_T+1:0] bb_out_scaled;		// bb_out multiplied by gain 
wire signed [N_DCO_T+1:0] inc;					// increment of dco_ctl_track
wire [N_DCO_TF-1:0] dco_ctl_fine_frac; // dco fine control word
wire ovfw_dco_ctl_track;	// flag indicating dco_ctl_track will be overflowed
wire udfw_dco_ctl_track;	// flag indicating dco_ctl_track will be underflowed

reg [N_DAC_T-1:0] dac_ctl_track; // dac track control word (integer+fraction)
wire [N_DAC_T-1:0] dac_ctl_track_nxt;			// next dco_ctl_track (clipped)
wire signed [N_DAC_T+1:0] dac_ctl_track_nxt_unclipped;	// next dco_ctl_track (unclipped)
wire signed [N_DAC_T+1:0] dac_bb_out_scaled;		// bb_out multiplied by gain 
wire signed [N_DAC_T+1:0] dac_inc;					// increment of dco_ctl_track
wire [N_DAC_TF-1:0] dac_ctl_frac; // dco fine control word
wire ovfw_dac_ctl_track;	// flag indicating dco_ctl_track will be overflowed
wire udfw_dac_ctl_track;	// flag indicating dco_ctl_track will be underflowed

wire latch_dco_ctl_track;
wire hold_dco_ctl_track;
wire reset_dac_ctl_track;

wire resetn_sync_clk_lf;
wire load_sync;
wire [2:0] sel_dac_loop_d;
wire [N_BB_GB-1:0] gain_bb_sync;
wire [N_BB_GDAC-1:0] gain_bb_dac_sync;
wire en_hold_sync;
wire freeze_dco_sync;
wire freeze_dac_sync;


//---------------------
// INSTANTIATION
//---------------------

// reset sync
defparam uRESETN_SYNC.DEPTH = 2;
mdll_reset_sync uRESETN_SYNC ( .clk(clk_lf), .rstn(resetn), .rstn_sync(resetn_sync_clk_lf) );

// load sync
defparam uS_LOAD.DEPTH = 2;
mdll_synchronizer uS_LOAD ( .clk(clk_lf), .din(load), .dout(load_sync), .din_d() );

// sel_dac_loop sync
defparam uS_SEL_DAC_LOOP.DEPTH = 3;
mdll_synchronizer uS_SEL_DAC_LOOP ( .clk(clk_lf), .din(sel_dac_loop), .dout(), .din_d(sel_dac_loop_d) );

// en_hold sync
defparam uS_EN_HOLD.DEPTH = 2;
mdll_synchronizer uS_EN_HOLD ( .clk(clk_lf), .din(en_hold), .dout(en_hold_sync), .din_d() );

// freeze sync
defparam uS_FREEZE_DCO.DEPTH = 2;
mdll_synchronizer uS_FREEZE_DCO ( .clk(clk_lf), .din(freeze_lf_dco_track), .dout(freeze_dco_sync), .din_d() );
defparam uS_FREEZE_DAC.DEPTH = 2;
mdll_synchronizer uS_FREEZE_DAC ( .clk(clk_lf), .din(freeze_lf_dac_track), .dout(freeze_dac_sync), .din_d() );

// gain_bb_sync & gain_bb_dac_sync
generate
    for (k=0;k<N_BB_GB;k++) begin: genblk1
        mdll_synchronizer #(.DEPTH(2)) uS_GAIN_BB ( .clk(clk_lf), .din(gain_bb[k]), .dout(gain_bb_sync[k]), .din_d() );
    end
    for (k=0;k<N_BB_GDAC;k++) begin: genblk2
        mdll_synchronizer #(.DEPTH(2)) uS_GAIN_BB_DAC ( .clk(clk_lf), .din(gain_bb_dac[k]), .dout(gain_bb_dac_sync[k]), .din_d() );
    end
endgenerate


// dac sigma-delta modulator
mdll_dac_sdm uSDM (
	.clk(clk_sdm),
	.rstn(resetn),
	.en_sdm(en_sdm),
//	.prbs_mag(prbs_mag),
	.din(dac_ctl_frac),     // CDC
	.dout_sdm(dac_ctl_dither)
);


//---------------------
// COMBINATIONAL
//---------------------

assign resetn = rstn & en_osc;

assign dco_ctl_fine_frac = dco_ctl_track[N_DCO_TF-1:0];

assign bb_out_scaled = (gain_bb_sync==0)? '0 : (bb_out_inc ? (1 << gain_bb_sync) : (-1 << gain_bb_sync)) ;
assign inc = bb_out_scaled ;

assign dco_ctl_track_nxt_unclipped = load_sync ? $signed({2'b0,ld_value,{N_DCO_TF{1'b0}}}) : (dco_ctl_track + inc);
assign ovfw_dco_ctl_track = (dco_ctl_track_nxt_unclipped[(N_DCO_T+1)-:(2+N_DCO_TI)] == {2'b01,{(N_DCO_TI){1'b1}}});
assign udfw_dco_ctl_track = dco_ctl_track_nxt_unclipped[N_DCO_T+1];	
assign dco_ctl_track_nxt = ovfw_dco_ctl_track ? {{(N_DCO_TI){1'b1}},{(N_DCO_TF){1'b0}}} : ( udfw_dco_ctl_track ? '0 : dco_ctl_track_nxt_unclipped ) ;
assign dco_ctl_fine = dco_ctl_track[(N_DCO_T-1)-:N_DCO_TI];

assign dac_ctl_frac = dac_ctl_track[N_DAC_TF-1:0];

assign dac_bb_out_scaled = (gain_bb_dac_sync==0)? '0 : (bb_out_inc ? (1 << gain_bb_dac_sync) : (-1 << gain_bb_dac_sync)) ;
assign dac_inc = dac_bb_out_scaled ;

assign dac_ctl_track_nxt_unclipped = load_sync ? $signed({2'b0,ld_value_dac,{N_DAC_TF{1'b0}}}) : (dac_ctl_track + dac_inc );
assign ovfw_dac_ctl_track = (dac_ctl_track_nxt_unclipped[(N_DAC_T+1)-:(2+N_DAC_TI)] == {2'b01,{(N_DAC_TI){1'b1}}});
assign udfw_dac_ctl_track = dac_ctl_track_nxt_unclipped[N_DAC_T+1];	
assign dac_ctl_track_nxt = ovfw_dac_ctl_track ? {{(N_DAC_TI){1'b1}},{(N_DAC_TF){1'b0}}} : ( udfw_dac_ctl_track ? '0 : dac_ctl_track_nxt_unclipped ) ;
assign dac_ctl = dac_ctl_track[(N_DAC_T-1)-:N_DAC_TI] + dac_ctl_dither;

assign latch_dco_ctl_track = (sel_dac_loop_d[2:1]==2'b01);  // rise edge of dac loop
assign hold_dco_ctl_track = (sel_dac_loop_d[2:1]==2'b11) & en_hold_sync ;   // high
assign reset_dac_ctl_track = (sel_dac_loop_d[2:1]==2'b00);  // low

//---------------------
// SEQ
//---------------------

// bb-loop integrator
always @(posedge clk_lf, negedge resetn_sync_clk_lf) 
	if (!resetn_sync_clk_lf) dco_ctl_track <= {ld_value,{N_DCO_TF{1'b0}}};
	else if (~freeze_dco_sync) begin
        if (latch_dco_ctl_track) begin
			if (dco_ctl_track_nxt[(N_DCO_T-1)-:N_DCO_TI]!=0) 
				dco_ctl_track <= {dco_ctl_track_nxt[(N_DCO_T-1)-:N_DCO_TI] - 1, dco_ctl_track_nxt[N_DCO_TF-1:0]};  // -1 for integer
			else 
				dco_ctl_track <= {dco_ctl_track_nxt[(N_DCO_T-1)-:N_DCO_TI], dco_ctl_track_nxt[N_DCO_TF-1:0]};  
		end else if (!hold_dco_ctl_track) 
			dco_ctl_track <= dco_ctl_track_nxt;
    end

// supply-dac integrator
always @(posedge clk_lf, negedge resetn_sync_clk_lf) 
	if (!resetn_sync_clk_lf) dac_ctl_track <= {ld_value_dac,{N_DAC_TF{1'b0}}};
	else if (~freeze_dac_sync) begin
        if (reset_dac_ctl_track) dac_ctl_track <= {ld_value_dac,{N_DAC_TF{1'b0}}};
        else dac_ctl_track <= dac_ctl_track_nxt;
    end


//---------------------
// OTHERS
//---------------------

// synopsys translate_off

// synopsys translate_on

endmodule

