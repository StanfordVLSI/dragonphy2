/****************************************************************

Copyright (c) #YEAR# #LICENSOR#. All rights reserved.

The information and source code contained herein is the 
property of #LICENSOR#, and may not be disclosed or
reproduced in whole or in part without explicit written 
authorization from #LICENSOR#.

* Filename   : mdll_inv_x1.sv
* Author     : Byongchan Lim (bclim@alumni.stanford.edu)
* Description:
  - X1 inverter

* Note       :
  -

* Todo       :
  -

* Fixme      :
  -

* Revision   :
  - 00/00/00: Initial commit

****************************************************************/


module mdll_inv_x1 import mdll_pkg::*; #(
// parameters here
`ifdef SIMULATION
	parameter real TD = 0.0 // delay
`endif //SIMULATION
) (
// I/Os here
    input A,
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
    //INSTANCE//
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

assign #(TD*1s) ZN = ~A;

// synopsys translate_on

endmodule

