/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_dff_sampler.v
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - This is a D F/F cell dedicated for phase sampling operation

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_dff_sampler import mdll_pkg::*; #(
// parameters here
	parameter POSEDGE = 1'b1 	// 1: posedge d f/f; 0: negedge

) (
// I/Os here
	input clk,		// clock 
	input d,		// d input
	output reg q	// sampled output
);

timeunit 1fs;
timeprecision 1fs;

//---------------------
// VARIABLES, WIRES
//---------------------


//---------------------
// INSTANCE
//---------------------

`ifndef SIMULATION
    DFFHQX1LVT u1 ( .Q(q), .D(d), .CK(clk) ); // gpdk 45nm
`endif // ~SIMULATION

//---------------------
// COMBINATIONAL
//---------------------


//---------------------
// SEQ
//---------------------



//---------------------
// OTHERS
//---------------------

// synopsys translate_off

generate
	if (POSEDGE)
		always @(posedge clk) q <= d;
	else
		always @(negedge clk) q <= d;
endgenerate

// synopsys translate_on

endmodule

