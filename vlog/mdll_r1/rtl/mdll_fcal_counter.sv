/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_fcal_counter.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - clock counter for coarse frequency calibration

* Note       :
  -

* Todo       :
  - add synchronizers for reset and inputs

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_fcal_counter import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
	input en_fcal,		// enable fcal mode
	input clk_refp,		// accurate reference clock
	input [$clog2(N_FCAL_CNT)-1:0] fcal_ndiv_ref,	// divide clk_refp by 2**ndiv_ref to create a ref_pulse
	input clk_fb,		// feedback clock
	input fcal_start,	// start counter (request)
	output reg [N_FCAL_CNT-1:0] fcal_cnt, // fcal counter value
	output reg fcal_ready	// fcal result ready (acknowledge)
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

wire [N_FCAL_CNT-1:0] ref_cnt;
wire ref_pulse; // reference pulse to count
wire [2:0] ref_pulse_d;	// multiple sampled ref_pulse for metastability
wire ref_pulse_rise;	// start counting
wire ref_pulse_fall;	// end counting and latch the count value
wire [$clog2(N_FCAL_CNT):0] ndiv_plsgen;

wire en_fcal_sync;
wire fcal_start_sync;

reg [N_FCAL_CNT-1:0] fb_cnt;	// counter of ref_pulse high duration


//---------------------
// INSTANTIATION
//---------------------

// synchronize ref_pulse to clk_fb clock
defparam uREF_PLS_SYNC.DEPTH = 3;
mdll_synchronizer uREF_PLS_SYNC ( .clk(clk_fb), .din(ref_pulse), .dout(), .din_d(ref_pulse_d) );

// en_fcal sync
defparam uS_EN_FCAL.DEPTH = 2;
mdll_synchronizer uS_EN_FCAL ( .clk(clk_fb), .din(en_fcal), .dout(en_fcal_sync), .din_d() );

// fcal_start sync
defparam uS_FCAL_START_SYNC.DEPTH = 2;
mdll_synchronizer uS_FCAL_START_SYNC ( .clk(clk_fb), .din(fcal_start), .dout(fcal_start_sync), .din_d() );

// reference pulse generator; replace w/ ripple counter 
defparam uREF_PLSGEN.N = N_FCAL_CNT;
mdll_freq_div_radix2 uREF_PLSGEN ( .cki(clk_refp), .ndiv(ndiv_plsgen), .cko(), .ckob(), .cntr(ref_cnt) );

//---------------------
// COMBINATIONAL
//---------------------

assign ndiv_plsgen = N_FCAL_CNT;
assign ref_pulse = ref_cnt[fcal_ndiv_ref];
assign ref_pulse_rise = en_fcal & fcal_start & (ref_pulse_d[2:1]==2'b01);
assign ref_pulse_fall = en_fcal & fcal_start & (ref_pulse_d[2:1]==2'b10);


//---------------------
// SEQ
//---------------------

always @(posedge clk_fb) 
	if (en_fcal_sync) begin
		if (ref_pulse_rise) fb_cnt <= '0;
		else fb_cnt <= fb_cnt + 1;
	end

always @(posedge clk_fb) 
	if (en_fcal_sync) begin	
		if (~fcal_start_sync) begin	// counter inactive 
			fcal_cnt <= '0;		// reset counter value
			fcal_ready <= 1'b0;	// reset acknowledge
		end
		if (ref_pulse_fall) begin
			fcal_cnt <= fb_cnt;	// latch counter value
			fcal_ready <= 1'b1;	// acknowledge
		end
	end else begin
		fcal_ready <= 1'b0;
	end


//---------------------
// OTHERS
//---------------------

// synopsys translate_off
	
initial fb_cnt = $urandom();

// synopsys translate_on

endmodule

