`include "mdll_param.vh"
/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_sdm1_multibit.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  -	One stage (multi-bit) sigma-delta modulator.

* Note       :
  -

* Todo       :
  - handle overflow with dither input

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_sdm1_multibit #(
// parameters here
	parameter N_DI = 6,	// input bit width
	parameter N_DO = 1 	// output bit width
) (
// I/Os here
	input clk,	// clock
	input rstn,	// reset, active low
	input en_sdm,	// enable sdm (active high)
	input [N_DI-1:0] din,		// data input
	input signed [N_DI-1:0] dither,	// dither input
	output [N_DO-1:0] dout 		// data output
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

localparam MODULO = (N_DI-N_DO); // 2**MODULO = quantizer threshold

reg  signed [N_DI:0] qin_d;		// qin*z^(-1)
reg  [N_DI-1:0] dacout_d;	// dacout*z^(-1)
wire signed [N_DI:0] qin;		// quantizer input
wire [N_DI-1:0] dacout;		// dac output
wire [N_DO-1:0] qout;	// quantizer output

//---------------------
// INSTANTIATION
//---------------------


//---------------------
// COMBINATIONAL
//---------------------
assign qin = $signed({1'b0,din}) + qin_d + $signed({dither[N_DI-1],dither}) - $signed({1'b0,dacout_d});	// quantizer input
assign qout = (|qin[(N_DI-1)-:N_DO]) ? $unsigned(qin[(N_DI-1)-:N_DO]) : '0;	// quantizer
assign dacout = qout << MODULO;
assign dout = en_sdm ? qout : '0;

//---------------------
// SEQ
//---------------------

always @(posedge clk, negedge rstn) 
	if (!rstn) qin_d <= '0;
	else qin_d <= qin;

always @(posedge clk, negedge rstn) 
	if (!rstn) dacout_d <= '0;
	else dacout_d <= dacout;


//---------------------
// OTHERS
//---------------------

// synopsys translate_off

// synopsys translate_on

endmodule

