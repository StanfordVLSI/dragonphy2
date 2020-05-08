`include "mdll_param.vh"
/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_sourcefollower.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - nMOS source follower

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_sourcefollower #(
// parameters here

) (
// I/Os here
    input G,
    output S
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

// `ifndef SIMULATION
// 	// synopsys dc_script_begin
// 	// set_dont_touch u1
// 	// synopsys dc_script_end
//    nand2 u1 ( .A1(G), .A2(S) );
//`endif // ~SIMULATION

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

