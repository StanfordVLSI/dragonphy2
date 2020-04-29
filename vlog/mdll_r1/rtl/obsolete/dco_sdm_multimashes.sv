/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : dco_sdm_multimashes.sv
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


module dco_sdm_multimashes #(
// parameters here

) (
// I/Os here
	input clk,	// clock
	input rstn,	// reset, active low
	input en_sdm,	// enable sdm; active high
	input [1:0] sel_sdm_mash,	// select 0: DSM1; 1: DSM11; 2: DSM111, 3: invalid
	input [$clog2(`N_DCO_TF)-1:0] prbs_mag, 	// prbs gain; 0: 0, 1: 1, 2: 2^1, 3: 2^2, ...
	input [`N_DCO_TF-1:0] din,			// fractional part of tracking control
	output signed [`N_DCO_DITH:0] dout_sdm 	// DSM output
);

timeunit 1ps;
timeprecision 1fs;

/*
wire rstn_mash1;
wire signed [`N_DCO_TF-1:0] dither_prbs;

assign rstn_mash1 = rstn & en_sdm;

prbs19 uPRBS (
	.clk(clk),
	.rstn(rstn),
	.prbs_mag(prbs_mag),
	.dith_out(dither_prbs)
);

defparam uMASH1.N_DI = `N_DCO_TF;
defparam uMASH1.N_DO = `N_DCO_DITH;

sdm1_multibit uMASH1 (
	.clk(clk),
	.rstn(rstn_mash1),
	.en_sdm(en_sdm),
	.din(din),
	.dither(dither_prbs),
	.dout(dout_sdm),
	.neout()
);
*/

//---------------------
// VARIABLES, WIRES
//---------------------


reg o2_d;
reg o3_d;
reg o3_dd;
reg signed [`N_DCO_DITH:0] dout_sdm_pre; 

wire signed [`N_DCO_TF-1:0] dither_prbs;
wire o1; 
wire o2, o3;
wire [`N_DCO_TF-1:0] ne1;
wire [`N_DCO_TF-1:0] ne2;
wire signed [`N_DCO_DITH:0] do_mash1, do_mash11, do_mash111;
wire rstn_mash1;
wire rstn_mash11;
wire rstn_mash111;


//---------------------
// INSTANTIATION
//---------------------

defparam uMASH1.N_DI = `N_DCO_TF;
defparam uMASH1.N_DO = 1;
defparam uMASH11.N_DI = `N_DCO_TF;
defparam uMASH11.N_DO = 1;
defparam uMASH111.N_DI = `N_DCO_TF;
defparam uMASH111.N_DO = 1;

prbs19 uPRBS (
	.clk(clk),
	.rstn(rstn),
	.prbs_mag(prbs_mag),
	.dith_out(dither_prbs)
);


sdm1 uMASH1 (
	.clk(clk),
	.rstn(rstn_mash1),
	.en_sdm(en_sdm),
	.din(din),
	.dither(dither_prbs),
	.dout(o1),
	.neout(ne1)
);

sdm1 uMASH11 (
	.clk(clk),
	.rstn(rstn_mash11),
	.en_sdm(en_sdm),
	.din(ne1),
	.dither('0),
	.dout(o2),
	.neout(ne2)
);

sdm1 uMASH111 (
	.clk(clk),
	.rstn(rstn_mash111),
	.en_sdm(en_sdm),
	.din(ne2),
	.dither('0),
	.dout(o3),
	.neout()
);

//---------------------
// COMBINATIONAL
//---------------------

//assign dout_sdm = o1;

assign rstn_mash1 = rstn & en_sdm;
assign rstn_mash11 = rstn & en_sdm & ( (sel_sdm_mash == 2'd1) | (sel_sdm_mash == 2'd2) );
assign rstn_mash111 = rstn & en_sdm & (sel_sdm_mash == 2'd2) ;

assign do_mash1 = {{(`N_DCO_DITH){1'b0}},o1};
assign do_mash11 = {{(`N_DCO_DITH){1'b0}},o1} + {{(`N_DCO_DITH){1'b0}},o2} - {{(`N_DCO_DITH){1'b0}},o2_d};
assign do_mash111 = {{(`N_DCO_DITH){1'b0}},o1} + {{(`N_DCO_DITH){1'b0}},o2} - {{(`N_DCO_DITH){1'b0}},o2_d} + {{(`N_DCO_DITH){1'b0}},o3} - ({{(`N_DCO_TF){1'b0}},o3_d} << 1) + {{(`N_DCO_TF){1'b0}},o3_dd};

always @* begin
	case(sel_sdm_mash) // synopsys parallel_case
		2'd0: dout_sdm_pre = do_mash1;
		2'd1: dout_sdm_pre = do_mash11;
		2'd2: dout_sdm_pre = do_mash111;
		2'd3: dout_sdm_pre = do_mash1;
		default: dout_sdm_pre = do_mash1;
	endcase
end

//---------------------
// SEQ
//---------------------

always @(posedge clk) o2_d <= o2;
always @(posedge clk) o3_d <= o3;
always @(posedge clk) o3_dd <= o3_d;
//always @(posedge clk) dout_sdm <= dout_sdm_pre;
assign dout_sdm = dout_sdm_pre;


//---------------------
// OTHERS
//---------------------

// synopsys translate_off

// synopsys translate_on

endmodule

