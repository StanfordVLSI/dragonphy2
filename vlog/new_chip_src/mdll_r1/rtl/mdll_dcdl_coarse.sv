`include "mdll_param.vh"
/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_dcdl_coarse.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
    - Differential coarse delay line
   

* Note       :
    - If N stages are on, the delay is about (2*TD)*N.

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/

`include "iotype.sv"


module mdll_dcdl_coarse import mdll_pkg::*; #(
// parameters here
    parameter N_STG = 2, // number of statges
    parameter USE_VREG = 1'b0 // delay cell using regulated supply
) (
// I/Os here
`ifdef SIMULATION
    input real VREG,
`endif
    input cinp,  // (+) clock input
    input cinn,  // (-) clock input
    input [N_STG-1:0] ctl_thm, // coarse delay control in thermometer
    output coutp, // (+) clock output
    output coutn  // (-) clock output
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------

wire coutn_1;

//---------------------
// INSTANTIATION
//---------------------

defparam uP.N_STG = N_STG;
defparam uN.N_STG = N_STG;
defparam uP.USE_VREG = USE_VREG;
defparam uN.USE_VREG = USE_VREG;

mdll_dcdl_coarse_single uP ( 
`ifdef SIMULATION
    .VREG(VREG),
`endif
	.cin(cinp),
	.ctl_thm(ctl_thm),
	.cout(coutp)
);

mdll_dcdl_coarse_single uN ( 
`ifdef SIMULATION
    .VREG(VREG),
`endif
	.cin(cinn),
	.ctl_thm(ctl_thm),
	.cout(coutn_1)
);

mdll_dcdl_coarse_coupler uXCOUPLER (
	.cinp(coutp),
	.cinn(coutn)
);

//---------------------
// COMBINATIONAL
//---------------------

`ifdef SIMULATION
    assign coutn = ~coutp;
`else
    assign coutn = coutn_1;
`endif

//---------------------
// SEQ
//---------------------


//---------------------
// OTHERS
//---------------------

// synopsys translate_off

// synopsys translate_on

endmodule

