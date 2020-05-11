/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_dac_sdm.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  -

* Note       :
  - MASH1 = o1
  - MASH11 = o1 + o2*(1-z^(-1))
  - MASH111 = o1 + o2*(1-z^(-1)) + o3*(1-z^(-1))^2

* Todo       :
  - Figure out why having one cycle latency (use flop from dout_sdm_pre to dout_sdm) worsen DJ.

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_dac_sdm import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
	input clk,	// clock
	input rstn,	// reset, active low
	input en_sdm,	// enable sdm; active high; false path
//	input [$clog2(N_DAC_TF)-1:0] prbs_mag, 	// prbs gain; 0: 0, 1: 1, 2: 2^1, 3: 2^2, ..., false path
	input [N_DAC_TF-1:0] din,			// fractional part of tracking control
	output [N_DAC_DITH-1:0] dout_sdm 	// DSM output
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on


//---------------------
// VARIABLES, WIRES
//---------------------

//wire signed [N_DAC_TF-1:0] dither_prbs;
wire [N_DAC_DITH-1:0] o1; 
//wire o2, o3;
//wire [N_DAC_TF-1:0] ne1;
wire rstn_mash1;
wire rstn_sync;


//---------------------
// INSTANTIATION
//---------------------

mdll_reset_sync uRSTN_SYNC ( .clk(clk), .rstn(rstn_mash1), .rstn_sync(rstn_sync) );

//mdll_prbs19 uPRBS (
//	.clk(clk),
//	.rstn(rstn_sync),
//	.prbs_mag(prbs_mag),
//	.dith_out(dither_prbs)
//);

defparam uMASH1.N_DI = N_DAC_TF;
defparam uMASH1.N_DO = N_DAC_DITH;

mdll_sdm1_multibit uMASH1 (
	.clk(clk),
	.rstn(rstn_sync),
	.en_sdm(en_sdm),
	.din(din),
//	.dither(dither_prbs),
	.dither('0),
	.dout(o1)
);


//---------------------
// COMBINATIONAL
//---------------------

assign dout_sdm = o1;
assign rstn_mash1 = rstn & en_sdm;

//---------------------
// SEQ
//---------------------


//---------------------
// OTHERS
//---------------------

// synopsys translate_off

// synopsys translate_on

endmodule

