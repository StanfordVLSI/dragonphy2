/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : pd_top.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - phase detector top.

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module pd_top import mdll_pkg::*; #(
// parameters here
) (
// I/Os here
	input clk_ref,	// a reference clock to latch the sampled information
    input clk_fb,	// feedback clock
	input osc_0,	// dco I clock (before mux)
	output bb_out_inc	// bb pd output (early) 1: +1 (inc delay) ; 0 : -1 (dec delay)
);

timeunit 1fs;
timeprecision 1fs;

//---------------------
// VARIABLES, WIRES
//---------------------


//---------------------
// INSTANTIATION
//---------------------

pd_bb uPDBB ( .clk_ref(clk_ref), .osc_0(osc_0), .early(bb_out_inc) );
//pfd uPDBB ( .clk_ref(clk_fb), .clk_fb(clk_ref), .bb_out(bb_out_inc) );


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

// synopsys translate_on

endmodule

