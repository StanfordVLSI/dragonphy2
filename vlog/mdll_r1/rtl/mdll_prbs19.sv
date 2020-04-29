/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_prbs19.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - 19-bit, balanced PRBS with gain control
  - 1+x^14+x^17+x^18+x^19

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_prbs19 import mdll_pkg::*; #(
// parameters here
	parameter N = 1	// bit width of dith_out

) (
// I/Os here
	input clk,						// clock
	input rstn,						// reset, active low
	input [$clog2(N_DAC_TF)-1:0] prbs_mag, 	// prbs gain; 0: 0, 1: 1, 2: 2^1, 3: 2^2, ...
	output signed [N_DAC_TF-1:0] dith_out	// PRBS output
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

reg [18:0] lfsr_reg;
reg flip;

wire resetn;
wire [$clog2(N_DAC_TF)-1:0] gain;
wire [18:0] lfsr_nxt;
wire lfsr0;
wire lfsr_out;
wire flip_nxt;

//---------------------
// INSTANTIATION
//---------------------


//---------------------
// COMBINATIONAL
//---------------------

assign resetn = rstn & (prbs_mag!='0);
assign gain = (prbs_mag - 1) ;

assign lfsr0 = lfsr_reg[13] ^ lfsr_reg[16] ^ lfsr_reg[17] ^lfsr_reg[18];
assign lfsr_nxt = {lfsr_reg[18:0],lfsr0};
assign flip_nxt = (lfsr_reg == '1) ? ~flip : flip;
assign lfsr_out = flip ? ~lfsr_reg[0] : lfsr_reg[0];
assign dith_out = (prbs_mag==0) ? 0 : (lfsr_out ? ( 1 << gain ) : ( -1 << gain ));

//---------------------
// SEQ
//---------------------

always @(posedge clk, negedge resetn) begin
	if (!resetn) lfsr_reg <= '1;
	else lfsr_reg <= lfsr_nxt;
end

always @(posedge clk, negedge resetn) begin
	if (!resetn) flip <= 1'b0;
	else flip <= flip_nxt;
end

//---------------------
// OTHERS
//---------------------

// synopsys translate_off

// synopsys translate_on

endmodule

