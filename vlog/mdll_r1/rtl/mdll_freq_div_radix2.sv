/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#. Contact #EMAIL# for details.

* Filename   : mdll_freq_div_radix2.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description: 
	- Frequency divider with radix-2 division ratio.
	  All the counter bits can be used for lower divisition ratio.

* Note       :

* Revision   :
  - 00/00/00 : First release

****************************************************************/


module mdll_freq_div_radix2 #(
    parameter int N = 1     // divider ratio = 2**N (N >= 1)
) (
	input cki,    			// input clock
    input [$clog2(N):0] ndiv, // 2**ndiv division ratio
	output cko,   			// divided clock
	output ckob,  			// ~cko
	output [N-1:0] cntr	// counter outputs
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

reg [N-1:0] cntr_reg;
wire [N-1:0] cntr_nxt;
wire [N-1:0] mask;

//---------------------
// COMBINATIONAL
//---------------------

assign mask = ('1 << ndiv); 
assign cntr_nxt = (cntr_reg + 1) | mask ;
assign cntr = cntr_reg;
assign cko = ~cntr[ndiv-1];
assign ckob = ~cko;

//---------------------
// SEQ
//---------------------

always @(posedge cki) cntr_reg <= cntr_nxt;

//---------------------
// OTHERS
//---------------------

// synopsys translate_off

initial #1ps cntr_reg = $urandom();
initial assert (N >= 1) else $error("[ERROR][%m]: N must be larger than zero.");

// synopsys translate_on

endmodule
