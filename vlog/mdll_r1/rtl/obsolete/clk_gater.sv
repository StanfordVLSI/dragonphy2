/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : clk_gater.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - Clock gating cell

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module clk_gater #(
// parameters here

) (
// I/Os here
	input clk,	// input clock
	input en,	// enable 
	output gclk	// gated clock
);

timeunit 1ps;
timeprecision 1fs;

//---------------------
// VARIABLES, WIRES
//---------------------

reg en_out;

//---------------------
// INSTANTIATION
//---------------------


//---------------------
// COMBINATIONAL
//---------------------

assign gclk = clk & en_out;

//---------------------
// SEQ
//---------------------

// latch
always @(en, clk) if (!clk) en_out <= en;


//---------------------
// OTHERS
//---------------------

// synopsys translate_off

// synopsys translate_on

endmodule

