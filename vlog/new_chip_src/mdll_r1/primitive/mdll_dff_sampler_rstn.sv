/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_dff_sampler_rstn.v
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - This is a D F/F cell dedicated for phase sampling operation
	with active low reset

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_dff_sampler_rstn import mdll_pkg::*; (
// I/Os here
	input clk,		// clock 
	input d,		// d input
	input rstn,		// reset (active low)
	output q		// sampled output
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------


//---------------------
// INSTANCE
//---------------------

`ifndef SIMULATION
	// synopsys dc_script_begin
	// set_dont_touch u1
	// synopsys dc_script_end
    dffc u1 ( .CP(clk), .D(d), .CDN(rstn), .Q(q) );
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

reg q_reg;
assign q = q_reg;

always @(posedge clk, negedge rstn) 
	if(!rstn) q_reg <= 1'b0;
	else q_reg  <= d;

// synopsys translate_on

endmodule

