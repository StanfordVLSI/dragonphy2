/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : sdm1.sv
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


module sdm1 #(
// parameters here
	parameter N_DI = 6,	// input bit width
	parameter N_DO = 1 	// output bit width
) (
// I/Os here
	input clk,	// clock
	input rstn,	// reset, active low
	input en_sdm,	// enable sdm; active high
	input [N_DI-1:0] din,		// data input
	input signed [N_DI-1:0] dither,	// dither input, does nothing
	output [1-1:0] dout,		// data output
	output [N_DI-1:0] neout		// 
);

timeunit 1ps;
timeprecision 1fs;

//---------------------
// VARIABLES, WIRES
//---------------------

localparam MODULO = (N_DI-1); // 2**MODULO = quantizer threshold

reg  [N_DI-1:0] neout_d;	// neout*z^(-1)

wire signed [N_DI+1:0] qin;		// quantizer input
wire [N_DI-1:0] dacout;		// dac output
wire [1-1:0] qout;	// quantizer output

//---------------------
// INSTANTIATION
//---------------------


//---------------------
// COMBINATIONAL
//---------------------

assign qin = {2'b0,din} + {2'b0,neout_d} + {{(N_DI+2-2){dither[1]}},dither[1:0]};	// quantizer input
assign qout = (|qin[(N_DI)-:1]) ? 1 : 0;	// quantizer
assign dacout = qout << MODULO;
assign dout = en_sdm ? qout : 1'b0;
assign neout = qin - dacout;

//---------------------
// SEQ
//---------------------

always @(posedge clk, negedge rstn) 
	if (!rstn) neout_d <= '0;
	else neout_d <= neout;


//---------------------
// OTHERS
//---------------------

// synopsys translate_off

// synopsys translate_on

endmodule

