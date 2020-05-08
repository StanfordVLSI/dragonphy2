`include "mdll_param.vh"
/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_ckmuxi.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - 2-to-1 mux for clock muxing

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_ckmuxi import mdll_pkg::*; #(
// parameters here

) (
// I/Os here
    input I0,
    input I1,
    input S0,
    output ZN
);

//synopsys translate_off
timeunit 1fs;
timeprecision 1fs;
//synopsys translate_on

//---------------------
// VARIABLES, WIRES
//---------------------


//---------------------
// INSTANTIATION
//---------------------

`ifndef SIMULATION
	// synopsys dc_script_begin
	// set_dont_touch u1
	// synopsys dc_script_end
    mux2i u1 ( .I1(I0), .I0(I1), .S(S0), .ZN(ZN) );
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

assign #(TD_DCDL_MUX*1s) ZN = S0 ? ~I0 : ~I1;

// synopsys translate_on

endmodule

