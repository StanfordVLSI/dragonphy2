`include "mdll_param.vh"
/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_pd_bb.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - Bang-bang phase detector

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_pd_bb import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
	input clk_refp,	// reference clock
	input clk_refn,	// reference clock
	input osc_0,	// oscillator clock
    input sel_inj,  // select injection
	output bb_out	// 1: osc_0 leads clk_ref; 0: osc_0 lags clk_ref
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

wire early;

//---------------------
// INSTANTIATION
//---------------------

mdll_pfd uPD (.sel_inj(sel_inj), .osc_0(osc_0), .clk_ref(clk_refp), .bb_out(early));
mdll_dff_sampler uPDS ( .clk(clk_refn), .d(early), .q(bb_out) );

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

